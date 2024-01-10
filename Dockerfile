FROM ubuntu:jammy

# Pinned Versions
ENV CODE_SERVER_RELEASE=4.16.1
ENV S6_OVERLAY_RELEASE=3.1.0.1

ENV DEBIAN_FRONTEND=noninteractive

# Install Apt Packages
RUN apt-get update \
  && apt-get install -y \
    busybox \
    curl \
    dnsutils \
    docker.io \
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
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Configure Docker
RUN groupmod -g 997 docker

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

# Install s6-overlay
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_RELEASE}/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_RELEASE}/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add - \
     && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
     && apt-get update \
     && apt-get install -y tailscale

# Install https://github.com/justmiles/go-get-ssm-params
RUN curl -sfLo - https://github.com/justmiles/go-get-ssm-params/releases/download/v1.8.0/get-ssm-params_1.8.0_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin get-ssm-params \
  && chmod +x /usr/local/bin/get-ssm-params

# Install https://github.com/justmiles/ssm-parameter-store
RUN curl -sfLo - https://github.com/justmiles/ssm-parameter-store/releases/download/v0.0.7/ssm-parameter-store_0.0.7_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ssm-parameter-store

# Install https://github.com/justmiles/ecs-deploy
RUN curl -sfLo - https://github.com/justmiles/ecs-deploy/releases/download/v0.5.0/ecs-deploy_0.5.0_Linux_arm64.tar.gz | tar -xzf - -C /usr/local/bin ecs-deploy

# Install https://github.com/justmiles/athena-cli
RUN curl -sfLo - https://github.com/justmiles/athena-cli/releases/download/v0.1.10/athena-cli_0.1.10_linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin athena

# Install https://github.com/justmiles/ecs-cli
RUN curl -sfLo - https://github.com/justmiles/ecs-cli/releases/download/v0.3.2/ecs_0.3.2_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ecs

# Install https://github.com/justmiles/jumpcloud-cli
RUN curl -sfLo - https://github.com/justmiles/jumpcloud-cli/releases/download/v0.0.5/jumpcloud-cli_0.0.5_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin jc

# Install https://github.com/coder/code-server
RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v${CODE_SERVER_RELEASE}/code-server-${CODE_SERVER_RELEASE}-linux-amd64.tar.gz | tar -xzf - -C /usr/local/code-server --strip-components=1

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

# Install https://github.com/ddworken/hishtory
RUN curl -sfLo hishtory https://github.com/ddworken/hishtory/releases/download/v0.251/hishtory-linux-amd64 && chmod +x hishtory && ./hishtory install --offline

RUN sh /tmp/nix-install --no-daemon

WORKDIR /home/sandbox

RUN export PATH=$HOME/.nix-profile/bin:$PATH \
  && nix-env -i \
  ran \
  rsync \
  unzip \
  zsh \
  jq \
  chezmoi \
  taskwarrior \
  gopass \
  direnv \
  awscli2 \
  ssm-session-manager-plugin \
  csvq \
  grex \
  gron \
  watchexec \
  whois \
  yq \
  restic \
  go \
  pipx \
  pwgen \
  textql-unstable \
  hclfmt \
  gopls \
  golangci-lint \
  gdlv \
  terraform-docs \
  packer \
  gopass \
  rclone \
  drone-cli \
  nomad \
  pre-commit \
  tfswitch \
  python3 pipx \
  oh-my-zsh \
&& nix-env -iA nixpkgs.python311Packages.pip \
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
# TODO: Figure out how to support the tabnine.tabnine-vscode extension
RUN for item in \
      # Golang
      golang.go \
      # Terrafomr
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
      eamodio.gitlens \
      jebbs.plantuml \
      # Install snazzy themes
      pkief.material-icon-theme \
      zhuangtongfa.Material-theme \
      mtxr.sqltools \
      mtxr.sqltools-driver-pg \
      nixpkgs-fmt \
    ; do /usr/local/code-server/bin/code-server --force --install-extension $item; done

RUN mkdir -p ~/.ssh

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

CMD ["/usr/local/bin/code-server.sh"]
