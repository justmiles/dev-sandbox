
export PATH=$PATH:$HOME/.local/bin:$HOME/bin

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.local/share/oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled # disable automatic updates

DISABLE_AUTO_TITLE="true"

plugins=(git)

[ -f "$ZSH/oh-my-zsh.sh" ] && source $ZSH/oh-my-zsh.sh
[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source $HOME/.nix-profile/etc/profile.d/nix.sh

export GOPATH=$HOME/go

autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit

for f in $(find ~/.bashrc.d -type f | sort -r ); do
    source $f || echo "[$f] could not load - exit code $?"
done

# Hook direnv
eval "$(direnv hook zsh)"

# Hishtory Config:
export PATH="$PATH:/home/sandbox/.hishtory"
source /home/sandbox/.hishtory/config.zsh
