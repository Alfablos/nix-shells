{
  pkgs
  , rustVersion
  , crate2nix
  , withPkgs
  , ...
}:
let
  oxalica-override = pkgs.rust-bin.stable.${rustVersion}.default.override {
    extensions = [ "rust-src" "clippy" "rust-analyzer" "rustfmt" ];
  };
in
  pkgs.mkShell {
    packages = [
      pkgs.llvmPackages.bintools
      pkgs.pkg-config
      oxalica-override
      pkgs.nodejs-slim
      # Since aliases don't work
      (pkgs.writeShellScriptBin "rustrover" "tmux new -d '$HOME/.local/share/JetBrains/Toolbox/apps/rustrover/bin/rustrover .'")
      crate2nix
    ] ++ ( with pkgs; withPkgs );
    
    RUST_SRC_PATH = "${oxalica-override}/lib/rustlib/src/rust";

    shellHook = ''
      alias v=nvim
      alias vim=nvim

      export RUST_BACKTRACE=full

      echo "Rust version: $(rustc --version)"
      echo "Cargo version: $(cargo --version)"
      echo "Rust toolchain location: ${oxalica-override}/bin"
      echo "RUST_SRC_PATH (stdlib location): $RUST_SRC_PATH"
    '';
  }

