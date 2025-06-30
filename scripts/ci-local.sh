#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "🚀 Running local CI checks..."
echo "================================"

# 1. Format check
echo "📝 Checking code formatting..."
if ! go fmt ./devices/raspberry-pi/... | grep -q .; then
    echo "✅ Code is properly formatted"
else
    echo "❌ Code formatting issues found. Run 'go fmt ./devices/raspberry-pi/...' to fix."
    exit 1
fi

# 2. Vet check
echo ""
echo "🔍 Running go vet..."
if go vet ./devices/raspberry-pi/...; then
    echo "✅ go vet passed"
else
    echo "❌ go vet failed"
    exit 1
fi

# 3. Lint check
echo ""
echo "🧹 Running golangci-lint..."
if command -v golangci-lint >/dev/null 2>&1; then
    if golangci-lint run ./devices/raspberry-pi/...; then
        echo "✅ golangci-lint passed"
    else
        echo "❌ golangci-lint failed"
        exit 1
    fi
else
    echo "⚠️  golangci-lint not installed. Install it with:"
    echo "    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# 4. Tests with race detection
echo ""
echo "🧪 Running tests with race detection..."
if go test -race -v ./devices/raspberry-pi/...; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi

# 5. Coverage check
echo ""
echo "📊 Running coverage analysis..."
if go test -coverprofile=coverage.out ./devices/raspberry-pi/...; then
    coverage=$(go tool cover -func=coverage.out | tail -1 | awk '{print $3}')
    echo "✅ Coverage: $coverage"
    
    # Generate HTML report
    go tool cover -html=coverage.out -o coverage.html
    echo "📄 Coverage report: coverage.html"
else
    echo "❌ Coverage analysis failed"
    exit 1
fi

# 6. Build check
echo ""
echo "🔨 Building application..."
mkdir -p bin/
if (cd devices/raspberry-pi && go build -o ../../bin/raspberry-pi-mqtt .); then
    echo "✅ Build successful: bin/raspberry-pi-mqtt"
else
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "🎉 All CI checks passed! Ready to push."
echo "================================"