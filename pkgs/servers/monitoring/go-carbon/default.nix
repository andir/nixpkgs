{stdenv, buildGoPackage, fetchgit, git }:

buildGoPackage rec {
  version = "0.11.0";
  name = "go-carbon-${version}";
  goPackagePath = "github.com/lomik/go-carbon";
  src = fetchgit {
    url = "https://github.com/lomik/go-carbon.git";
    rev = "v${version}";
    sha256 = "1qqbr6mppk6dcfdibqwgx8ri6f4cdc0dc3kk287b9h53f6v4dz1r";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ git ];

  #preBuild = ''
    #cd $src
    #make submodules
  #'';
}
