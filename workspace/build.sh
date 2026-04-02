#!/bin/bash
podman build \
    --no-cache \
    --build-arg-file ./argfile.conf \
    -t vinhnp/workspace .