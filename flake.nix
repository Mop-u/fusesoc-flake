{
    description = "Helper for a declarative fusesoc environment";

    inputs = {
        nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    };

    outputs =
        inputs@{ self, nixpkgs, ... }:
        let
            inherit (nixpkgs) lib;
            forEachSystem = systems: f: builtins.foldl' (lib.recursiveUpdate) { } (builtins.map (f) systems);
        in
        (forEachSystem [ "x86_64-linux" ] (
            system:
            let
                pkgs = nixpkgs.legacyPackages.${system};
            in
            {
                packages.${system} = rec {
                    yosys-slang = pkgs.callPackage ./pkgs/yosys-slang.nix { };

                    edalize = pkgs.callPackage ./pkgs/edalize.nix { };

                    fusesoc = pkgs.callPackage ./pkgs/fusesoc.nix { inherit edalize; };

                    fusesocLib = pkgs.callPackage ./lib/fusesocLib.nix { };

                    runFusesocCore = pkgs.callPackage ./lib/runFusesocCore.nix { inherit fusesoc fusesocLib; };

                    mkFusesocCore = pkgs.callPackage ./lib/mkFusesocCore.nix {
                        inherit fusesocLib runFusesocCore;
                    };
                };
            }
        ))
        // { };
}
