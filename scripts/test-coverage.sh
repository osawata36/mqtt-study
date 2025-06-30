#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "Running tests with coverage..."
go test -v -coverprofile=coverage.out ./devices/raspberry-pi/...
go tool cover -html=coverage.out -o coverage.html
echo "Coverage report generated: coverage.html"