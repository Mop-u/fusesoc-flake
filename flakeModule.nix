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
                    withCcache = lib.mkEnableOption "Use ccache with verilator";
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
                    # See: https://flake.parts/options/devshell.html
                    devshells.default =
                        let
                            fusesocConf = pkgs.writeTextFile {
                                name = "fusesoc.conf";
                                text = mkFusesocConf cfg.sources;
                            };
                            fusesocWrapped = pkgs.writeShellScriptBin "fusesoc" ''
                                exec ${pkgs.fusesoc}/bin/fusesoc --config ${fusesocConf} $@
                            '';
                        in
                        {
                            packages = lib.concatLists [
                                [ fusesocWrapped ]
                                (lib.optionals cfg.withVerilator [
                                    pkgs.verilator
                                    pkgs.zlib.dev
                                ])
                                (lib.optional cfg.withCcache pkgs.ccache)
                                cfg.extraPackages
                            ];
                            env = lib.optional cfg.withCcache {
                                name = "OBJCACHE";
                                value = "ccache";
                            };
                        };
                };
        }
    );
}
