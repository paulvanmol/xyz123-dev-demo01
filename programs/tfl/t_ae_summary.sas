/*======================================================================
  Program : t_ae_summary.sas
  Study   : XYZ123
  Purpose : Summary table - subjects with adverse events by treatment
  Author  : <your name>
======================================================================*/

libname adam "&workshop_root./data/adam";

proc sql;
  create table work.n_saf as
    select TRT01P, count(distinct USUBJID) as N_SAF
    from adam.adsl where SAFFL = "Y"
    group by TRT01P;
quit;

proc sql;
  create table work.n_ae as
    select TRTA as TRT01P, count(distinct USUBJID) as N_AE
    from adam.adae where TRTEMFL = "Y"
    group by TRTA;
quit;

data work.rep;
  merge work.n_saf(in=a) work.n_ae;
  by TRT01P;
  if a;
  if N_AE = . then N_AE = 0;
  PCT = 100 * N_AE / N_SAF;
run;

proc report data=work.rep nowd;
  column TRT01P N_SAF N_AE PCT;
  define TRT01P / "Treatment"          width=30;
  define N_SAF  / "Safety N"           width=10;
  define N_AE   / "Subjects with TEAE" width=18;
  define PCT    / "%%" format=5.1      width=8;
  title "XYZ123 - Subjects with treatment-emergent AEs by treatment";
run;
title;
