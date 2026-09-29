/*== adae_solution.sas [INSTRUCTOR] completed AESEVN ==*/
libname sdtm "&workshop_root./data/sdtm";
libname adam "&workshop_root./data/adam";
proc sort data=sdtm.ae   out=work.ae;   by USUBJID; run;
proc sort data=adam.adsl out=work.adsl(keep=USUBJID TRT01P TRT01PN SAFFL); by USUBJID; run;
data adam.adae; merge work.ae(in=a) work.adsl(in=b); by USUBJID; if a and b;
  length TRTA $40 AESEVN 8; TRTA=TRT01P;
  select (upcase(AESEV));
    when ("MILD") AESEVN=1; when ("MODERATE") AESEVN=2; when ("SEVERE") AESEVN=3;
    otherwise AESEVN=.; end;
  TRTEMFL="Y"; label AESEVN="Severity (N)"; run;
proc sort data=adam.adae; by USUBJID AESEQ; run;
