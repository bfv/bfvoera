 
using Progress.Lang.Object.
using bfv.oera.interfaces.iservicemgr.
using bfv.oera.interfaces.icomponent.
using bfv.oera.base.manager.
using bfv.oera.service.servicemgr.
/*using bfv.oera.service.authenticationservice.*/
/*using bfv.oera.service.authorizationservice. */
/*using bfv.oera.service.contextmanager.*/
using bfv.oera.service.exceptionservice.
using bfv.oera.service.sessioncontextservice.
using bfv.lib.system.ObjectFactory.

class bfv.oera.service.servicemgr inherits manager 
  implements iservicemgr, icomponent:
        
  define private static variable instance as servicemgr no-undo.
    
  /* These instance values are set locally and accessed elsewhere. */
  define public property SessionContextService as sessioncontextservice
    get.
    private set.
/*  define public property AuthenticationService as authenticationservice*/
/*    get.                                                               */
/*    private set.                                                       */
/*  define public property AuthorizationService  as authorizationservice*/
/*    get.                                                              */
/*    private set.                                                      */
  define public property ExceptionService      as exceptionservice
    get. 
    private set.
/*  define public property ContextService        as contextmanager*/
/*    get.                                                        */
/*    private set.                                                */


  define private static variable factory as ObjectFactory no-undo.
        

  method public static final servicemgr getInstance(  ):
		
    if not valid-object(instance) then 
      instance = new servicemgr().
            
    return instance.

  end method.

  method public void StartServices():
    ExceptionService      = bfv.oera.service.exceptionservice:getInstance().
/*    ContextService        = contextmanager:getInstance().                        */
/*    AuthenticationService = new authenticationservice().                         */
/*    AuthorizationService  = new authorizationservice().                          */
    Sessioncontextservice = bfv.oera.service.sessioncontextservice:getInstance().
  end method.

  method public void StopServices():
    ExceptionService:destroyComponent() no-error.
/*    AuthorizationService:destroyComponent() no-error. */
    Sessioncontextservice:destroyComponent() no-error.
/*    Authenticationservice:destroyComponent() no-error.*/
/*    ContextService:destroyComponent() no-error.*/
  end method.

  method public void InitializeComponent():
  /* No body for this component method yet. */
  end method.

  method public void DestroyComponent():
    delete object this-object.
  end method.

  method public character GetServiceFile(pcServiceName as character, pcComponentType as character):
    /* No body for this manager method yet. */
    return ?.
  end method.
    
  method public Progress.Lang.Object StartService (classname as character, pcComponentType as character):
    return factory:GetInstance(classname).
  end method.  /* StartService */
  
  
  method public Object StartService(classname as character):
    return StartService(classname, "").
  end method.  /* StartService */
  
    
  method public void StopService(instanceObject as Object):
    factory:ReleaseObject(instanceObject).
  end method.

  /* FatalError */
  method public void FatalError (pcMessage as char):
    message "Fatal error!" skip pcMessage view-as alert-box error.
  end.  

  constructor private servicemgr():
    factory = new ObjectFactory().
    startServices().        
  end constructor.
     
  /* destructor: deletes the services and other started class instances */
  destructor public servicemgr():
    factory:ResetFactory().        
  end destructor. 
 
end class.

               
