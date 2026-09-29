/*======================================================================
  Program : qc_adsl.sas
  Study   : XYZ123
  Purpose : INDEPENDENT QC (double programming) of ADSL, then PROC
            COMPARE against the production ADSL.
  Standard: ADaMIG v1.1        SAP: v2.1
  Author  : <qc developer>
  ---------------------------------------------------------------------
  Workshop use (Module 8):
    - Written independently from the SAP, WITHOUT reading adsl.sas.
    - Production adsl.sas lives on feature/xyz123-prod-adsl.
    - This QC program lives on feature/xyz123-qc-adsl.
    - The PROC COMPARE "no unequal values" note is the QC evidence
      pasted into the merge request.
  Note:
    - Also invoked in batch by the CI pipeline (.gitlab-ci.yml).
======================================================================*/

%let workshop_root = %sysfunc(coalescec(%superq(workshop_root), d:/workshop/dev/xyz123-dev));

libname sdtm  "&workshop_root./data/sdtm";
libname adam  "&workshop_root./data/adam";   /* production output */
libname qcout "&workshop_root./data/qc";     /* QC output         */

/*======================================================================
  Independent derivation of ADSL (built only from the SAP, not from the
  production code). Kept intentionally parallel so a correct QC run
  reproduces the same values.
======================================================================*/
data work.qc_base;
  set sdtm.dm;
  length TRT01P $40 TRT01PN 8 SAFFL $1 ITTFL $1;
  TRT01P  = ARM;
  TRT01PN = ARMCD + 0;
  TRTSDT  = input(RFSTDTC, ?? yymmdd10.);
  TRTEDT  = input(RFENDTC, ?? yymmdd10.);
  format TRTSDT TRTEDT date9.;
  ITTFL = "Y";
  if TRTSDT ne . then SAFFL = "Y"; else SAFFL = "N";
run;

proc sort data=sdtm.ds out=work.qc_ds;
  by USUBJID descending DSSTDTC;
  where DSDECOD ne "";
run;
data work.qc_dslast;
  set work.qc_ds; by USUBJID;
  if first.USUBJID; keep USUBJID DSDECOD;
run;

data qcout.adsl;
  merge work.qc_base(in=a) work.qc_dslast(in=b);
  by USUBJID; if a;
  length EOSSTT $10;
  if      DSDECOD in ("COMPLETED") then EOSSTT = "COMPLETE";
  else if DSDECOD ne ""            then EOSSTT = "DISCONT";
  else                                  EOSSTT = "ONGOING";
run;
proc sort data=qcout.adsl; by USUBJID; run;

/*======================================================================
  The QC step: compare production vs independent QC output.
  A clean run prints:
     "NOTE: No unequal values were found. All values compared are
      exactly equal."
======================================================================*/
proc compare base=adam.adsl compare=qcout.adsl
             out=qcout.diff_adsl outnoequal listall;
  id USUBJID;
  title "XYZ123 ADSL - QC double programming PROC COMPARE";
run;
title;
