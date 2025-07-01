.PHONY: test test-coverage test-ci build clean lint fmt vet

# Test commands
test:
	@echo "Running tests..."
	cd devices/raspberry-pi && go test -v ./...

test-coverage:
	@echo "Running tests with coverage..."
	cd devices/raspberry-pi && go test -v -coverprofile=../../coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "Coverage report generated: coverage.html"

test-ci:
	@echo "Running CI tests..."
	cd devices/raspberry-pi && go test -v -race -coverprofile=../../coverage.out -covermode=atomic ./...

# Build commands
build-raspberry-pi:
	@echo "Building Raspberry Pi client..."
	cd devices/raspberry-pi && go build -o ../../bin/raspberry-pi-mqtt .

build: build-raspberry-pi

# Code quality
fmt:
	@echo "Formatting code..."
	cd devices/raspberry-pi && go fmt ./...

vet:
	@echo "Running go vet..."
	cd devices/raspberry-pi && go vet ./...

lint:
	@echo "Running golangci-lint..."
	cd devices/raspberry-pi && golangci-lint run ./...

# Utility commands
clean:
	@echo "Cleaning up..."
	rm -rf bin/
	rm -f coverage.out coverage.html

deps:
	@echo "Installing dependencies..."
	cd devices/raspberry-pi && go mod download
	go work sync

# Setup commands
setup: deps
	@echo "Setting up development environment..."
	mkdir -p bin/
	@echo "Setup complete!"

# Run commands
run-raspberry-pi:
	@echo "Running Raspberry Pi client..."
	cd devices/raspberry-pi && go run .

# Docker commands (for testing with MQTT broker)
docker-mqtt:
	@echo "Starting MQTT broker in Docker..."
	docker run -it -p 1883:1883 -p 9001:9001 eclipse-mosquitto

# Help
help:
	@echo "Available commands:"
	@echo "  test              - Run all tests"
	@echo "  test-coverage     - Run tests with coverage report"
	@echo "  test-ci           - Run tests for CI (with race detection)"
	@echo "  build             - Build all applications"
	@echo "  build-raspberry-pi - Build Raspberry Pi client"
	@echo "  fmt               - Format code"
	@echo "  vet               - Run go vet"
	@echo "  lint              - Run golangci-lint"
	@echo "  clean             - Clean build artifacts"
	@echo "  deps              - Install dependencies"
	@echo "  setup             - Setup development environment"
	@echo "  run-raspberry-pi  - Run Raspberry Pi client"
	@echo "  docker-mqtt       - Start MQTT broker in Docker"
	@echo "  help              - Show this help"