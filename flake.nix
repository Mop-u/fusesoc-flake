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
          coreList = pkgs.callPackage ./cores/fusesoc-cores.nix { fusesocLib = fusesoc.lib; };
        in
        {
          # Flakes that export cores should extend/override legacyPackages.${system}.fusesocCores
          legacyPackages.fusesocCores = fusesoc.lib.cores;

          packages = {
            default = fusesoc.lib.dumpCores fusesoc.lib.cores;

            inherit (moppkgs.packages.${system}) edalize;

            yosys-slang = pkgs.callPackage ./pkgs/yosys-slang.nix { };

            # fusesoc lib is accessible thru `packages.${system}.fusesoc.lib`
            fusesoc =
              let
                pkg = pkgs.fusesoc.override {
                  python3Packages = pkgs.python3Packages // {
                    inherit (self.packages.${system}) edalize;
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
            packages = [ (fusesoc.lib.wrapFusesoc fusesoc.lib.cores) ];
          };
          checks =
            let
              noVendor = fusesoc.lib.cores.""."";
              inherit (fusesoc.lib.cores) bespoke-silicon-group;
            in
            {
              inherit (noVendor)
                SD-card-controller
                ac97
                altera_virtual_jtag
                verilog-arbiter
                cdc_utils
                ethmac
                fplib
                jtag_tap
                ompic
                ;
              bsg-basejump_stl-hard = bespoke-silicon-group.basejump_stl.hard;
              bsg-basejump_stl-nonsynth = bespoke-silicon-group.basejump_stl.nonsynth;
              bsg-basejump_stl-rtl = bespoke-silicon-group.basejump_stl.rtl;
              bsg-external-hardfloat = fusesoc.lib.cores.bsg-external.hardfloat."0.0.1"; # original corename is mangled like this
              jtag_vpi_0-r3 = noVendor.jtag_vpi."0-r3";
              jtag_vpi_0-r4 = noVendor.jtag_vpi."0-r4";
              jtag_vpi_0-r5 = noVendor.jtag_vpi."0-r5";
              "mor1kx_5.0-r2" = noVendor.mor1kx."5.0-r2";
              "mor1kx_5.1" = noVendor.mor1kx."5.1";
              "mor1kx_5.2" = noVendor.mor1kx."5.2";
              # Runnable testbenches
              # SD-card-controller-lint = noVendor.SD-card-controller.run.lint.withTools [ pkgs.verilator ];
              # ac97-sim = noVendor.ac97.run.sim.withTools [ pkgs.iverilog ];
              ethmac-lint = noVendor.ethmac.run.lint.withTools [ pkgs.verilator ];
              adv_debug_sys = noVendor.adv_debug_sys.run.jsp_tb.withTools [ pkgs.iverilog ];
              inherit ((noVendor.fifo.withTools [ pkgs.iverilog ]).run)
                fifo_fwft_tb
                dual_clock_fifo_tb
                fifo_tb
                ;
              "i2c_1.15-sim" = noVendor.i2c."1.15".run.sim.withTools [ pkgs.iverilog ];
              "i2c_1.14-r1-sim" = noVendor.i2c."1.14-r1".run.sim.withTools [ pkgs.iverilog ];
            };
        }
      );
}
