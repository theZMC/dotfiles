# [theZMC](https://github.com/thezmc)'s Dotfiles

These are [dotfiles](https://wiki.archlinux.org/title/Dotfiles). Most of the
inspiration for how this repo is set up is taken from
[Dreams of Autonomy](https://www.youtube.com/@dreamsofautonomy)'s fantastic
[dotfiles video](https://www.youtube.com/watch?v=y6XCebnB9gs).

Everything is applied by [`mise bootstrap`](https://mise.jdx.dev/bootstrap.html),
configured in [`.config/mise/config.toml`](.config/mise/config.toml):

- `[bootstrap.packages]`: Homebrew formulae and casks on macOS, and a shell
  baseline (zsh, git, curl, gnupg, pinentry) from apt, dnf, or pacman on Linux.
- `[dotfiles]`: links every git-tracked file under `.agents`, `.claude`,
  `.config`, `.gnupg`, `.local`, and `.ssh` into `$HOME`, plus `.gitconfig`
  and `.zshrc`.
- `[bootstrap].macos`: Dock, Finder, and keyboard defaults.
- `[tools]`: CLI tools. Most are `lazy = true` and install the first time you
  run them; `mise install --include-lazy` installs everything up front.

## Usage

The checkout lives at `~/Code/github.com/thezmc/dotfiles`, which is where
`dotfiles.root` points. To keep it somewhere else on one machine, override the
root in an untracked `~/.config/mise/config.local.toml` and pass the same path
to `--from-dir`:

```toml
[settings.dotfiles]
root = "/somewhere/else/github.com/thezmc/dotfiles"
```

`dotfiles.root` does not expand templates or `$CODE_HOME`, and the shell's
environment isn't there for bootstrap or background services, so the path is
written out.

1. **macOS only:** put `~/Code` on a case-sensitive APFS volume. Check the
   container name with `diskutil apfs list` (usually `disk3` on Apple Silicon):

   ```sh
   diskutil apfs addVolume disk3 'Case-sensitive APFS' Code
   ln -s /Volumes/Code ~/Code
   ```

2. Install mise:

   ```sh
   curl -fsSL https://mise.run | sh
   ```

3. Clone and bootstrap. Preview with `--dry-run` first:

   ```sh
   ~/.local/bin/mise bootstrap \
     --from https://github.com/thezmc/dotfiles.git \
     --from-dir ~/Code/github.com/thezmc/dotfiles
   ```

4. Restart your terminal.

To pick up changes later:

```sh
git -C ~/Code/github.com/thezmc/dotfiles pull
mise bootstrap
```

`mise bootstrap status` shows what is out of date. Removing a package from the
config does not uninstall it; `mise bootstrap packages prune --manager brew`
does.

If you want to use this as a base for your own configuration, fork it and
change `dotfiles.root` and the URLs above. **Fair warning**: the gnupg and ssh
directories are _pretty_ specific to my setup, so you may want to remove those
first.
