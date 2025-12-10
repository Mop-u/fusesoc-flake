{
    description = "Helper for a declarative fusesoc environment";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-25.11";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs =
        inputs@{ flake-parts, ... }:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = [
                "x86_64-linux"
            ];
            perSystem =
                {
                    config,
                    self',
                    inputs',
                    pkgs,
                    system,
                    ...
                }:
                {
                    packages = {
                        inherit (pkgs.callPackage ./lib.nix { })
                            mkFusesocLib
                            mkFusesocConf
                            mkFusesocShell
                            ;
                    };
                };
        };
}
