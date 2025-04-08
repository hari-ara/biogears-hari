package container_scan

# Maximum allowed counts for different vulnerability severities
max_critical = 0
max_high = 5
max_medium = 20

# Count vulnerabilities by severity
critical_count = count {
    count = count([v | v = input.Results[_].Vulnerabilities[_]; v.Severity == "CRITICAL"])
}

high_count = count {
    count = count([v | v = input.Results[_].Vulnerabilities[_]; v.Severity == "HIGH"])
}

medium_count = count {
    count = count([v | v = input.Results[_].Vulnerabilities[_]; v.Severity == "MEDIUM"])
}

# Vulnerability policy violations
violations[msg] {
    critical_count > max_critical
    msg := sprintf("Critical vulnerabilities found: %d (maximum allowed: %d)", [critical_count, max_critical])
}

violations[msg] {
    high_count > max_high
    msg := sprintf("High vulnerabilities found: %d (maximum allowed: %d)", [high_count, max_high])
}

violations[msg] {
    medium_count > max_medium
    msg := sprintf("Medium vulnerabilities found: %d (maximum allowed: %d)", [medium_count, max_medium])
}

# Image scan is compliant if there are no violations
compliant {
    count(violations) == 0
}

# Generate an attestation statement
attestation[result] {
    result := {
        "compliant": compliant,
        "critical_vulnerabilities": critical_count,
        "high_vulnerabilities": high_count, 
        "medium_vulnerabilities": medium_count,
        "timestamp": time.now_ns()
    }
}
