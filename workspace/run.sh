#!/bin/bash
podman run -d \
    -p 2222:22 \
    -v friday:/home/friday/ \
    --device nvidia.com/gpu=all \
    --network workspace \
    --name workspace \
    --hostname workspace \
    vinhnp/workspace
