/*======================================================================
  Macro   : mk_saffl
  Purpose : Derive the Safety Population Flag (SAFFL) - a reusable,
            cross-study standard macro.
  Study   : shared (used by all studies)  SAP ref: s2.3
  Author  : <your name>
  ---------------------------------------------------------------------
  Workshop use (Module 7):
    - Develop / modify this shared macro on a feature branch.
    - Open a Merge Request; CODEOWNERS routes approval to the macro
      owner (@paulvanmol). It cannot merge to main until approved.

  Parameters
    in      = input dataset (subject level, must contain TRTSDT)
    out     = output dataset (adds SAFFL)
    trtvar  = treatment-start date variable (default TRTSDT)
  Usage
    %mk_saffl(in=work.adsl_base, out=work.adsl_saf);
======================================================================*/
%macro mk_saffl(in=, out=, trtvar=TRTSDT);

  %if %superq(in)= or %superq(out)= %then %do;
    %put ERROR: mk_saffl - IN= and OUT= are required.;
    %return;
  %end;

  data &out;
    set &in;
    length SAFFL $1;
    if &trtvar ne . then SAFFL = "Y";
    else                 SAFFL = "N";
    label SAFFL = "Safety Population Flag";
  run;

  %put NOTE: mk_saffl - SAFFL derived on &out (based on &trtvar).;

%mend mk_saffl;
