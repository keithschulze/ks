{
  description = "A simple flake for a projects";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    rust-overlay.url = github:oxalica/rust-overlay;

    flake-utils = {
      url = github:numtide/flake-utils;
    };
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          name = "ks-jupyter";
          pkgs = import nixpkgs {
            inherit system overlays;
          };

          rust = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" ];
            targets = [ "wasm32-unknown-unknown" ];
          };
        in
          {
            devShells.default = pkgs.mkShell rec {
              buildInputs = with pkgs; [
                bashInteractive
                openssl
                pkg-config
                exa
                fd
                evcxr
                rust
                python310
                poetry
                darwin.apple_sdk.frameworks.IOKit
              ];

              shellHook = ''
                set +e
                if [[ ! -d ./.venv ]]; then
                  python -m venv .venv
                fi

                [[ -f poerty.lock ]] && poetry install
              '';
            };
          }
        );
}
