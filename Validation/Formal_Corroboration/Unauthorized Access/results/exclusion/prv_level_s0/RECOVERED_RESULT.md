# Recovered `prv_level_s0` exclusion result

The original Jasper process returned exit code `1` before the generated TCL
reached its status/report export commands. The raw log nevertheless contains a
completed proof of the main exclusion assertion and the validity evidence used
by the package's exclusion classifier.

Original raw log:

```text
neorv32_lsu_priv_jasper_ua_mediation_v1_1_1/results/exclusion/prv_level_s0/jasper.log
SHA-256: 2bc31e82eb0ebcbf176c5c5fcc2b6465e4ff5245a02acfe28b55d05535f5523b
Size: 259748 bytes
```

Decisive messages, with original one-based log line numbers:

```text
229: INFO (IPF047): 2.0.Bm: The cover property "ua_exclusion_prv_level_s0.UA_COVER_ATTACK" was covered in 42 cycles in 0.18 s.
940: INFO (IPF047): 2.0.J: The cover property "ua_exclusion_prv_level_s0.UA_GOLDEN_NONVACUOUS_BY_BOUND:precondition1" was covered in 901 cycles in 0.78 s.
2639: INFO (IPF057): 2.0.Bcustom1: The property "ua_exclusion_prv_level_s0.UA_GOLDEN_NONVACUOUS_BY_BOUND" was proven in 13.52 s.
3245: INFO (IPF057): 2.0.Ht: The property "ua_exclusion_prv_level_s0.UA_EXCLUSION_NO_BYPASS_BY_BOUND" was proven in 305.61 s.
```

Immediately before the final message, Jasper also reports:

```text
2.0.Ht: Trace Attempt 901 [306.06 s]
2.0.Ht: A proof was found: No trace exists. [306.39 s]
```

The original `tools/status.py` exclusion classifier requires the golden
non-vacuity assertion to be proven, its precondition to be covered, and the
attack cover to be covered before classifying a proven main assertion as
`NO_BYPASS_PROVEN`. All four decisive conditions are present above.

Because no exported `status.tsv` or `report.rpt` exists for this run, this file
does not pretend to be tool-generated output. It is a provenance-preserving
record extracted from the raw log. A fresh rerun is optional but recommended if
a clean export is required.

