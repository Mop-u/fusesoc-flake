{
  lib,
  parseDependency,
}:
let
  parseDeps =
    coreDrv:
    map parseDependency (
      builtins.concatLists (lib.mapAttrsToList (n: v: v.depend or [ ]) (coreDrv.core.filesets or { }))
    );

  fetchDepsShallow =
    coreDrv: coreSet:
    map (
      req:
      let
        core = coreSet.${req.vendor}.${req.library}.${req.name};
        default = core; # toplevel derivation is always the latest version
        candidates = core.list;
      in
      lib.findFirst (dep: req.condition dep.version) default candidates
    ) (parseDeps coreDrv);

  fetchDepsRecursive =
    coreDrv: coreSet:
    let
      deps = fetchDepsShallow coreDrv coreSet;
    in
    deps ++ (builtins.concatMap (dep: fetchDepsRecursive dep coreSet) deps);

in
coreDrv: coreSet: lib.unique (map (drv: "${drv}") (fetchDepsRecursive coreDrv coreSet))
