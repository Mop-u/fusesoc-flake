{
    fusesoc,
    verilator,
    ccache,
    zlib,
    mkShell,
    writeTextFile,
    writeShellScriptBin,
    lib,
    ...
}:
rec {
    mkFusesocLib = name: path: ''
        [library.${name}]
        location = ${path}
        sync-uri = ${path}
        sync-type = local
        auto-sync = false
    '';

    mkFusesocConf = sources: builtins.concatStringsSep "\n" (lib.mapAttrsToList (mkFusesocLib) sources);

    mkFusesocShell =
        {
            fusesoc ? fusesoc,
            sources ? {
                _localCores = ".";
            },
            withVerilator ? false,
            verilator ? verilator,
            withCcache ? false,
            ccache ? ccache,
            extraPackages ? [ ],
        }:
        let
            fusesocConf = writeTextFile "fusesoc.conf" (mkFusesocConf sources);
            fusesocWrapped = writeShellScriptBin "fusesoc" ''
                exec ${fusesoc}/bin/fusesoc --config ${fusesocConf} \$@
            '';
        in
        mkShell {
            packages = lib.concatLists [
                [ fusesocWrapped ]
                (lib.optionals withVerilator [
                    verilator
                    zlib.dev
                ])
                (lib.optional withCcache ccache)
                extraPackages
            ];
            shellHook = ''
                ${lib.optionalString withCcache "export OBJCACHE=ccache"}
            '';
        };
}
