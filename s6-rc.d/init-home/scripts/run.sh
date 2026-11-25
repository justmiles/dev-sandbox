#!/command/with-contenv bash

set -euo pipefail

up () {
  # Set sandbox UID/GID
  [ -n "${SANDBOX_UID:-}" ] && usermod -u "$SANDBOX_UID" sandbox
  [ -n "${SANDBOX_GID:-}" ] && groupmod -g "$SANDBOX_GID" sandbox

  # Initialize home directory from skeleton if it exists
  if [ -d /home_skel ]; then
    echo "Initializing /home/sandbox from skeleton..."

    # Sync files from skeleton to home directory, setting their owner/group to sandbox
    rsync -a --chown=sandbox:sandbox --ignore-existing /home_skel/ /home/sandbox/

    # Always overwrite Nix profile symlinks from the skeleton to ensure we point to the valid image store paths.
    # We remove the existing links first to avoid copying issues and clear any corrupted generations from previous image runs.
    if [ -d /home_skel/.local/state/nix/profiles ]; then
      rm -f /home/sandbox/.nix-profile
      rm -rf /home/sandbox/.local/state/nix/profiles
      mkdir -p /home/sandbox/.local/state/nix
      cp -af /home_skel/.nix-profile /home/sandbox/.nix-profile
      cp -af /home_skel/.local/state/nix/profiles /home/sandbox/.local/state/nix/profiles
      chown -h sandbox:sandbox /home/sandbox/.nix-profile
      chown -R sandbox:sandbox /home/sandbox/.local/state/nix/profiles
    fi

    # Ensure sandbox owns the home directory itself
    chown sandbox:sandbox /home/sandbox
  fi
}

$1 2>&1 | s6-log -bp n3 "p[init-home]" 1 /var/log/init-home
