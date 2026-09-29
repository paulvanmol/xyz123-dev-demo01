#!/usr/bin/env python3
"""
check_compare.py  -  CI gate for the QC double-programming step.

Fails (non-zero exit) if:
  * the SAS log contains ERROR: lines, or
  * PROC COMPARE reported unequal values (i.e. the "No unequal values
    were found" note is absent from the listing).

Usage (called by .gitlab-ci.yml):
    python validation/check_compare.py reports/qc_adsl.log reports/qc_adsl.lst
"""
import sys
from pathlib import Path

CLEAN_COMPARE = "no unequal values were found"


def read(path: str) -> str:
    p = Path(path)
    if not p.exists():
        print(f"::error:: expected file not found: {path}")
        sys.exit(2)
    # SAS 9.4 may write WLATIN1/latin-1; be tolerant of encoding.
    return p.read_text(encoding="latin-1", errors="replace").lower()


def main(argv):
    if len(argv) < 3:
        print("usage: check_compare.py <log> <listing>")
        return 2

    log_text = read(argv[1])
    lst_text = read(argv[2])
    failed = False

    # 1) No SAS errors in the log
    errors = [ln for ln in log_text.splitlines() if ln.strip().startswith("error:")]
    if errors:
        failed = True
        print(f"::error:: SAS log contains {len(errors)} ERROR line(s):")
        for ln in errors[:10]:
            print("   ", ln.strip())

    # 2) PROC COMPARE must report a clean comparison
    if CLEAN_COMPARE not in lst_text:
        failed = True
        print("::error:: PROC COMPARE did NOT report a clean comparison.")
        print("          QC output differs from production ADSL - review the MR.")
    else:
        print("PROC COMPARE clean: production and QC ADSL are exactly equal.")

    if failed:
        print("QC GATE: FAILED - merge blocked.")
        return 1

    print("QC GATE: PASSED.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
