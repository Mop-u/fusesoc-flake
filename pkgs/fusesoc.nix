{
  fusesoc,
  edalize,
  python3Packages,
}:
fusesoc.override {
  python3Packages = python3Packages // {
    inherit edalize;
  };
}
