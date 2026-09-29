/*======================================================================
  Program : adsl.sas   [STARTER - work to do]
  Study   : XYZ123 | ADaMIG v1.1 | SAP v2.1
  DEVELOPMENT TASK (Module 5 - Task 1):
    This starter builds the ADSL base only. The End of Study Status
    (EOSSTT) derivation is NOT yet implemented. On your feature branch,
    add it per ADaM spec v1.0 s3.2 (derive from SDTM.DS). A completed
    reference is in solutions/adsl_solution.sas (instructor).
    Until EOSSTT is added, validation/qc_adsl.sas PROC COMPARE will FAIL
    (EOSSTT present in QC, absent in production) - expected; it turns
    CLEAN once you complete the task correctly.
======================================================================*/
libname sdtm "&workshop_root./data/sdtm";
libname adam "&workshop_root./data/adam";

data work.adsl_base;
  set sdtm.dm;
  length TRT01P $40 TRT01PN 8 SAFFL $1 ITTFL $1;
  TRT01P=ARM; TRT01PN=ARMCD+0;
  TRTSDT=input(RFSTDTC, ?? yymmdd10.);
  TRTEDT=input(RFENDTC, ?? yymmdd10.);
  format TRTSDT TRTEDT date9.;
  ITTFL="Y";
  if TRTSDT ne . then SAFFL="Y"; else SAFFL="N";
  label SAFFL="Safety Population Flag" ITTFL="Intent-to-Treat Population Flag";
  /* -----------------------------------------------------------------
     TODO (feature/xyz123-$gituser-adsl-eosstt):
       Derive EOSSTT from SDTM.DS per spec s3.2:
         COMPLETED         -> "COMPLETE"
         any other DSDECOD -> "DISCONT"
         no DS record      -> "ONGOING"
       Tip: sort SDTM.DS by USUBJID, take latest disposition, merge by
            USUBJID, then assign EOSSTT.
     ----------------------------------------------------------------- */
run;

proc sort data=sdtm.ds out=work.ds_eos;
	by USUBJID descending DSSTDTC;
	where DSDECOD ne "";
run;

data work.ds_last;
	set work.ds_eos;
	by USUBJID;

	if first.USUBJID;
	keep USUBJID DSDECOD;
run;

data adam.adsl;
	merge work.adsl_base(in=a) work.ds_last(in=b);
	by USUBJID;

	if a;
	length EOSSTT $10;

	if DSDECOD in ("COMPLETED") then
		EOSSTT="COMPLETE";
	else if DSDECOD ne "" then
		EOSSTT="DISCONT";
	else
		EOSSTT="ONGOING";
	label EOSSTT="End of Study Status";
run;


proc sort data=adam.adsl; by USUBJID; run;
/*Modify the proc freq and add EOSSTT to the tables statement*/
proc freq data=adam.adsl;
	tables EOSSTT SAFFL*TRT01P / missing;
	title "XYZ123 ADSL (starter) - SAFFL by treatment";
run;