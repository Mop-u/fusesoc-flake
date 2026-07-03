{
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
  excludeDrvArgNames = [
    "coreRoot"
    "coreName"
    "dependencies"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      coreRoot,
      coreName,
      core ? readYAML "${coreRoot}/${coreName}",
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
      src = coreRoot;
      installPhase = lib.concatStringsSep "\n" (
        (map (file: ''
          mkdir -p $out/${dirOf file}
          cp ${file} $out/${file}
        '') coreFileset)
        ++ [
          ''
            mkdir -p $out/
            cp ${(formats.yaml { }).generate coreName finalAttrs.passthru.core} $out/${coreName}
          ''
        ]
      );
    };
}
