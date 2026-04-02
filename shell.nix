with import <nixpkgs>{}; {
  my_shell = stdenv.mkDerivation {
    name = "build-env";
    buildInputs = [
      cargo
      rustc
      gnumake
      cmake
      gcc
      zlib
      python3
      (perl.withPackages (p: [
        p.XMLLibXSLT
        p.XMLLibXML
      ]))
      curl
      meson
      libunistring
      ninja
    ];
  };
}