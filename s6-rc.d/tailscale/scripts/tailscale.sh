#!/command/with-contenv sh

[ ! -z "${TS_AUTH_KEY}" ]   && UP_ARGS="--authkey=${TS_AUTH_KEY} ${UP_ARGS}"
[ ! -z "${TS_HOSTNAME}" ]   && UP_ARGS="--hostname=${TS_HOSTNAME} ${UP_ARGS}"
[ ! -z "${TS_EXTRA_ARGS}" ] && UP_ARGS="${UP_ARGS} ${TS_EXTRA_ARGS}"

tailscale --socket=/tmp/tailscaled.sock up ${UP_ARGS}
