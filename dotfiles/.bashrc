export PATH=$PATH:$HOME/.local/bin:$HOME/bin

[ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && source "$HOME/.nix-profile/etc/profile.d/nix.sh"

export GOPATH=$HOME/go

# Hook direnv
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook bash)"
