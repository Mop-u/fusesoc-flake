{
    lib,
    fetchFromGitHub,
    stdenv,
    gnumake,
    cmake,
    python3,
    yosys,
}:
stdenv.mkDerivation (finalAttrs: {
    pname = "yosys-slang";
    version = "0-unstable-2026-02-21";
    plugin = "slang";

    src = fetchFromGitHub {
        owner = "povik";
        repo = "yosys-slang";
        rev = "d82b0b163a725fc1a401fbb6b465cd862517ec1f";
        hash = "sha256-z+eEhTb9UZJ/L4X0GLwJMcjPcaPbnGFXJe09eLXGBB4=";
        fetchSubmodules = true; # Needed to fetch the pinned slang source
    };

    nativeBuildInputs = [
        gnumake
        cmake
        python3
        yosys
    ];

    installPhase = ''
        mkdir -p $out/share/yosys/plugins
        cp slang.so $out/share/yosys/plugins/slang.so
    '';

    meta = {
        description = "Slang plugin for Yosys providing a SystemVerilog frontend.";
        homepage = "https://github.com/povik/yosys-slang";
        license = lib.licenses.isc;
        platforms = lib.platforms.all;
    };
})
