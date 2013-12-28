
DEFINE TEMP-TABLE ttResetPassword NO-UNDO {&reference-only}
  field username as character
  field PasswordResetted as logical
  .
  
DEFINE DATASET dsResetPassword {&reference-only} FOR ttResetPassword.