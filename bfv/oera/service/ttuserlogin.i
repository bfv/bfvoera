
define temp-table ttUserLogin no-undo
  {&REFERENCE-ONLY}
  field UserLoginName as character
  field UserLoginAuthToken as character 
  field UserLoginDomain as character
  field UserLoginSecondaryName as character
  field UserLoginSecondaryToken as character 
  field DaysBeforeExpiration  as integer
  field MustChangeAuthToken as logical
  .   

