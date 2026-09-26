# [theZMC](https://github.com/thezmc)'s Dotfiles

These are [dotfiles](https://wiki.archlinux.org/title/Dotfiles). Most of the
inspiration for how this repo is set up is taken from
[Dreams of Autonomy](https://www.youtube.com/@dreamsofautonomy)'s fantastic
[dotfiles video](https://www.youtube.com/watch?v=y6XCebnB9gs).

## Usage

1. Clone this repo:

   ```sh
   git clone https://github.com/thezmc/dotfiles.git ~/dotfiles # or wherever you want to put it
   ```

2. Use [stow](https://www.gnu.org/software/stow/) to populate your home
   directory with symlinks for all of this repo's configuration files:

   ```sh
   cd ~/dotfiles

   # --no-folding symlinks files directly instead of directories
   # this prevents extra content in those directories from polluting
   # our dotfiles
   stow --no-folding -t "$HOME" .
   ```

3. Restart your terminal and wait for mise to do its thing. It installs only
   the tools the shell itself needs up front; everything else is marked
   `lazy = true` in `.config/mise/config.toml` and installs the first time you
   run one of its commands. To pre-install everything instead, run
   `mise install --include-lazy`.

That's it! Enjoy the dotfiles. If you want to use this is a base for your own
configuration, you can `rm -rf ~/dotfiles/.git && cd ~/dotfiles && git init` to
create your own git repo. **Fair warning**: the gnupg and ssh directories are
_pretty_ specific to my setup, so you may want to remove those first if you
seriously want to use this as a base for your own config.
