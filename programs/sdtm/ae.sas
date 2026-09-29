/*======================================================================
  Program : ae.sas
  Study   : XYZ123
  Purpose : Build the SDTM AE (Adverse Events) domain (teaching sample)
  Standard: SDTMIG v3.3
  Author  : <your name>
======================================================================*/

libname raw    "&workshop_root./data/raw";
libname sdtm   "&workshop_root./data/sdtm";

data sdtm.ae;
  set raw.adverse;
  length STUDYID $8 DOMAIN $2 USUBJID $20
         AETERM $200 AEDECOD $200 AESEV $10 AESER $1;

  STUDYID = "XYZ123";
  DOMAIN  = "AE";
  USUBJID = catx("-", STUDYID, put(subjid, z4.));

  AESEQ   = aeseq;
  AETERM  = strip(aeterm);            /* verbatim term          */
  AEDECOD = strip(aedecod);           /* MedDRA preferred term  */
  AEBODSYS= strip(aebodsys);
  AESEV   = upcase(aesev);            /* MILD / MODERATE / SEVERE */
  AESER   = upcase(aeser);            /* Y / N                  */
  AESTDTC = put(aestdt, is8601da.);
  AEENDTC = put(aeendt, is8601da.);

  keep STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AEBODSYS
       AESEV AESER AESTDTC AEENDTC;
run;

proc sort data=sdtm.ae; by USUBJID AESEQ; run;

proc freq data=sdtm.ae;
  tables AESEV AESER / missing;
  title "XYZ123 SDTM.AE - severity / seriousness check";
run;
title;
