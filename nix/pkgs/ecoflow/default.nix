{
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  makeWrapper,
}: let
  ha-ef-ble = fetchFromGitHub {
    owner = "rabits";
    repo = "ha-ef-ble";
    rev = "4c410ec00f33d3c7d030e63543d411231fab1b6f";
    hash = "sha256-FKpRAo9qPOPr9n7NZuND8nzRGRPr3qB7C1LmghuVZvI=";
  };

  python = python3.withPackages (ps: [
    ps.bleak
    ps.bleak-retry-connector
    ps.ecdsa
    ps.protobuf
    ps.pycryptodome
  ]);
in
  stdenvNoCC.mkDerivation {
    pname = "ecoflow";
    version = "0.1.0";

    dontUnpack = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/lib/ecoflow
      cp -r --no-preserve=mode ${ha-ef-ble}/custom_components/ef_ble/eflib $out/lib/ecoflow/eflib
      cp ${./ecoflow.py} $out/lib/ecoflow/ecoflow.py
      ${python.interpreter} -m compileall -q $out/lib/ecoflow

      makeWrapper ${python.interpreter} $out/bin/ecoflow \
        --add-flags $out/lib/ecoflow/ecoflow.py
    '';

    meta.mainProgram = "ecoflow";
  }
