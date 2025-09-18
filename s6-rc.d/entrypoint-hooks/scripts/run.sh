#!/command/with-contenv bash

[ -z "${ENTRYPOINT_HOOKS}" ] && exit 0

# Set sanbox UID/GID
[ ! -z "${SANDBOX_UID}" ] && usermod -u $SANDBOX_UID sandbox
[ ! -z "${SANDBOX_GID}" ] && groupmod -g $SANDBOX_GID sandbox

export HOME=/home/sandbox

# Load entrypoint hooks, if set
find $ENTRYPOINT_HOOKS -type f -executable | while read f; do
  echo "ENTRYPOINT_HOOKS: $f: running"

  HOME=/home/sandbox s6-setuidgid sandbox $f
  
  if [ "$?" -gt "0" ]; then
    echo "ENTRYPOINT_HOOKS: $f: failed" && exit "$?"
  fi

  echo "ENTRYPOINT_HOOKS: $f: complete"
done
