package sbom

# SBOM must be in CycloneDX format
valid_format {
    input.bomFormat == "CycloneDX"
}

# SBOM must have a version specified
has_version {
    input.specVersion != null
    input.specVersion != ""
}

# SBOM must have components
has_components {
    count(input.components) > 0
}

# Verify SBOM has metadata
has_metadata {
    input.metadata != null
}

# Check if there are any critical vulnerabilities
has_critical_vulnerabilities {
    some component, vulnerability
    input.components[component].vulnerabilities[vulnerability].severity == "critical"
}

# Deny if there are critical vulnerabilities
deny[msg] {
    has_critical_vulnerabilities
    msg := "SBOM contains components with critical vulnerabilities"
}

# SBOM is valid if it passes all validation checks
valid {
    valid_format
    has_version
    has_components
    has_metadata
}

# Generate an attestation statement
attestation[result] {
    result := {
        "valid": valid,
        "format": input.bomFormat,
        "components_count": count(input.components),
        "timestamp": time.now_ns()
    }
}
