package intoto

# Convert custom attestation to in-toto format
to_intoto_format(data, subject_name, subject_digest, predicate_type) = intoto_statement {
    intoto_statement := {
        "_type": "https://in-toto.io/Statement/v0.1",
        "subject": [{
            "name": subject_name,
            "digest": subject_digest
        }],
        "predicateType": predicate_type,
        "predicate": data
    }
}

# Generate in-toto build attestation
build_attestation[statement] {
    # First get regular build attestation data
    attestation := data.build_attestation.attestation[_]
    
    # Convert to in-toto format
    statement := to_intoto_format(
        attestation,
        sprintf("build-%s", [attestation.build_platform]),
        {"sha256": attestation.commit_hash},
        "https://example.org/attestations/build/v1"
    )
}

# Generate in-toto container scan attestation
container_scan_attestation[statement] {
    # Get container scan attestation data
    scan := data.container_scan.attestation[_]
    
    # Convert to in-toto format
    statement := to_intoto_format(
        scan,
        sprintf("container-scan-%s", [input.image_name]),
        {"sha256": input.image_digest},
        "https://example.org/attestations/container-scan/v1"
    )
}

# Generate in-toto SBOM attestation
sbom_attestation[statement] {
    # Get SBOM attestation data
    sbom := data.sbom.attestation[_]
    
    # Convert to in-toto format
    statement := to_intoto_format(
        sbom,
        sprintf("sbom-%s", [input.image_name]),
        {"sha256": input.image_digest},
        "https://in-toto.io/attestation/sbom/v1"
    )
}
