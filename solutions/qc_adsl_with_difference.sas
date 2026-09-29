/*== solutions/qc_adsl_with_difference.sas [INSTRUCTOR DEMO]
  A QC build that DELIBERATELY diverges so the class sees PROC COMPARE
  report differences. Planted: (1) uses FIRST disposition not latest;
  (2) codes EOSSTT="DISC" instead of "DISCONT". */
%let workshop_root = %sysfunc(coalescec(%superq(workshop_root), c:/workshop/dev/xyz123-dev));
libname sdtm "&workshop_root./data/sdtm";
libname adam "&workshop_root./data/adam";
libname qcout "&workshop_root./data/qc";
data work.qc_base; set sdtm.dm;
  length TRT01P $40 TRT01PN 8 SAFFL $1 ITTFL $1;
  TRT01P=ARM; TRT01PN=ARMCD+0;
  TRTSDT=input(RFSTDTC, ?? yymmdd10.); TRTEDT=input(RFENDTC, ?? yymmdd10.);
  format TRTSDT TRTEDT date9.; ITTFL="Y";
  if TRTSDT ne . then SAFFL="Y"; else SAFFL="N"; run;
proc sort data=sdtm.ds out=work.qc_ds; by USUBJID DSSTDTC; where DSDECOD ne ""; run; /* FIRST, not latest */
data work.qc_dslast; set work.qc_ds; by USUBJID; if first.USUBJID; keep USUBJID DSDECOD; run;
data qcout.adsl; merge work.qc_base(in=a) work.qc_dslast(in=b); by USUBJID; if a;
  length EOSSTT $10;
  if      DSDECOD in ("COMPLETED") then EOSSTT="COMPLETE";
  else if DSDECOD ne ""            then EOSSTT="DISC";   /* wrong code */
  else                                  EOSSTT="ONGOING"; run;
proc sort data=qcout.adsl; by USUBJID; run;
proc compare base=adam.adsl compare=qcout.adsl
             out=qcout.diff_adsl outnoequal outbase outcomp outdif listall;
  id USUBJID; title "XYZ123 ADSL - QC WITH PLANTED DIFFERENCES (teaching)"; run; title;
