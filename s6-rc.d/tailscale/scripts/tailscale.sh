#!/command/with-contenv sh

# only start tailscale if it's enabled
[ -z "${TS_AUTH_KEY}" ] && exit 0

[ "${TS_ACCEPT_ROUTES}" = "true" ]  && ARGS="--accept-routes ${ARGS}"
[ ! -z "${TS_AUTH_KEY}" ]           && ARGS="--authkey=${TS_AUTH_KEY} ${ARGS}"
[ ! -z "${TS_HOSTNAME}" ]           && ARGS="--hostname=${TS_HOSTNAME} ${ARGS}"
[ ! -z "${TS_ROUTES}" ]             && ARGS="--advertise-routes=${TS_ROUTES} ${ARGS}"
[ ! -z "${TS_EXTRA_ARGS}" ]         && ARGS="${TS_EXTRA_ARGS} ${ARGS}"

tailscale up ${ARGS}
