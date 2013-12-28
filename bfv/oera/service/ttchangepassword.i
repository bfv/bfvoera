
DEFINE TEMP-TABLE ttChangePassword NO-UNDO  {&REFERENCE-ONLY}
  FIELD username             as character
  field oldpassword          as character
  field newpassword          as character
  field pwdchanged           as logical
  FIELD RejectionDescription as character
  .