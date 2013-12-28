 
using Progress.Lang.Object.
using bfv.lib.system.ObjectFactory.
using bfv.lib.system.ISingleton.
using bfv.lib.system.IDisposable.

routine-level on error undo, throw.

class bfv.lib.system.ObjectFactory: 
  
  define public static property Default as ObjectFactory get. private set. 
  
  define protected temp-table ttObjectInstance
    field classname  as character 
    field objref     as Progress.Lang.Object
    field issingleton as logical 
    index pk-objectinstance as primary unique classname objref
    .
  
  
  constructor public ObjectFactory():
    
  end.
   
  constructor static ObjectFactory():
    ObjectFactory:Default = new ObjectFactory().
  end.
  
  
  method public Object GetInstance(classNameIn as character):
    
    define variable objectInstance as Object no-undo.
    define variable isSingleton as logical no-undo.
    
    do on error undo, throw:
    
      find first ttObjectInstance where ttObjectInstance.classname = classNameIn no-error.
      
      if (not available ttObjectInstance or not ttObjectInstance.issingleton) then
        objectInstance = dynamic-new (classNameIn)().
           
      if (not available ttObjectInstance) then do:
        
        create ttObjectInstance.
        assign 
          ttObjectInstance.classname   = classNameIn
          ttObjectInstance.issingleton = isSingleton(objectInstance)
          ttObjectInstance.objref      = objectInstance
          .
          
      end.
      else if (not valid-object(objectInstance)) then 
        objectInstance = ttObjectInstance.objref.
      
      return objectInstance.
      
      catch err1 as Progress.Lang.Error :
        return ?.		
      end catch.
    
    end.
    
  end method.  /* GetInstance */
  
  
  method private logical isSingleton(objectInstance as Object):
    
    if (not valid-object(objectInstance)) then 
      return ?.
      
    return (objectInstance:GetClass():IsA("bfv.lib.system.ISingleton")).
       
  end method.  /* isSingleton */
  
  
  method public void DeleteInstance(objectInstance as Object):   
    
    if (not valid-object(objectInstance)) then 
      return.
      
    find ttObjectInstance where ttObjectInstance.classname = objectInstance:GetClass():TypeName 
                            and ttObjectInstance.objref = objectInstance 
                                no-error.
    if (available(ttObjectInstance)) then
      delete ttObjectInstance.
    
    if (objectInstance:GetClass():IsA("bfv.lib.system.IDisposable")) then 
      cast(objectInstance, "bfv.lib.system.IDisposable"):Dispose().
      
    delete object objectInstance no-error. 
    
  end method.  /* DeleteInstance */
  
  /* de release method houdt rekening met of het object al dan niet een singleton
     is. Zo ja, doe niks, zo nee, delete het object uit de factory & de sessie */
  method public void ReleaseObject(objectInstance as Object):
    
    if (isSingleton(objectInstance)) then
      return.
    else
      DeleteInstance(objectInstance).
    
  end.
  
  method public void ResetFactory():
    
    for each ttObjectInstance:
      DeleteInstance(ttObjectInstance.objref).
    end.  
  
  end method.  /* ResetFactory */
  
end class.