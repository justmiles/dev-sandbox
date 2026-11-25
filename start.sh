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
    s6-setuidgid sandbox claude rc $CLAUDE_RC_ARGS || {
      echo ""
      echo "================================================================"
      echo "  Claude Remote Control exited. Authentication may be required."
      echo ""
      echo "  To authenticate, run:"
      echo "    docker exec -it <container> s6-setuidgid sandbox claude auth login"
      echo ""
      echo "  Waiting 5 minutes before exiting to allow time to log in..."
      echo "================================================================"
      sleep 300
      exit 1
    }
    ;;
  *)
    echo "Unknown AGENT: $AGENT (valid: claude, opencode)"
    exit 1
    ;;
esac
