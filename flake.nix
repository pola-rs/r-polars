{
  inputs = {
    fenix.url = "github:nix-community/fenix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rustPlatformFix.url =
      "github:winterqt/nixpkgs/import-cargo-lock-git-dep-workspace-inheritance";
  };

  outputs = { self, fenix, flake-utils, nixpkgs, rustPlatformFix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        rustNightly = fenix.packages.${system}.complete;
        pkgs = nixpkgs.legacyPackages.${system}.extend (final: prev: {
          inherit (rustPlatformFix.legacyPackages.${system}) rustPlatform;
        });
        # Build r-polars from source
        rpolars = pkgs.rPackages.buildRPackage {
          name = "polars";
          src = self;
          cargoDeps = pkgs.rustPlatform.importCargoLock {
            lockFile = "${self}/${rpolars.cargoRoot}/Cargo.lock";
            outputHashes = {
              "arrow2-0.16.0" =
                "sha256-Ac/DhiLKd16ffBmmZXK2ph7gWrm/2YgioOclSpzTMx8=";
              "extendr-api-0.4.0" =
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
        renv = pkgs.rWrapper.override {
          packages = with pkgs.rPackages; [ devtools rextendr rpolars ];
        };
      in {
        packages.default = rpolars;
        devShells.default = pkgs.mkShell {
          inputsFrom = pkgs.lib.singleton rpolars;
          packages = pkgs.lib.singleton renv;
        };
      });

  nixConfig = {
    extra-substituters = [ "https://r-polars.cachix.org" ];
    extra-trusted-public-keys =
      [ "r-polars.cachix.org-1:LhIYJk3lSZay+OuJ30RU4WkvAc8VY0QvaSy7rIcQ31w=" ];
  };

}
