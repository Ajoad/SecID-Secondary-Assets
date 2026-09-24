# Information leakage: ten-asset repeated exclusion effort

This directory archives the JasperGold results used for the openMSP430
information-leakage formal corroboration. The artifacts are provided as result
evidence and are not intended as a self-contained reproduction environment.

The archived campaign contains ten current assets, five baseline repeats, and
five exclusion repeats per asset, for 55 runs total. Every archived run exited
cleanly and returned `FLOW_FOUND`.

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
including the proof/wall-time statistics and paired ratios, are archived in
`evidence/summary.json` and `evidence/asset_effort_summary.csv`.

## Included

- `EFFORT_REPORT.md`, `summary.json`, `asset_effort_summary.csv`, and
  `raw_runs.csv`.
- For each of the 55 archived runs: parsed result, status, report, signoff,
  consistency information, timing, command, metadata, and exit code.
- The current ten-asset configuration, Jasper configuration, source asset JSON,
  and candidate-reference files.

## Interpretation

All exclusions still produce an information-flow witness, indicating the
existence of alternative leakage paths. However, exclusion of several assets
substantially increases JasperGold search effort. In particular,
`dbg_0.mem_data_rd`, `dbg_0.mem_data`,
`dbg_0.dbg_uart_0.xfer_buf_nxt`, and `dbg_reg_din` produce the largest
increases relative to the baseline, providing formal corroboration that these
SecID-selected assets strongly mediate the modeled leakage path.