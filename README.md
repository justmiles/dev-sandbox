[![Build Status](https://drone.justmiles.io/api/badges/justmiles/dev-sandbox/status.svg)](https://drone.justmiles.io/justmiles/dev-sandbox)

# justmiles dev sandbox

This repo contains common tools and plugins I use when developing remotely.

## Usage

Quickstart:

```bash
docker run -p 8080:8080 -v $PWD:/home/sandbox/workspaces justmiles/dev-sandbox:latest
```

When running as a service, consider mapping the following volumes for a generally better experience:

- /home/sandbox/.ssh - SSH auth
- /home/sandbox/workspaces - persistent workspaces
- /var/run/docker.sock - access to the docker daemon

## Environment Variables

- HISTFILE - path to your persistant history file
- ENTRYPOINT_HOOKS - custom startup scripts
