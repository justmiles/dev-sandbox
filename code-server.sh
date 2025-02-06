#!/command/with-contenv sh

set -e

exec 2>&1

CODE_SERVER_ARGS="$CODE_SERVER_ARGS"

if [ ! -z "${TS_DOMAIN_ALIAS}" ] && [ "${TS_SSL_ENABLED}" = "true" ]  ; then

  while ! tailscale ip -4; do
      echo "waiting for tailscale"
      sleep 10
  done

  IP=$(tailscale ip -4)
  HOST=$(tailscale status | grep $IP | awk '{print $2}')

  mkdir -p /home/sandbox/.local/share/code-server/ssl
  tailscale cert --cert-file /home/sandbox/.local/share/code-server/ssl/tailscale.crt --key-file /home/sandbox/.local/share/code-server/ssl/tailscale.key "${HOST}.${TS_DOMAIN_ALIAS}"
  setcap cap_net_bind_service=+ep /usr/local/code-server/lib/node

  CODE_SERVER_ARGS="$CODE_SERVER_ARGS --cert /home/sandbox/.local/share/code-server/ssl/tailscale.crt"
  CODE_SERVER_ARGS="$CODE_SERVER_ARGS --cert-key /home/sandbox/.local/share/code-server/ssl/tailscale.key"
  CODE_SERVER_ARGS="$CODE_SERVER_ARGS --bind-addr 0.0.0.0:443"

  chown -R sandbox:sandbox /home/sandbox/.local/share/code-server/ssl
fi

export HOME=/home/sandbox
export PATH=$HOME/.nix-profile/bin:$PATH

exec s6-setuidgid sandbox /usr/local/code-server/bin/code-server $CODE_SERVER_ARGS
