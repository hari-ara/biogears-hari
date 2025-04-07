package build_attestation

# Required build metadata fields
required_fields = {
    "builder_id",
    "build_type",
    "source_repo",
    "commit_hash",
    "build_timestamp",
    "build_platform"
}

# Check if all required fields are present
has_required_fields {
    field := required_fields[_]
    input[field]
}

missing_fields[field] {
    field := required_fields[_]
    not input[field]
}

# Verify the build type is allowed
allowed_build_types = {"Release", "Debug"}

has_valid_build_type {
    input.build_type == allowed_build_types[_]
}

# Verify the build platform is allowed
allowed_platforms = {"ubuntu-latest", "macos-latest", "windows-latest"}

has_valid_platform {
    input.build_platform == allowed_platforms[_]
}

# Deny reasons
deny[msg] {
    count(missing_fields) > 0
    msg := sprintf("Missing required build metadata fields: %v", [missing_fields])
}

deny[msg] {
    not has_valid_build_type
    msg := sprintf("Invalid build type: %s. Allowed types: %v", [input.build_type, allowed_build_types])
}

deny[msg] {
    not has_valid_platform
    msg := sprintf("Invalid build platform: %s. Allowed platforms: %v", [input.build_platform, allowed_platforms])
}

# Build attestation is valid if there are no violations
valid {
    count(deny) == 0
}

# Generate an attestation statement
attestation[result] {
    result := {
        "valid": valid,
        "builder_id": input.builder_id,
        "build_type": input.build_type,
        "source_repo": input.source_repo,
        "commit_hash": input.commit_hash,
        "build_timestamp": input.build_timestamp,
        "build_platform": input.build_platform,
        "timestamp": time.now_ns()
    }
} 