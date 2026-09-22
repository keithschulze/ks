{
  pkgs,
  stdenv,
  ...
}:
stdenv.mkDerivation {
  pname = "keithschulze";
  version = "0.0.1";
  src = ./.;
  nativeBuildInputs = [pkgs.zola pkgs.cacert];
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  buildPhase = ''
    zola build
  '';
  installPhase = ''
    cp -r public $out
  '';
}
