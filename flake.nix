{
  description = "Rust shell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    oxalica-rust = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # git-hooks.url = "github:cachix/git-hooks.nix";
  };

  outputs =
    {
      self,
      nixpkgs,
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
          commonPackages = with pkgs; [
            git
            curl
            httpie
            wget
            jq
            fx
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
                inherit commonPackages;
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
