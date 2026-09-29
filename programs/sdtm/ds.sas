/*======================================================================
  Program : ds.sas
  Study   : XYZ123
  Purpose : Build the SDTM DS (Disposition) domain (teaching sample)
  Standard: SDTMIG v3.3
  Author  : <your name>              (populated by the Git commit author)
  ---------------------------------------------------------------------
  Reads   : raw.disposition   (verbatim status + reason, one row per
                               subject who has a disposition event)
  Creates : sdtm.ds           (consumed by adsl.sas / qc_adsl.sas to
                               derive EOSSTT)
  Note    : Subjects with no raw.disposition record (still ongoing, or
            never treated) intentionally get NO DS row, so ADSL derives
            EOSSTT = 'ONGOING' for them.
======================================================================*/

libname raw    "&workshop_root./data/raw";
libname sdtm   "&workshop_root./data/sdtm";

/*--- Map verbatim disposition to SDTM controlled terminology ---------*/
data sdtm.ds;
  set raw.disposition;
  length STUDYID $8 DOMAIN $2 USUBJID $20
         DSDECOD $30 DSTERM $60 DSSTDTC $10;

  STUDYID = "XYZ123";
  DOMAIN  = "DS";
  USUBJID = catx("-", STUDYID, put(subjid, z4.));
  DSSEQ   = 1;

  /* Verbatim collected term -> controlled DSDECOD                     */
  DSTERM = strip(dsreas);                     /* verbatim / as collected */

  if upcase(dsstat) = "COMPLETED" then do;
    DSDECOD = "COMPLETED";
    if DSTERM = "" then DSTERM = "PROTOCOL COMPLETED";
  end;
  else do;
    select;
      when (index(upcase(dsreas), "ADVERSE"))  DSDECOD = "ADVERSE EVENT";
      when (index(upcase(dsreas), "WITHDRAW")) DSDECOD = "WITHDRAWAL BY SUBJECT";
      when (index(upcase(dsreas), "EFFICACY")) DSDECOD = "LACK OF EFFICACY";
      when (index(upcase(dsreas), "FOLLOW"))   DSDECOD = "LOST TO FOLLOW-UP";
      otherwise                                DSDECOD = "OTHER";
    end;
  end;

  DSSTDTC = put(dsdt, is8601da.);             /* ISO 8601 start date     */

  label DSDECOD = "Standardized Disposition Term"
        DSTERM  = "Reported Term for the Disposition Event"
        DSSTDTC = "Start Date/Time of Disposition Event";

  keep STUDYID DOMAIN USUBJID DSSEQ DSDECOD DSTERM DSSTDTC;
run;

proc sort data=sdtm.ds; by USUBJID; run;

/*--- Minimal in-line check (expected output in the log) --------------*/
proc freq data=sdtm.ds;
  tables DSDECOD / missing;
  title "XYZ123 SDTM.DS - disposition term check";
run;
title;
