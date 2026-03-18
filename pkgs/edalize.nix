{
    python3Packages,
    fetchFromGitHub,
}:
python3Packages.edalize.overridePythonAttrs (old: {
    version = "0.6.4";
    src = fetchFromGitHub {
        owner = "Mop-u";
        repo = "edalize";
        rev = "55b31ed3910c412c0a79e44d49136a435eb933f8";
        hash = "sha256-ub6Lrb5OXdPzv1hH/XFa/Wy6IEWjVBPUPPw5FXTYtUk=";
    };
    dependencies = (old.dependencies or [ ]) ++ [ python3Packages.cocotb ];
})
