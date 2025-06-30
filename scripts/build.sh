#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "Building Raspberry Pi client..."
mkdir -p bin/
cd devices/raspberry-pi && go build -o ../../bin/raspberry-pi-mqtt .
echo "Build completed: bin/raspberry-pi-mqtt"