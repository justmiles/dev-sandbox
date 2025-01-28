[![Build Status](https://drone.justmiles.io/api/badges/justmiles/dev-sandbox/status.svg)](https://drone.justmiles.io/justmiles/dev-sandbox)

# justmiles dev sandbox

This repo contains common tools and plugins I use when developing remotely.

## Quickstart

Run a basic sandbox with the following

```bash
docker run \
  -p 8080:8080 \
  -v $PWD:/home/sandbox/workspaces \
  justmiles/dev-sandbox:latest
```

or with Tailscale

```
docker run --privileged \
  -e TS_AUTH_KEY="tskey-xxxxxxxxxxxxxxxxxxxxxxxxxxx" \
  -e TS_HOSTNAME="my-dev-sandbox" \
  -e TS_SSL_ENABLED=true \
  -e TS_DOMAIN_ALIAS="tailnet-xxxx.ts.net" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $PWD:/home/sandbox/workspaces \
  justmiles/dev-sandbox:latest
```

## Volumes

Consider mapping the following volumes for a generally better experience.

| Name                     | Description                     |
| ------------------------ | ------------------------------- |
| /home/sandbox/.ssh       | pass in your SSH credentials    |
| /home/sandbox/workspaces | working directory for IDE       |
| /var/run/docker.sock     | access to the docker daemon     |
| /dev/net/tun             | TUN/TAP for Tailscale & OpenVPN |

## Environment Variables

All environment variables are optional.

| Name             | Description                                                                                           | Default             |
| ---------------- | ----------------------------------------------------------------------------------------------------- | ------------------- |
| SANDBOX_UID      | set the sandbox user's user ID                                                                        | 1000                |
| SANDBOX_GID      | set the sandbox user's group ID                                                                       | 1000                |
| TS_AUTH_KEY      | tailscale authentication key. Enables tailscale                                                       |                     |
| TS_HOSTNAME      | tailscale hostname for this machine                                                                   |                     |
| TS_STATE_DIR     | absolute path of tailscale state file                                                                 | /var/lib/tailscaled |
| TS_ROUTES        | additional network routes for tailscale                                                               |                     |
| TS_USERSPACE     | true / false - whether or not to run tailscale in userspace                                           | true                |
| TS_EXTRA_ARGS    | additional arguments to the `tailscale up` command                                                    |                     |
| TS_SSL_ENABLED   | (required for TLS) serve code-server over HTTPS using tailscale certificates                          | false               |
| TS_DOMAIN_ALIAS  | (required for TLS) [tailscale domain alias](https://login.tailscale.com/admin/settings/features)      |                     |
| HISTFILE         | path to your persistant history file                                                                  |                     |
| S6\_\*           | [s6-rc configuration options](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour) |                     |
| ENTRYPOINT_HOOKS | path to directory of executables to be invoked before launching code-server                           |                     |
| CHEZMOI_REPO     | optional Chezmoi repo to init                                                                         |                     |

## Useful Snippits

Upgrade all the Nix installed packages

```bash
export NIXPKGS_ALLOW_UNFREE=1
nix-channel --update
nix-env -u '*'
```
