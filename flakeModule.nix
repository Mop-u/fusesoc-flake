{ nixpkgs-lib, flake-parts-lib, ... }:
let
    inherit (flake-parts-lib) mkPerSystemOption;
    inherit (nixpkgs-lib) lib;
in
{
    config,
    self,
    inputs,
    ...
}:
{
    options.perSystem = mkPerSystemOption (
        { config, pkgs, ... }:
        let
            cfg = config.fusesoc-project;
        in
        {
            # TODO: multi-project with .<name>. pattern mapping to devShell.<name>
            options.fusesoc-project =
                let
                    inherit (lib) types;
                in
                {
                    withVerilator = lib.mkEnableOption "Include verilator";
                    verilatorPkg = lib.mkOption {
                        type = types.package;
                        default = pkgs.verilator;
                    };
                    withCcache = lib.mkEnableOption "Use ccache with verilator";
                    ccachePkg = lib.mkOption {
                        type = types.package;
                        default = pkgs.ccache;
                    };
                    sources = lib.mkOption {
                        type = types.attrsOf (types.either types.path types.str);
                        default = { };
                    };
                    extraPackages = lib.mkOption {
                        type = types.listOf types.package;
                        default = [ ];
                    };
                };
            config =
                let
                    mkFusesocLib = name: path: ''
                        [library.${name}]
                        location = ${path}
                        sync-uri = ${path}
                        sync-type = local
                        auto-sync = false
                    '';
                    mkFusesocConf = sources: builtins.concatStringsSep "\n" (lib.mapAttrsToList (mkFusesocLib) sources);
                in
                {
                    devShells.default =
                        let
                            fusesocConf = pkgs.writeTextFile {
                                name = "fusesoc.conf";
                                text = mkFusesocConf cfg.sources;
                            };
                            fusesocWrapped = pkgs.writeShellScriptBin "fusesoc" ''
                                exec ${pkgs.fusesoc}/bin/fusesoc --config ${fusesocConf} $@
                            '';
                        in
                        pkgs.mkShell {
                            packages = lib.concatLists [
                                [ fusesocWrapped ]
                                (lib.optionals cfg.withVerilator [
                                    cfg.verilatorPkg
                                    pkgs.zlib.dev # needed for generating fst traces
                                ])
                                (lib.optional cfg.withCcache cfg.ccachePkg)
                                cfg.extraPackages
                            ];
                            shellHook = lib.optionalString cfg.withCcache "export OBJCACHE=ccache";
                        };
                };
        }
    );
}
