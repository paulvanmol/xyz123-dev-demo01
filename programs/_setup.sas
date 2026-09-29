/*======================================================================
  Program : _setup.sas
  Study   : XYZ123
  Purpose : Set the workshop root and assign librefs. %include this at
            the top of a session, or run it once per SAS Studio session.
  ---------------------------------------------------------------------
  Set &workshop_root to match your platform. The path is configurable:
    Windows : d:/workshop/dev/xyz123-dev   (or c:/workshop/...)
    Linux   : /workshop/dev/xyz123-dev
======================================================================*/

options dlcreatedir;                 /* auto-create the data folders */

%global workshop_root;
%let workshop_root = d:/workshop/dev/xyz123-dev;   /* <-- edit per site */

libname raw   "&workshop_root./data/raw";
libname sdtm  "&workshop_root./data/sdtm";
libname adam  "&workshop_root./data/adam";
libname qcout "&workshop_root./data/qc";

%put NOTE: workshop_root = &workshop_root;
