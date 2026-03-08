#!/command/with-contenv bash

up () {
# Only run if CHEZMOI_REPO is configured
[ -z "${CHEZMOI_REPO}" ] && exit 0

cat <<EOF | HOME=/home/sandbox s6-setuidgid sandbox bash
  export PATH=$PATH:/home/sandbox/.nix-profile/bin

  chmod 0600 /home/sandbox/.ssh/id_rsa

  ssh-keyscan -H github.com >> /home/sandbox/.ssh/known_hosts 2>/dev/null

  chezmoi init \
    --source /home/sandbox/.local/share/chezmoi \
    --cache /home/sandbox/.cache/chezmoi \
    --exclude scripts \
    --force \
    --apply "${CHEZMOI_REPO}"

  chezmoi \
    --source /home/sandbox/.config/chezmoi-public \
    --cache /home/sandbox/.cache/chezmoi-public \
    --refresh-externals \
    --force \
    --exclude scripts \
    apply
EOF
}

$1 2>&1 | s6-log -bp n3 "p[chezmoi]" 1 /var/log/chezmoi