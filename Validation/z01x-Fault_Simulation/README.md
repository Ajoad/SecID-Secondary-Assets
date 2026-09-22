# OpenMSP430 Z01X Reviewer Results v1.1.1

This Windows-safe compact package contains the exact Z01X/testbench configuration, fault manifests, completed structured results, all 24 campaign audits, sanitized run logs, and integrity metadata.

Campaign audit filenames are shortened to `c00`–`c23` to avoid the Windows `MAX_PATH` extraction error. Their complete original campaign names remain inside each audit and in `results/full_run/audits/audit_file_map.csv`.

## Verify

Open PowerShell or a terminal in the extracted directory and run:

```text
python verification/verify_artifact.py
```

Expected result:

```text
PASS: reviewer artifact integrity and accounting verified
  148 candidates; 1,304 bits; 2,608 unique SA faults
  24 campaigns; 62,592 requested; 34,200 attempted; 7,637 PC-detected
  all generation/post-report audits passed; unresolved/missing = 0
```

## Contents

- `configuration/`: testbench, Z01X policy/strobes, candidate manifest, SFF, and bit-level fault manifests.
- `results/full_run/`: complete rankings, baseline evidence, compact campaign audits, sanitized logs, and compressed per-fault outcomes.
- `RESULTS.md`: methodology, accounting, and primary candidate ranking.
- `verification/verify_artifact.py`: offline integrity/accounting check.
- `PROVENANCE.json` and `SHA256SUMS.txt`: traceability and file-integrity records.

The package intentionally excludes RTL, run/analysis scripts, simulator executables/databases, repetitive raw reports, and the separately discussed FIF/FM comparison.

If an older Windows extractor still reports an error, extract the ZIP to a short location such as `C:\z01x`.
