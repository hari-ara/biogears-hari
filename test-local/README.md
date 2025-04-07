# BioGears Docker Local Testing

This directory contains scripts to test the Docker builds locally before pushing to GitHub. This helps identify and fix issues in the Docker build process before relying on GitHub Actions.

## Available Test Scripts

1. **test-docker-builds.sh**: Tests all three stages of the Docker build process:
   - External dependencies image
   - BioGears builder image
   - Runtime image
   
   This script validates the Docker image syntax and build process for all stages.

2. **test-release-build.sh**: Specifically tests the process of modifying the release Dockerfile, which is the step that's failing in the GitHub Actions workflow.

## How to Use

1. Make sure Docker is installed and running on your system.
2. Run the scripts from the repository root:

```bash
# Run the complete Docker build test
./test-local/test-docker-builds.sh

# Run the release Dockerfile test
./test-local/test-release-build.sh
```

## What the Tests Verify

- Correct Docker syntax for all Dockerfiles
- Proper installation of dependencies
- Ability to build and run the containers
- Extraction of build artifacts
- Creation of the runtime image

## If Tests Fail

If any test fails, the script will provide information about which step failed and why. Check the following:

1. Syntax issues in Docker commands
2. Missing dependencies
3. Issues with apt-get commands
4. Path or permission issues

After fixing any issues, run the tests again before pushing to GitHub.

## Clean Up

Both scripts offer an option to clean up Docker images created during testing. 
You can also manually remove them with:

```bash
docker rmi biogears-external-test biogears-builder-test biogears-runtime-test biogears-external biogears-release-test
``` 