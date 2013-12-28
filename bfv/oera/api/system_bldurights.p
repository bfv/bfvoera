
/*------------------------------------------------------------------------
    File        : system_bldurights.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : rvkanten
    Created     : Thu Jul 25 16:18:00 CET 2013
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using bfv.oera.service.servicemgr.

routine-level on error undo, throw.

define input parameter SessionID as character no-undo.
define input parameter UserCode  as character no-undo.

define variable lob_ServiceManager as servicemgr     no-undo.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
lob_ServiceManager = servicemgr:getInstance().

do on stop undo, leave:

  lob_ServiceManager:sessionContextService:setSessionId(SessionID).
    
/*  if (not lob_ServiceManager:authenticationService:loadPrincipal(SessionID))*/
/*  then                                                                      */
/*    lob_ServiceManager:exceptionService:throwError(                         */
/*      "UNKOWN",                                                             */
/*      "Invalid SessionID"                                                   */
/*      ).                                                                    */
     
/*  lob_ServiceManager:authorizationService:buildUserRights(UserCode).*/
end.
