[![Build Status](https://drone.justmiles.io/api/badges/justmiles/dev-sandbox/status.svg)](https://drone.justmiles.io/justmiles/dev-sandbox)

# justmiles dev sandbox

This repo contains common tools and plugins I use when developing remotely.

## Usage

Quickstart:

```bash
docker run --privileged \
  -e TS_AUTH_KEY \
  -e TS_EXTRA_ARGS \
  -e TS_HOSTNAME \
  -v /dev/net/tun:/dev/net/tun \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -p 8080:8080 \
  -v $PWD:/home/sandbox/workspaces \
  justmiles/dev-sandbox:latest

```

## Volumes

When running as a service, consider mapping the following volumes for a generally better experience:

- /home/sandbox/.ssh - SSH auth
- /home/sandbox/workspaces - persistent workspaces
- /var/run/docker.sock - access to the docker daemon
- /dev/net/tun - TUN/TAP for Tailscale & OpenVPN

## Environment Variables

| Name          | Description                                        |
| ------------- | -------------------------------------------------- |
| TS_AUTH_KEY   | Tailscale authentication key                       |
| TS_HOSTNAME   | Tailscale hostname for this machine                |
| TS_EXTRA_ARGS | Additional arguments to the `tailscale up` command |
| HISTFILE      | path to your persistant history file               |

## Daemons

This project uses an s6-overlay to manage backend daemons.

| Name          | Description                              |
| ------------- | ---------------------------------------- |
| code-server   | The main IDE                             |
| tailscald     | Tailscale daemon for mesh VPN            |
| TODO: OpenVPN | Client VPN to access privileged networks |
