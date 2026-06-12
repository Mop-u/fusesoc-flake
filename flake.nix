{
  description = "Helper for a declarative fusesoc environment";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    moppkgs = {
      url = "github:Mop-u/moppkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      moppkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem = systems: f: builtins.foldl' (lib.recursiveUpdate) { } (map f systems);
    in
    (forEachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages.${system} = rec {
          inherit (moppkgs.packages.${system}) edalize;

          yosys-slang = pkgs.callPackage ./pkgs/yosys-slang.nix { };

          fusesoc = pkgs.callPackage ./pkgs/fusesoc.nix { inherit edalize; };

          fusesocLib = pkgs.callPackage ./lib/fusesocLib.nix { inherit fusesoc; };
        };
      }
    ))
    // { };
}
