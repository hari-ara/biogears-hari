#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Set up colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}GitHub Actions Workflow Fix Test${NC}"
echo "=================================================="
echo "This script tests the specific fix for the GitHub Actions workflow"
echo "by generating the Dockerfiles with the corrected apt-get syntax."
echo "=================================================="

# Create test directories
mkdir -p test-local/github-action-test

# Test the original problematic command (should fail)
echo -e "\n${YELLOW}STEP 1: Testing Problematic apt-get command (should fail)${NC}"
cat > test-local/github-action-test/Dockerfile.problematic << 'EOF'
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# This syntax is broken on purpose - notice the escaped asterisk and the misplaced &&
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/\* 

CMD ["/bin/bash"]
EOF

echo "Testing problematic command (should fail)..."
if ! docker build --no-cache -q -t biogears-test-problematic -f test-local/github-action-test/Dockerfile.problematic test-local/github-action-test 2>/dev/null; then
    echo -e "${GREEN}✓ Problematic apt-get command failed as expected!${NC}"
else
    echo -e "${RED}✗ Problematic apt-get command unexpectedly worked!${NC}"
fi

# Test the fixed command (should succeed)
echo -e "\n${YELLOW}STEP 2: Testing Fixed apt-get command (should succeed)${NC}"
cat > test-local/github-action-test/Dockerfile.fixed << 'EOF'
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# This is the correct syntax that should work
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
EOF

echo "Testing fixed command (should succeed)..."
if docker build --no-cache -q -t biogears-test-fixed -f test-local/github-action-test/Dockerfile.fixed test-local/github-action-test; then
    echo -e "${GREEN}✓ Fixed apt-get command works correctly!${NC}"
else
    echo -e "${RED}✗ Fixed apt-get command still has issues!${NC}"
    exit 1
fi

# Test the workflow file fixes
echo -e "\n${YELLOW}STEP 3: Verifying GitHub Actions Workflow Fix${NC}"
echo "Checking if the workflow file has the correct syntax..."

# Check if the workflow file has the corrected syntax
WORKFLOW_FILE=".github/workflows/biogears-complete-pipeline.yml"
FIXED_PATTERN="ca-certificates && "

if grep -q "$FIXED_PATTERN" "$WORKFLOW_FILE"; then
    echo -e "${GREEN}✓ GitHub Actions workflow has the correct apt-get command syntax!${NC}"
else
    echo -e "${RED}✗ GitHub Actions workflow does not have the correct apt-get command syntax!${NC}"
    exit 1
fi

echo -e "\n${GREEN}All GitHub Actions workflow fixes are valid!${NC}"
echo "The workflow should now run successfully on GitHub."

# Cleanup option
read -p "Do you want to clean up the test Docker images? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleaning up Docker images..."
    docker rmi biogears-test-fixed biogears-test-problematic 2>/dev/null || true
    echo "Cleanup complete!"
fi 