{
  dumpCores,
  fusesoc,
  lib,
  parseVlnv,
  stdenv,
  writableTmpDirAsHomeHook,
}:
lib.extendMkDerivation {
  constructDrv = stdenv.mkDerivation;
  excludeDrvArgNames = [
    "core"
    "target"
    "extraArgs"
    "dependencies"
    "version"
    "pname"
  ];
  extendDrvArgs =
    finalAttrs:
    {
      core,
      target ? "default",
      extraArgs ? "",
      dependencies,
      tools ? [ ],
      passthru ? { },
      ...
    }:
    let
      opt = str: lib.optional (str != "") str;
      mapOpts = strs: builtins.concatLists (map opt strs);
      parsed = parseVlnv finalAttrs.passthru.core.name;
    in
    {
      pname =
        with parsed;
        lib.concatStringsSep "_" (mapOpts [
          vendor
          library
          "${name}-${finalAttrs.passthru.target}"
        ]);
      inherit (parsed) version;
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
          core
          dependencies
          extraArgs
          parsed
          target
          tools
          ;
      };
      nativeBuildInputs = finalAttrs.passthru.tools ++ [
        writableTmpDirAsHomeHook
        fusesoc
      ];
      src = dumpCores finalAttrs.passthru.dependencies;
      buildPhase = lib.concatStringsSep " " [
        "fusesoc --cores-root $src"
        "run --target ${finalAttrs.passthru.target}"
        finalAttrs.passthru.extraArgs
        finalAttrs.passthru.core.name
      ];
      installPhase =
        let
          vlnvDir =
            with parsed;
            lib.concatStringsSep "_" (mapOpts [
              vendor
              library
              name
              version
            ]);
          toolName = lib.flatten [
            finalAttrs.passthru.core.targets.${finalAttrs.passthru.target}.default_tool or [ ]
          ];
          buildFolder = lib.concatStringsSep "-" ([ finalAttrs.passthru.target ] ++ toolName);
        in
        ''
          mkdir -p $out
          cp -r ./build/${vlnvDir}/${buildFolder}/* $out/
        '';
    };
}
