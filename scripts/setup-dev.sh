#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "🛠️  Setting up development environment..."
echo "========================================"

# Install golangci-lint if not present
if ! command -v golangci-lint >/dev/null 2>&1; then
    echo "📦 Installing golangci-lint..."
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    echo "✅ golangci-lint installed"
else
    echo "✅ golangci-lint already installed"
fi

# Create directories
echo ""
echo "📁 Creating directories..."
mkdir -p bin/
echo "✅ Directories created"

# Install Go dependencies
echo ""
echo "📦 Installing Go dependencies..."
go work sync
echo "✅ Dependencies synced"

# Setup pre-commit hook (optional)
echo ""
read -p "🪝 Do you want to install pre-commit hook? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ -f ".git/hooks/pre-commit" ]; then
        echo "⚠️  Pre-commit hook already exists. Backing up..."
        mv .git/hooks/pre-commit .git/hooks/pre-commit.backup
    fi
    cp scripts/pre-commit.sh .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✅ Pre-commit hook installed"
else
    echo "⏭️  Skipping pre-commit hook installation"
fi

# Run initial CI check
echo ""
echo "🧪 Running initial CI check..."
./scripts/ci-local.sh

echo ""
echo "🎉 Development environment setup complete!"
echo "========================================"
echo ""
echo "Available commands:"
echo "  ./scripts/test.sh           - Run tests"
echo "  ./scripts/test-coverage.sh  - Run tests with coverage"
echo "  ./scripts/build.sh          - Build application"
echo "  ./scripts/ci-local.sh       - Run full CI checks locally"
echo "  ./scripts/pre-commit.sh     - Run pre-commit checks"