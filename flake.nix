{
  description = "Rust shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=041c867bad68dfe34b78b2813028a2e2ea70a23c";
    oxalica-rust.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      #  fenix,
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
      devShells = forAllSystems (pkgs: rec {
        default = rust;
        rust = self.packages.${pkgs.system}.lib.shells.rust { };
      });

      packages = forAllSystems (pkgs: {
        lib.shells.rust = { rustVersion ? "1.84.0" }:
          pkgs.callPackage ./rust.nix {
            pkgs = import nixpkgs { system = pkgs.system; overlays = [ (import oxalica-rust) ]; };
            inherit rustVersion;
        };
        lib.configs.neovim.rust = {}; # TODO
      });
    };
}

