# Fault-Simulation Results

## Experiment

- Design: OpenMSP430
- Primary asset/detector: `tb.dut_g.frontend_0.pc[15:0]`
- Direction: retained candidate bit → PC
- Fault model: one permanent stuck-at-0 and stuck-at-1 fault per selected bit
- Fault collapsing: disabled
- Matrix: 8 workloads × 3 seeds = 24 equally weighted cells per candidate
- Detection: Z01X status U8/U9 after `$fs_compare` observes a PC difference
- Attempt indicator: `FaultInfo.Attempts > 0`

The 24 campaigns cover `core_mix`, `branch_mix`, `call_return`, `memory_mix`, `peripheral_mix`, `interrupt_mix`, `dma_contention`, and `debug_uart`, each with seeds 20260818, 20260819, and 20260820.

## Accounting

Two views are reported and must not be conflated:

| View | Requested | Attempted | PC detected | PC not detected after attempt |
|---|---:|---:|---:|---:|
| Balanced execution matrix | 62,592 | 34,200 | 7,637 | 26,563 |
| Unique-fault union across all cells | 2,608 | 1,716 | 868 | 848 |

The matrix view counts every fault/workload/seed execution and is the basis of the balanced ranking. The union view asks whether each physical SA fault was ever attempted or detected anywhere in the matrix.

All 24 generation audits satisfy:

```text
requested = fr2fdef total = raw report records = manifest-mapped faults = 2,608
```

All 24 post-report audits pass. The final union accounting has zero unresolved faults, zero missing report records, zero attempted unknown statuses, and a 100% analysis-resolution rate.

## Primary ranking

For candidate `c`, the primary score is:

```text
balanced overall PC-impact rate(c)
  = PC-detected executions(c)
    / [selected SA faults(c) × 24 workload-seed cells]
```

This score is width-normalized and gives every candidate identical workload/seed exposure.

| Rank | Candidate | Overall PC impact | Attempt rate | PC impact given attempted |
|---:|---|---:|---:|---:|
| 1 | `frontend_0.fetch` | 0.9375 | 1.0000 | 0.9375 |
| 2 | `exec_done` | 0.9375 | 1.0000 | 0.9375 |
| 3 | `frontend_0.i_state` | 0.9167 | 0.9167 | 1.0000 |
| 4 | `frontend_0.i_state_nxt` | 0.9167 | 0.9167 | 1.0000 |
| 5 | `frontend_0.e_state_nxt` | 0.8594 | 1.0000 | 0.8594 |
| 6 | `frontend_0.e_first_state` | 0.8177 | 0.9062 | 0.9023 |
| 7 | `mem_backbone_0.fe_mab` | 0.7014 | 0.8667 | 0.8093 |
| 8 | `mem_backbone_0.pmem_dout` | 0.6875 | 0.9128 | 0.7532 |
| 9 | `frontend_0.decode` | 0.6875 | 1.0000 | 0.6875 |
| 10 | `decode_noirq` | 0.6875 | 1.0000 | 0.6875 |

There are 53 candidates with zero balanced PC impact. Low-score interpretation should consider attempt coverage. The strongest zero-impact examples include `frontend_0.sconst_nxt` (attempt rate 1.0), `execution_unit_0.alu_0.alu_sxt` (0.9375), `frontend_0.dest_reg` (0.9375), `execution_unit_0.alu_0.alu_shift` (0.9010), and `dbg_0.cpu_stat_set` (0.75).

Complete rankings and per-workload/seed statistics are under `results/full_run/analysis_output/`.

## Seed-diversity evidence

Every workload has three distinct realized stimulus hashes. The raw seed label is excluded from the hash source, preventing labels alone from manufacturing diversity. Seven workloads retain the same nominal PC trace across seeds; `dma_contention` produces three distinct PC traces. The appropriate claim is therefore three distinct realized stimulus variants per workload, not three independent control-flow paths per workload.
