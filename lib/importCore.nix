{
  fetchProvider,
  formats,
  lib,
  mkRunners,
  parseVlnv,
  readYAML,
  resolveDeps,
  stdenvNoCC,
  stripCond,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;
  excludeDrvArgNames = [ ];
  extendDrvArgs =
    finalAttrs:
    {
      coreRoot,
      coreName,
      core ? (readYAML "${coreRoot}/${coreName}"),
      patches ? [ ],
      providerHash ? "",
      preservePaths ? [ ],
      tools ? [ ],
      dependencies ? [ ],
      passthru ? { },
    }:
    let
      parsed = parseVlnv finalAttrs.passthru.core.name;
      coreFileset =
        (builtins.concatLists (
          lib.mapAttrsToList (
            n: v:
            map (
              entry:
              stripCond (if builtins.isAttrs entry then (builtins.head (builtins.attrNames entry)) else entry)
            ) (v.files or [ ])
          ) (finalAttrs.passthru.core.filesets or { })
        ))
        ++ finalAttrs.passthru.preservePaths;
      useProvider =
        let
          inherit (finalAttrs.passthru) core;
        in
        (builtins.hasAttr "provider" core) && (core.provider.name != "local");
    in
    {
      pname =
        let
          opt = str: lib.optional (str != "") str;
          mapOpts = strs: builtins.concatLists (map opt strs);
        in
        with parsed;
        lib.concatStringsSep "_" (mapOpts [
          vendor
          library
          name
        ]);
      inherit (finalAttrs.passthru.parsed) version;
      passthru = passthru // {
        withTools =
          toolList:
          finalAttrs.finalPackage.overrideAttrs (
            final: prev: {
              passthru = prev.passthru // {
                tools = prev.passthru.tools ++ toolList;
              };
            }
          );
        linkWith =
          coreSet:
          finalAttrs.finalPackage.overrideAttrs (
            final: prev: {
              passthru = prev.passthru // {
                dependencies = resolveDeps finalAttrs.finalPackage coreSet;
              };
            }
          );
        list = builtins.sort (p: q: lib.versionOlder p.version q.version) (
          lib.mapAttrsToList (_: v: v) (
            lib.filterAttrs (n: _: !(isNull (builtins.match "^[[:digit:]]+.*$" n))) (
              { ${finalAttrs.passthru.parsed.version} = finalAttrs.finalPackage; } // finalAttrs.passthru
            )
          )
        );
        inherit
          dependencies
          parsed
          preservePaths
          tools
          core
          ;
        run = mkRunners {
          inherit (finalAttrs.passthru) core tools;
          dependencies = finalAttrs.passthru.dependencies ++ [ finalAttrs.finalPackage ];
        };
      };
      phases = [
        "unpackPhase"
        "patchPhase"
        "installPhase"
      ];
      patches =
        patches ++ (map (patch: "${coreRoot}/${patch}") (finalAttrs.passthru.core.provider.patches or [ ]));
      src = if useProvider then fetchProvider finalAttrs.passthru.core providerHash else coreRoot;
      installPhase =
        let
          patchedCore = removeAttrs finalAttrs.passthru.core [ "provider" ];
        in
        ''
          mkdir -p $out/
          ${lib.concatStringsSep "\n" (
            map (file: ''
              mkdir -p $out/${dirOf file}
              cp ${file} $out/${file}
            '') coreFileset
          )}
          cp ${(formats.yaml { }).generate coreName patchedCore} $out/${coreName}
        '';
    };
}
