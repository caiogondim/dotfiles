<img src="https://rawgit.com/caiogondim/dotfiles/master/logo/logo.svg">

# dotfiles

My dotfiles with configuration for:
- ESLint
- git
- OS X
- Vim
- ZSH

The ZSH theme i use is [Bullet train](https://github.com/caiogondim/bullet-train-oh-my-zsh-theme).
For tmux, i use [Maglev](https://github.com/caiogondim/maglev).

## Installing

Clone the repo:

```bash
git clone git@github.com:caiogondim/dotfiles.git
```

And install it:

```bash
make install
```

This will symlink all the configuration files. If you already have a, for
instance, `.vimrc`, a backup copy will be created as `.vimrc.bak`.

## Updating

To update, update the repo and you are good to go.

```bash
git pull --rebase
```

If you need to personalize ZSH, you can use the `~.zshrc.local`. This way you
don't need to resolve conflicts between every `git pull`.

## Credits

That project is highly inspired in those ones:

- [Mathias Bynen's dotfiles](https://github.com/mathiasbynens/dotfiles)
- Icon by Mat Stevens, from the Noun Project
