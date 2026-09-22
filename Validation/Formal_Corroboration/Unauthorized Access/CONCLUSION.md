# Conclusion: UA three-candidate individual exclusion

## Supported conclusion

The original Jasper v1.1.1 campaign supports the following bounded statement:

> Under the included post-PMP UCP attack model, semantic contexts, assumptions,
> relational equality exclusions, and 900-cycle property construction,
> individually constraining `prv_level` or `mstatus_mpp` eliminated all modeled
> bypasses. Individually constraining `mstatus_mprv` did not eliminate all
> modeled bypasses; Jasper found a counterexample demonstrating an alternative
> modeled route.

The three selected-candidate outcomes are therefore two
`NO_BYPASS_PROVEN` results and one `BYPASS_CEX` result.

| Case | Candidate | Original exclusion outcome | Jasper-reported property time | Evidence completeness |
|---|---|---|---:|---|
| `prv_level_s0` | `neorv32_cpu_control.csr.prv_level` | `NO_BYPASS_PROVEN` | 305.610 s | `LOG_RECOVERED` |
| `mstatus_mpp_s2` | `neorv32_cpu_control.csr.mstatus_mpp` | `NO_BYPASS_PROVEN` | 1194.927 s | `COMPLETE_EXPORTED_STATUS` |
| `mstatus_mprv_s2` | `neorv32_cpu_control.csr.mstatus_mprv` | `BYPASS_CEX` | 61.748 s | `COMPLETE_EXPORTED_STATUS` |

The times above are Jasper's per-property solver times. They are not all total
job wall-clock times, and proof and counterexample times should not be compared
as though they measure the same search task.

## Evidence basis

For every candidate, the package contains a valid UCP bypass baseline and a
same-trace mediated-bypass result. For the two clean individual exclusions,
the bundled classifier re-derives the reported outcomes from exported
`status.tsv` files.

The original `prv_level_s0` run is different. Its Jasper log contains all four
conditions required by the exclusion classifier:

1. `UA_COVER_ATTACK` was covered in 42 cycles.
2. `UA_GOLDEN_NONVACUOUS_BY_BOUND:precondition1` was covered in 901 cycles.
3. `UA_GOLDEN_NONVACUOUS_BY_BOUND` was proven.
4. `UA_EXCLUSION_NO_BYPASS_BY_BOUND` was proven in 305.61 seconds.

The enclosing `prove -all` continued working on an auxiliary cover and the
process later exited with code 1 before the TCL export statements ran. No
tool-generated `status.tsv` or `report.rpt` exists for that original exclusion
run. The package therefore retains the complete sanitized log and labels the
outcome `LOG_RECOVERED`; it does not fabricate an exported report.

