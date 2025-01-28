{
  description = "Rust shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=041c867bad68dfe34b78b2813028a2e2ea70a23c";
    flake-utils.url = "github:numtide/flake-utils";

    # Nightly and macrobacktrace
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells = {
          default = self.devShells.${system}.rust;
          rust = pkgs.callPackage ./rust.nix { };
        };

      });
}

