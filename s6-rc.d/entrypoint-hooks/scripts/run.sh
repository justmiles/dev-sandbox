#!/command/with-contenv bash

# Load entrypoint hooks, if set
[ ! -z "${ENTRYPOINT_HOOKS}" ] && find $ENTRYPOINT_HOOKS -type f -executable | while read f; do
  echo "ENTRYPOINT_HOOKS: $f: running"

  exec s6-setuidgid sandbox $f
  
  if [ "$?" -gt "0" ]; then
    echo "ENTRYPOINT_HOOKS: $f: failed" && exit "$?"
  fi

  echo "ENTRYPOINT_HOOKS: $f: complete"
done
