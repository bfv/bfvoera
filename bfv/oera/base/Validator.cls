 
using bfv.oera.interfaces.IValidator.


class bfv.oera.base.Validator implements IValidator abstract: 
  
  method public abstract logical ValidateData(dataset-handle dsdata).
    
    
  method protected void SetError(bufferhandle as handle, errorstring as character):
     
    assign 
      bufferhandle:error-string = (if (bufferhandle:error-string > "") then 
                                     bufferhandle:error-string + "~n" 
                                   else 
                                     "") + 
                                  substitute("&1", errorstring)
      bufferhandle:error = true
      bufferhandle:dataset:error = true
      .
      
  end method.
  
end class.