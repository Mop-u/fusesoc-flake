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
    version = "0-unstable-2026-03-16";
    plugin = "slang";

    src = fetchFromGitHub {
        owner = "povik";
        repo = "yosys-slang";
        rev = "8c82a4b7c4dff83d1d446610d8ee582aa094fd9d";
        hash = "sha256-wpOeskpD9kK0d163G1zn5atO4An80xNREaahmHFGPsY=";
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
