#!/command/with-contenv bash

set -euo pipefail

exec 2>&1

OPENCODE_ARGS="${OPENCODE_ARGS:---hostname 0.0.0.0 --port 8080}"

export HOME=/home/sandbox
export PATH=$HOME/.nix-profile/bin:$PATH

# Support additional custom groups
CUSTOMGROUPS="${SANDBOX_GIDS:-}" ; CUSTOMGROUPS="${CUSTOMGROUPS//,/ }"

for gid in $CUSTOMGROUPS; do
  # Create group if it does not exist yet
  if ! getent group "${gid}" >/dev/null 2>&1; then
    groupadd -g "${gid}" "sandbox-${gid}"
  fi

  usermod -a -G "${gid}" sandbox
done

exec s6-setuidgid sandbox /usr/local/bin/opencode serve $OPENCODE_ARGS
