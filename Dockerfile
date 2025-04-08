FROM ubuntu:jammy AS stoken

RUN apt-get update && apt-get install -y \
    libgtk-3-dev \
    libtomcrypt-dev \
    libxml2-dev \
    autoconf \
    automake \
    libtool \
    build-essential \
    git \
    && mkdir -p /tmp/build \
    && git clone https://github.com/stoken-dev/stoken /tmp/stoken \
    && cd /tmp/stoken \
  && ./autogen.sh \
  && ./configure --prefix=/tmp/build \
  && make \
  && make check \
    && make install \
    && apt-get clean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/apt/lists/* /tmp/stoken

FROM ubuntu:jammy

# Pinned Versions - GitHub Releases
ENV GITHUB_RELEASE_CODER__CODE_SERVER=4.99.0
ENV GITHUB_RELEASE_JUST_CONTAINERS__S6_OVERLAY=3.1.0.1
ENV GITHUB_RELEASE_JUSTMILES__GO_GET_SSM_PARAMS=1.8.0
ENV GITHUB_RELEASE_JUSTMILES__SSM_PARAMETER_STORE=0.0.7
ENV GITHUB_RELEASE_JUSTMILES__ECS_DEPLOY=0.5.0
ENV GITHUB_RELEASE_JUSTMILES__ATHENA_CLI=0.1.10
ENV GITHUB_RELEASE_JUSTMILES__ECS_CLI=0.5.4
ENV GITHUB_RELEASE_JUSTMILES__JUMPCLOUD_CLI=0.0.5
ENV GITHUB_RELEASE_DDWORKEN__HISHTORY=0.251
ENV GITHUB_RELEASE_SIGODEN__AICHAT=0.26.0

ENV DEBIAN_FRONTEND=noninteractive

# Install Apt Packages
RUN apt-get update \
  && apt-get install -y \
    busybox \
    curl \
    dnsutils \
    docker.io \
    docker-buildx \
    g++ \
    git \
    git-lfs \
    gnupg \
    iputils-ping \
    less \
    locales \
    lsb-release \
    libsecret-1-dev \
    make \
    man \
    ncdu \
    net-tools \
    netcat \
    nmap \
    openssh-client \
    procps \
    rng-tools \
    sudo \
    traceroute \
    tree \
    vim \
    wget \
  && apt-get install -y libnss3-dev libatk1.0-0 libatk-bridge2.0-dev libcups2-dev libxkbcommon-dev libxcomposite-dev libxdamage-dev libxrandr-dev libgbm-dev libpango-1.0-0 libcairo2-dev libasound2-dev \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

COPY --from=stoken /tmp/build/lib /lib
COPY --from=stoken /tmp/build/bin /bin
COPY --from=stoken /tmp/build/share /share

# Configure Docker
RUN groupmod -g 997 docker

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

# Install s6-overlay
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${GITHUB_RELEASE_JUST_CONTAINERS_S6_OVERLAY}/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${GITHUB_RELEASE_JUST_CONTAINERS_S6_OVERLAY}/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add - \
     && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
     && apt-get update \
     && apt-get install -y tailscale

# Install https://github.com/justmiles/go-get-ssm-params
RUN curl -sfLo - https://github.com/justmiles/go-get-ssm-params/releases/download/v${GITHUB_RELEASE_JUSTMILES_GO_GET_SSM_PARAMS}/get-ssm-params_${GITHUB_RELEASE_JUSTMILES_GO_GET_SSM_PARAMS}_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin get-ssm-params \
  && chmod +x /usr/local/bin/get-ssm-params

# Install https://github.com/justmiles/ssm-parameter-store
RUN curl -sfLo - https://github.com/justmiles/ssm-parameter-store/releases/download/v${GITHUB_RELEASE_JUSTMILES_SSM_PARAMETER_STORE}/ssm-parameter-store_${GITHUB_RELEASE_JUSTMILES_SSM_PARAMETER_STORE}_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ssm-parameter-store

# Install https://github.com/justmiles/ecs-deploy
RUN curl -sfLo - https://github.com/justmiles/ecs-deploy/releases/download/v${GITHUB_RELEASE_JUSTMILES_ECS_DEPLOY}/ecs-deploy_${GITHUB_RELEASE_JUSTMILES_ECS_DEPLOY}_Linux_arm64.tar.gz | tar -xzf - -C /usr/local/bin ecs-deploy

# Install https://github.com/justmiles/athena-cli
RUN curl -sfLo - https://github.com/justmiles/athena-cli/releases/download/v${GITHUB_RELEASE_JUSTMILES_ATHENA_CLI}/athena-cli_${GITHUB_RELEASE_JUSTMILES_ATHENA_CLI}_linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin athena

# Install https://github.com/justmiles/ecs-cli
RUN curl -sfLo - https://github.com/justmiles/ecs-cli/releases/download/v${GITHUB_RELEASE_JUSTMILES_ECS_CLI}/ecs_${GITHUB_RELEASE_JUSTMILES_ECS_CLI}_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ecs

# Install https://github.com/justmiles/jumpcloud-cli
RUN curl -sfLo - https://github.com/justmiles/jumpcloud-cli/releases/download/v${GITHUB_RELEASE_JUSTMILES_JUMPCLOUD_CLI}/jumpcloud-cli_${GITHUB_RELEASE_JUSTMILES_JUMPCLOUD_CLI}_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin jc

# Install https://github.com/coder/code-server
RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v${GITHUB_RELEASE_CODER_CODE_SERVER}/code-server-${GITHUB_RELEASE_CODER_CODE_SERVER}-linux-amd64.tar.gz | tar -xzf - -C /usr/local/code-server --strip-components=1

# Install https://github.com/ddworken/hishtory
RUN curl -sfLo /usr/local/bin/hishtory https://github.com/ddworken/hishtory/releases/download/v${GITHUB_RELEASE_DDWORKEN_HISHTORY}/hishtory-linux-amd64 && chmod +x /usr/local/bin/hishtory

# Install https://github.com/sigoden/aichat
RUN curl -sfLo - https://github.com/sigoden/aichat/releases/download/v${GITHUB_RELEASE_SIGODEN_AICHAT}/aichat-v${GITHUB_RELEASE_SIGODEN_AICHAT}-x86_64-unknown-linux-musl.tar.gz | tar -xzf - -C /usr/local/bin aichat

# Setup sandbox user
RUN useradd --shell /home/sandbox/.nix-profile/bin/zsh --create-home sandbox \
  && echo 'sandbox ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sandbox \
  && usermod -a -G docker sandbox

# Install Nix
ADD https://nixos.org/nix/install /tmp/nix-install
RUN chmod 666 /tmp/nix-install
RUN groupadd nixbld
RUN usermod -a -G nixbld sandbox
RUN mkdir -m 0755 /nix && chown -R sandbox /nix

# cleanup
RUN find /var/log -type f | sudo xargs -I % truncate -s0 %

# Copy code-server
COPY code-server.sh /usr/local/bin/code-server.sh

USER sandbox

RUN sh /tmp/nix-install --no-daemon

WORKDIR /home/sandbox

RUN export PATH=$HOME/.nix-profile/bin:$PATH \
  && NIXPKGS_ALLOW_UNFREE=1 nix-env -iA \
  nixpkgs.awscli2 \
  nixpkgs.chezmoi \
  nixpkgs.csvq \
  nixpkgs.direnv \
  nixpkgs.docker-compose \
  nixpkgs.drone-cli \
  nixpkgs.dstask \
  nixpkgs.gdlv \
  nixpkgs.gh \
  nixpkgs.go \
  nixpkgs.golangci-lint \
  nixpkgs.gopass \
  nixpkgs.gopass \
  nixpkgs.gopls \
  nixpkgs.grex \
  nixpkgs.gron \
  nixpkgs.hclfmt \
  nixpkgs.jq \
  nixpkgs.nomad \
  nixpkgs.oh-my-zsh \
  nixpkgs.ollama \
  nixpkgs.packer \
  nixpkgs.pipx \
  nixpkgs.pre-commit \
  nixpkgs.pwgen \
  nixpkgs.python3 \
  nixpkgs.python311Packages.pip \
  nixpkgs.ran \
  nixpkgs.rclone \
  nixpkgs.rconc \
  nixpkgs.restic \
  nixpkgs.rsync \
  nixpkgs.ssm-session-manager-plugin \
  nixpkgs.terraform-docs \
  nixpkgs.textql \
  nixpkgs.tfswitch \
  nixpkgs.tldr \
  nixpkgs.unzip \
  nixpkgs.watchexec \
  nixpkgs.whois \
  nixpkgs.yq \
  nixpkgs.zsh \
 && go install github.com/justmiles/git-bump@latest \
 && go install github.com/go-jira/jira/cmd/jira@latest \
 && go install github.com/appleboy/CodeGPT/cmd/codegpt@latest \
 && go install github.com/ichinaski/pxl@latest \
 && pipx install shell-gpt \
 && nix-env --delete-generations old \
 && nix-store --gc

# Copy user dotfiles
COPY --chown=sandbox:sandbox dotfiles /home/sandbox

RUN $HOME/.nix-profile/bin/chezmoi --exclude scripts --source ~/.config/chezmoi-public --cache ~/.cache/chezmoi-public --refresh-externals init --apply https://github.com/justmiles/dotfiles.git

# Install VS Code Extensions
RUN for item in \
      # AI
      RooVeterinaryInc.roo-cline \
      # Golang
      golang.go \
      # Terraform
      hashicorp.terraform \
      hashicorp.hcl \
      # Python
      ms-python.python \
      # Java
      redhat.java \
      gabrielbb.vscode-lombok \
      # Generic language parsers / prettifiers
      esbenp.prettier-vscode \
      redhat.vscode-yaml \
      jkillian.custom-local-formatters \
      # Generic tools
      johnpapa.vscode-peacock \
      jebbs.plantuml \
      # Install snazzy themes
      pkief.material-icon-theme \
      zhuangtongfa.Material-theme \
      mtxr.sqltools \
      mtxr.sqltools-driver-pg \
    ; do /usr/local/code-server/bin/code-server --force --install-extension $item; done

RUN mkdir -p ~/.ssh ~/.hishtory && hishtory completion zsh > ~/.hishtory/config.zsh

EXPOSE 8080

WORKDIR /home/sandbox

USER root

# Copy s6-overlay configs
COPY s6-rc.d /etc/s6-overlay/s6-rc.d

# Set default environment variables
ENV S6_VERBOSITY 0
ENV S6_CMD_WAIT_FOR_SERVICES_MAXTIME 0
ENV PATH=$PATH:$HOME/bin
ENTRYPOINT ["/init"]

COPY media /usr/local/code-server/src/browser/media
CMD ["/usr/local/bin/code-server.sh"]
