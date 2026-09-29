# Programming Plan — Study XYZ123 (workshop sample)

## Scope

Teaching subset of a clinical study used for the Git + SAS Studio workshop.
It is **not** a real analysis and the datasets are synthetic.

## Deliverables

| Layer  | Program                          | Output          | Owner (CODEOWNERS)     |
|--------|----------------------------------|-----------------|------------------------|
| RAW    | `programs/mk_sample_data.sas`    | `raw.*`         | instructor             |
| SDTM   | `programs/sdtm/dm.sas`           | `sdtm.dm`       | lead-stat / paulvanmol |
| SDTM   | `programs/sdtm/ae.sas`           | `sdtm.ae`       | lead-stat / paulvanmol |
| SDTM   | `programs/sdtm/ds.sas`           | `sdtm.ds`       | lead-stat / paulvanmol |
| ADaM   | `programs/adam/adsl.sas`         | `adam.adsl`     | lead-stat / paulvanmol |
| ADaM   | `programs/adam/adae.sas`         | `adam.adae`     | lead-stat / paulvanmol |
| TFL    | `programs/tfl/t_ae_summary.sas`  | AE summary      | lead-stat / paulvanmol |
| Macro  | `macros/mk_saffl.sas`            | `%mk_saffl`     | paulvanmol             |
| QC     | `validation/qc_adsl.sas`         | `qc.adsl` + cmp | qc-lead / paulvanmol   |

## Run order (end-to-end)

```
_setup.sas -> mk_sample_data.sas -> dm.sas -> ae.sas -> ds.sas
           -> adsl.sas -> adae.sas -> qc_adsl.sas
```

## Environment

- SAS Studio 3.83 on SAS 9.4M9.
- Workshop root libref set via `&workshop_root` (default `d:/workshop/dev/xyz123-dev`).
- Data lives under `data/` (git-ignored); reports under `reports/` (git-ignored).

## Workflow

Develop on feature branches → Merge Request into `main` → lead approves →
CI runs lint + CDISC validation + PROC COMPARE → tag at DB lock.

## Compliance context

- 21 CFR Part 11, EU GMP Annex 11, ICH E6(R3) GCP (ALCOA+).
- Git history + MR approvals + annotated tags form the program-level audit trail.
- Data is versioned by Data Management, not in this code repo.
