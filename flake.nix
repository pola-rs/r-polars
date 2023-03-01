{
  inputs = {
    nixpkgs.url =
      "github:winterqt/nixpkgs/import-cargo-lock-git-dep-workspace-inheritance";
    flake-utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = { self, nixpkgs, flake-utils, fenix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        rustNightly = fenix.packages.${system}.complete;
        pkgs = nixpkgs.legacyPackages.${system};
        # Build r-polars from source
        rpolars = pkgs.rPackages.buildRPackage {
          name = "polars";
          src = self;
          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = "${self}/${rpolars.cargoRoot}/Cargo.lock";
            outputHashes = {
              "arrow2-0.16.0" =
                "sha256-Ac/DhiLKd16ffBmmZXK2ph7gWrm/2YgioOclSpzTMx8=";
              "extendr-api-0.3.1" =
                "sha256-HOglEF9PLLV12uP3gWr/6pSZFfn38I+ATcJPBbGzpJI=";
              "jsonpath_lib-0.3.0" =
                "sha256-NKszYpDGG8VxfZSMbsTlzcMGFHBOUeFojNw4P2wM3qk=";
              "polars-0.27.2" =
                "sha256-8FBAcs5dh0EmeNmguUH4FDS+GVFRimX39nX/vyk6wMk=";
            };
          };
          cargoRoot = "src/rust";
          nativeBuildInputs = with pkgs;
            [ cmake rPackages.codetools rustPlatform.cargoSetupHook ]
            ++ pkgs.lib.singleton rustNightly.toolchain;
        };
        # Create R development environment with r-polars and other useful libraries
        rpkgs = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [ rextendr rpolars tidyverse ];
        };
      in {
        packages.default = rpolars;
        devShells.default = pkgs.mkShell {
          inputsFrom = pkgs.lib.singleton rpolars;
          packages = pkgs.lib.singleton rpkgs;
        };
      });
}
