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
    # git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      crate2nix,
      oxalica-rust,
      # git-hooks
    }:
    let
      forAllSystems = f:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system: f (import nixpkgs { inherit system; config.allowUnfree = true; overlays = []; }));

    in
    {
      devShells = forAllSystems (pkgs: {
        default = self.devShells.${pkgs.system}.rust;
        rust-stable = (self.packages.${pkgs.system}.lib.shells.rust { }).stable;
        rust-nightly = (self.packages.${pkgs.system}.lib.shells.rust { }).nightly;
      });

      packages = forAllSystems (pkgs:
      let
        commonPackages = with pkgs; [
          git bat fd ripgrep just gnumake neovim
          procs bottom hexyl hyperfine tokei
        ];
      in
      {
        lib.shells.rust = { rustVersionStable ? "latest", rustVersionNightly ? "latest", withPkgs ? [ ], additionalLibraryPaths ? null }:
          pkgs.callPackage ./rust.nix {
            pkgs = import nixpkgs { system = pkgs.system; overlays = [ (import oxalica-rust) ]; };
            crate2nix = crate2nix.packages.${pkgs.system}.default;
            inherit rustVersionStable rustVersionNightly withPkgs commonPackages;
        };
        lib.configs.neovim.rust = {}; # TODO
      });
    };
}

