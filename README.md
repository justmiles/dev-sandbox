[![Build Status](https://drone.justmiles.io/api/badges/justmiles/dev-sandbox/status.svg)](https://drone.justmiles.io/justmiles/dev-sandbox)

# justmiles dev sandbox

This repo contains common tools and plugins I use when developing remotely.

## Quickstart

Run a basic sandbox with the following

```bash
docker run \
  -p 8080:8080 \
  -v dev-sandbox-home:/home/sandbox \
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
  -v dev-sandbox-home:/home/sandbox \
  -v tailscale-state:/var/lib/tailscale \
  justmiles/dev-sandbox:latest
```

## Volumes

Consider mapping the following volumes for a generally better experience.

| Name                 | Description                                                                    |
| -------------------- | ------------------------------------------------------------------------------ |
| /home/sandbox        | Persist the entire home directory (dotfiles, nix profiles, SSH, history, etc.) |
| /var/lib/tailscale   | Persist Tailscale state so the node keeps the same identity across restarts    |
| /var/run/docker.sock | access to the docker daemon                                                    |
| /dev/net/tun         | TUN/TAP for Tailscale                                                          |

## Environment Variables

All environment variables are optional.

| Name             | Description                                                                                           | Default             |
| ---------------- | ----------------------------------------------------------------------------------------------------- | ------------------- |
| SANDBOX_UID      | set the sandbox user's user ID                                                                        | 1000                |
| SANDBOX_GID      | set the sandbox user's group ID                                                                       | 1000                |
| SANDBOX_GIDS     | add additional group IDs to the sandbox user                                                          |                     |
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

## Entrypoint Hooks

If you need to run custom initialization scripts on container start (for example, configuring shell aliases or starting daemons), you can configure entrypoint hooks:

1. Set the `ENTRYPOINT_HOOKS` environment variable to a directory path inside the container (e.g. `-e ENTRYPOINT_HOOKS=/home/sandbox/hooks`).
2. Mount or copy your scripts into that directory.
3. Every executable script in that folder will run in alphabetical order as the non-root `sandbox` user before `code-server` starts.
4. Each script has a execution timeout defined by `ENTRYPOINT_HOOK_TIMEOUT` (default: 120 seconds). If a script fails or times out, the container will fail to start.

## Custom Nix Packages (`package.nix`)

A template `package.nix` file is automatically copied to `/home/sandbox/package.nix` on initial container startup if none exists. You can use this file to declaratively define packages that should always be installed and active in your container environment:

1. Open `/home/sandbox/package.nix` and add package attributes to the `paths` array. For example:
   ```nix
   with import <nixpkgs> {};
   buildEnv {
     name = "user-packages";
     paths = [
       htop
       ripgrep
     ];
   }
   ```
2. The `nix-packages` service evaluates this file on container start and automatically updates your user profile environment.

## Useful Snippits

Upgrade all the Nix installed packages

```bash
export NIXPKGS_ALLOW_UNFREE=1
nix-channel --update
nix-env -u '*'
```

Build this ship with podman:

uidmap
