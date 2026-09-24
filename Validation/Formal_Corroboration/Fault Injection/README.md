# Fault injection: final-seven, five-seed analysis

This directory archives the JasperGold results used for the CV32E40P
fault-injection formal corroboration. The artifacts are provided as result
evidence and are not intended as a self-contained reproduction environment.

The analysis compares the final seven SecID-selected signals against five
equal-size frozen random-control cohorts. All 100 selected/control jobs are
valid.

## Result

| Signal-weighted metric | Selected | Mean random | Enrichment |
|---|---:|---:|---:|
| Primary witness yield | 1.000000 | 0.178571 | 5.6x |
| Semantic witness yield | 0.785714 | 0.178571 | 4.4x |

Selected yield is greater than the corresponding random yield in all five seeds.

The selected **signal-weighted** semantic yield is 0.785714, computed as the
mean over the seven selected signals. The corresponding **job-weighted**
semantic yield is 7/10 = 0.7. These are different estimands and should not be
interchanged.

## Included

- `FINAL7_REUSE_AUDIT.json`, the five-seed CSV/JSON summaries, and all five
  per-seed comparison JSON/CSV pairs.
- The final-seven asset source, selected opportunity manifest, and the five
  frozen control signal/opportunity manifests.
- Selected and control aggregate `per_job`, `per_signal`, and `summary`
  JSON/CSV files for all 100 valid jobs.

## Sampling and inference boundary

Each control cohort is the first seven signals from a previously frozen
seed-shuffled order. It is not a fresh sample from the exact updated final-seven
pool. The 35 control observations contain 33 unique signals because two signals
recur across seeds. Therefore, the five seeds should not be pooled and treated
as 35 independent control observations. The same selected cohort is also reused
in every seed comparison.

UNKNOWN outcomes remain unresolved and are never reclassified as safe. Results
apply to the included one-cycle fault and 24-cycle observation contract.

## Result summary

For CV32E40P, the 7-signal SecID cohort is compared in JasperGold FPV with
equal-size randomly selected structurally connected sets across five seeds.
The SecID cohort achieves a 100% primary-asset fault-witness yield, compared
with a 17.9% mean for the random cohorts. The SecID cohort also achieves a
78.6% signal-weighted attack-relevant semantic witness yield along the
fault-propagation path, compared with a 17.9% random-cohort mean.