{
  description = "Rust shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    oxalica-rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crate2nix = {
      # Only used for `crate2nix generate`
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
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs
          [
            "x86_64-linux"
            "aarch64-linux"
            "x86_64-darwin"
            "aarch64-darwin"
          ]
          (
            system:
            f (
              import nixpkgs {
                inherit system;
                config.allowUnfree = true;
                overlays = [ ];
              }
            )
          );
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          crate2nix' = crate2nix.packages.${pkgs.system}.default;
          commonPackages = with pkgs; [
            git
            curl
            httpie
            wget
            bat
            fd
            ripgrep
            just
            gnumake
            procs
            bottom
            hexyl
            hyperfine
            tokei
          ];
          rustShell =
            prefs:
            (import ./rust.nix (
              prefs
              // {
                inherit commonPackages crate2nix';
                pkgs = import nixpkgs {
                  inherit (pkgs) system;
                  overlays = [
                    (import oxalica-rust)
                  ];
                };
              }
            ));
        in
        {
          default = self.devShells.${pkgs.system}.rust-stable;
          rust-stable = { ... }@prefs: (rustShell prefs).stable;
          rust-nightly = { ... }@prefs: (rustShell prefs).nightly;
        }
      );

      packages = forAllSystems (pkgs: {
        configs.neovim.rust = { }; # TODO
      });
    };
}
