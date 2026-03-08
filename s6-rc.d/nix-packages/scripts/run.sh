#!/command/with-contenv bash

up () {
  [ ! -f /home/sandbox/package.nix ] && exit 0

  echo "Installing Nix packages from /home/sandbox/package.nix..."
  cat <<"EOF" | HOME=/home/sandbox s6-setuidgid sandbox bash
    export USER=sandbox
    if [ -f /home/sandbox/.nix-profile/etc/profile.d/nix.sh ]; then
      source /home/sandbox/.nix-profile/etc/profile.d/nix.sh
    fi
    export PATH=$PATH:/home/sandbox/.nix-profile/bin
    if ! nix-env -i -f /home/sandbox/package.nix; then
      echo "Failed to install packages. Re-trying with a clean profile..."
      rm -f /home/sandbox/.nix-profile
      rm -rf /home/sandbox/.local/state/nix/profiles
      if [ -d /home_skel/.local/state/nix/profiles ]; then
        mkdir -p /home/sandbox/.local/state/nix
        cp -af /home_skel/.nix-profile /home/sandbox/.nix-profile
        cp -af /home_skel/.local/state/nix/profiles /home/sandbox/.local/state/nix/profiles
      fi
      nix-env -i -f /home/sandbox/package.nix
    fi
EOF
}

$1 2>&1 | s6-log -bp n3 "p[nix-packages]" 1 /var/log/nix-packages
