{
  description = "Rust shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    oxalica-rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {  # Only used for `crate2nix generate`
      url = "github:nix-community/crate2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      nixpkgs,
      crate2nix,
      oxalica-rust,
    }:
    let
      forAllSystems = f:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: f (import nixpkgs { inherit system; config.allowUnfree = true; overlays = []; }));

    in
    {
      devShells = forAllSystems (pkgs: {
        default = self.devShells.${pkgs.system}.rust;
        rust = self.packages.${pkgs.system}.lib.shells.rust { };
      });

      packages = forAllSystems (pkgs: {
        lib.shells.rust = { rustVersion ? "1.84.0", withPkgs ? [ ] }:
          pkgs.callPackage ./rust.nix {
            pkgs = import nixpkgs { system = pkgs.system; overlays = [ (import oxalica-rust) ]; };
            crate2nix = crate2nix.packages.${pkgs.system}.default;
            inherit rustVersion withPkgs;
        };
        lib.configs.neovim.rust = {}; # TODO
      });
    };
}

