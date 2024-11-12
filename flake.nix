{
  description = "Example Hydra flake configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Hydra jobs are defined in the hydraJobs output
        hydraJobs = {
          # Basic hello world package build
          hello = pkgs.stdenv.mkDerivation {
            name = "hello-example";
            version = "1.0.0";
            
            src = pkgs.fetchurl {
              url = "https://ftp.gnu.org/gnu/hello/hello-2.12.1.tar.gz";
              sha256 = "sha256-jZkUKv2SV28wsM18tCqNxoCZmLxdYH2Idh9RLibH2yA=";
            };
          };

          # Test job
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
            
            src = ./docs;
            
            buildCommand = ''
              mkdir -p $out
              pandoc $src/manual.md -o $out/manual.html
            '';
          };

          # Matrix build example
          matrix = let
            supportedPythonVersions = [ "python39" "python310" "python311" ];
          in
            builtins.listToAttrs (map
              (pythonVersion: {
                name = "python-${pythonVersion}";
                value = pkgs.stdenv.mkDerivation {
                  name = "python-test-${pythonVersion}";
                  buildInputs = [ pkgs.${pythonVersion} ];
                  buildCommand = ''
                    ${pkgs.${pythonVersion}}/bin/python --version > $out
                  '';
                };
              })
              supportedPythonVersions
            );

          # Container build example
          container = pkgs.dockerTools.buildImage {
            name = "example-container";
            tag = "latest";
            contents = [ self.packages.${system}.hello ];
            config = {
              Cmd = [ "${self.packages.${system}.hello}/bin/hello" ];
              ExposedPorts = {
                "8080/tcp" = {};
              };
            };
          };
        };

        # Regular flake outputs that can be used outside Hydra
        packages = {
          default = self.hydraJobs.hello;
          hello = self.hydraJobs.hello;
        };
      }
    );
}
