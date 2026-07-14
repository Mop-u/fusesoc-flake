{
  lib,
  parseDependency,
  unique,
}:
let
  parseDeps =
    coreDrv:
    map parseDependency (
      builtins.concatLists (lib.mapAttrsToList (n: v: v.depend or [ ]) (coreDrv.core.filesets or { }))
    );

  fetchDepsShallow =
    coreDrv: coreSet:
    builtins.filter (x: !(isNull x)) (
      map (
        req:
        let
          existing = builtins.filter (
            dep:
            ({ inherit (dep.parsed) vendor library name; } == { inherit (req) vendor library name; })
            && (req.condition dep.version)
          ) coreDrv.dependencies;
        in
        if existing != [ ] then
          # Use existing dependency if already set
          (builtins.head existing)
        else
          (lib.findFirst (dep: req.condition dep.version) null (
            coreSet.${req.vendor}.${req.library}.${req.name}.list or (lib.warn
              "unable to find suitable dependency ${req.vendor}:${req.library}:${req.name} for core ${coreDrv.parsed.vendor}:${coreDrv.parsed.library}:${coreDrv.parsed.name}:${coreDrv.version}"
              [ ]
            )
          ))
      ) (parseDeps coreDrv)
    );

  fetchDepsRecursive =
    coreDrv: coreSet:
    let
      deps = fetchDepsShallow coreDrv coreSet;
    in
    deps ++ (builtins.concatMap (dep: fetchDepsRecursive dep coreSet) deps);

in
coreDrv: coreSet: unique (fetchDepsRecursive coreDrv coreSet)
