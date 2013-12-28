
/*------------------------------------------------------------------------
    File        : system_updurights.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : rvkanten
    Created     : Mon Feb 22 16:36:31 CET 2011
    Notes       :
  ----------------------------------------------------------------------*/
/*======================================================================
$Log: /CURA91/OERA/api/system_updurights.p $
 
 2     2-03-11 9:28 Rvk
 COBUS: Naar release 09.1.06.12 (02/03/11). Bijwerken van autorisatie op
 AppServer.
========================================================================*/       

/* ***************************  Definitions  ************************** */
using bfv.oera.base.*.
using bfv.oera.service.*.

routine-level on error undo, throw.

define input        parameter ipch_SessionID as character no-undo.

define variable lob_ServerContext  as srvdatacontext no-undo.
define variable lob_ServiceManager as servicemgr     no-undo.


/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
/*lob_ServiceManager = OERA.service.servicemgr:getInstance().*/

do on stop undo, leave:

    lob_ServiceManager:sessionContextService:setSessionId(ipch_SessionID).
    
/*    if not lob_ServiceManager:authenticationService:loadPrincipal(input ipch_SessionID)*/
/*    then                                                                               */
/*        lob_ServiceManager:exceptionService:throwError(                                */
/*          'UNKOWN':U,                                                                  */
/*          'Invalid SessionID':U                                                        */
/*        ).                                                                             */
/*                                                                                       */
/*    lob_ServiceManager:authorizationService:updateUserRights().                        */
end.
