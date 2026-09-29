# Traceability Matrix — Study XYZ123 (workshop sample)

Links analysis requirements to programs, outputs and their QC. In a real
study this ties SAP items to ADaM variables, TFL shells and QC evidence.

| Req ID | SAP ref | Requirement                          | Program              | Variable / Output | QC evidence                    |
|--------|---------|--------------------------------------|----------------------|-------------------|--------------------------------|
| R-01   | s2.3    | Safety population flag               | `macros/mk_saffl.sas`| `SAFFL`           | reviewed in ADSL MR            |
| R-02   | s3.2    | End of Study Status                  | `programs/adam/adsl.sas` | `EOSSTT`      | `qc_adsl.sas` PROC COMPARE     |
| R-03   | s2.1    | Planned treatment                    | `programs/adam/adsl.sas` | `TRT01P/TRT01PN` | PROC COMPARE                 |
| R-04   | s4.2    | Numeric AE severity                  | `programs/adam/adae.sas` | `AESEVN`      | reviewer diff in MR            |
| R-05   | s5.1    | Subjects with TEAE by treatment      | `programs/tfl/t_ae_summary.sas` | AE table | output review              |
| R-06   | SDTM    | Disposition (controlled terminology) | `programs/sdtm/ds.sas`   | `DSDECOD`     | DSDECOD freq check in log      |

## How the audit trail is established

- **Who / when / why** → `git log`, `git blame` on each program.
- **Four-eyes** → GitLab Merge Request approvals (CODEOWNERS-routed).
- **Automated QC** → CI runs CDISC validation + PROC COMPARE on every MR.
- **Frozen version** → annotated tag (e.g. `v1.0`) at database lock.
