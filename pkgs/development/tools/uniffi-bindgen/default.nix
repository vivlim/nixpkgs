{ lib
, stdenv
, rustPlatform
, fetchFromGitHub
, ktlint
, yapf
, rubocop
, rustfmt
, makeWrapper
}:

rustPlatform.buildRustPackage rec {
  pname = "uniffi-bindgen";
  version = "0.19.6";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "uniffi-rs";
    rev = "v${version}";
    hash = "sha256-G/H0MJE0foYNY0m59+VzWBU3PGmeOb1IGmPIoD9Dpz0=";
  };

  cargoLock.lockFile = ./Cargo.lock;

  cargoBuildFlags = [ "-p uniffi_bindgen" ];
  cargoTestFlags = [ "-p uniffi_bindgen" ];
  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  postFixup = ''
    wrapProgram "$out/bin/uniffi-bindgen" \
      --suffix PATH : ${lib.strings.makeBinPath [ rustfmt ktlint yapf rubocop ] }
  '';

  passthru.updateScript = ./update.sh;

  meta = with lib; {
    description = "Toolkit for building cross-platform software components in Rust";
    homepage = "https://mozilla.github.io/uniffi-rs/";
    license = licenses.mpl20;
    maintainers = with maintainers; [ vtuan10 ];
  };
}
