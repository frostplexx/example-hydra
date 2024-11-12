{ nixpkgs ? <nixpkgs> }:

let
  pkgs = import nixpkgs {};
in {
  # Basic hello world package build
  hello = pkgs.stdenv.mkDerivation {
    name = "hello-example";
    version = "1.0.0";
    
    src = pkgs.fetchurl {
      url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
      sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
    };
  };

  # Simple test job
  tests = pkgs.stdenv.mkDerivation {
    name = "example-tests";
    
    buildInputs = [ pkgs.hello ];
    
    buildCommand = ''
      # Simple test that verifies hello works
      hello
      if [ $? -eq 0 ]; then
        echo "Test passed!" > $out
      else
        exit 1
      fi
    '';
  };

  # Documentation job
  docs = pkgs.stdenv.mkDerivation {
    name = "example-docs";
    
    buildInputs = [ pkgs.pandoc ];
    
    src = ./docs;  # Assuming you have a docs directory
    
    buildCommand = ''
      mkdir -p $out
      pandoc $src/manual.md -o $out/manual.html
    '';
  };
}
