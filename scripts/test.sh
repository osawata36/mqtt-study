#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "Running tests..."
go test -v ./devices/raspberry-pi/...