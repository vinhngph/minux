#!/bin/bash
podman run -it \
    -p 2222:22 \
    -v workspace-ssh:/home/friday/.ssh \
    -v workspace-gpg:/home/friday/.gnupg \
    -v workspace-workspace:/home/friday/workspace \
    --device nvidia.com/gpu=all \
    --network workspace \
    --name workspace \
    --hostname workspace \
    vinhnp/workspace
