
/*------------------------------------------------------------------------
    File        : ttuserlogin.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : rvkanten
    Created     : Fri Jun 29 13:44:11 CEST 2007
    Notes       :
  ----------------------------------------------------------------------*/

DEFINE TEMP-TABLE ttUserLogin NO-UNDO
  {&REFERENCE-ONLY}
  FIELD UserLoginName AS CHARACTER
  FIELD UserLoginAuthToken AS CHARACTER 
  FIELD UserLoginDomain AS CHARACTER
  FIELD UserLoginSecondaryName AS CHARACTER
  FIELD UserLoginSecondaryToken AS CHARACTER 
  FIELD DaysBeforeExpiration  as integer
  field MustChangeAuthToken as logical
  .   

