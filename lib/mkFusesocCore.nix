{
    lib,
    callPackage,
    symlinkJoin,
    runCommand,
    writeText,
    formats,
    fusesoc,
    fusesocLib,
    runFusesocCore,
}:
lib.extendMkDerivation {
    constructDrv = symlinkJoin;
    excludeDrvArgNames = [
        "core"
        "corePath"
        "coreName"
        "buildInputs"
        "dependencies"
        "rtl"
    ];
    excludeFunctionArgNames = [ ];
    extendDrvArgs =
        let
            yamlFormat = formats.yaml { };
        in
        finalAttrs:
        {
            core,
            corePath ? "",
            coreName ? (fusesocLib.parseVlnv core.name).name,
            buildInputs ? [ ],
            dependencies ? [ ],
            rtl ? [ ],
            passthru ? { },
            ...
        }@args:
        let
            parsed = fusesocLib.parseVlnv finalAttrs.passthru.core.name;
            finalCore =
                let
                    coreFile = yamlFormat.generate "${coreName}.core" finalAttrs.passthru.core;
                in
                runCommand "writeCore" { } ''
                    mkdir -p $out/${finalAttrs.passthru.corePath}
                    cp ${coreFile} $out/${finalAttrs.passthru.corePath}/${finalAttrs.passthru.coreName}.core
                '';
        in
        {
            pname =
                with parsed;
                lib.concatStringsSep "_" [
                    vendor
                    library
                    name
                ];
            inherit (parsed) version;
            passthru = passthru // {
                inherit
                    core
                    corePath
                    coreName
                    buildInputs
                    dependencies
                    parsed
                    rtl
                    ;
                run = lib.mapAttrs (
                    n: v:
                    runFusesocCore (
                        _:
                        let
                            inherit (finalAttrs.passthru) buildInputs dependencies;
                        in
                        {
                            vlnv = finalAttrs.passthru.core.name;
                            target = n;
                            dependencies = dependencies ++ [ "${finalAttrs.finalPackage}" ];
                            nativeBuildInputs =
                                if builtins.isList buildInputs then
                                    buildInputs
                                else
                                    buildInputs."${n}" or buildInputs.default or [ ];
                        }
                    )
                ) finalAttrs.passthru.core.targets;
            };
            paths =
                let
                    inherit (finalAttrs.passthru) rtl;
                in
                (if builtins.isList rtl then rtl else [ rtl ]) ++ [ finalCore ];
        };
}
