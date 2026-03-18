{
    lib,
    callPackage,
    stdenv,
    writeText,
    writeScriptBin,
    fusesoc,
    fusesocLib,
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
        let
            sanitize =
                regex: str:
                lib.concatStrings (
                    builtins.map (x: if (builtins.match regex x) != null then x else "_") (lib.stringToCharacters str)
                );
            mkLib = name: path: ''
                [library.${sanitize "([a-zA-Z0-9])" name}]
                location = ${path}
                sync-uri = ${path}
                sync-type = local
                auto-sync = false
            '';
            mkFusesocConf =
                sources:
                writeText "fusesoc.conf" (
                    lib.concatLines
                        (builtins.foldl'
                            (acc: elem: {
                                count = acc.count + 1;
                                libs = acc.libs ++ [
                                    (mkLib "${builtins.baseNameOf "${elem}"}-${builtins.toString acc.count}" elem)
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
        finalAttrs:
        {
            core,
            target ? "default",
            extraArgs ? "",
            dependencies,
            nativeBuildInputs ? [ ],
            passthru ? { },
        }@args:
        let
            parsed = fusesocLib.parseVlnv finalAttrs.passthru.core.name;
            fusesocWrapped =
                let
                    conf = mkFusesocConf finalAttrs.passthru.dependencies;
                in
                writeScriptBin "fusesoc" ''
                    exec ${fusesoc}/bin/fusesoc --config ${conf} $@
                '';
        in
        {
            pname =
                with parsed;
                lib.concatStringsSep "_" [
                    vendor
                    library
                    "${name}-${finalAttrs.passthru.target}"
                ];
            inherit (parsed) version;
            passthru = passthru // {
                inherit
                    dependencies
                    core
                    target
                    extraArgs
                    parsed
                    ;
            };
            nativeBuildInputs = nativeBuildInputs ++ [ fusesocWrapped ];
            phases = [
                "buildPhase"
                "installPhase"
            ];
            buildPhase =
                let
                    buildCmd = lib.concatStringsSep " " [
                        "HOME=$TEMP"
                        "${fusesocWrapped}/bin/fusesoc"
                        "run --target ${finalAttrs.passthru.target}"
                        finalAttrs.passthru.extraArgs
                        finalAttrs.passthru.core.name
                    ];
                in
                buildCmd;
            installPhase =
                let
                    vlnvDir =
                        with parsed;
                        lib.concatStringsSep "_" [
                            vendor
                            library
                            name
                            version
                        ];
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
