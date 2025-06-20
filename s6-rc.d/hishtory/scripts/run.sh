#!/command/with-contenv bash

# upsert hishtory hooks to match the installed hishtory version
hishtory completion zsh > /home/sandbox/.hishtory/config.zsh
hishtory completion bash > /home/sandbox/.hishtory/config.sh
hishtory completion fish > /home/sandbox/.hishtory/config.fish
