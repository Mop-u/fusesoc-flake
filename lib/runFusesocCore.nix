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
        "vlnv"
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
            vlnv,
            target ? "default",
            extraArgs ? "",
            dependencies,
            nativeBuildInputs ? [ ],
            passthru ? { },
        }@args:
        let
            parsed = fusesocLib.parseVlnv finalAttrs.passthru.vlnv;
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
                    vlnv
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
                        finalAttrs.passthru.vlnv
                    ];
                in
                buildCmd;
            installPhase =
                let
                    vlnvDir = sanitize "([a-zA-Z0-9\.])" finalAttrs.passthru.vlnv;
                in
                ''
                    mkdir -p $out
                    cp -r ./build/${vlnvDir}/${finalAttrs.passthru.target}/* $out/
                '';
        };
}
