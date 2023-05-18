{
  inputs = {
    fenix.url = "github:nix-community/fenix/monthly";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, fenix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustNightly = fenix.packages.${system}.complete;
        rdeps = with pkgs; [
          curl
          fontconfig
          fribidi
          harfbuzz
          libjpeg
          libpng
          libtiff
          libxml2
          openssl
          pkg-config
        ];
        # Build r-polars from source
        rpolars = pkgs.rPackages.buildRPackage {
          name = "polars";
          src = self;
          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = "${self}/${rpolars.cargoRoot}/Cargo.lock";
            outputHashes = {
              "arrow2-0.17.0" = "sha256-c3g7SjMWOpyurn/iZWjLdLWeywl+kmFzY25pCM5S3AA=";
              "extendr-api-0.4.0" =
                "sha256-tbA8+aaGz2p71BfPSgPBRxqwgD+XHGoSrMfGM/RKZHo=";
              "jsonpath_lib-0.3.0" =
                "sha256-NKszYpDGG8VxfZSMbsTlzcMGFHBOUeFojNw4P2wM3qk=";
              "polars-0.28.0" = "sha256-QNg9cIfeACiKSV4Hr7KC0dG4CQVzCSxxNycsmcmOJEk=";
            };
          };
          cargoRoot = "src/rust";
          nativeBuildInputs = with pkgs;
            [ cmake rPackages.codetools rustPlatform.cargoSetupHook ]
            ++ pkgs.lib.singleton rustNightly.toolchain;
        };
        # Create R development environment with r-polars and other useful libraries
        rvenv = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [ renv ];
        };
      in {
        packages.default = rpolars;
        devShells.default = pkgs.mkShell {
          buildInputs = rdeps;
          inputsFrom = pkgs.lib.singleton rpolars;
          packages = pkgs.lib.singleton rvenv;
          LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath rdeps;
        };
      });

}
