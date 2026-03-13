{
    fusesoc,
    edalize,
    python3Packages,
    fetchFromGithub,
}:
fusesoc.override {
    python3Packages = python3Packages // {
        inherit edalize;
    };
}
