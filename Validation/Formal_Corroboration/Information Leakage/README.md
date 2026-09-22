# Information leakage: ten-asset repeated exclusion effort

This package represents the logical `v1.3.1-reuse10` state: ten current assets,
five baseline repeats, and five exclusion repeats per asset, for 55 runs total.
Every run exited cleanly and returned `FLOW_FOUND`.

## Result

| Excluded asset | FLOW_FOUND | Median proof (s) | Median paired proof ratio |
|---|---:|---:|---:|
| `execution_unit_0.reg_src` | 5/5 | 4.760 | 1.080 |
| `execution_unit_0.op_src` | 5/5 | 4.660 | 1.058 |
| `execution_unit_0.alu_out` | 5/5 | 4.370 | 0.995 |
| `execution_unit_0.register_file_0.reg_incr_val` | 5/5 | 4.320 | 0.995 |
| `execution_unit_0.mdb_out_nxt` | 5/5 | 4.300 | 0.973 |
| `dbg_mem_dout` | 5/5 | 4.320 | 0.984 |
| `dbg_0.mem_data` | 5/5 | 49.090 | 11.182 |
| `dbg_reg_din` | 5/5 | 24.870 | 5.713 |
| `dbg_0.mem_data_rd` | 5/5 | 80.630 | 18.358 |
| `dbg_0.dbg_uart_0.xfer_buf_nxt` | 5/5 | 31.460 | 7.185 |

The baseline median proof/search time is 4.390 s (MAD 0.080 s). Exact values,
including all proof/wall-time MADs and paired ratios, are in `evidence/summary.json`
and `evidence/asset_effort_summary.csv` and are recomputed by the top-level
verifier.

## Included

- Four headline files: `EFFORT_REPORT.md`, `summary.json`,
  `asset_effort_summary.csv`, and `raw_runs.csv`.
- For exactly the 55 current run IDs: parsed result, status, report, signoff,
  consistency, timing, command, metadata, and exit code.
- Current ten-asset CSV, Jasper configuration, source asset JSON, candidate
  reference CSV, 55 portable environment-rooted generated TCL files, and the
  original generator/parser/summarizer/validator scripts.
- Separate original-source and sanitized-public hashes plus a complete inventory.

The ten obsolete 11-asset result directories, old asset CSV, patch backups,
Jasper logs/work databases, RTL, and machine-specific paths are excluded.

## Claim boundary

Longer proof/search time after an exclusion corroborates that the modeled search
became harder and is evidence about path/search importance. It does not establish
security severity or prove that an individual signal is necessary. Because all
exclusions still found flow, each run demonstrates an alternate modeled route;
it does not demonstrate that the excluded asset is irrelevant.

To reuse a generated TCL, set `SECID_ROOT` to a full source-package checkout
that contains `rtl/`. The public artifact intentionally does not contain RTL.
