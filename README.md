# Nix Shells


## Rust

### Usage

```Nix
# ...

      devShells = forAllSystems (pkgs: {
        default = nix-shells.devShells.x86_64-linux.rust-stable {
          version = "1.93.0";   # Defaults to latest
          withPkgs = with pkgs; [
            (writeShellScriptBin "rustrover" "tmux new -d 'rust-rover .'")  # Rustrover must be in path outside the shell
          ];
          postHook = ''
            exec -l zsh # ALIASES WILL BE LOST!
          '';
        };
      });
# ...
```



