# [theZMC](https://github.com/thezmc)'s Dotfiles

These are [dotfiles](https://wiki.archlinux.org/title/Dotfiles). Most of the
inspiration for how this repo is set up is taken from
[Dreams of Autonomy](https://www.youtube.com/@dreamsofautonomy)'s fantastic
[dotfiles video](https://www.youtube.com/watch?v=y6XCebnB9gs).

## Usage

1. Clone this repo:

   ```bash
   git clone https://github.com/thezmc/dotfiles.git ~/dotfiles
   ```

2. Use [stow](https://www.gnu.org/software/stow/) to populate your home
   directory with symlinks for all of this repo's configuration files:

   ```bash
   cd ~/dotfiles

   # --no-folding symlinks files directly instead of directories
   # this prevents extra content in those directories from polluting
   # our dotfiles
   stow --no-folding .
   ```

3. Restart your terminal and wait for zsh and tmux plugins to install.

That's it! Enjoy the dotfiles. If you want to use this is a base for your own
configuration, you can `rm -rf ~/dotfiles/.git && cd ~/dotfiles && git init` to
create your own git repo.
