# Single-exclusion SPV effort report (core)

Baseline runs found: **5/5**; FLOW=5, NO_FLOW=0, UNRESOLVED=0.
Baseline median SPV proof/search time: **4.390 s** (MAD 0.080 s); median wall: **10.600 s**; median CEX: **573.0 cycles**.

| # | Excluded asset | FLOW | NO-FLOW | UNRES | Median proof s | Paired proof ratio | Median CEX | Interpretation |
|---:|---|---:|---:|---:|---:|---:|---:|---|
| 0 | `execution_unit_0.reg_src` | 5 | 0 | 0 | 4.760 | 1.080 | 843.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 1 | `execution_unit_0.op_src` | 5 | 0 | 0 | 4.660 | 1.058 | 843.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 2 | `execution_unit_0.alu_out` | 5 | 0 | 0 | 4.370 | 0.995 | 573.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 3 | `execution_unit_0.register_file_0.reg_incr_val` | 5 | 0 | 0 | 4.320 | 0.995 | 573.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 4 | `execution_unit_0.mdb_out_nxt` | 5 | 0 | 0 | 4.300 | 0.973 | 574.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 5 | `dbg_mem_dout` | 5 | 0 | 0 | 4.320 | 0.984 | 986.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 6 | `dbg_0.mem_data` | 5 | 0 | 0 | 49.090 | 11.182 | 986.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 7 | `dbg_reg_din` | 5 | 0 | 0 | 24.870 | 5.713 | 640.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 8 | `dbg_0.mem_data_rd` | 5 | 0 | 0 | 80.630 | 18.358 | 458.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |
| 9 | `dbg_0.dbg_uart_0.xfer_buf_nxt` | 5 | 0 | 0 | 31.460 | 7.185 | 368.0 | FLOW_REMAINS_COMPARE_SEARCH_EFFORT |

## Guardrails
- Search-effort ratios are interpreted primarily for paired `FLOW_FOUND` runs.
- Clean `NO_FLOW_PROVEN` is a stronger status transition, not merely a larger runtime.
- Remaining `FLOW_FOUND` means an alternate modeled route exists; it does not make the excluded asset irrelevant.
- CEX cycles are observed witness lengths, not guaranteed shortest paths.
- Unresolved or signoff-risk runs remain qualified.
