#!/bin/bash

set -e

# Change to project root directory
cd "$(dirname "$0")/.."

echo "🚀 Running local CI checks..."
echo "================================"

# 1. Format check
echo "📝 Checking code formatting..."
cd devices/raspberry-pi
if ! go fmt ./... | grep -q .; then
    echo "✅ Code is properly formatted"
else
    echo "❌ Code formatting issues found. Run 'cd devices/raspberry-pi && go fmt ./...' to fix."
    exit 1
fi
cd ../..

# 2. Vet check
echo ""
echo "🔍 Running go vet..."
cd devices/raspberry-pi
if go vet ./...; then
    echo "✅ go vet passed"
else
    echo "❌ go vet failed"
    exit 1
fi
cd ../..

# 3. Lint check
echo ""
echo "🧹 Running golangci-lint..."
if command -v golangci-lint >/dev/null 2>&1; then
    cd devices/raspberry-pi
    if golangci-lint run ./...; then
        echo "✅ golangci-lint passed"
    else
        echo "❌ golangci-lint failed"
        exit 1
    fi
    cd ../..
else
    echo "⚠️  golangci-lint not installed. Install it with:"
    echo "    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
fi

# 4. Tests with race detection
echo ""
echo "🧪 Running tests with race detection..."
cd devices/raspberry-pi
if go test -race -v ./...; then
    echo "✅ Tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi
cd ../..

# 5. Coverage check
echo ""
echo "📊 Running coverage analysis..."
cd devices/raspberry-pi
if go test -coverprofile=../../coverage.out ./...; then
    cd ../..
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