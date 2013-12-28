
{curaservices/common/dsResponse.i}  /* voor syntax checking */

/** -- generieke error handling ten behoeve vd services -- **/
catch oApplError as OpenEdge.Core.System.ApplicationError:
  create ttResponse.
  assign 
    ttResponse.ResponseCode    = "0"
    ttResponse.ResponseMessage = oApplError:ResolvedMessageText()
    ttResponse.ResponseLevel   = "0"
    .
  release ttResponse.
end catch.

catch oAppError as Progress.Lang.AppError:
  
  define variable responseMessageOut as character no-undo.
  
  if (oAppError:GetMessage(1) > "") then
    responseMessageOut = oAppError:GetMessage(1).
  else 
    responseMessageOut = oAppError:ReturnValue.
    
  create ttResponse.
  assign 
    ttResponse.ResponseCode    = "0"
    ttResponse.ResponseMessage = responseMessageOut
    ttResponse.ResponseLevel   = "0"
    .
  release ttResponse.
end catch.

catch oError as Progress.Lang.Error:
  create ttResponse.
  assign 
    ttResponse.ResponseCode    = "0"
    ttResponse.ResponseMessage = oError:GetMessage(1) + (if oError:CallStack > "" then ("~n" + oError:CallStack) else "")
    ttResponse.ResponseLevel   = "0"
    .
  release ttResponse.
end catch.
