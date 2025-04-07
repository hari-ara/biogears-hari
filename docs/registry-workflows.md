# BioGears Registry Workflows

This document describes the ORAS-based registry workflows set up for publishing BioGears artifacts to various OCI-compatible registries.

## Supported Registries

The project supports publishing artifacts to the following registries:

1. **GitHub Container Registry (ghcr.io)**
   - Configured in `.github/workflows/github-registry-publish.yml`
   - Uses GitHub Actions OIDC token-based authentication
   - Repository format: `ghcr.io/{owner}/{repo}`

2. **GitLab Container Registry**
   - Configured in `.gitlab-ci/gitlab-registry-publish.yml`
   - Uses GitLab CI built-in registry authentication
   - Repository format: `registry.gitlab.com/{namespace}/{project}`

3. **JFrog Artifactory**
   - Configured in `.github/workflows/jfrog-registry-publish.yml`
   - Uses username/password authentication
   - Repository format: `{jfrog-url}/{repository}/biogears`

4. **Harbor Registry**
   - Configured in `.github/workflows/harbor-registry-publish.yml`
   - Uses username/password authentication
   - Repository format: `{harbor-url}/{project}/{repo-name}`

## Published Artifacts

Each workflow publishes the following types of artifacts:

- **SBOMs**: CycloneDX format Software Bill of Materials
- **Attestations**: In-toto format attestations about builds, scans, and SBOMs
- **Signatures**: Cosign signatures for all artifacts
- **Policies**: OPA/Rego policies used for validation
- **Reference Manifest**: OCI manifest tying all artifacts together

## Required Secrets

### GitHub Workflows

For GitHub Container Registry:
- No additional secrets required (uses `GITHUB_TOKEN`)

For JFrog Artifactory:
- `JFROG_URL`: URL of your JFrog Artifactory instance
- `JFROG_USERNAME`: Username for JFrog authentication
- `JFROG_PASSWORD`: Password for JFrog authentication
- `JFROG_REPO`: Repository name in JFrog

For Harbor Registry:
- `HARBOR_URL`: URL of your Harbor instance
- `HARBOR_USERNAME`: Username for Harbor authentication
- `HARBOR_PASSWORD`: Password for Harbor authentication
- `HARBOR_PROJECT`: Harbor project name

### GitLab CI

For GitLab Container Registry:
- No additional secrets required (uses built-in GitLab CI variables)

## Usage

The registry publish workflows are triggered automatically after a successful build on the main branches, or can be triggered manually using the workflow_dispatch event for GitHub Actions.

### Versioning

Artifacts are versioned using:
1. Git tags if available
2. Date-based version with commit SHA if no tags are available: `YYYYMMDD-SHA`

### Artifacts Storage

All artifacts are stored with appropriate OCI media types:
- SBOMs: `application/vnd.cyclonedx+json`
- Attestations: `application/in-toto+json`
- Signatures: `application/vnd.sigstore+tar+gzip`
- Policies: `application/vnd.rego+tar+gzip`
- Reference Manifest: `application/vnd.biogears.release`

## Verification

After artifacts are published, you can verify them with the ORAS CLI:

```bash
# List all artifacts in a repository
oras discover -o json <registry-url>/<repository>/release:<version>

# Get detailed tree view
oras discover -o tree <registry-url>/<repository>/release:<version>
```

You can also verify signatures using Cosign:

```bash
# Verify a specific artifact
cosign verify-blob --key <public-key> --signature <signature-file> <artifact-file>
```

## Reports

Each workflow generates a report of published artifacts and uploads it as a build artifact, which can be downloaded from the CI/CD interface. 