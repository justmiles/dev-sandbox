#!/command/with-contenv sh

# only start tailscale if it's enabled
[ -z "${TS_AUTH_KEY}" ] && exit 0

[ ! -z "${TS_AUTH_KEY}" ]   && UP_ARGS="--authkey=${TS_AUTH_KEY} ${UP_ARGS}"
[ ! -z "${TS_HOSTNAME}" ]   && UP_ARGS="--hostname=${TS_HOSTNAME} ${UP_ARGS}"
[ ! -z "${TS_EXTRA_ARGS}" ] && UP_ARGS="${UP_ARGS} ${TS_EXTRA_ARGS}"

tailscale up ${UP_ARGS}
