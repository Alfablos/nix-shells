# Check the latest stable and unstable with:
# nix repl --expr 'let oxalica-rust = builtins.fetchTarball "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"; in import <nixpkgs> { overlays = [ (import oxalica-rust) ]; }'
{
  # git-hooks
  pkgs
  , commonPackages
  , rustVersionStable
  , rustVersionNightly
  , crate2nix
  , withPkgs
  , additionalLibraryPaths ? null
  , ...
}:
let
  oxalica-override-stable = pkgs.rust-bin.stable.${rustVersionStable}.default.override {
    extensions = [ "rust-src" "clippy" "rust-analyzer" "rustfmt" "cargo" "rustc" ];
  };
  oxalica-override-nightly = pkgs.rust-bin.nightly.${rustVersionNightly}.default.override {
    extensions = [ "rust-src" "clippy" "rust-analyzer" "rustfmt" "cargo" "rustc" ];
  };
  aliases = ''
    alias v=nvim
    alias vim=nvim
    alias fmt="cargo fmt --all"
    alias lint="cargo clippy --all-targets --all-features -- -D warnings"
    alias check="cargo check --all-targets --all-features"
  
    echo "Development aliases:"
    echo "  fmt: Format all code"
    echo "  lint: Run clippy with deny warnings"
    echo "  check: Run cargo check"
    
    alias test="cargo nextest run"
    alias coverage="cargo tarpaulin --out html"
    alias bench="cargo criterion"
  
    echo "Testing aliases:"
    echo "  test: Run tests with nextest"
    echo "  coverage: Generate coverage report"
    echo "  bench: Run benchmarks"
    
    alias audit="cargo audit"
    alias deny="cargo deny check"
    alias sort-deps="cargo sort"
  
    echo "Security aliases:"
    echo "  audit: Check for security vulnerabilities"
    echo "  deny: Check licenses and dependencies"
    echo "  sort-deps: Sort Cargo.toml dependencies"
  '';
  shellHookFor = rustPackage: ''
    ${aliases}
    
    export RUST_BACKTRACE=full
    ${if ! builtins.isNull additionalLibraryPaths
      then ''export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${additionalLibraryPaths}"''
      else ''''}

    echo "Rust version: $(rustc --version)"
    echo "Cargo version: $(cargo --version)"
    echo "Rust toolchain location: ${rustPackage}/bin"
    echo "RUST_SRC_PATH (stdlib location): $RUST_SRC_PATH"
  '';
  allPackages = [
    pkgs.llvmPackages.bintools
    pkgs.pkg-config
    crate2nix
    pkgs.cargo-watch
    pkgs.cargo-expand
    pkgs.cargo-audit
    pkgs.cargo-nextest
    pkgs.cargo-tarpaulin
    pkgs.cargo-criterion
    pkgs.cargo-sort
    pkgs.cargo-deny
    pkgs.mdbook
    
    pkgs.nodejs-slim
    pkgs.git
  ] ++ withPkgs ++ commonPackages;
in
{
  stable = pkgs.mkShell {
    packages = allPackages ++ [oxalica-override-stable];
    RUST_SRC_PATH = "${oxalica-override-stable}/lib/rustlib/src/rust";
    shellHook = shellHookFor oxalica-override-stable;
  };
  nightly = pkgs.mkShell {
    packages = allPackages ++ [oxalica-override-nightly];
    RUST_SRC_PATH = "${oxalica-override-nightly}/lib/rustlib/src/rust";
    shellHook = shellHookFor oxalica-override-nightly;
  };
}
