#!/bin/bash
podman run -it \
    --userns=keep-id \
    --mount type=bind,src=$XDG_RUNTIME_DIR/gnupg,dst=/run/user/1000/gnupg,rw,rslave \
    --mount type=bind,src=$SSH_AUTH_SOCK,dst=/run/user/1000/keyring/ssh,rw,rslave \
    --mount type=bind,src=$HOME/.gitconfig,dst=/home/friday/.gitconfig,readonly,rslave \
    --mount type=bind,src=$HOME/.gnupg,dst=/home/friday/.gnupg,readonly,rslave \
    --mount type=bind,src=$HOME/workspace,dst=/home/friday/workspace,rw,rslave \
    --device nvidia.com/gpu=all \
    --name workspace \
    --hostname workspace \
    vinhnp/workspace