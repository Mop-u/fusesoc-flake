{
    description = "Helper for a declarative fusesoc environment";

    # See: https://github.com/VTimofeenko/writing-flake-modules/blob/master/example-1-configurable-inputs-bumper/provider/flake.nix
    inputs = {
        nixpkgs-lib.url = "github:Nixos/nixpkgs/nixos-25.11?dir=lib";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs =
        inputs@{ flake-parts, ... }:
        flake-parts.lib.mkFlake { inherit inputs; } (
            { flake-parts-lib, ... }:
            {
                flake.flakeModule = flake-parts-lib.importApply ./flakeModule.nix {
                    inherit flake-parts-lib;
                    inherit (inputs) nixpkgs-lib;
                };
            }
        );
}
