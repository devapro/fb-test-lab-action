#!/bin/bash

#
# Local Testing Script for Firebase Test Lab GitHub Action
#
# This script allows you to test the Docker action locally before deploying.
# It builds the Docker image and runs it with your service account and test arguments.
#
# Prerequisites:
# 1. Docker must be installed and running
# 2. A valid service_account.json file must exist in the current directory
# 3. Your APK files should be accessible from the current directory
#
# Usage:
#   ./test.sh [arg-spec-arguments]
#
# Example:
#   ./test.sh "--type=instrumentation --timeout=30m --app=app.apk --test=test.apk --device=model=Pixel2,version=28"
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${YELLOW}INFO: $1${NC}"
}

# Check if service_account.json exists
if [ ! -f "service_account.json" ]; then
    print_error "service_account.json not found in current directory"
    echo "Please create a service_account.json file with your GCP service account credentials"
    echo "You can download it from: https://console.cloud.google.com/iam-admin/serviceaccounts"
    exit 1
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running"
    echo "Please start Docker and try again"
    exit 1
fi

# Get arguments or use default test arguments
if [ -z "$1" ]; then
    print_info "No arguments provided. Using example test arguments (will likely fail without actual APK files)"
    ARG_SPEC="--type=instrumentation --timeout=30m --app=app-debug.apk --test=app-debug-test.apk --device=model=Pixel2,version=28,locale=en"
else
    ARG_SPEC="$1"
fi

print_info "Building Docker image..."
docker build -t fb-test-lab-action . || {
    print_error "Docker build failed"
    exit 1
}

print_success "Docker image built successfully"

print_info "Running action with arguments:"
echo "  $ARG_SPEC"
echo ""

# Run the Docker container
docker run --rm \
  -e SERVICE_ACCOUNT="$(cat service_account.json)" \
  -v "$PWD":/workspace \
  -w /workspace \
  fb-test-lab-action \
  "$ARG_SPEC"

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    print_success "Action completed successfully"
else
    print_error "Action failed with exit code: $EXIT_CODE"
fi

exit $EXIT_CODE
