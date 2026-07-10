{
  fetchProvider,
  formats,
  lib,
  mkRunners,
  parseVlnv,
  readYAML,
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
      core ? readYAML "${coreRoot}/${coreName}",
      providerHash ? "",
      tools ? [ ],
      dependencies ? [ ],
      passthru ? { },
    }:
    let
      parsed = parseVlnv finalAttrs.passthru.core.name;
      coreFileset = builtins.concatLists (
        lib.mapAttrsToList (
          n: v:
          map (
            entry:
            stripCond (if builtins.isAttrs entry then (builtins.head (builtins.attrNames entry)) else entry)
          ) (v.files or [ ])
        ) finalAttrs.passthru.core.filesets
      );
      useProvider =
        let
          inherit (finalAttrs.passthru) core;
        in
        (builtins.hasAttr "provider" core) && (core.provider.name != "local");
    in
    {
      pname =
        with parsed;
        lib.concatStringsSep "_" [
          vendor
          library
          name
        ];
      version = lib.versions.pad 3 parsed.version;
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
        inherit
          dependencies
          parsed
          tools
          core
          ;
        run = mkRunners {
          inherit (finalAttrs.passthru) core tools;
          dependencies = finalAttrs.passthru.dependencies ++ [ "${finalAttrs.finalPackage}" ];
        };
      };
      phases = [
        "unpackPhase"
        "installPhase"
      ];
      src = if useProvider then fetchProvider finalAttrs.passthru.core providerHash else coreRoot;
      installPhase =
        let
          patches = core.provider.patches or [ ];
          patchedCore =
            let
              inherit (finalAttrs.passthru) core;
            in
            if useProvider then
              core
              // {
                provider = {
                  name = "local";
                  inherit patches;
                };
              }
            else
              core;
          copyFromPwd =
            dir:
            lib.concatStringsSep "\n" (
              map (file: ''
                mkdir -p $out/${dirOf file}
                cp ${file} $out/${file}
              '') dir
            );
        in
        ''
          mkdir -p $out/
          ${copyFromPwd coreFileset}
          cp ${(formats.yaml { }).generate coreName patchedCore} $out/${coreName}
          ${if useProvider then "cd ${coreRoot}\n${copyFromPwd patches}" else ""}
        '';
    };
}
