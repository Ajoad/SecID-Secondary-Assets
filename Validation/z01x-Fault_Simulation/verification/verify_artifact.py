#!/usr/bin/env python3
"""Offline integrity and accounting verification for the reviewer artifact."""

from __future__ import annotations

import csv
import gzip
import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
RESULTS = ROOT / "results" / "full_run"
ANALYSIS = RESULTS / "analysis_output"
CONFIGURATION = ROOT / "configuration"
ERRORS: list[str] = []


def check(condition: bool, message: str) -> None:
    if not condition:
        ERRORS.append(message)


def load_json(path: Path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        ERRORS.append(f"cannot parse JSON {path.relative_to(ROOT)}: {exc}")
        return {}


def load_csv(path: Path) -> list[dict[str, str]]:
    try:
        with path.open(newline="", encoding="utf-8") as handle:
            return list(csv.DictReader(handle))
    except Exception as exc:
        ERRORS.append(f"cannot parse CSV {path.relative_to(ROOT)}: {exc}")
        return []


def integer(row: dict[str, str], field: str) -> int:
    return int(row[field])


def verify_checksums() -> None:
    sums = ROOT / "SHA256SUMS.txt"
    check(sums.is_file(), "SHA256SUMS.txt is missing")
    if not sums.is_file():
        return
    count = 0
    for line in sums.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        match = re.fullmatch(r"([0-9a-f]{64})  (.+)", line)
        check(match is not None, f"malformed checksum line: {line!r}")
        if not match:
            continue
        expected, relative = match.groups()
        path = ROOT / relative
        check(path.is_file(), f"checksummed file is missing: {relative}")
        if path.is_file():
            actual = hashlib.sha256(path.read_bytes()).hexdigest()
            check(actual == expected, f"checksum mismatch: {relative}")
        count += 1
    check(count >= 100, f"checksum manifest is unexpectedly small: {count} files")


def verify_no_private_or_binary_material() -> None:
    forbidden_path_parts = {"__fmsh__", "__fubs__", "__globfiles__"}
    forbidden_suffixes = {".zdb", ".db", ".daidir"}
    # Encoded so the verifier does not contain the signatures it rejects.
    private_markers = tuple(
        bytes.fromhex(value)
        for value in (
            "6d642e686173616e",
            "2f6563656c2f55464144",
            "2f686f6d652f55464144",
            "4f6e6544726976652432302d243230556e6976657273697479",
            "636861746770742e636f6d2f",
        )
    )
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(ROOT)
        check(not (forbidden_path_parts & set(relative.parts)), f"proprietary workspace included: {relative}")
        check(path.suffix not in forbidden_suffixes, f"proprietary database included: {relative}")
        check(not path.name.startswith("zoix.sim"), f"compiled simulator included: {relative}")
        if relative == Path("SHA256SUMS.txt"):
            continue
        payload = path.read_bytes()
        if path.suffix == ".gz":
            try:
                payload = gzip.decompress(payload)
            except Exception as exc:
                ERRORS.append(f"invalid gzip file {relative}: {exc}")
                continue
        for marker in private_markers:
            check(marker not in payload, f"private marker {marker!r} remains in {relative}")


def verify_experiment_definition() -> None:
    candidates = load_csv(CONFIGURATION / "manifests" / "candidate_manifest.csv")
    check(len(candidates) == 148, f"candidate manifest count is {len(candidates)}, expected 148")
    check(len({row["candidate"] for row in candidates}) == 148, "candidate names are not unique")
    widths = sum(integer(row, "effective_bit_count") for row in candidates)
    check(widths == 1304, f"candidate effective-bit total is {widths}, expected 1304")

    campaign = load_json(CONFIGURATION / "generated" / "campaign_manifest.json")
    groups = campaign.get("groups", []) if isinstance(campaign, dict) else []
    check(len(groups) == 1, f"generated campaign group count is {len(groups)}, expected 1")
    if groups:
        check(groups[0].get("candidate_count") == 148, "generated group does not contain 148 candidates")
        check(groups[0].get("selected_bit_count") == 1304, "generated group does not contain 1,304 bits")
        check(groups[0].get("expected_unique_faults") == 2608, "generated group does not contain 2,608 faults")


def verify_matrix_results() -> None:
    rows = load_csv(ANALYSIS / "zoix_candidate_ranking.csv")
    check(len(rows) == 148, f"ranking row count is {len(rows)}, expected 148")
    if not rows:
        return
    check(len({r["candidate"] for r in rows}) == 148, "ranking candidate names are not unique")
    expected = {
        "selected_bits": 1304,
        "unique_sa_faults": 2608,
        "matrix_fault_executions_requested": 62592,
        "matrix_fault_executions_attempted": 34200,
        "matrix_fault_executions_pc_detected": 7637,
        "matrix_fault_executions_attempted_pc_not_detected": 26563,
    }
    for field, value in expected.items():
        actual = sum(integer(row, field) for row in rows)
        check(actual == value, f"{field} sums to {actual}, expected {value}")
    check(all(integer(r, "workload_count") == 8 for r in rows), "not every candidate has eight workloads")
    check(all(integer(r, "seed_count") == 3 for r in rows), "not every candidate has three seeds")
    check(all(integer(r, "workload_seed_cells") == 24 for r in rows), "not every candidate has 24 cells")
    ranks = sorted(integer(r, "rank_balanced_overall_pc_impact") for r in rows)
    check(ranks == list(range(1, 149)), "primary ranks are not a complete 1..148 ordering")
    check(rows[0]["candidate"] == "frontend_0.fetch", "unexpected first-ranked candidate")
    zero_scores = sum(float(r["balanced_matrix_overall_pc_impact_rate"]) == 0.0 for r in rows)
    check(zero_scores == 53, f"zero-score candidate count is {zero_scores}, expected 53")


def verify_campaign_audits() -> None:
    matrix = load_csv(RESULTS / "campaign_matrix.csv")
    check(len(matrix) == 24, f"campaign matrix contains {len(matrix)} rows, expected 24")
    if matrix:
        scenarios = {r["scenario"] for r in matrix}
        seeds = {integer(r, "seed") for r in matrix}
        check(len(scenarios) == 8, f"campaign matrix contains {len(scenarios)} workloads, expected 8")
        check(seeds == {20260818, 20260819, 20260820}, f"unexpected seed set: {sorted(seeds)}")
        check(sum(integer(r, "expected_faults") for r in matrix) == 62592, "campaign requested total is not 62,592")
        check(sum(integer(r, "generated_faults") for r in matrix) == 62592, "campaign generated total is not 62,592")
        check(sum(integer(r, "faults_attempted_unique") for r in matrix) == 34200, "campaign attempt total is not 34,200")
        check(sum(integer(r, "pc_detected_faults") for r in matrix) == 7637, "campaign PC-detection total is not 7,637")
        check(all(r["generation_audit_passed"] == "True" for r in matrix), "campaign index contains a failed generation audit")
        check(all(r["post_report_audit_passed"] == "True" for r in matrix), "campaign index contains a failed post-report audit")

    audit_root = RESULTS / "audits"
    audit_map = load_csv(audit_root / "audit_file_map.csv")
    check(len(audit_map) == 24, f"campaign audit map contains {len(audit_map)} rows, expected 24")
    check({r["campaign"] for r in audit_map} == {r["campaign"] for r in matrix}, "audit map and campaign matrix differ")
    for row in audit_map:
        audit_id = row["audit_id"]
        generation = load_json(audit_root / row["generation"])
        post = load_json(audit_root / row["post_report"])
        check(generation.get("campaign") == row["campaign"], f"{audit_id}: generation campaign mismatch")
        check(post.get("campaign") == row["campaign"], f"{audit_id}: post-report campaign mismatch")
        check(bool(generation.get("passed")), f"generation audit failed: {audit_id}")
        check(bool(post.get("passed")), f"post-report audit failed: {audit_id}")
        counts = generation.get("counts", {})
        for field in ("requested_faults", "fr2fdef_total_faults", "raw_standard_report_records", "manifest_mapped_unique_faults"):
            check(counts.get(field) == 2608, f"{audit_id}: {field} is not 2,608")
        report = post.get("report_audit", {})
        check(report.get("mapped_unique_faults") == 2608, f"{audit_id}: incomplete mapped post-report")
        check(post.get("attempted_unknown_status") == 0, f"{audit_id}: attempted unknown status")
        check(post.get("zero_attempt_pending_status") == 0, f"{audit_id}: zero-attempt pending status")
        check((audit_root / row["summary"]).is_file(), f"summary report missing: {audit_id}")


def verify_union_and_per_fault_results() -> None:
    stats = load_json(ANALYSIS / "ZOIX_FAULT_STATS.json")
    total = stats.get("total", {}) if isinstance(stats, dict) else {}
    expected = {
        "selected_bits": 1304,
        "faults_requested": 2608,
        "faults_attempted_unique": 1716,
        "faults_detected_pc_total": 868,
        "faults_not_detected_pc": 848,
        "faults_unresolved": 0,
        "faults_missing_report_record": 0,
        "faults_attempted_other_unresolved": 0,
        "faults_zero_attempt_pending_status": 0,
    }
    for field, value in expected.items():
        check(total.get(field) == value, f"union {field} is {total.get(field)!r}, expected {value}")
    check(total.get("zoix_analysis_resolution_rate") == 1.0, "union analysis resolution is not 100%")
    unmatched = load_json(ANALYSIS / "parser_unmatched_lines.json")
    check(unmatched == [], "parser unmatched-line report is not empty")

    compressed = ANALYSIS / "zoix_per_fault_outcomes.json.gz"
    try:
        outcomes = json.loads(gzip.decompress(compressed.read_bytes()))
    except Exception as exc:
        ERRORS.append(f"cannot decode per-fault outcomes: {exc}")
        return
    check(isinstance(outcomes, list), "per-fault outcomes are not a JSON list")
    if not isinstance(outcomes, list):
        return
    check(len(outcomes) == 2608, f"per-fault outcome count is {len(outcomes)}, expected 2,608")
    identities = {(x.get("target_path"), x.get("polarity")) for x in outcomes}
    check(len(identities) == 2608, "per-fault identities are not unique")
    record_count = sum(len(x.get("campaign_records", [])) for x in outcomes)
    check(record_count == 62592, f"per-fault campaign-record count is {record_count}, expected 62,592")


def verify_baselines_and_compile() -> None:
    compile_audit = load_json(RESULTS / "COMPILE_AUDIT.json")
    check(bool(compile_audit.get("passed")), "compile instrumentation audit did not pass")
    fingerprint = load_json(RESULTS / "BASELINE_FINGERPRINT_AUDIT.json")
    check(bool(fingerprint.get("passed")), "baseline fingerprint audit did not pass")
    workloads = fingerprint.get("workloads", []) if isinstance(fingerprint, dict) else []
    check(len(workloads) == 8, f"baseline audit contains {len(workloads)} workloads, expected 8")
    for workload in workloads:
        check(workload.get("seed_count") == 3, f"{workload.get('workload')}: baseline seed count is not 3")
        check(workload.get("stimulus_unique_hash_count") == 3, f"{workload.get('workload')}: stimuli are not 3/3 unique")
        check(bool(workload.get("passed")), f"{workload.get('workload')}: fingerprint audit failed")
    preflight = load_json(RESULTS / "BASELINE_PREFLIGHT.json")
    check(bool(preflight.get("passed")), "baseline preflight did not pass")
    check(bool(preflight.get("fingerprint_audit_passed")), "baseline preflight did not accept fingerprint audit")


def main() -> int:
    verify_checksums()
    verify_no_private_or_binary_material()
    verify_experiment_definition()
    verify_matrix_results()
    verify_campaign_audits()
    verify_union_and_per_fault_results()
    verify_baselines_and_compile()
    if ERRORS:
        print(f"FAIL: {len(ERRORS)} verification error(s)", file=sys.stderr)
        for error in ERRORS:
            print(f"  - {error}", file=sys.stderr)
        return 1
    print("PASS: reviewer artifact integrity and accounting verified")
    print("  148 candidates; 1,304 bits; 2,608 unique SA faults")
    print("  24 campaigns; 62,592 requested; 34,200 attempted; 7,637 PC-detected")
    print("  all generation/post-report audits passed; unresolved/missing = 0")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
