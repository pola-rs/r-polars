{
  inputs = {
    fenix.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, fenix, flake-utils, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        rustToolchains = fenix.packages.${system}.default;
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
            outputHashes = {};
            allowBuiltinFetchGit = true;
          };
          cargoRoot = "src/rust";
          nativeBuildInputs = with pkgs;
            [ cmake rPackages.codetools rustPlatform.cargoSetupHook ]
            ++ pkgs.lib.singleton rustToolchains.toolchain;
        };
        # Create R development environment with r-polars and other useful libraries
        rvenv = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [ devtools languageserver renv rextendr ];
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
