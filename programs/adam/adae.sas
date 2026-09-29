*======================================================================
  Program : adae.sas   [STARTER - work to do]
  Study   : XYZ123 | ADaMIG v1.1 | SAP v2.1 s4.2
  DEVELOPMENT TASK (Module 5 - Task 2):
    Merges AE with ADSL but does NOT yet derive numeric severity AESEVN.
    On your feature branch, add AESEVN per SAP s4.2. Completed reference
    in solutions/adae_solution.sas (instructor).
======================================================================*/
libname sdtm "&workshop_root./data/sdtm";
libname adam "&workshop_root./data/adam";

proc sort data=sdtm.ae out=work.ae;
    by USUBJID;
run;

proc sort data=adam.adsl out=work.adsl(keep=USUBJID TRT01P TRT01PN SAFFL);
    by USUBJID;
run;

data adam.adae;
    merge work.ae(in=a) work.adsl(in=b);
    by USUBJID;
    if a and b;
    length TRTA $40 AESEVN 8;
    ;
    TRTA=TRT01P;
    TRTEMFL="Y";
    label TRTA="Actual Treatment" TRTEMFL="Treatment Emergent Flag";
    /* -----------------------------------------------------------------
    TODO (feature/xyz123-$gituser-adae-severity):
    Add numeric severity AESEVN per SAP s4.2:
    MILD->1  MODERATE->2  SEVERE->3  (else .)
    ----------------------------------------------------------------- */
    select (upcase(AESEV));
        when ("MILD") AESEVN=1;
        when ("MODERATE") AESEVN=2;
        when ("SEVERE") AESEVN=3;
        otherwise AESEVN=.;
    end;
    label AESEVN="Severity (N)";
run;

proc sort data=adam.adae;
    by USUBJID AESEQ;
run;

proc freq data=adam.adae;
    tables AESEV*TRTA / missing;
    tables AESEVN*TRTA /missing;
    title "XYZ123 ADAE (starter) - severity (char) by treatment";
run;
title;
