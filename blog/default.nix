{ pkgs, stdenv, ... }:
stdenv.mkDerivation rec {
  pname = "keithschulze";
  version = "0.0.1";
  src = ./.;
  buildInputs = [ pkgs.zola ];
  buildPhase = ''
    zola build
  '';
  installPhase = ''
    cp -r public $out
  '';
}
