#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Set up colors for better readability
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}BioGears Build Debug Test${NC}"
echo "=================================================="
echo "This script focuses on debugging the 'Build BioGears with Docker' step"
echo "that is failing in the GitHub Actions workflow."
echo "=================================================="

# Create test directories
echo -e "\n${YELLOW}Creating test directories...${NC}"
mkdir -p test-local/build-debug/external
mkdir -p test-local/build-debug/modified
mkdir -p test-local/build-debug/biogears

# Step 1: Test External dependencies image with verbose output
echo -e "\n${YELLOW}STEP 1: Building External Dependencies Image${NC}"
cat > test-local/build-debug/external/Dockerfile << 'EOF'
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Install basic dependencies with verbose output
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    libxml2-dev \
    libxerces-c-dev \
    liblog4cpp5v5-dev \
    libeigen3-dev && \
    rm -rf /var/lib/apt/lists/*

# Handle architecture-specific package installation
# Skip CodeSynthesis XSD in local testing to avoid architecture issues
RUN echo "Skipping XSD installation for local testing"

ENV PATH="/usr/local/bin:${PATH}"
WORKDIR /opt/biogears

CMD ["/bin/bash"]
EOF

echo "Building external dependencies image with verbose output..."
docker build --progress=plain -t biogears-external-debug -f test-local/build-debug/external/Dockerfile test-local/build-debug/external

# Step 2: Extract the build step from workflow file and recreate it locally
echo -e "\n${YELLOW}STEP 2: Recreating the failing build step locally${NC}"

# Create a minimal release Dockerfile similar to the original
cat > test-local/build-debug/modified/Dockerfile.builder << 'EOF'
FROM biogears-external-debug

# Display debug information
RUN echo "Debugging environment" && \
    echo "Architecture: $(uname -m)" && \
    echo "Operating System: $(cat /etc/os-release | grep PRETTY_NAME)" && \
    ls -la /

# Create dummy artifacts for testing (simulating a successful build)
RUN mkdir -p /artifacts/lib /artifacts/bin && \
    echo 'This is a dummy shared library' > /artifacts/lib/libbiogears.so && \
    echo 'This is a dummy static library' > /artifacts/lib/libbiogears.a && \
    echo '#!/bin/bash' > /artifacts/bin/bg-cli && \
    echo 'echo "BioGears CLI Simulator"' >> /artifacts/bin/bg-cli && \
    chmod +x /artifacts/bin/bg-cli

# Test environment
RUN apt-get update && apt-get install -y ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    echo "Environment test successful"

# Create output directories for the build products
RUN mkdir -p /usr/local/lib /usr/local/bin && \
    cp -r /artifacts/lib/* /usr/local/lib/ && \
    cp -r /artifacts/bin/* /usr/local/bin/

WORKDIR /opt/biogears
CMD ["/bin/bash"]
EOF

echo "Attempting to build with the modified builder Dockerfile..."
docker build --progress=plain -t biogears-builder-debug -f test-local/build-debug/modified/Dockerfile.builder test-local/build-debug/modified || {
    echo -e "${YELLOW}⚠ Modified builder failed - checking exact error...${NC}"
    
    # Create a simpler test to isolate the issue
    cat > test-local/build-debug/biogears/Dockerfile.minimal << 'EOF'
FROM biogears-external-debug

# Just create minimal directories
RUN mkdir -p /artifacts/lib /artifacts/bin

WORKDIR /opt/biogears
CMD ["/bin/bash"]
EOF

    echo "Testing with minimal Dockerfile to isolate the issue..."
    docker build --progress=plain -t biogears-minimal-debug -f test-local/build-debug/biogears/Dockerfile.minimal test-local/build-debug/biogears
}

# Step 3: Check the GitHub Actions workflow and compare with local environment
echo -e "\n${YELLOW}STEP 3: Comparing GitHub Actions environment with local environment${NC}"
echo "GitHub Actions runs on ubuntu-latest with AMD64 architecture"
echo "Local environment runs on $(uname -s) with $(uname -m) architecture"

echo "Checking if any path issues exist in the GitHub workflow file..."
grep -n "docker build" .github/workflows/biogears-complete-pipeline.yml

echo -e "\n${YELLOW}STEP 4: Testing container extraction${NC}"
echo "Creating a temporary container to test artifact extraction..."
CONTAINER_ID=$(docker create biogears-builder-debug || docker create biogears-minimal-debug)

# Create directories for extracted files
mkdir -p test-local/build-debug/artifacts/lib test-local/build-debug/artifacts/bin

# Extract artifacts for testing
echo "Extracting artifacts from container..."
docker cp $CONTAINER_ID:/artifacts/lib/. test-local/build-debug/artifacts/lib/ || echo "Failed to copy libraries"
docker cp $CONTAINER_ID:/artifacts/bin/. test-local/build-debug/artifacts/bin/ || echo "Failed to copy binaries"

# Remove the temporary container
docker rm $CONTAINER_ID

# List extracted contents
echo "Extracted libraries:"
ls -la test-local/build-debug/artifacts/lib/ || echo "No libraries extracted"
echo "Extracted binaries:"
ls -la test-local/build-debug/artifacts/bin/ || echo "No binaries extracted"

echo -e "\n${YELLOW}Debugging Summary${NC}"
echo "1. Check for any architecture-specific issues (ARM64 vs AMD64)"
echo "2. Look for issues with directories or permissions in the Docker build context"
echo "3. Check for path issues in the GitHub Actions workflow"
echo "4. Verify that the Docker build context is correctly specified"

# Cleanup option
read -p "Do you want to clean up the test Docker images? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleaning up Docker images..."
    docker rmi biogears-external-debug biogears-builder-debug biogears-minimal-debug 2>/dev/null || true
    echo "Cleanup complete!"
fi 