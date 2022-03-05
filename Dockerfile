FROM justmiles/docker-shell-sandbox

ENV BUILD_DATE=20220206
ENV VERSION=4.0.2

# https://github.com/coder/code-server/releases
ENV CODE_SERVER_RELEASE=4.1.0
USER root

RUN apt-get update \
  && apt-get install -y \
  dumb-init \
  htop \
  locales \
  man \
  git \
  make \
  git-lfs \
  procps \
  openssh-client \
  lsb-release \
  docker.io \
  rsync \
  direnv \
  ncdu \
  && git lfs install \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8

RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v${CODE_SERVER_RELEASE}/code-server-${CODE_SERVER_RELEASE}-linux-amd64.tar.gz | tar -xzvf - -C /usr/local/code-server --strip-components=1

COPY user-settings.json /home/sandbox/.local/share/code-server/User/settings.json
COPY keybindings.json /home/sandbox/.local/share/code-server/User/keybindings.json

COPY config.yaml /home/sandbox/.config/code-server/config.yaml

RUN chown -R sandbox:sandbox /home/sandbox/.local /home/sandbox/.config /home/sandbox/.local/share/code-server /home/sandbox/.zshrc

RUN usermod -a -G docker sandbox && groupmod -g 999 docker

RUN curl -L https://releases.hashicorp.com/nomad/1.2.3/nomad_1.2.3_linux_amd64.zip > nomad.zip \
 && unzip nomad.zip -d /usr/local/bin \
 && chmod 0755 /usr/local/bin/nomad \
 && chown root:root /usr/local/bin/nomad \
 && rm -rf nomad.zip

RUN curl -sfLO https://raw.githubusercontent.com/warrensbox/terraform-switcher/release/install.sh \
  && chmod +x install.sh \
  && ./install.sh -b /usr/bin \
  && rm -rf install.sh

USER sandbox

ENV items "golang.go hashicorp.terraform ms-python.python redhat.vscode-yaml eamodio.gitlens pkief.material-icon-theme zhuangtongfa.Material-theme"
RUN for item in $items; do \
  /usr/local/code-server/bin/code-server --force --install-extension $item; \
  done;

EXPOSE 8080

COPY entrypoint.sh /usr/bin/entrypoint

WORKDIR /home/sandbox

ENTRYPOINT ["entrypoint"]
