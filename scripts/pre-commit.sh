#!/bin/bash

# Pre-commit hook script
# Copy this to .git/hooks/pre-commit and make it executable

set -e

cd "$(dirname "$0")/../.."

echo "🔍 Running pre-commit checks..."

# Quick format check
echo "📝 Checking formatting..."
if ! go fmt ./devices/raspberry-pi/... | grep -q .; then
    echo "✅ Formatting OK"
else
    echo "❌ Formatting required. Auto-fixing..."
    go fmt ./devices/raspberry-pi/...
    echo "✅ Code formatted. Please add the changes and commit again."
    exit 1
fi

# Quick vet check
echo "🔍 Running go vet..."
if go vet ./devices/raspberry-pi/...; then
    echo "✅ go vet passed"
else
    echo "❌ go vet failed"
    exit 1
fi

# Quick test (without race detection for speed)
echo "🧪 Running quick tests..."
if go test ./devices/raspberry-pi/...; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-commit checks passed!"