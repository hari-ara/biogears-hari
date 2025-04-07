# BioGears Secure CI/CD Pipeline

This directory contains GitHub Actions workflows for building and securing the BioGears human physiology engine with a focus on secure software supply chain practices.

## Pipeline Overview

The secure pipeline performs the following steps:

1. **Docker Build**: Builds BioGears Docker images using the project's existing Dockerfiles and docker-compose configuration
2. **Vulnerability Scanning**: Scans images for security vulnerabilities using Trivy
3. **SBOM Generation**: Creates CycloneDX Software Bill of Materials (SBOMs) for all images
4. **Policy Creation**: Generates and signs OPA/Rego policies defining security requirements
5. **Attestation Generation**: Creates in-toto attestations for builds, scans, and SBOMs
6. **Digital Signing**: Signs all artifacts with Cosign
7. **Registry Publication**: Publishes all artifacts to OCI registries

## Workflows

- **docker-based-pipeline-v2.yml**: Latest version of the pipeline using a Docker-based approach
- **docker-compose-test.yml**: Focused workflow to test and validate Docker Compose functionality
- **github-registry-publish.yml**: Workflow for publishing to GitHub Container Registry
- **jfrog-registry-publish.yml**: Workflow for publishing to JFrog Artifactory
- **harbor-registry-publish.yml**: Workflow for publishing to Harbor Registry

## Supply Chain Security Features

### Software Bill of Materials (SBOM)

The pipeline generates CycloneDX format SBOMs for all Docker images, providing:
- Complete component inventory (packages, libraries, dependencies)
- Component versions
- Licensing information
- Dependency relationships
- Vulnerability data

### Vulnerability Scanning

Trivy is used for container vulnerability scanning:
- Scans for OS package vulnerabilities
- Detects application dependencies vulnerabilities
- Identifies unfixed/unpatched CVEs
- Reports severity levels for proper risk assessment

### Policy as Code

The pipeline implements policy as code using OPA (Open Policy Agent) with Rego:
- **SBOM Policy**: Validates proper SBOM formatting and content
- **Container Scan Policy**: Defines acceptable vulnerability thresholds
- **Build Attestation Policy**: Verifies build metadata requirements

### Digital Signatures

Cosign is used to sign all artifacts:
- Container images are signed with Cosign
- SBOMs are signed to verify authenticity
- Policies are signed to prevent tampering
- Attestations are signed to create verifiable supply chain records

### In-toto Attestations

The pipeline creates in-toto format attestations:
- Build attestations document the build environment and process
- Scan attestations document vulnerability scan results
- SBOM attestations document the completeness of component inventory

### OCI Registry Integration

All artifacts are published to OCI-compatible registries:
- Container images with signatures
- SBOMs attached to their respective images
- Signed policies
- In-toto attestations

## Usage

To run the full pipeline:

```
gh workflow run docker-based-pipeline-v2.yml
```

To test Docker Compose functionality:

```
gh workflow run docker-compose-test.yml
```

## Verification

After the pipeline runs, you can verify artifacts:

```bash
# Verify image signatures
cosign verify --key cosign.pub ghcr.io/OWNER/biogears-external:latest

# Verify SBOM
cosign verify-blob --key cosign.pub --signature sbom.json.sig sbom.json

# Verify attestations
cosign verify-attestation --key cosign.pub ghcr.io/OWNER/biogears-external:latest
```

## Security Considerations

This pipeline implements multiple layers of security:
- **Defense in depth**: Multiple security controls at different layers
- **Trust verification**: Digital signatures and verification throughout
- **Policy enforcement**: Automated policy checking
- **Transparency**: Complete software inventory with SBOMs
- **Traceability**: In-toto attestations create an audit trail

## Troubleshooting

Common issues:

1. **Docker Compose not found**: The pipeline includes automated installation of both Docker Compose V1 and Docker Compose V2 plugin
2. **Registry authentication errors**: Ensure proper secrets are configured in GitHub repository settings
3. **Policy failures**: Check the policy violation messages for specific thresholds being exceeded 