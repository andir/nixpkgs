{ stdenv, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "bird-exporter-${version}";
  version = "1.2.1";
  rev = "${version}";

  goPackagePath = "github.com/czerwonk/bird_exporter";

  src = fetchFromGitHub {
    inherit rev;
    owner = "czerwonk";
    repo = "bird_exporter";
    sha256 = "0mxym0ybpwb3f6dpj7vnr9dnyb8n10bn2icf3a5py103ny62xry9";
  };

  meta = with stdenv.lib; {
    description = "Bird exporter for prometheus metrics";
    homepage = https://github.com/czworker/bird_exporter;
    license = licenses.mit;
    maintainers = with maintainers; [ andir ];
    platforms = platforms.unix;
  };

}

