# XYZ123 — Development Repository (`xyz123-dev`)

Starter repository for the **Git Versioning with SAS® Studio & GitLab** workshop
(Statistical Programming). It contains sample SDTM/ADaM programs,
a shared macro, a QC double-programming example, a synthetic data generator, and
a CI/CD pipeline that runs CDISC validation and PROC COMPARE before code reaches
`main`.

> **Environment:** SAS Studio · GitLab · workshop folder
> `/workshop/$gituser` (configurable to `/home/user`).

---

## Repository layout

```
xyz123-dev/
├─ programs/
│  ├─ _setup.sas                        # sets &workshop_root + librefs
│  ├─ mk_sample_data.sas                # builds synthetic RAW data
│  ├─ sdtm/   dm.sas  ae.sas  ds.sas    # SDTM programs
│  ├─ adam/   adsl.sas  adae.sas        # ADaM analysis datasets
│  └─ tfl/    t_ae_summary.sas          # tables / figures / listings
├─ macros/    mk_saffl.sas              # shared, cross-study macro
├─ validation/                          # QC & CI helper scripts
│  ├─ qc_adsl.sas                       # independent QC of ADSL + PROC COMPARE
│  ├─ run_core.py                       # CDISC rules-engine wrapper (stub)
│  ├─ check_compare.py                  # fails CI if COMPARE/log not clean
│  └─ lint_sas.py                       # fast static checks on .sas source
├─ docs/
│  ├─ programming-plan.md
│  ├─ traceability-matrix.md
│  └─ branching-and-commit-conventions.md
├─ data/        (git-ignored)           # local RAW/SDTM/ADaM/QC datasets
├─ reports/     (git-ignored)           # logs, listings, CDISC reports
├─ .gitignore   .gitattributes  CODEOWNERS  .gitlab-ci.yml
```

`data/` and `reports/` are intentionally **ignored** — version programs, never
data or generated output. Each folder ships with a `.gitkeep` so the empty
structure clones cleanly. Regenerate the sample data after cloning.

---

## First-time setup (run once per clone)

SAS Studio does **not** set Git config for you, so configure it per repo:

```bash
cd /workshop/$gituser/xyz123-dev
git config user.name  "Your Name"
git config user.email "first.lastname@company.com"
git config core.autocrlf true      # Windows client
git config core.fileMode false     # avoid phantom "changed" files on the server
```

## Build the sample data and run the flow end-to-end

The programs are driven by a `&workshop_root` macro variable. Run in this order:

```sas
%include "&workshop_root./programs/_setup.sas";          /* librefs        */
%include "&workshop_root./programs/mk_sample_data.sas";  /* RAW data       */
%include "&workshop_root./programs/sdtm/dm.sas";         /* -> sdtm.dm     */
%include "&workshop_root./programs/sdtm/ae.sas";         /* -> sdtm.ae     */
%include "&workshop_root./programs/sdtm/ds.sas";         /* -> sdtm.ds     */
%include "&workshop_root./programs/adam/adsl.sas";       /* -> adam.adsl   */
%include "&workshop_root./programs/adam/adae.sas";       /* -> adam.adae   */
%include "&workshop_root./validation/qc_adsl.sas";       /* PROC COMPARE   */
```

## The everyday Git workflow

```bash
git checkout main && git pull
git checkout -b feature/xyz123-<user>-<task>   # e.g. feature/xyz123-paulvm-adsl-eosstt
# ...edit a program in SAS Studio...
git add programs/adam/adsl.sas
git commit -m "[XYZ123] Add EOSSTT derivation to ADSL (ADaM spec v1.0 s3.2)"
git push -u origin feature/xyz123-<user>-<task>
```

Then open a **Merge Request** into `main` on GitLab and assign
`@paulvanmol` as approver. `main` is protected — no direct pushes.

See `docs/branching-and-commit-conventions.md` for the full convention.

---

## Continuous validation

On every merge request the pipeline (`.gitlab-ci.yml`) runs:

1. **`sas_lint`** — static scan of the SAS source.
2. **`cdisc_core_validation`** — CDISC rules engine on the ADaM data (Python).
3. **`proc_compare_qc`** — runs `validation/qc_adsl.sas` in **sas-viya batch**
   and fails if PROC COMPARE reports differences or the log contains errors.


