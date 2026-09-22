# SecID: Threat-Aware RTL Secondary-Asset Identification Artifacts

This is the repository for *SecID: An LLM-Guided Framework for Threat-Aware Secondary Asset Identification with Quantitative RTL Analysis*. The repository seven open-source processor and IP designs with twelve primary-asset–threat cases. It evaluates information leakage (IL), unauthorized access (UA), fault injection (FI), and denial of service (DoS).

## Repository organization

| Path | Contents |
|---|---|
| [`00_SecID_Results_00/`](./00_SecID_Results_00/) | Agent-wise intermediate candidates along with functional-influence values, threat-feature measurements, and final secondary assets for all twelve cases. |
| [`Agent-3 Threat_Scenarios/`](./Agent-3%20Threat_Scenarios/) | Eighteen feature-specific scenario sets containing 856 structured dynamic-simulation requirements. |
| [`Agent-4 Cluster-local_RTL Guarded_Paths/`](./Agent-4%20Cluster-local_RTL%20Guarded_Paths/) | 133 candidate clusters with localized RTL and guarded dependency-path evidence. |
| [`Agent-4 Attack_Mechanisms/`](./Agent-4%20Attack_Mechanisms/) | Candidate-local threat-specific attack mechanisms derived from the localized RTL evidence. |
| [`Reference_Asset Annotations.xlsx`](./Reference_Asset%20Annotations.xlsx) | Expert-curated reference assets and natural-language rationales for the twelve cases. |
| [`Validation/`](./Validation/) | Formal corroboration for representative IL, UA, and FI cases; final-stage ablation and repeatability annotations; threshold-sensitivity analysis; and a Z01X fault-simulation result package. |

The validation materials are organized as
[`Formal_Corroboration/`](./Validation/Formal_Corroboration/),
[`Final-Stage_Ablation Annotations/`](./Validation/Final-Stage_Ablation%20Annotations/),
[`LLM_Repeatability Annotations/`](./Validation/LLM_Repeatability%20Annotations/),
[`Threshold_Sensitivity 4_Case_Studies.csv`](./Validation/Threshold_Sensitivity%204_Case_Studies.csv),
and [`z01x-Fault_Simulation/`](./Validation/z01x-Fault_Simulation/).

## Case studies

Final counts are reported in threat order when a primary asset is evaluated
under two threats.

| Design | Primary asset | Threat case(s) | Final secondary assets |
|---|---|---|---:|
| openMSP430 | `pc` | FI | 19 |
| openMSP430 | `r4` | IL | 10 |
| openMSP430 | `exec_done` | DoS | 11 |
| NEORV32 | `lsu_priv` | UA; FI | 12; 8 |
| CV32E40P | `csr_we_int` | UA; FI | 4; 7 |
| APB GPIO | `gpio_dir` | UA; FI | 3; 6 |
| AXI adapter | `valid_o` | DoS | 9 |
| SHA-3 | `keccak_in` | IL | 6 |
| AES core | `key` | IL | 20 |

## SecID results

| File | Interpretation |
|---|---|
| `01_initial_candidates.csv` | Canonical RTL candidates obtained from the program-dependence graph. |
| `02_filtered_candidates.csv` | Candidates retained by Boolean functional-influence analysis, with aggregate, path, guard, and legal-mode influence values. |
| `03a_*.csv`, `03b_*.csv` | The two normalized, threat-specific evidence channels and their available measurement metadata. |
| `04_final_secondary_assets.json` | Final retained assets with structural paths, attack mechanisms, normalized evidence, and decision rationales. |
