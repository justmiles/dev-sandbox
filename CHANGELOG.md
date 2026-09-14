# Changelog

All notable changes to this project will be documented in this file. See [standard-version](https://github.com/conventional-changelog/standard-version) for commit guidelines.

## [Unreleased]


## [0.1.8] - 2025-12-01

### Added

- Nix-env extension
- Hishtory hook scripts that run after mounting the .hishtory volume
- Semantic versioning with semantic-release

### Changed

- Updated Node.js to v24
- Updated code-server to v4.105.1
- Updated aichat to v0.30.0

### Removed

- Hishtory file sourcing from .zshrc

### Fixed

- Entrypoint hook
- Hishtory zsh hook

## [0.1.2] - 2025-04-21

_No user-facing changes were detected in the commits for this release._


## [0.1.1] - 2025-04-14

_No user-facing changes were detected in the commits for this release._


## [0.1.0] - 2025-04-13

### Added

- Semantic versioning with semantic-release for automated version management

### Changed

- Docker build now properly uses GITHUB_RELEASE tags


## [0.0.17] - 2025-04-08

_No user-facing changes were detected in the commits for this release._


## [0.0.16] - 2025-04-08

### Added

- Roo dependencies


## [0.0.15] - 2025-04-07

### Changed

- Upgraded code-server to latest version


## [0.0.14] - 2025-04-01

### Added

- New media files and icons for website and PWA


## [0.0.13] - 2025-02-27

### Added

- Support for stoken and podman in Docker image
- tldr tool in Docker image
- Continue.continue extension for development tooling

### Changed

- Updated Dockerfile and README with stoken and podman support
- Upgraded ecs-cli to v0.5.4
- Refactored Docker image packages

### Removed

- rjmacarthy.twinny extension


## [0.0.12] - 2024-05-17

### Added

- Dockerfile extensions for code-editor enhancements


## [0.0.11] - 2024-02-02

### Changed

- Upgraded code-server to latest release


## [0.0.10] - 2024-01-14

### Added

- Added pxl tool to the development sandbox
- Added rconc tool to the development sandbox
- Enabled unfree Nix packages support

### Changed

- Updated Dockerfile and .zshrc for hishtory integration
- Configured hishtory to install in offline mode


## [0.0.9] - 2023-11-16

### Added

- Added nixpkgs-fmt for Nix package formatting
- Added sgpt tool support

### Changed

- Updated VSCode settings


## [0.0.8] - 2023-09-01

### Added

- Session manager plugin support
- Renovate configuration for automated dependency updates

### Changed

- Enhanced extensions collection

### Fixed

- Fixed chezmoi to include nix in path


## [0.0.7] - 2023-02-06

### Added

- Add gotop for system monitoring
- Add ctop for container monitoring

### Changed

- Upgrade Nomad to latest version


## [0.0.6] - 2023-01-11

### Added

- Dev tools included in sandbox environment
- Chezmoi tool added for dotfile management

### Removed

- Verbose logging for go install

### Fixed

- Chezmoi configuration


## [0.0.5] - 2022-07-07

### Added

- Support for custom sandbox UID/GID


## [0.0.4] - 2022-07-07

### Added

- Support for Tailscale HTTPS connections
- Support for Tailscale routes
- Optional Tailscale disable configuration

### Changed

- Code-server now runs as the default container command


## [0.0.3] - 2022-07-01

### Added

- Added .local/bin to PATH for custom binaries
- Added PlantUML for diagram generation
- Added Tailscale for secure networking
- Added support for entrypoint hooks using s6-overlay

### Changed

- Upgraded Go to version 1.18
- Upgraded code-server to v4.4.0
- Reorganized configuration structure


## [0.0.2] - 2022-05-05

### Added

- Add git-bump tool for automated version management


## [0.0.1] - 2022-04-27

### Added

- yq
- go-enum
- lombok extension for java
- java
- drone-cli
- nvm
- python pip
- tfswitch
- custom entrypoints support
- docker support
- code-server with Go, Terraform, and AWS CLI v2 environments

### Changed

- Upgraded to Ubuntu Focal
- Upgraded Go to version 1.7
- Upgraded code-server to 4.2.0
- Updated PATH to include ~/bin
- Switched build to Docker plugin
- Switched to Docker-in-Docker
- Set Docker API version configuration
- Added Docker layer caching
- Reorganized Dockerfile and added nvm
- Merged shell-sandbox tools

### Removed

- Unused extensions

### Fixed

- Terraform formatter

