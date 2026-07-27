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
    {
      self,
      nixpkgs,
      moppkgs,
      ...
    }:
    let
      inherit (nixpkgs) lib;
      forEachSystem =
        systems: f:
        builtins.foldl' (lib.recursiveUpdate) { } (
          map (system: builtins.mapAttrs (_: v: { ${system} = v; }) (f system)) systems
        );
    in
    forEachSystem
      [
        "aarch64-darwin"
        "aarch64-linux"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ]
      (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (self.packages.${system}) fusesoc;
          coreList =
            (pkgs.callPackage ./cores/fusesoc-cores.nix { fusesocLib = fusesoc.lib; })
            ++ (fusesoc.lib.importCores (
              pkgs.fetchFromGitHub {
                name = "openrisc-cores-github";
                owner = "openrisc";
                repo = "openrisc-cores";
                rev = "b87ad6a7799c996814200c51a7f58d27ab93818f";
                hash = "sha256-R7KWnrerYV4ZA+NE6z4yWS9fgfKyUxP/LoBB0z0EOk8=";
              }
            ))
            ++ [
              (fusesoc.lib.importCore {
                coreName = "elf-loader.core";
                coreRoot = pkgs.fetchFromGitHub {
                  name = "elf-loader-github";
                  owner = "fusesoc";
                  repo = "elf-loader";
                  rev = "7a8f63ae203cb8eef0cc0b96c52a1056ae2a423e";
                  hash = "sha256-ABzox3UanVqTJSuXuT4IEyxYQuvAxCvpzJiuaXZu8Co=";
                };
              })
            ];
        in
        {
          # Flakes that export cores should extend/override legacyPackages.${system}.fusesocCores
          legacyPackages.fusesocCores = fusesoc.lib.cores;

          packages = {
            default = fusesoc.lib.dumpCores fusesoc.lib.cores;

            inherit (moppkgs.packages.${system}) edalize;

            # fusesoc lib is accessible thru `packages.${system}.fusesoc.lib`
            fusesoc =
              let
                pkg = pkgs.fusesoc.override {
                  python3Packages = pkgs.python3Packages // {
                    inherit (moppkgs.packages.${system}) edalize;
                  };
                };
              in
              pkg.overrideAttrs (
                _: prev: {
                  passthru = prev.passthru // {
                    lib = (pkgs.callPackage ./lib/fusesocLib.nix { fusesoc = pkg; }) // {
                      cores = fusesoc.lib.mkCoreSet coreList; # Bundle fusesoc "stdlib" under fusesoc.lib.cores for convenience
                    };
                  };
                }
              );
          };
          devShells.default = pkgs.mkShell {
            packages = [
              fusesoc
              pkgs.iverilog
              pkgs.verilator
              pkgs.icestorm
              pkgs.yosys
              pkgs.nextpnr
            ];
            shellHook = ''
              export FUSESOC_CONFIG=${fusesoc.lib.mkConf fusesoc.lib.cores}
            '';
          };
          checks =
            let
              noVendor = fusesoc.lib.cores.""."";
              inherit (fusesoc.lib) cores;
            in
            {
              inherit (self.packages.${system}) default;

              # Runnable flows
              ethmac-lint = noVendor.ethmac.run.lint.withTools [ pkgs.verilator ];
              adv_debug_sys-jsp_tb = noVendor.adv_debug_sys.run.jsp_tb.withTools [ pkgs.iverilog ];
              inherit ((noVendor.fifo.withTools [ pkgs.iverilog ]).run)
                fifo_fwft_tb
                dual_clock_fifo_tb
                fifo_tb
                ;
              "i2c_1.15-sim" = noVendor.i2c."1.15".run.sim.withTools [ pkgs.iverilog ];
              "i2c_1.14-r1-sim" = noVendor.i2c."1.14-r1".run.sim.withTools [ pkgs.iverilog ];
              servant-tinyfpga_bx = noVendor.servant.run.tinyfpga_bx.withTools [
                pkgs.icestorm
                pkgs.yosys
                pkgs.nextpnr
              ];
              blinky-tinyfpga_bx = cores.fusesoc.utils.blinky.run.tinyfpga_bx.withTools [
                pkgs.icestorm
                pkgs.yosys
                pkgs.nextpnr
              ];
            };
        }
      );
}
