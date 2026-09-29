#!/usr/bin/env python3
"""
lint_sas.py  -  fast static checks on SAS source before a merge.

Scans .sas files for a few banned/risky patterns. Deliberately simple and
dependency-free so it runs on any runner. Extend the RULES list to match
your programming standards.

Usage (called by .gitlab-ci.yml):
    python validation/lint_sas.py programs
"""
import re
import sys
from pathlib import Path

# (regex, message, is_error)
RULES = [
    (re.compile(r"\brsubmit\b", re.I),      "rsubmit found - no remote submit in study code", True),
    (re.compile(r"\bx\s+['\"]", re.I),      "X command (OS shell) found - not allowed", True),
    (re.compile(r"\bsystask\b", re.I),      "SYSTASK found - review OS interaction", True),
    (re.compile(r"c:\\|d:\\", re.I),        "hard-coded drive path - use &workshop_root", False),
    (re.compile(r"password\s*=", re.I),     "possible hard-coded password", True),
]


def scan(root: Path):
    n_files = 0
    errors = 0
    warnings = 0
    for f in sorted(root.rglob("*.sas")):
        n_files += 1
        text = f.read_text(encoding="latin-1", errors="replace")
        for i, line in enumerate(text.splitlines(), start=1):
            if line.lstrip().startswith("*") or line.lstrip().startswith("/*"):
                continue  # skip comment-only lines
            for rx, msg, is_err in RULES:
                if rx.search(line):
                    tag = "error" if is_err else "warning"
                    print(f"::{tag}:: {f}:{i}: {msg}")
                    if is_err:
                        errors += 1
                    else:
                        warnings += 1
    print(f"lint: scanned {n_files} .sas file(s); {errors} error(s), {warnings} warning(s).")
    return errors


def main(argv):
    root = Path(argv[1]) if len(argv) > 1 else Path("programs")
    if not root.exists():
        print(f"note: '{root}' not found; nothing to lint.")
        return 0
    return 1 if scan(root) else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
