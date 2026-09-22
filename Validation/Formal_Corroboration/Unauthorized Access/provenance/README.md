# Provenance and sanitization

`original_to_public_hashes.csv` maps each copied public artifact to its source
group and source-relative path. It records both the SHA-256 of the original
source artifact and the SHA-256 of the public copy. `transformation=verbatim`
means the bytes are identical; `text-sanitized` means only machine-specific
text was replaced.

Source groups are:

- `original-v1.1.1-campaign`: original Jasper result directories;
- `focused-bundle`: existing three-candidate evidence/configuration bundle;
- `clean-export-rerun`: exported evidence and log from the later attempt;
- `clean-export-runner`: exact targeted runner files included for audit.

Sanitization replaces usernames, user-home/workspace roots, hostnames, working
directories, and license-configuration endpoints with explicit placeholders.
Tool version, property names, statuses, bounds, engine messages, solver times,
and proof/counterexample outcomes are retained. The manifest hashes the
sanitized public files; the provenance CSV separately preserves the original
source hashes.

