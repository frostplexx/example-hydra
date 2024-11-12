{
  # Basic information about the project
  example-project = {
    enabled = 1;
    hidden = false;
    description = "Example project demonstrating Hydra basics";
    nixexprinput = "exampleSource";
    nixexprpath = "release.nix";
    checkinterval = 300;  # Check every 5 minutes
    schedulingshares = 100;
    enableemail = false;
    emailoverride = "";
    keepnr = 3;  # Keep last 3 builds
  };
}
