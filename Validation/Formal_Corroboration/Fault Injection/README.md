# Fault injection: final-seven, five-seed reuse analysis

This package contains the normalized final-seven comparison and its full
five-seed sensitivity evidence. All 100 selected/control jobs are valid.

## Result

| Signal-weighted metric | Selected | Mean random | Enrichment |
|---|---:|---:|---:|
| Primary witness yield | 1.000000 | 0.178571 | 5.6x |
| Semantic witness yield | 0.785714 | 0.178571 | 4.4x |

Selected yield is greater than the corresponding random yield in all five seeds.
The selected **signal-weighted** semantic yield is 0.785714 (mean over seven
signals). The **job-weighted** selected semantic yield is 7/10 = 0.7. These are
different estimands and must not be interchanged.

## Included

- `FINAL7_REUSE_AUDIT.json`, five-seed CSV/JSON summaries, and all five
  per-seed comparison JSON/CSV pairs.
- Final-seven asset source, selected opportunity manifest, and the five frozen
  control signal/opportunity manifests.
- Selected and control aggregate `per_job`, `per_signal`, and `summary` JSON/CSV
  for all 100 valid jobs.
- Reuse-patch, comparison, aggregation, and five-seed analysis scripts.
- Explicit selected-result provenance and separate source/public hashes.

## Sampling and inference boundary

Each control cohort is the first seven signals from a previously frozen v1.3.0
seed-shuffled order. It is not a fresh sample from the exact updated final-seven
pool. The 35 control observations contain 33 unique signals because two signals
recur across seeds. Seeds therefore must not be pooled or treated as 35
independent control observations. The same selected cohort is also reused in
every seed comparison.

UNKNOWN outcomes remain unresolved and are never reclassified as safe. Results
apply to the included one-cycle fault and 24-cycle observation contract.
