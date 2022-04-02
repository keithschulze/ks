{
  description = "keithschulze.com";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url   = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, ... }:
    let
      pkgsFor = system: import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      };
    in {
      overlay = final: prev: {
        blog = prev.callPackage ./blog {};
      };

    } // utils.lib.eachDefaultSystem (system:
      let pkgs = pkgsFor system;
      in {
        defaultPackage = pkgs.blog;

        devShell = pkgs.mkShell {
          buildInputs = [ pkgs.zola ];
        };
      });
}
