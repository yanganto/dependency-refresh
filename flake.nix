{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.stable.latest.default;
      in
      with pkgs;
      rec {
        packages.${system}.dr = pkgs.rustPlatform.buildRustPackage {
          name = "dr";
          src = self;
          cargoSha256 = "sha256-FxqTp0P3TEkOvlinGK6u3sZ+GksIwLVaenly9nMJEUM=";

          # Currently, all check in dr using network
          doCheck = false;

          buildInputs = [ openssl ];
          nativeBuildInputs = [ pkg-config ];
        };
        defaultPackage = packages.${system}.dr;
        devShell = mkShell {
          buildInputs = [
            openssl
            pkg-config
            rust
          ];
        };
      }
    );
}
