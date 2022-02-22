FROM justmiles/docker-shell-sandbox

ENV BUILD_DATE=20220206
ENV VERSION=4.0.2
ENV CODE_RELEASE=v4.0.2
USER root

RUN apt-get update \
  && apt-get install -y \
  dumb-init \
  htop \
  locales \
  man \
  git \
  git-lfs \
  procps \
  openssh-client \
  lsb-release \
  docker.io \
  && git lfs install \
  && rm -rf /var/lib/apt/lists/*

# https://wiki.debian.org/Locale#Manually
RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen

ENV LANG=en_US.UTF-8

RUN mkdir -p /usr/local/code-server \
  && curl -sfLo - https://github.com/coder/code-server/releases/download/v4.0.2/code-server-4.0.2-linux-amd64.tar.gz | tar -xzvf - -C /usr/local/code-server --strip-components=1

COPY user-settings.json /home/sandbox/.local/share/code-server/User/settings.json
COPY config.yaml /home/sandbox/.config/code-server/config.yaml

RUN chown -R sandbox:sandbox /home/sandbox/.local /home/sandbox/.config

RUN usermod -a -G docker sandbox

USER sandbox

ENV items "golang.go hashicorp.terraform ms-python.python"
RUN for item in $items; do \
  /usr/local/code-server/bin/code-server --force --install-extension $item; \
  done;

EXPOSE 8080

WORKDIR /home/sandbox

ENTRYPOINT ["dumb-init", "/usr/local/code-server/bin/code-server"]
