{ pkgs, system, ... }:
let
    rustMixed = with pkgs; symlinkJoin {
      name = "rust-mixed";
      # Do NOT include rustup. Rustrover will go nuts trying to call cargo with rustup flags.
      paths = [ rustc cargo rust-analyzer clippy cargo-watch rustfmt rustPlatform.rustcSrc ];
      # paths = [ fenix-toolchain rustPlatform.rustcSrc ];
    };
    # fenix-toolchain = fenix.packages.${system}.default.toolchain;
in
  pkgs.mkShell {
    packages = [
      pkgs.llvmPackages.bintools
      pkgs.pkg-config
      rustMixed
      pkgs.crate2nix
    ];
    
    RUST_SRC_PATH = "${rustMixed}/library";

    shellHook = ''
      alias rustrover="tmux new -d '$HOME/.local/share/JetBrains/Toolbox/apps/rustrover/bin/rustrover .'"
      alias v=nvim

      export RUST_BACKTRACE=full

      echo "Rust version: $(rustc --version)"
      echo "Cargo version: $(cargo --version)"
      echo "Rust toolchain location: ${rustMixed}/bin"
      echo "Rust stdlib location: ${rustMixed}/library"
      echo "RUST_SRC_PATH (stdlib location): $RUST_SRC_PATH"
    '';
  }

