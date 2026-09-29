#!/usr/bin/env python3
"""
run_core.py  -  thin wrapper around a CDISC rules engine (stub).

In production this would invoke the CDISC Rules Engine (CORE) or the
Pinnacle 21 community engine to validate the ADaM datasets against a
published standard, then write an Excel report. For the workshop it is
a self-contained stub so the pipeline runs without external data: it
demonstrates the shape of the call and produces a report file.

Usage (called by .gitlab-ci.yml):
    python validation/run_core.py --standard adamig --version 1-1 \
           --data data/adam --report reports/core_adam.xlsx

Exit code is non-zero if any rule fails, which blocks the merge request.
"""
import argparse
import sys
from pathlib import Path


def parse_args():
    ap = argparse.ArgumentParser(description="CDISC CORE validation wrapper (stub)")
    ap.add_argument("--standard", required=True, help="e.g. adamig, sdtmig")
    ap.add_argument("--version", required=True, help="e.g. 1-1")
    ap.add_argument("--data", required=True, help="folder with datasets")
    ap.add_argument("--report", required=True, help="output report path")
    return ap.parse_args()


def run_rules(data_dir: Path):
    """Placeholder for the real engine call.

    Replace the body with, for example:
        from cdisc_rules_engine import ...
    Return a list of (rule_id, severity, message) findings.
    """
    findings = []
    if not data_dir.exists():
        # No data in the workshop clone -> treat as "nothing to validate"
        print(f"note: data folder '{data_dir}' not present; skipping rule run.")
        return findings
    # ... real rule execution would populate findings ...
    return findings


def write_report(report_path: Path, findings):
    report_path.parent.mkdir(parents=True, exist_ok=True)
    # Keep the stub dependency-free: write a simple text report even though
    # the extension is .xlsx in the pipeline example.
    lines = [f"CDISC validation findings: {len(findings)}"]
    for rid, sev, msg in findings:
        lines.append(f"{sev}\t{rid}\t{msg}")
    report_path.write_text("\n".join(lines), encoding="utf-8")


def main():
    args = parse_args()
    print(f"Validating {args.data} against {args.standard} v{args.version} ...")
    findings = run_rules(Path(args.data))
    write_report(Path(args.report), findings)

    errors = [f for f in findings if f[1].upper() in ("ERROR", "REJECT")]
    if errors:
        print(f"::error:: CDISC validation found {len(errors)} blocking issue(s).")
        return 1
    print("CDISC validation passed (no blocking findings).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
