{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.zola

    # keep this line if you use bash
    pkgs.bashInteractive
  ];
}
