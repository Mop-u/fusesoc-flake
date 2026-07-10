{
  lib,
  fetchFromGitHub,
  fetchgit,
  fetchsvn,
  fetchurl,
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
      jsonFile = runCommand "from-yaml-${baseNameOf path}" {
        nativeBuildInputs = [ remarshal ];
      } ''remarshal -k -if yaml -i "${path}" -of json -o "$out"'';
    in
    builtins.fromJSON (builtins.readFile jsonFile);

  parseVlnv =
    vlnv:
    let
      split = lib.splitString ":" vlnv;
      vlnvParts = builtins.length split;
      noVersion = "0";
    in
    if vlnvParts == 1 then
      {
        vendor = "";
        library = "";
      }
      // (
        let
          legacySplit = lib.splitString "-" vlnv;
        in
        if builtins.length legacySplit == 1 then
          {
            name = vlnv;
            version = noVersion;
          }
        else
          {
            name = builtins.head legacySplit;
            version = lib.concatStringsSep "-" (builtins.tail legacySplit);
          }
      )

    else if vlnvParts >= 3 then
      {
        vendor = builtins.elemAt split 0;
        library = builtins.elemAt split 1;
        name = builtins.elemAt split 2;
        version = if builtins.length split == 4 then lib.last split else noVersion;
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

          cmp = builtins.compareVersions check version;

          specificity =
            if builtins.length split < 4 then 0 else builtins.length (builtins.splitVersion version);

          caretVersion =
            lib.concatStringsSep "."
              (builtins.foldl'
                (acc: elem: {
                  hitNonZero = acc.hitNonZero || (elem != "0");
                  newVer = (if acc.hitNonZero then acc.newVer else acc.newVer ++ [ elem ]);
                })
                {
                  hitNonZero = false;
                  newVer = [ ];
                }
                (builtins.splitVersion version)
              ).newVer;

          conds = {
            "=" = cmp == 0;
            "<" = cmp < 0;
            ">" = cmp > 0;
            "<=" = cmp <= 0;
            ">=" = cmp >= 0;
            "^" =
              conds.">="
              && (lib.versions.compareVersions (lib.zipListsWith (a: _: a) check caretVersion) caretVersion <= 0);
            "~" =
              let
                f = if specificity > 1 then lib.versions.majorMinor else lib.versions.major;
              in
              conds.">=" && ((lib.versions.compareVersions (f check) (f version)) <= 0);
            "" = conds."=";
          };
        in
        conds.${parsedCondition} || (specificity == 0);
    in
    parsed // { inherit condition; };

  stripCond =
    cond:
    let
      # extract the argument from conditional syntax
      # e.g.
      # "tool_quartus ? (data/fifo.sdc)" -> ["data/fifo.sdc"]
      # "rtl/fifo.v" -> Null
      stripped = builtins.match ''^!?[_a-zA-Z]*[[:space:]]*\??[[:space:]]*\((.*)\)$'' cond;
    in
    if (isNull stripped) then cond else builtins.head stripped;

  resolveDeps = import ./resolveDeps.nix { inherit lib parseDependency; };

  fetchProvider =
    core: hash:
    let
      inherit (core) provider;
    in
    {
      local = throw "local providers should not be fetched! use coreRoot.";
      github = fetchFromGitHub {
        inherit (core) name;
        owner = provider.user;
        repo = provider.repo;
        rev = provider.version;
        inherit hash;
      };
      git = fetchgit {
        inherit (core) name;
        url = provider.repo;
        rev = provider.version;
        inherit hash;
      };
      svn = fetchsvn {
        inherit (core) name;
        inherit (provider) url;
        rev = provider.revision;
        inherit hash;
      };
      url =
        let
          fetch = fetchurl {
            inherit (core) name;
            inherit (provider) url;
            inherit hash;
          };
        in
        {
          tar = fetch;
          zip = fetch;
          simple =
            let
              fileName = lib.last (lib.splitString "/" provider.url);
            in
            runCommand "${core.name}-source" { } ''
              mkdir -p $out
              ln -s ${fetch} $out/${fileName}
            '';
        }
        .${provider.filetype}
          or (throw "Unknown url provider filetype ${provider.filetype} in ${core.name}");
      opencores = throw "opencores provider not yet implemented";
    }
    .${provider.name} or (throw "Unknown provider name: ${provider.name}");

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
                      ${coreDrv.version} = linkedCore;
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
      tools ? [ ],
    }:
    lib.mapAttrs (
      target: v:
      runCore (_: {
        inherit core target dependencies;
        tools = if (builtins.isList tools) then tools else tools."${target}" or tools.default or [ ];
      })
    ) core.targets;

  importCore = import ./importCore.nix {
    inherit
      fetchProvider
      formats
      lib
      mkRunners
      parseVlnv
      readYAML
      stdenvNoCC
      stripCond
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
