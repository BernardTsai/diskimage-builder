#!/usr/bin/env bash

# Change working directory to script directory
cd "$( dirname "${BASH_SOURCE[0]}" )"

# Build the image
docker build -t tsai/diskimage-builder .
