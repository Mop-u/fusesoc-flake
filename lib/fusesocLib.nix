{
  lib,
  formats,
  fusesoc,
  remarshal,
  runCommand,
  stdenv,
  stdenvNoCC,
  writeScriptBin,
  writeText,
}:
rec {
  readYAML =
    path:
    let
      jsonFile =
        runCommand "from-yaml-${baseNameOf path}"
          {
            nativeBuildInputs = [ remarshal ];
          }
          ''
            remarshal -k -if yaml -i "${path}" -of json -o "$out"
          '';
    in
    builtins.fromJSON (builtins.readFile jsonFile);

  parseVlnv =
    vlnv:
    let
      split = lib.splitString ":" vlnv;
    in
    if builtins.length split >= 3 then
      {
        vendor = builtins.elemAt split 0;
        library = builtins.elemAt split 1;
        name = builtins.elemAt split 2;
        version = if builtins.length split == 4 then lib.last split else "0.0.0";
      }
    else
      throw "Unable to parse vlnv ${vlnv}. Expected format: `vendor:library:name:version`.";

  parseDependency =
    cvlnv:
    let
      # https://fusesoc.readthedocs.io/en/stable/user/build_system/dependencies.html#version-constraints
      split = lib.splitString ":" cvlnv;
      match = builtins.match "(^\>\=|\<\=|[~^=><]?)(.*$)" (builtins.head split);
      parsedCondition = builtins.elemAt match 0;
      vendor = builtins.elemAt match 1;
      vlnv = lib.concatStringsSep ":" ([ vendor ] ++ (builtins.tail split));
      parsed = parseVlnv vlnv;

      condition =
        check:
        let
          inherit (parsed) version;

          versionPad = lib.versions.pad 3 version;

          cmp = builtins.compareVersions check versionPad;

          specificity =
            if builtins.length split < 4 then 0 else builtins.length (lib.splitString "." version);

          splitVer = builtins.splitVersion versionPad;

          nextMajor = lib.concatStringsSep "." [
            ((builtins.head splitVer) + 1)
            0
            0
          ];

          nextMinor = lib.concatStringsSep "." [
            (builtins.elemAt splitVer 0)
            ((builtins.elemAt splitVer 1) + 1)
            0
          ];

          caretVersion =
            lib.concatStringsSep "."
              (builtins.foldl'
                (acc: elem: {
                  hitNonZero = acc.hitNonZero || (elem != 0);
                  newVer = acc.newVer ++ [ (if (acc.hitNonZero || (elem == 0)) then 0 else elem + 1) ];
                })
                {
                  hitNonZero = false;
                  newVer = [ ];
                }
                splitVer
              ).newVer;

          conds = {
            "=" = cmp == 0;
            "<" = cmp < 0;
            ">" = cmp > 0;
            "<=" = cmp <= 0;
            ">=" = cmp >= 0;
            "^" = conds.">=" && (lib.versionOlder check caretVersion);
            "~" = conds.">=" && (lib.versionOlder check (if specificity > 1 then nextMinor else nextMajor));
            "" = conds."=";
          };
        in
        conds.${parsedCondition} || (specificity == 0);
    in
    parsed // { inherit condition; };

  resolveDeps = import ./resolveDeps.nix { inherit lib parseDependency; };

  mkCoreSet =
    coreList:
    let
      self = builtins.foldl' (
        acc: coreDrv:
        with coreDrv.parsed;
        lib.recursiveUpdateUntil
          (
            path: _: _:
            builtins.length path == 3
          )
          acc
          {
            ${vendor}.${library}.${name} =
              let
                prev = (acc.${vendor}.${library}.${name}.passthru or { });
                linkedCore = coreDrv.overrideAttrs (
                  _: prevAttrs: {
                    passthru = prevAttrs.passthru // {
                      dependencies = prevAttrs.passthru.dependencies ++ (resolveDeps coreDrv self);
                    };
                  }
                );
              in
              # The last core is the latest version and the default if no semver attribute is specified.
              linkedCore.overrideAttrs (
                _: prevAttrs: {
                  passthru =
                    (removeAttrs prev (
                      builtins.filter (n: isNull (builtins.match ''^[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+$'' n)) (
                        lib.attrNames prev
                      )
                    ))
                    // prevAttrs.passthru
                    // {
                      ${coreDrv.version} = linkedCore; # use pad 3 version for consistency
                      list = [ linkedCore ] ++ (prev.list or [ ]); # list descending
                    };
                }
              );
          }
      ) { } (builtins.sort (p: q: lib.versionOlder p.version q.version) coreList); # sort versions ascending
    in
    self;

  wrapFusesoc =
    let
      sanitize =
        regex: str:
        lib.concatStrings (
          map (x: if (builtins.match regex x) != null then x else "_") (lib.stringToCharacters str)
        );
      mkLib = name: path: ''
        [library.${sanitize "([a-zA-Z0-9])" name}]
        location = ${path}
        sync-uri = ${path}
        sync-type = local
        auto-sync = false
      '';
      mkConf =
        sources:
        writeText "fusesoc.conf" (
          lib.concatLines
            (builtins.foldl'
              (acc: elem: {
                count = acc.count + 1;
                libs = acc.libs ++ [
                  (mkLib "${baseNameOf "${elem}"}-${toString acc.count}" elem)
                ];
              })
              {
                count = 0;
                libs = [ ];
              }
              sources
            ).libs
        );
    in
    sources:
    writeScriptBin "fusesoc" ''
      exec ${fusesoc}/bin/fusesoc --config ${mkConf sources} $@
    '';

  runCore = import ./runCore.nix {
    inherit
      lib
      stdenv
      parseVlnv
      wrapFusesoc
      ;
  };

  mkRunners =
    {
      core,
      dependencies,
      nativeBuildInputs ? [ ],
    }:
    lib.mapAttrs (
      target: v:
      runCore (_: {
        inherit core target dependencies;
        nativeBuildInputs =
          if (builtins.isList nativeBuildInputs) then
            nativeBuildInputs
          else
            nativeBuildInputs."${target}" or nativeBuildInputs.default or [ ];
      })
    ) core.targets;

  importCore = import ./importCore.nix {
    inherit
      lib
      formats
      readYAML
      stdenvNoCC
      mkRunners
      parseVlnv
      ;
  };

  importCores =
    root:
    map
      (
        coreFile:
        importCore {
          coreRoot = dirOf coreFile;
          coreName = baseNameOf coreFile;
        }
      )
      (
        lib.filter (path: (lib.pathIsRegularFile path) && (lib.hasSuffix ".core" (baseNameOf path))) (
          lib.filesystem.listFilesRecursive root
        )
      );

  mkCore =
    core: coreRoot:
    importCore {
      inherit core coreRoot;
      coreName = "${(parseVlnv core.name).name}.core";
    };
}
