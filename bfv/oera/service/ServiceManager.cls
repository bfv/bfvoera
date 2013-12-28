 
 /* Dit is de static implementatie van servicemgr zodat er niet 
  * langer "tussen variabelen" nodig zijn
  */

using Progress.Lang.Object.
/*using bfv.oera.service.authenticationservice.*/
/*using bfv.oera.service.authorizationservice. */
/*using bfv.oera.service.contextmanager.       */
using bfv.oera.service.exceptionservice.
using bfv.oera.service.sessioncontextservice.
using bfv.oera.service.servicemgr.


routine-level on error undo, throw.

class bfv.oera.service.ServiceManager: 
  
  define private static variable srvMgrInstance as servicemgr no-undo. 
    
/*  define public static property AuthenticationService as authenticationservice*/
/*    get:                                                                      */
/*      return srvMgrInstance:AuthenticationService.                            */
/*    end.                                                                      */
/*                                                                              */
/*  define public static property AuthorizationService  as authorizationservice */
/*    get:                                                                      */
/*      return srvMgrInstance:AuthorizationService.                             */
/*    end.                                                                      */
/*                                                                              */
/*  define public static property ContextService        as contextmanager       */
/*    get:                                                                      */
/*      return srvMgrInstance:ContextService.                                   */
/*    end.                                                                      */
/*                                                                              */
  define public static property ExceptionService      as exceptionservice
    get: 
      return srvMgrInstance:ExceptionService.
    end. 
    
  define public static property SessionContextService as sessioncontextservice
    get:
      return srvMgrInstance:SessionContextService.
    end.
  
  
  constructor static ServiceManager():
    srvMgrInstance = servicemgr:getInstance().
  end.
  
  
  method public static Object StartService(classname as character):
    return srvMgrInstance:StartService(classname).
  end method.  
  

  method public static void StopService(instanceObject as Object):
    srvMgrInstance:StopService(instanceObject).
  end method.
  
  
  method public static void SetSessionId (sessionId as character):
  
    SessionContextService:SetSessionId(SessionId).
    ExceptionService:EmptyException().

/*    if (not AuthenticationService:LoadPrincipal(input SessionId)) then         */
/*      ExceptionService:throwError("UNKOWN", "Load of client-principal failed").*/
    
  end method.
  
end class.