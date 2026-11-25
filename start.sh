#!/command/with-contenv bash

set -euo pipefail

exec 2>&1

export HOME=/home/sandbox
export PATH=$HOME/.nix-profile/bin:$PATH

# Support additional custom groups
CUSTOMGROUPS="${SANDBOX_GIDS:-}"; CUSTOMGROUPS="${CUSTOMGROUPS//,/ }"
for gid in $CUSTOMGROUPS; do
  if ! getent group "${gid}" >/dev/null 2>&1; then
    groupadd -g "${gid}" "sandbox-${gid}"
  fi
  usermod -a -G "${gid}" sandbox
done

AGENT="${AGENT:-claude}"

case "$AGENT" in
  opencode)
    OPENCODE_ARGS="${OPENCODE_ARGS:---hostname 0.0.0.0 --port 8080}"
    exec s6-setuidgid sandbox /usr/local/bin/opencode serve $OPENCODE_ARGS
    ;;
  claude)
    CLAUDE_RC_ARGS="${CLAUDE_RC_ARGS:-}"
    exec s6-setuidgid sandbox claude rc $CLAUDE_RC_ARGS
    ;;
  *)
    echo "Unknown AGENT: $AGENT (valid: claude, opencode)"
    exit 1
    ;;
esac
