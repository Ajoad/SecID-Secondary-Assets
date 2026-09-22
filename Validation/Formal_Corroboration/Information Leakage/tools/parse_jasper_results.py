#!/usr/bin/env python3
"""Parse Jasper SPV campaign results into normalized SecID semantics and metrics.

Conservative normalization:
  CEX / counterexample / falsified -> FLOW_FOUND
  proven / proved / pass           -> NO_FLOW_PROVEN
  timeout / error / unknown        -> UNRESOLVED

Missing information is never converted into a security claim.
"""
from __future__ import annotations
import argparse, csv, json, re
from pathlib import Path

FLOW_WORDS = ("counterexample", "cex", "falsified", "failed", " fail")
PROVEN_WORDS = ("proven", "proved", " pass")
UNRES_WORDS = ("undetermined", "unresolved", "explored", "timeout", "unknown", "error", "aborted", "inconclusive")


def canonical_prop(name: str) -> str:
    name = (name or "").strip().strip('"')
    if "::SECID_" in name:
        name = name[name.rfind("::") + 2:]
    return name


def norm(raw: str) -> str:
    s = (raw or "").strip().lower()
    if any(w in s for w in FLOW_WORDS):
        return "FLOW_FOUND"
    if any(w in s for w in PROVEN_WORDS):
        return "NO_FLOW_PROVEN"
    if any(w in s for w in UNRES_WORDS):
        return "UNRESOLVED"
    return "UNRESOLVED"


def parse_status_tsv(p: Path):
    out = {}
    if not p.exists() or p.stat().st_size == 0:
        return out
    try:
        with open(p, newline="") as f:
            for r in csv.DictReader(f, delimiter="\t"):
                name = canonical_prop(r.get("property") or "")
                raw = (r.get("status") or "").strip()
                if name.startswith("SECID_"):
                    out[name] = (raw, norm(raw), "status.tsv")
    except Exception:
        pass
    return out


def parse_log_status(text: str):
    out = {}
    props = sorted(set(re.findall(r"\bSECID_[A-Za-z0-9_]+\b", text)))
    lines = text.splitlines()
    for prop in props:
        # Prefer an explicit result line mentioning the property.
        best = None
        for line in lines:
            if prop not in line:
                continue
            low = line.lower()
            token = None
            for w in ("counterexample", "cex", "falsified", "proven", "proved", "undetermined", "unresolved", "timeout", "error", "failed"):
                if w in low:
                    token = w
                    break
            if token:
                best = (token, norm(token), "jasper.log")
                if norm(token) in ("FLOW_FOUND", "NO_FLOW_PROVEN"):
                    break
        if best:
            out[prop] = best
    return out


def parse_proof_metrics(text: str):
    metrics = {}
    # Observed Jasper 2024.09 form:
    # A counterexample (cex) with 562 cycles was found for the property
    # "<embedded>::PROP" in 1.95 s.
    cex_re = re.compile(
        r"counterexample\s*\(cex\)\s*with\s*(\d+)\s*cycles.*?property\s+\"(?:[^\"]*::)?(SECID_[A-Za-z0-9_]+)\"\s+in\s+([0-9.]+)\s*s",
        re.I | re.S,
    )
    for m in cex_re.finditer(text):
        metrics.setdefault(m.group(2), {}).update({
            "cex_cycles": int(m.group(1)),
            "proof_seconds": float(m.group(3)),
        })

    # Generic one-line fallback for CEX timing/depth.
    for line in text.splitlines():
        if "SECID_" not in line:
            continue
        pm = re.search(r"(?:[^\s\"]*::)?(SECID_[A-Za-z0-9_]+)", line)
        if not pm:
            continue
        p = pm.group(1)
        cm = re.search(r"(?:counterexample|cex).*?(\d+)\s*cycles", line, re.I)
        tm = re.search(r"\bin\s+([0-9.]+)\s*s\b", line, re.I)
        if cm:
            metrics.setdefault(p, {})["cex_cycles"] = int(cm.group(1))
        if tm and any(w in line.lower() for w in ("counterexample", "cex", "proven", "proved")):
            metrics.setdefault(p, {})["proof_seconds"] = float(tm.group(1))

    # Generic proven form, if present.
    proven_re = re.compile(
        r"property\s+\"(?:[^\"]*::)?(SECID_[A-Za-z0-9_]+)\".*?(?:proven|proved).*?\bin\s+([0-9.]+)\s*s",
        re.I,
    )
    for m in proven_re.finditer(text):
        metrics.setdefault(m.group(1), {})["proof_seconds"] = float(m.group(2))
    return metrics


def parse_time_file(p: Path):
    if not p.exists():
        return {}
    text = p.read_text(errors="ignore")
    out = {}
    m = re.search(r"Maximum resident set size \(kbytes\):\s*(\d+)", text)
    if m:
        out["max_rss_kb"] = int(m.group(1))
    m = re.search(r"wall_seconds=(\d+)", text)
    if m:
        out["wall_seconds"] = float(m.group(1))
    else:
        m = re.search(r"Elapsed \(wall clock\) time \([^)]*\):\s*([^\n]+)", text)
        if m:
            val = m.group(1).strip()
            try:
                parts = [float(x) for x in val.split(":")]
                sec = 0.0
                for x in parts:
                    sec = sec * 60.0 + x
                out["wall_seconds"] = sec
            except Exception:
                pass
    return out


def parse_audit(run_dir: Path, log_text: str):
    signoff = (run_dir / "signoff.txt").read_text(errors="ignore") if (run_dir / "signoff.txt").exists() else ""
    consistency = (run_dir / "consistency.txt").read_text(errors="ignore") if (run_dir / "consistency.txt").exists() else ""
    combined = log_text + "\n" + signoff + "\n" + consistency
    low = combined.lower()
    incomplete = sorted(set(re.findall(r"(?im)^\s*([^\n:]+):\s*Incomplete\s*$", combined)))
    reset_seen = "starting reset analysis" in low or "reset analysis complete" in low
    reset_all = None
    if reset_seen:
        reset_all = "all flops/latches have concrete values after reset analysis" in low
    blackbox = "black-boxes in coi" in low or "blackboxes in coi" in low
    taint_incomplete = "use taint feedback loop" in low and "incomplete" in low
    stopat = "stopats:" in low and not re.search(r"stopats:\s*\{\s*\}", combined, re.I)
    return {
        "signoff_file_present": bool(signoff),
        "consistency_file_present": bool(consistency),
        "signoff_incomplete_items": [x.strip() for x in incomplete],
        "blackbox_in_coi": blackbox,
        "taint_feedback_incomplete": taint_incomplete,
        "stopat_in_coi": bool(stopat),
        "reset_audit_seen": reset_seen,
        "reset_all_concrete": reset_all,
        "auto_multiplier_blackboxed": "automatically black boxed" in low and "mult" in low,
        "material_signoff_risk": bool(blackbox or taint_incomplete or stopat),
    }


def parse_run(run_dir):
    run_dir = Path(run_dir)
    logp = run_dir / "jasper.log"
    text = logp.read_text(errors="ignore") if logp.exists() else ""

    got = parse_status_tsv(run_dir / "status.tsv")
    log_status = parse_log_status(text)
    # Log result is generally more specific than a missing/unknown TSV entry.
    for k, v in log_status.items():
        if k not in got or got[k][1] == "UNRESOLVED":
            got[k] = v

    # report.rpt fallback.
    rp = run_dir / "report.rpt"
    if rp.exists():
        for k, v in parse_log_status(rp.read_text(errors="ignore")).items():
            got.setdefault(k, v)

    proof_metrics = parse_proof_metrics(text)
    records = []
    for p, (raw, n, s) in sorted(got.items()):
        rec = {
            "property": p,
            "raw_status": raw,
            "normalized_status": n,
            "source": s,
        }
        rec.update(proof_metrics.get(p, {}))
        records.append(rec)

    exit_code = None
    ep = run_dir / "exit_code.txt"
    if ep.exists():
        try:
            exit_code = int(ep.read_text().strip())
        except Exception:
            pass

    return {
        "run_dir": str(run_dir),
        "exit_code": exit_code,
        "properties": records,
        "process_metrics": parse_time_file(run_dir / "time.txt"),
        "audit": parse_audit(run_dir, text),
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("run_dir")
    ap.add_argument("--out")
    a = ap.parse_args()
    d = parse_run(a.run_dir)
    out = Path(a.out) if a.out else Path(a.run_dir) / "parsed_results.json"
    out.write_text(json.dumps(d, indent=2) + "\n")
    print(f"[PARSE] {a.run_dir}: properties={len(d['properties'])} exit={d['exit_code']} -> {out}")
    for r in d["properties"]:
        extra = []
        if "cex_cycles" in r:
            extra.append(f"cycles={r['cex_cycles']}")
        if "proof_seconds" in r:
            extra.append(f"proof_s={r['proof_seconds']}")
        print(r["property"], r["normalized_status"], f"({r['raw_status']})", " ".join(extra))
    aud = d["audit"]
    print(
        "[AUDIT]",
        f"blackbox_in_coi={aud['blackbox_in_coi']}",
        f"taint_feedback_incomplete={aud['taint_feedback_incomplete']}",
        f"auto_multiplier_blackboxed={aud['auto_multiplier_blackboxed']}",
        f"reset_audit_seen={aud['reset_audit_seen']}",
        f"reset_all_concrete={aud['reset_all_concrete']}",
        f"material_signoff_risk={aud['material_signoff_risk']}",
    )


if __name__ == "__main__":
    main()
