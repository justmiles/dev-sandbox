FROM ubuntu:focal

ENV CODE_SERVER_RELEASE=4.4.0
ENV DEBIAN_FRONTEND=noninteractive

# Install Apt Packages
RUN apt-get update \
  && apt-get install -y \
    busybox \
    curl \
    direnv \
    dnsutils \
    docker.io \
    g++ \
    git \
    git-lfs \
    htop \
    iputils-ping \
    less \
    locales \
    lsb-release \
    make \
    man \
    ncdu \
    netcat \
    net-tools \
    nmap \
    openssh-client \
    procps \
    python3-pip \
    rsync \
    sudo \
    traceroute \
    tree \
    unzip \
    vim \
    wget \
    zsh \
  && apt-get clean autoclean \
  && apt-get autoremove --yes \
  && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Configure Docker
RUN groupmod -g 999 docker

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

# Install s6-overlay
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-noarch.tar.xz | tar -Jxpf - -C /
RUN curl -sfLo - https://github.com/just-containers/s6-overlay/releases/download/v3.1.0.1/s6-overlay-x86_64.tar.xz | tar -Jxpf - -C /

# Install tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.gpg | sudo apt-key add - \
     && curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
     && apt-get update \
     && apt-get install -y tailscale

# Setup python
RUN sudo ln -s /usr/bin/python3 /usr/bin/python \
  && echo 'export PATH=$PATH:$HOME/.local/bin' > /etc/profile.d/python.sh

# Install https://github.com/aws/aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
  && unzip awscliv2.zip \
  && sudo ./aws/install --update \
  && rm -rf aws awscliv2.zip

# Install https://github.com/stedolan/jq
RUN curl -sfLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
  && chmod +x /usr/local/bin/jq

# Install https://github.com/justmiles/go-get-ssm-params
RUN curl -sfLo /usr/local/bin/get-ssm-params https://github.com/justmiles/go-get-ssm-params/releases/download/v1.7.0/get-ssm-params.v1.7.0.linux-amd64 \
  && chmod +x /usr/local/bin/get-ssm-params

# Install https://github.com/justmiles/ssm-parameter-store
RUN curl -sfLo - https://github.com/justmiles/ssm-parameter-store/releases/download/v0.0.6/ssm-parameter-store_0.0.6_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ssm-parameter-store

# Install https://github.com/justmiles/ecs-deploy
RUN curl -sfLo - https://github.com/justmiles/ecs-deploy/releases/download/v0.2.5/ecs-deploy_0.2.5_Linux_arm64.tar.gz | tar -xzf - -C /usr/local/bin ecs-deploy

# Install https://github.com/justmiles/athena-cli
RUN curl -sfLo - https://github.com/justmiles/athena-cli/releases/download/v0.1.8/athena-cli_0.1.8_linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin athena

# Install https://github.com/justmiles/ecs-cli
RUN curl -sfLo - https://github.com/justmiles/ecs-cli/releases/download/v0.0.20/ecs_0.0.20_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin ecs

# Install https://github.com/justmiles/jumpcloud-cli
RUN curl -sfLo - https://github.com/justmiles/jumpcloud-cli/releases/download/v0.0.2/jumpcloud-cli_0.0.2_Linux_x86_64.tar.gz | tar -xzf - -C /usr/local/bin jc

# Install https://github.com/mithrandie/csvq
RUN curl -sfLo - https://github.com/mithrandie/csvq/releases/download/v1.15.2/csvq-v1.15.2-linux-amd64.tar.gz | tar -xzf - -C /usr/local/bin --strip-components=1 csvq-v1.15.2-linux-amd64/csvq

# Install https://github.com/pemistahl/grex
RUN curl -sfLo - https://github.com/pemistahl/grex/releases/download/v1.3.0/grex-v1.3.0-x86_64-unknown-linux-musl.tar.gz | tar -xzf - -C /usr/local/bin grex

# Install https://github.com/tomnomnom/gron
RUN curl -sfLo - https://github.com/tomnomnom/gron/releases/download/v0.6.1/gron-linux-amd64-0.6.1.tgz | tar -xzf - -C /usr/local/bin

# Install https://github.com/likexian/whois
RUN curl -sfLo - https://github.com/likexian/whois/releases/download/v1.12.1/whois-linux-amd64.zip | busybox unzip -qd /usr/local/bin/ - \
  && chmod +x /usr/local/bin/whois

# Install https://github.com/mikefarah/yq
RUN curl -sfLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.24.5/yq_linux_amd64 \
  && chmod +x /usr/local/bin/yq

# Install https://github.com/restic/restic
RUN curl -sfLo - https://github.com/restic/restic/releases/download/v0.12.1/restic_0.12.1_linux_amd64.bz2 | bzip2 -d -qc > /usr/local/bin/restic \
  && chmod +x /usr/local/bin/restic

# Install golang
RUN curl -sLo - https://go.dev/dl/go1.18.3.linux-amd64.tar.gz | tar -xzf - -C /usr/local \
  && echo 'export PATH=$PATH:/usr/local/go/bin:/root/go/bin:$HOME/go/bin' > /etc/profile.d/go.sh

# Install https://github.com/lpar/kpwgen
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install github.com/lpar/kpwgen@latest

# Install https://github.com/dinedal/textql
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install github.com/dinedal/textql/...@latest

# Install hclfmt
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install github.com/hashicorp/hcl/v2/cmd/hclfmt@latest

# Install git bump
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install -v github.com/justmiles/git-bump@latest

# Install gopls
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install -v golang.org/x/tools/gopls@latest

# Install golangci-lint
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install -v github.com/golangci/golangci-lint/cmd/golangci-lint@v1.46.1

# Install dlv
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install -v github.com/go-delve/delve/cmd/dlv@latest

# Install github.com/abice/go-enum
RUN GOBIN=/usr/local/bin/ /usr/local/go/bin/go install -v github.com/abice/go-enum@latest

# Install https://github.com/rclone/rclone
RUN curl -sfO https://downloads.rclone.org/rclone-current-linux-amd64.deb \
  && sudo dpkg -i rclone-current-linux-amd64.deb \
  && rm -rf rclone-current-linux-amd64.deb

# Install Nomad
RUN curl -sfLo - https://releases.hashicorp.com/nomad/1.2.3/nomad_1.2.3_linux_amd64.zip | busybox unzip -qd /usr/local/bin - \
 && chmod +x /usr/local/bin/nomad

# TODO: install https://github.com/terraform-docs/terraform-docs
# TODO: install pip install pre-commit

# Install https://github.com/warrensbox/terraform-switcher
RUN curl -sfLo - https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh | bash /dev/stdin -b /usr/bin

# Install  https://github.com/harness/drone-cli
RUN curl -sfLo - https://github.com/harness/drone-cli/releases/latest/download/drone_linux_amd64.tar.gz | tar -xzf - -C /usr/local/bin

# Install Java
RUN apt-get update \
    && apt-get install -y openjdk-8-jdk openjdk-11-jdk openjdk-17-jdk ant maven \
    && apt-get install -y ant maven gradle \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install https://github.com/coder/code-server
RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v${CODE_SERVER_RELEASE}/code-server-${CODE_SERVER_RELEASE}-linux-amd64.tar.gz | tar -xzf - -C /usr/local/code-server --strip-components=1

# Setup sandbox user
RUN useradd --shell /usr/bin/zsh --create-home sandbox \
  && echo 'sandbox ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sandbox \
  && usermod -a -G docker sandbox

# Copy user dotfiles
COPY --chown=sandbox:sandbox dotfiles /home/sandbox

USER sandbox

WORKDIR /home/sandbox

# Install ohmyzsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install NVM
ENV NVM_DIR="/home/sandbox/.nvm"
RUN curl -sfLo- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | zsh \
 && . $NVM_DIR/nvm.sh \
 && nvm install --lts

# Install VS Code Extensions
# TODO: Figure out how to support the tabnine.tabnine-vscode extension
RUN for item in \
      # Golang
      golang.go \
      # Terrafomr
      hashicorp.terraform \
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
    ; do /usr/local/code-server/bin/code-server --force --install-extension $item; done

EXPOSE 8080

WORKDIR /home/sandbox

USER root

# Copy s6-overlay configs
COPY s6-rc.d /etc/s6-overlay/s6-rc.d

# Set default environment variables
ENV S6_VERBOSITY 1

ENTRYPOINT ["/init"]

CMD ["/etc/s6-overlay/s6-rc.d/code-server/run"]