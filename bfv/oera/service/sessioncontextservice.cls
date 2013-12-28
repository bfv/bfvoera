using bfv.oera.interfaces.*.
using bfv.oera.service.*.

class bfv.oera.service.sessioncontextservice 
  implements isessioncontext, icomponent:
    
  define private        variable contextId         as character             no-undo.
  define private        variable sessionId         as character             no-undo.
  define private static variable cob_SessionCtxSVC as sessioncontextservice no-undo.
   


  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
		
  constructor private sessioncontextservice (  ):
    super ().
		
  end constructor.


  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
	
  method public static final sessioncontextservice getInstance(  ):
		
    if not valid-object(cob_SessionCtxSVC) then
      cob_SessionCtxSVC = new sessioncontextservice().
            
    return cob_SessionCtxSVC.

  end method. 

  method public character getContextId():
    return contextId.
  end method.
   
  method public void setContextId(pcContextId as character):
    contextId = pcContextId.
  end method. 
   
  method public character getSessionId():
    return sessionId.
  end method.
   
  method public void setSessionId(pcSessionId as character):
    sessionId = pcSessionId.
  end method. 
  
  method public void initializeComponent():
  end method.

  method public void destroyComponent():
    delete object this-object.
  end method.
end class. 
