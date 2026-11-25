# agent-harness

An agent harness: a containerized sandbox that runs the [OpenCode](https://github.com/sst/opencode) coding agent as a long-lived server, preloaded with the tools and Nix environment I use for development.

## Quickstart

```bash
docker run \
  -p 8080:8080 \
  -v agent-harness-home:/home/sandbox \
  registry.chuckhires.net/agent-harness:latest
```

OpenCode serves its API on `0.0.0.0:8080`. Connect to it with the OpenCode TUI, editor extension, or any OpenCode client pointed at the exposed port.

To get an interactive shell instead of the agent server:

```bash
docker run --rm -it --entrypoint bash registry.chuckhires.net/agent-harness:latest
```

## Volumes

Consider mapping the following volumes for a generally better experience.

| Name                 | Description                                                                    |
| -------------------- | ------------------------------------------------------------------------------ |
| /home/sandbox        | Persist the entire home directory (dotfiles, nix profiles, SSH, history, etc.) |
| /var/run/docker.sock | access to the docker daemon                                                    |

## Environment Variables

All environment variables are optional.

| Name          | Description                                                                                           | Default                          |
| ------------- | ----------------------------------------------------------------------------------------------------- | -------------------------------- |
| SANDBOX_UID   | set the sandbox user's user ID                                                                        | 1000                             |
| SANDBOX_GID   | set the sandbox user's group ID                                                                       | 1000                             |
| SANDBOX_GIDS  | add additional group IDs to the sandbox user                                                          |                                  |
| OPENCODE_ARGS | arguments passed to `opencode serve`                                                                  | `--hostname 0.0.0.0 --port 8080` |
| S6\_\*        | [s6-rc configuration options](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour) |                                  |

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
