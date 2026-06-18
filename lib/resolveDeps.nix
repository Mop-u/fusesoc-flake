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
        candidates = with req; coreSet.${vendor}.${library}.${name};
      in
      lib.findFirst (dep: req.condition dep.version) candidates.latest candidates.list
    ) (parseDeps coreDrv);

  fetchDepsRecursive =
    coreDrv: coreSet:
    let
      deps = fetchDepsShallow coreDrv coreSet;
    in
    deps ++ (builtins.concatMap (dep: fetchDepsRecursive dep coreSet) deps);

in
coreDrv: coreSet: lib.unique (map (drv: "${drv}") (fetchDepsRecursive coreDrv coreSet))
