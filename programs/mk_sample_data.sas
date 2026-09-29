/*======================================================================
  Program : mk_sample_data.sas
  Study   : XYZ123
  Purpose : Generate SYNTHETIC source data so the workshop programs run
            end-to-end without any real (or confidential) clinical data.
  Creates : raw.demog        -> consumed by programs/sdtm/dm.sas
            raw.adverse      -> consumed by programs/sdtm/ae.sas
            raw.disposition  -> consumed by programs/sdtm/ds.sas
  ---------------------------------------------------------------------
  Run order for a full end-to-end demo:
      1) %include _setup.sas          (sets &workshop_root, librefs)
      2) %include mk_sample_data.sas  (THIS program - builds RAW data)
      3) %include programs/sdtm/dm.sas
      4) %include programs/sdtm/ae.sas
      5) %include programs/sdtm/ds.sas      (raw.disposition -> sdtm.ds)
      6) %include programs/adam/adsl.sas
      7) %include programs/adam/adae.sas
      8) %include validation/qc_adsl.sas    (PROC COMPARE = clean)

  Notes:
    - Reproducible: fixed random seeds (change SEED* to vary the sample).
    - Data is 100%% synthetic - no PII, safe to commit? NO. It is still
      DATA: leave it under data/ which is git-ignored. Regenerate on clone.
    - This program builds only the RAW source layer. sdtm.ds is derived
      programmatically by programs/sdtm/ds.sas, mirroring how Data
      Management collects verbatim disposition and programming maps it to
      controlled terminology.
======================================================================*/

/*--- Ensure librefs exist; auto-create the data folders --------------*/
options dlcreatedir;

%macro _ensure_setup;
  %if %symexist(workshop_root)=0 %then %do;
    %global workshop_root;
    %let workshop_root = d:/workshop/dev/xyz123-dev;   /* edit per site */
    %put NOTE: workshop_root defaulted to &workshop_root;
  %end;
%mend;
%_ensure_setup;

libname raw  "&workshop_root./data/raw";

/*--- Configuration ---------------------------------------------------*/
%let nsubj      = 30;          /* number of subjects                    */
%let seed_dm    = 20260811;    /* seed: demographics                    */
%let seed_ae    = 77;          /* seed: adverse events                  */
%let seed_ds    = 99;          /* seed: disposition                     */
%let p_untreated= 0.06;        /* ~6%% screen failures (not treated)    */

/*======================================================================
  1) raw.demog  - one record per subject
     Variable names match what programs/sdtm/dm.sas expects:
     subjid trtsdt trtedt age sex race armcd arm country
======================================================================*/
data raw.demog;
  call streaminit(&seed_dm);
  length sex $1 race $30 arm $40 country $12;

  /* pick-lists */
  array _race[5] $30 _temporary_
    ("WHITE","BLACK OR AFRICAN AMERICAN","ASIAN",
     "AMERICAN INDIAN OR ALASKA NATIVE","OTHER");
  array _ctry[6] $12 _temporary_
    ("FRANCE","BELGIUM","SPAIN","GERMANY","ITALY","NETHERLANDS");

  do subjid = 1 to &nsubj;

    /* 1:1 randomised treatment arm (numeric code + label) */
    if rand("uniform") < 0.5 then do; armcd = 1; arm = "Placebo";   end;
    else                          do; armcd = 2; arm = "XYZ 50 mg"; end;

    age = 18 + int(rand("uniform") * 67);          /* 18 - 84            */
    if rand("uniform") < 0.5 then sex = "M"; else sex = "F";
    race    = _race[ 1 + int(rand("uniform")*5) ];
    country = _ctry[ 1 + int(rand("uniform")*6) ];

    /* Enrolment / treatment window in 2025 */
    _enroll = mdy(1,1,2025) + int(rand("uniform")*300);

    /* Force the last 2 subjects to be screen failures so that SAFFL='N'
       always appears in the demo, regardless of the random seed.        */
    if subjid > (&nsubj - 2) or rand("uniform") < &p_untreated then do;
      /* screen failure / not treated -> SAFFL will be 'N' */
      trtsdt = .;
      trtedt = .;
    end;
    else do;
      trtsdt = _enroll;
      /* planned 12-week exposure; some discontinue earlier */
      _dur   = 84;
      if rand("uniform") < 0.25 then _dur = 14 + int(rand("uniform")*70);
      trtedt = trtsdt + _dur;
    end;
    format trtsdt trtedt date9.;

    output;
  end;
  keep subjid trtsdt trtedt age sex race armcd arm country;
run;

/*======================================================================
  2) raw.adverse - zero or more AE records per subject
     Variable names match programs/sdtm/ae.sas:
     subjid aeseq aeterm aedecod aebodsys aesev aeser aestdt aeendt
======================================================================*/
/* Small MedDRA-like dictionary (verbatim | preferred term | SOC) */
data work.aedict;
  length aeterm $50 aedecod $50 aebodsys $50;
  infile datalines dsd dlm='|';
  input aeterm $ aedecod $ aebodsys $;
  datalines;
Headache|Headache|Nervous system disorders
Feeling sick|Nausea|Gastrointestinal disorders
Throwing up|Vomiting|Gastrointestinal disorders
Loose stools|Diarrhoea|Gastrointestinal disorders
Tiredness|Fatigue|General disorders
Dizzy spells|Dizziness|Nervous system disorders
Skin rash|Rash|Skin and subcutaneous tissue disorders
Itching|Pruritus|Skin and subcutaneous tissue disorders
Joint pain|Arthralgia|Musculoskeletal disorders
High blood pressure|Hypertension|Vascular disorders
Cough|Cough|Respiratory disorders
Runny nose|Nasopharyngitis|Infections and infestations
Trouble sleeping|Insomnia|Psychiatric disorders
Back pain|Back pain|Musculoskeletal disorders
Fever|Pyrexia|General disorders
;
run;

data raw.adverse;
  call streaminit(&seed_ae);
  length aeterm $50 aedecod $50 aebodsys $50 aesev $10 aeser $1;
  set raw.demog(keep=subjid trtsdt trtedt) end=eof;

  /* Untreated subjects contribute no AEs */
  if trtsdt = . then nae = 0;
  else               nae = min( rand("poisson", 1.5), 5 );   /* 0..5      */

  _window = max( (trtedt - trtsdt), 7 );

  do aeseq = 1 to nae;

    /* random access one dictionary row */
    _idx = 1 + int( rand("uniform") * _ndict );
    set work.aedict point=_idx nobs=_ndict;

    /* severity: mostly mild/moderate */
    _u = rand("uniform");
    if      _u < 0.55 then aesev = "MILD";
    else if _u < 0.88 then aesev = "MODERATE";
    else                   aesev = "SEVERE";

    /* seriousness: rare, more likely when severe */
    if aesev = "SEVERE" then aeser = ifc(rand("uniform")<0.30, "Y", "N");
    else                     aeser = ifc(rand("uniform")<0.05, "Y", "N");

    aestdt = trtsdt + int( rand("uniform") * _window );
    aeendt = aestdt + 1 + int( rand("uniform") * 14 );
    if aeendt > trtedt then aeendt = trtedt;      /* cap within window   */
    format aestdt aeendt date9.;

    output;
  end;

  keep subjid aeseq aeterm aedecod aebodsys aesev aeser aestdt aeendt;
run;

proc sort data=raw.adverse; by subjid aeseq; run;

/*======================================================================
  3) raw.disposition - VERBATIM disposition as "collected" by Data
     Management. One record only for subjects who have a disposition
     event (completed or discontinued). Subjects still ongoing, or never
     treated, have NO record -> ds.sas leaves them out -> ADSL derives
     EOSSTT = 'ONGOING'.
     Variable names match programs/sdtm/ds.sas:
        subjid  dsstat  dsreas  dsdt
     Distribution among treated: ~10%% ongoing (no record),
        ~70%% completed, ~20%% discontinued with a verbatim reason.
======================================================================*/
data raw.disposition;
  call streaminit(&seed_ds);
  length dsstat $15 dsreas $40;
  set raw.demog(keep=subjid trtsdt trtedt);

  /* Untreated subjects: no disposition collected */
  if trtsdt = . then delete;

  _u = rand("uniform");
  if _u < 0.10 then delete;                       /* still ongoing: no row */
  else if _u < 0.80 then do;                      /* completed             */
    dsstat = "COMPLETED";
    dsreas = "";
    dsdt   = trtedt;
  end;
  else do;                                        /* discontinued          */
    dsstat = "DISCONTINUED";
    _r = rand("uniform");                          /* VERBATIM, mixed case  */
    if      _r < 0.40 then dsreas = "Adverse event";
    else if _r < 0.70 then dsreas = "Subject chose to withdraw";
    else if _r < 0.88 then dsreas = "Lack of efficacy";
    else                   dsreas = "Lost to follow-up";
    /* discontinuation date somewhere inside the treatment window */
    dsdt = trtsdt + int(rand("uniform")*max((trtedt-trtsdt),1));
  end;
  format dsdt date9.;

  keep subjid dsstat dsreas dsdt;
run;

proc sort data=raw.disposition; by subjid; run;

/*======================================================================
  4) Expected-output checks (self-verify the generated RAW sample)
======================================================================*/
title "mk_sample_data - generated RAW sample summary (study XYZ123)";

proc sql;
  select count(*)                         as n_subjects
         label="Subjects (demog)"                          from raw.demog;
  select sum(trtsdt is not missing)       as n_treated
         label="Treated (SAFFL=Y)"                         from raw.demog;
  select count(*)                         as n_ae_records
         label="AE records"                                from raw.adverse;
  select count(*)                         as n_disp
         label="Disposition records (raw)"                 from raw.disposition;
quit;

proc freq data=raw.demog;        tables arm sex / missing;         run;
proc freq data=raw.disposition;  tables dsstat dsreas / missing;   run;
proc freq data=raw.adverse;      tables aesev aeser / missing;     run;

title;

%put NOTE: mk_sample_data complete. raw.demog / raw.adverse / raw.disposition ready.;
%put NOTE: Next, run dm.sas, ae.sas, ds.sas, adsl.sas, adae.sas, then qc_adsl.sas.;
