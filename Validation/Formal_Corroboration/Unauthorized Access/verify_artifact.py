#!/usr/bin/env python3
"""Offline verifier for the UA three-candidate corroboration artifact."""

from __future__ import annotations

import csv
import hashlib
import importlib.util
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent
ERRORS: list[str] = []
sys.dont_write_bytecode = True


def check(condition: bool, message: str) -> None:
    if not condition:
        ERRORS.append(message)


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def load_status_tool():
    path = ROOT / "tools/status.py"
    spec = importlib.util.spec_from_file_location("ua_artifact_status", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def verify_manifest() -> None:
    manifest = ROOT / "MANIFEST.sha256"
    check(manifest.is_file(), "MANIFEST.sha256 is missing")
    if not manifest.is_file():
        return
    entries: dict[str, str] = {}
    for line_number, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
        match = re.fullmatch(r"([0-9a-f]{64})  (.+)", line)
        check(match is not None, f"malformed manifest line {line_number}")
        if match:
            entries[match.group(2)] = match.group(1)
    actual = {
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob("*")
        if path.is_file() and path.name != "MANIFEST.sha256"
    }
    check(set(entries) == actual, "manifest file set does not match package file set")
    for relative, expected in entries.items():
        check(sha256(ROOT / relative) == expected, f"manifest hash mismatch: {relative}")


def verify_classifications() -> None:
    status = load_status_tool()
    expected = {
        ("golden", "golden/s0_a0"): "GOLDEN_PASS",
        ("golden", "golden/s2_a0"): "GOLDEN_PASS",
        ("ucp_baseline", "ucp_baseline/s0_a0"): "BYPASS_CEX",
        ("ucp_baseline", "ucp_baseline/s2_a0"): "BYPASS_CEX",
        ("mediation", "mediation/prv_level_s0"): "MEDIATED_BYPASS_CEX",
        ("mediation", "mediation/mstatus_mpp_s2"): "MEDIATED_BYPASS_CEX",
        ("mediation", "mediation/mstatus_mprv_s2"): "MEDIATED_BYPASS_CEX",
        ("exclusion", "exclusion/mstatus_mpp_s2"): "NO_BYPASS_PROVEN",
        ("exclusion", "exclusion/mstatus_mprv_s2"): "BYPASS_CEX",
    }
    for (mode, relative), outcome in expected.items():
        result = status.classify(ROOT / "results" / relative / "status.tsv", mode)
        check(result["valid"], f"invalid classification prerequisites: {relative}")
        check(result["outcome"] == outcome, f"wrong outcome for {relative}: {result['outcome']}")


def verify_original_summary() -> None:
    summary_path = ROOT / "results/three_candidate_summary.csv"
    rows = {row["case_id"]: row for row in csv.DictReader(summary_path.open(newline="", encoding="utf-8"))}
    expected = {
        "prv_level_s0": ("NO_BYPASS_PROVEN", "LOG_RECOVERED", "305.61"),
        "mstatus_mpp_s2": ("NO_BYPASS_PROVEN", "COMPLETE_EXPORTED_STATUS", "1194.927"),
        "mstatus_mprv_s2": ("BYPASS_CEX", "COMPLETE_EXPORTED_STATUS", "61.748"),
    }
    check(set(rows) == set(expected), "three-candidate summary does not contain exactly the expected cases")
    for case_id, values in expected.items():
        row = rows.get(case_id, {})
        actual = (
            row.get("individual_exclusion"),
            row.get("evidence_completeness"),
            row.get("main_property_solver_seconds"),
        )
        check(actual == values, f"summary mismatch for {case_id}: {actual}")

    prv_log = (ROOT / "results/exclusion/prv_level_s0/jasper.log").read_text(
        encoding="utf-8", errors="replace"
    )
    required = (
        'UA_COVER_ATTACK" was covered in 42 cycles',
        'UA_GOLDEN_NONVACUOUS_BY_BOUND:precondition1" was covered in 901 cycles',
        'UA_GOLDEN_NONVACUOUS_BY_BOUND" was proven in 13.52 s',
        'UA_EXCLUSION_NO_BYPASS_BY_BOUND" was proven in 305.61 s',
    )
    for message in required:
        check(message in prv_log, f"missing decisive original prv_level evidence: {message}")
    check((ROOT / "results/exclusion/prv_level_s0/exit_code.txt").read_text().strip() == "1",
          "original prv_level process exit code is not preserved as 1")
    check(not (ROOT / "results/exclusion/prv_level_s0/status.tsv").exists(),
          "original prv_level directory must not contain a fabricated status.tsv")
    check(not (ROOT / "results/exclusion/prv_level_s0/report.rpt").exists(),
          "original prv_level directory must not contain a fabricated report.rpt")

    reports = {
        "mstatus_mpp_s2": ("proven", "1194.927"),
        "mstatus_mprv_s2": ("cex", "61.748"),
    }
    for case_id, (outcome, seconds) in reports.items():
        report = (ROOT / f"results/exclusion/{case_id}/report.rpt").read_text(encoding="utf-8")
        check("UA_EXCLUSION_NO_BYPASS_BY_BOUND" in report, f"missing main property in {case_id} report")
        check(outcome in report and seconds in report, f"missing {outcome}/{seconds} in {case_id} report")


def verify_reproduction_attempt() -> None:
    base = ROOT / "reproduction-attempt/prv_level_s0_20260922"
    acceptance = json.loads((base / "evidence/acceptance.json").read_text(encoding="utf-8"))
    check(acceptance.get("accepted") is False, "reproduction attempt must remain rejected")
    check(acceptance.get("outcome") == "UNRESOLVED", "reproduction attempt must be UNRESOLVED")
    check(acceptance.get("elapsed_ms") == 1866173, "unexpected reproduction elapsed time")
    statuses = load_status_tool().read_status(base / "evidence/status.tsv")
    main = load_status_tool().find(statuses, "UA_EXCLUSION_NO_BYPASS_BY_BOUND")
    check(main == "undetermined", f"reproduction main status is {main}, not undetermined")
    log = (base / "jasper.log").read_text(encoding="utf-8", errors="replace")
    check("Time limit expired (1800.00 s)" in log, "reproduction log lacks the 1800-second limit")
    check("SECID_UA_TARGETED_EXPORT_COMPLETE" in log, "reproduction log lacks export completion")


def verify_provenance() -> None:
    path = ROOT / "provenance/original_to_public_hashes.csv"
    rows = list(csv.DictReader(path.open(newline="", encoding="utf-8")))
    check(len(rows) == 95, f"expected 95 provenance rows, found {len(rows)}")
    for row in rows:
        public = ROOT / row["public_path"]
        check(public.is_file(), f"provenance public file missing: {row['public_path']}")
        if public.is_file():
            check(sha256(public) == row["public_sha256"],
                  f"public provenance hash mismatch: {row['public_path']}")
        check(re.fullmatch(r"[0-9a-f]{64}", row["original_sha256"]) is not None,
              f"invalid original hash: {row['public_path']}")
        check(row["transformation"] in {"verbatim", "text-sanitized"},
              f"invalid provenance transformation: {row['public_path']}")


def verify_privacy_and_structure() -> None:
    forbidden_parts = {"jgproject", "work", "__pycache__", ".cache"}
    for path in ROOT.rglob("*"):
        relative = path.relative_to(ROOT)
        check(not forbidden_parts.intersection(relative.parts), f"forbidden path included: {relative}")

    logs = list(ROOT.rglob("jasper.log"))
    check(len(logs) == 11, f"expected 11 Jasper logs, found {len(logs)}")

    private_patterns = (
        re.compile(r"md[.]hasan", re.IGNORECASE),
        re.compile("/" + "ecel" + "/", re.IGNORECASE),
        re.compile("/home/" + "UFAD/", re.IGNORECASE),
        re.compile("ece-" + "lnx-" + "06", re.IGNORECASE),
        re.compile("ece-" + "lnx-" + "06[.]ad[.]ufl[.]edu", re.IGNORECASE),
    )
    for path in (item for item in ROOT.rglob("*") if item.is_file()):
        if path.suffix.lower() in {".zip", ".png", ".jpg", ".jpeg"}:
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        for pattern in private_patterns:
            check(pattern.search(text) is None, f"privacy pattern found in {path.relative_to(ROOT)}")


def verify_tool_version() -> None:
    evidence_files = list((ROOT / "results").rglob("report.rpt"))
    evidence_files += [
        ROOT / "results/exclusion/prv_level_s0/jasper.log",
        ROOT / "reproduction-attempt/prv_level_s0_20260922/evidence/report.rpt",
    ]
    for path in evidence_files:
        check("2024.09p001" in path.read_text(encoding="utf-8", errors="replace"),
              f"Jasper version missing from {path.relative_to(ROOT)}")


def main() -> int:
    verify_manifest()
    verify_classifications()
    verify_original_summary()
    verify_reproduction_attempt()
    verify_provenance()
    verify_privacy_and_structure()
    verify_tool_version()
    if ERRORS:
        for error in ERRORS:
            print(f"[FAIL] {error}", file=sys.stderr)
        print(f"FAILED: {len(ERRORS)} check(s)", file=sys.stderr)
        return 1
    print("PASS: manifest, outcomes, timings, provenance, privacy, and structure verified")
    print("PASS: original campaign = 2 NO_BYPASS_PROVEN / 1 BYPASS_CEX")
    print("PASS: later prv_level clean-export attempt is separately recorded as UNRESOLVED")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
