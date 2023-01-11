#!/command/with-contenv bash

if [ ! -z "${CHEZMOI_REPO}" ]; then
  cat <<"EOF" | HOME=/home/sandbox exec s6-setuidgid sandbox bash
chmod 0600 ~/.ssh/id_rsa

ssh-keyscan -H github.com >> /home/sandbox/.ssh/known_hosts 2>/dev/null

chezmoi init \
  --source /home/sandbox/.local/share/chezmoi \
  --cache /home/sandbox/.cache/chezmoi \
  --exclude scripts \
  --apply "${CHEZMOI_REPO}"

chezmoi \
  --source /home/sandbox/.config/chezmoi-public \
  --cache /home/sandbox/.cache/chezmoi-public \
  --refresh-externals \
  --exclude scripts \
  apply
EOF
fi
