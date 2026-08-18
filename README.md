
This project has moved to [my tangled.org repo](https://tangled.org/did:plc:omuys45no7bhskevzink4e2t) as I'm getting a little tired of github outages

# Fusesoc Flake
This is a nix library intended to help with packaging fusesoc cores (and running them) in nix derivations, as well as creating reproducible dev shells.

### Add fusesoc-flake to your flake.nix
```nix
inputs.fusesoc-flake.url = "github:Mop-u/fusesoc-flake";  
``` 
### Access the fusesocTools library
```nix
inherit (inputs.fusesoc-flake.legacyPackages.x86_64-linux) fusesocTools;
```

## Import fusesoc cores

Fusesoc cores are imported as a derivation where their root holds the `.core` file and *only* the files specified by the `.core`'s filesets.

Any other files are not included in the derivation unless manually specified by the `preservePaths` escape hatch (e.g. for script and generator files).

If the core has patches, the patches are applied during the nix derivation's `patchPhase` and dropped from the output core.

If the core fetches from a remote, we do the fetch and patch out the `provider` section from the output core.

### Import an individual local core
```nix
myCore = fusesocTools.importCore {
  coreRoot = ./my/core/dir;
  coreName = "myCore.core"; # matches name of a core in coreRoot's location
};
```

### Import a remote core
```nix
remoteCore = fusesocTools.importCore {
  coreRoot = "${pkgs.fetchFromGitHub {/*...*/}}/some/subdir";
  coreName = "remoteCoreName.core";
};
```

### Import a core that uses the `provider` attribute for remote fetches
```nix
indirectCore = fusesocTools.importCore {
  coreRoot = ./local/or/remote/dir;
  coreName = "indirectCoreName.core";  
  providerHash = ""; # SRI hash of the fetched content
};
```

### Import a core that uses generator or script files (not listed in filesets)
```nix
generatorsCore = fusesocTools.importCore {
  coreName = "generators-0.1.7.core";
  coreRoot = "${pkgs.fetchFromGitHub {
    owner = "fusesoc";
    repo = "fusesoc-cores";
    rev = "df5d895909b4289aab8ba368250a332a3c6970ea";
    hash = "sha256-1zNYV6empYAoNkVPgqpGttR38KsHBRU2cxvomafzBsI=";
  }}/fusesoc_utils";
  providerHash = "sha256-ei2IXefe/RKa77jlZsQQ+/P0lPh2Of4+kqDSBvp9TXU=";
  preservePaths = [
    "chisel.py"
    "custom.py"
    "gitversion.py"
    "icepll.py"
    "template/template_generator.py"
    "template/templates/constants_pkg_sv.j2"
    "template/templates/constants_pkg_vhd.j2"
    "template/templates/sdc.j2"
    "template/templates/ucf.j2"
  ];
};
```

### Batch import many cores
```nix
myCores = fusesocTools.importCores ./.;
remoteCores = fusesocTools.importCores (pkgs.fetchFromGitHub {/*...*/});
```
Note that `importCores` only works with fusesoc cores that *do not* need a `providerHash` or `preservePaths` entry.

## Make a dev shell

Dev shells are straightforward to make using `mkConf` to generate a fusesoc config file for your environment. `mkConf` can take a core set or a core list as an argument.
For a dev environment, You don't need to link the cores using `mkCoreSet` unless you want to run fusesoc targets in nix.

```nix
pkgs.mkShell {
  packages = [
    pkgs.fusesoc
    # add verilator, yosys, iverilog, etc.
  ];
  shellHook = ''
    export FUSESOC_CONFIG=${fusesocTools.mkConf (fusesocTools.importCores ./.)}
  '';
}
```

## Make a core set

`mkCoreSet` turns a list of cores into an attribute set of cores which are addressed via fusesoc's vlnv format.

For example, `fusesoc:utils:blinky:1.1.1` is accessed via `fusesoc.utils.blinky."1.1.1"`, or `fusesoc.utils.blinky` if version `1.1.1` is the latest version in the core set.

Multiple versions of a core can be stored in a core set, but it isn't advisable unless the underlying fusesoc cores explicitly pin their version dependencies, as a lot of cores in the wild just look for the latest core regardless of compatibility.

When `mkCoreSet` is called, it links dependencies as specified by each fusesoc core. If you added a dependency list manually, only missing dependencies will be linked.

### Resolve dependencies between the imported cores
```nix
myCoreSet = fusesocTools.mkCoreSet (myCores ++ remoteCores ++ [
  myCore
  remoteCore
  indirectCore  
]);
```

### Extend your core set with another core
```nix
extendedCoreSet = fusesocTools.extendCoreSet oldCoreSet [ someExtraCore ];
```

### Export your core set in flake.nix
```nix
legacyPackages.x86_64-linux.fusesocCores = extendedCoreSet;
```

### Import a core set from a repo that uses fusesoc-flake
```nix
flakeCoreSet = inputs.someFlake.legacyPackages.x86_64-linux.fusesocCores;
```

### Pick out a dependency from another core set
```nix
myCoreSet = fusesocTools.mkCoreSet [
  myCore1
  myCore2
  myCore3
  flakeCoreSet.some.core.dependency."1.0.0"
];
```

### Extend a core set you depend on with your dependant cores
```nix
myCoreSet = fusesocTools.extendCoreSet dependCoreSet [ myCore1 myCore2 myCore3 ];
```

## Run a fusesoc target as a nix derivation

fusesoc-flake allows you to run *most* targets within the nix build system for easier CI. The exception is for when proprietary tools are involved that are infeasible to package for nix (think vivado, etc).

I'd like to have this project automatically detect and include tools needed per target (within reason), but for now tooling dependencies must be defined manually.

All imported cores have a `run` passthru attribute, which contains an attribute set of derivations. Each derviation is named after a `target` listed in the fusesoc core.

The output of a `target` derivation is the directory containing the build output of the fusesoc command that invoked it. You can do whatever you like from there.

### Run `fusesoc run --target tinyfpga_bx fusesoc:utils:blinky` as part of `nix flake check`
```nix
{
  inputs = {/*...*/};
  outputs = {self, nixpkgs, fusesoc-flake, ...}@inputs: {
    /*...*/
    checks.x86_64-linux = let
      cores = self.legacyPackages.x86_64-linux.fusesocCores;
    in
    {
      blinky-tinyfpga_bx = cores.fusesoc.utils.blinky.run.tinyfpga_bx.withTools [
        pkgs.icestorm
        pkgs.yosys
        pkgs.nextpnr
      ];
    };
  };
}
```

## Generate a folder with all dependent cores

Since it is possible to generate cores as part of your flow, included is a way to export core sets or lists in a regular flat folder structure using `dumpCores`.

### Setup flake.nix to output your cores to ./result with `nix build`
```nix
packages.x86_64-linux.default = fusesocTools.dumpCores self.legacyPackages.x86_64-linux.fusesocCores;
```
running `ls result` will show you the generated cores.
