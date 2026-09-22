# CV32E40P FI final10 -> final7 zero-rerun reuse patch

This patch is intentionally non-destructive. It does **not** overwrite the existing final10 campaign or its results.

It validates that the new source JSON contains exactly these seven retained assets:

- `core_i.id_stage_i.deassert_we`
- `core_i.data_misaligned`
- `core_i.csr_op`
- `core_i.id_stage_i.decoder_i.csr_op`
- `core_i.id_stage_i.csr_op`
- `core_i.id_ready`
- `core_i.ex_ready`

Because these seven are an exact subset of the prior final10 campaign, the selected Jasper jobs are reused exactly.

For each of the five already-frozen random cohorts, the patch takes the **first seven signals in the previously frozen random order** and reuses their existing Jasper results. This requires no Jasper rerun. A prefix of an already-random ordered sample is itself a random sample from that same frozen sampling frame; the prefix length 7 is dictated by the updated selected-cohort size, not by formal outcomes.

Important publication boundary: the prior v1.3.0 control pool had 479 eligible signals. With only the current final7 excluded, the exact updated pool has 481. The zero-rerun analysis therefore uses the previously frozen v1.3.0 sampling frame; it should not be described as a fresh uniform sample from the exact updated 481-signal pool. `FINAL7_REUSE_AUDIT.json` reports the precise difference.

## Run

From the parent directory containing both the patch folder and the completed v1.3.0 run directory:

```bash
python3 cv32e40p_csr_we_int_final7_reuse_patch_v1_0/apply_final7_reuse_patch.py \
  --target cv32e40p_csr_we_int_targeted_fi_v1_3_0_final10_5seed
```

Main outputs are created under:

```text
cv32e40p_csr_we_int_targeted_fi_v1_3_0_final10_5seed/final7_reuse_analysis/
```

including `final7_5seed_summary.json`, `final7_5seed_summary.csv`, five per-seed comparison JSONs, and `FINAL7_REUSE_AUDIT.json`.
