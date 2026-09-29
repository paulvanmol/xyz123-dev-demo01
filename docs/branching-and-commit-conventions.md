# Branching & Commit Conventions — XYZ123

## Branches

`main` is the **validated / production** baseline. It is protected: no direct
pushes, merges only via an approved Merge Request.

All work happens on a **feature branch**, named:

```
feature/<study>-<user>-<task>
```

| Part    | Meaning                          | Example        |
|---------|----------------------------------|----------------|
| study   | study id                         | `xyz123`       |
| user    | your short gitlab id             | `adenis`       |
| task    | short task description (kebab)   | `adsl-eosstt`  |

Examples:

```
feature/xyz123-adenis-adsl-eosstt
feature/xyz123-bsansas-adae-severity
feature/xyz123-qc-adsl
feature/xyz123-mgroc-macro-mkflag
```

One task = one branch. A second task starts from `main` again, it is **not**
a continuation of the first branch.

> In real projects you may keep both `main` (released) and `develop`
> (integration). This workshop uses `main` for simplicity.

## Commits

- Commit small and often; each commit should build/derive cleanly.
- Message format:

```
[XYZ123] <short summary in imperative mood>

 - what changed and why
 - spec / SAP reference (e.g. ADaM spec v1.0 s3.2, SAP v2.1)
 - how it was checked
```

Example:

```
[XYZ123] Add EOSSTT derivation to ADSL

 - Derived End of Study Status from SDTM.DS per ADaM spec v1.0 s3.2
 - Reviewed against SAP v2.1
```

## Merge Requests

1. Push your feature branch.
2. Open a Merge Request into `main` on GitLab.
3. Assign **@paulvanmol** (repository Owner) as approver.
4. `CODEOWNERS` auto-adds the right required reviewer for the path you touched.
5. The lead reviews the diff, discusses, then approves and merges;
   delete the source branch on merge.

**Merge in GitLab, not in SAS Studio** — the MR captures reviewer identity,
discussion and approval: the four-eyes evidence an inspector expects.

## Tagging a submission version

Tagging is done with the Git CLI (a controlled act), not SAS Studio:

```bash
git checkout main && git pull
git tag -a v1.0 -m "DB lock XYZ123 - programs frozen per protocol v3.0"
git push origin v1.0
```
