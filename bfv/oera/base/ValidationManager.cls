 
using bfv.oera.interfaces.IValidator.


class bfv.oera.base.ValidationManager: 
  
  define public property HasValidations as logical no-undo get. private set.
  
  define private variable initialized as logical no-undo.
  
   
  define private temp-table ttvalidator no-undo
    field classname as character
    field objref as Progress.Lang.Object
    .
    
  
  method public void RegisterValidator(classname as character):
    
    define variable validatorClass as Progress.Lang.Class no-undo.
    
    validatorClass = Progress.Lang.Class:GetClass(classname).
    if (not validatorClass:IsA("bfv.oera.interfaces.IValidator")) then 
      undo, throw new Progress.Lang.AppError(substitute ("'&1' is not an IValidator", classname), -1).
    
    create ttvalidator.
    assign 
      ttvalidator.classname = classname
      .
    
    HasValidations = true.
      
  end method.
  
  
  method public void RunValidations(dataset-handle dsdata):
    
    define variable validator as IValidator no-undo.
    
    for each ttvalidator:  
      
      if (not valid-object(ttvalidator.objref)) then 
        ttvalidator.objref = dynamic-new (ttvalidator.classname)().
        
      validator = cast(ttvalidator.objref, IValidator).
      validator:ValidateData(dataset-handle dsdata by-reference).
      
    end. 
      
  end method.
  
end class.