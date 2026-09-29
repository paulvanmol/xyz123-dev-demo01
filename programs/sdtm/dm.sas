/*======================================================================
  Program : dm.sas
  Study   : XYZ123
  Purpose : Build the SDTM DM (Demographics) domain (teaching sample)
  Standard: SDTMIG v3.3
  Author  : <your name>              (populated by the Git commit author)
  Notes   : Sample program for the Git workshop. Paths use the workshop
            libref set in _setup.sas; adjust to your site.
======================================================================*/

libname raw    "&workshop_root./data/raw";
libname sdtm   "&workshop_root./data/sdtm";

/*--- Derive DM from the raw enrolment/demography source --------------*/
data sdtm.dm;
  set raw.demog;
  length STUDYID $8 DOMAIN $2 USUBJID $20 SEX $1 ARM $40;

  STUDYID = "XYZ123";
  DOMAIN  = "DM";
  USUBJID = catx("-", STUDYID, put(subjid, z4.));

  RFSTDTC = put(trtsdt, is8601da.);   /* first treatment date  */
  RFENDTC = put(trtedt, is8601da.);   /* last treatment date   */

  AGE     = age;
  AGEU    = "YEARS";
  SEX     = sex;                      /* M / F                 */
  RACE    = race;
  ARMCD   = armcd;
  ARM     = arm;
  COUNTRY = country;

  keep STUDYID DOMAIN USUBJID RFSTDTC RFENDTC
       AGE AGEU SEX RACE ARMCD ARM COUNTRY;
run;

proc sort data=sdtm.dm; by USUBJID; run;

/*--- Minimal in-line check (expected output in the log) --------------*/
proc freq data=sdtm.dm;
  tables SEX ARM / missing;
  title "XYZ123 SDTM.DM - frequency check";
run;
title;
