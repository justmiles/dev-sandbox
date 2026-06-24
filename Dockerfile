
FROM ubuntu:jammy

ENV DEBIAN_FRONTEND=noninteractive

# Setup sandbox user
RUN useradd --shell /home/sandbox/.nix-profile/bin/zsh --create-home sandbox

# Install System Packages
RUN apt-get update \
  && apt-get install -y \
    docker.io \
    docker-buildx \
    gnupg \
    locales \
    lsb-release \
    xz-utils \
    curl wget \
    make \
    sudo \
    rsync \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
  && find /var/log -type f | xargs -I % truncate -s0 %
  
# Install Nix
RUN curl -fsSL https://nixos.org/nix/install -o /tmp/nix-install \
  && chmod 666 /tmp/nix-install \
  && groupadd nixbld \
  && usermod -a -G nixbld sandbox \
  && mkdir -m 0755 /nix && chown -R sandbox /nix

USER sandbox

RUN sh /tmp/nix-install --no-daemon

WORKDIR /home/sandbox

RUN export PATH=/home/sandbox/.nix-profile/bin:$PATH \
  && nix-env -iA \
  nixpkgs.busybox \
  nixpkgs.git \
  nixpkgs.git-lfs \
  nixpkgs.less \
  nixpkgs.ncdu \
  nixpkgs.nettools \
  nixpkgs.openssh \
  nixpkgs.procps \
  nixpkgs.tree \
  nixpkgs.chezmoi \
  nixpkgs.direnv \
  nixpkgs.docker-compose \
  nixpkgs.jq \
  nixpkgs.oh-my-zsh \
  nixpkgs.rclone \
  nixpkgs.tldr \
  nixpkgs.unzip \
  nixpkgs.unixtools.ping \
  nixpkgs.vim \
  nixpkgs.watchexec \
  nixpkgs.wget \
  nixpkgs.yq \
  nixpkgs.zsh \
 && nix-env --delete-generations old \
 && nix-store --gc

# Copy user dotfiles
COPY --chown=sandbox:sandbox dotfiles /home/sandbox

RUN ~/.nix-profile/bin/chezmoi --exclude scripts --source ~/.config/chezmoi-public --cache ~/.cache/chezmoi-public --refresh-externals init --depth 1 --apply https://github.com/justmiles/dotfiles.git

RUN mkdir -p ~/.ssh

USER root

RUN groupmod -g 997 docker \
  && echo 'sandbox ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sandbox \
  && usermod -a -G docker sandbox

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

# Pinned Versions - GitHub Releases
ENV GITHUB_RELEASE_CODER__CODE_SERVER=4.106.3
ENV GITHUB_RELEASE_JUST_CONTAINERS__S6_OVERLAY=3.2.1.0
# Install s6-overlay
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${GITHUB_RELEASE_JUST_CONTAINERS__S6_OVERLAY}/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${GITHUB_RELEASE_JUST_CONTAINERS__S6_OVERLAY}/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | apt-key add - \
  && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | tee /etc/apt/sources.list.d/tailscale.list \
  && apt-get update \
  && apt-get install -y tailscale

# Install https://github.com/coder/code-server
RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v${GITHUB_RELEASE_CODER__CODE_SERVER}/code-server-${GITHUB_RELEASE_CODER__CODE_SERVER}-linux-amd64.tar.gz | tar -xzf - -C /usr/local/code-server --strip-components=1

USER sandbox

USER root

# Copy s6-overlay configs
COPY s6-rc.d /etc/s6-overlay/s6-rc.d

# Copy code-server
COPY code-server.sh /usr/local/bin/code-server.sh

# Copy app icons
COPY media /usr/local/code-server/src/browser/media

# Set default environment variables
ENV S6_VERBOSITY=0
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME=300000
ENV PATH=$PATH:/home/sandbox/bin

# Copy the built home directory to a skeleton directory
RUN mkdir -p /home_skel && cp -a /home/sandbox/. /home_skel/ && chown -R sandbox:sandbox /home_skel

EXPOSE 8080
WORKDIR /home/sandbox
ENTRYPOINT ["/init"]
CMD ["/usr/local/bin/code-server.sh"]
