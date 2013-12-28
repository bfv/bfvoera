using OERA.service.ServiceManager.
using OERA.base.srvdatacontext.

routine-level on error undo, throw.

&if defined(direction) = 0 &then~
  &scoped-define direction  output
&endif~

define input  parameter sessionId      as  character no-undo.
{&params}
define output parameter dataset-handle     exceptionDatasetHandle.
&if defined(skipdataset) = 0 &then ~
define {&direction} parameter dataset-handle     dsdata.
&endif
&if defined(skipcontext) = 0 &then ~
define input-output parameter dataset-handle     contextDatasetHandle.
&endif ~
~
&if defined(skipcontext) = 0 &then
define variable contextObject  as srvdatacontext no-undo.
&endif ~
define variable implementation as {&classname} no-undo.


do on stop undo, leave: 
  
  ServiceManager:SessionContextService:setSessionId(sessionId).
  ServiceManager:ExceptionService:EmptyException().
  
  if (not ServiceManager:AuthenticationService:LoadPrincipal(sessionId)) then
    ServiceManager:ExceptionService:ThrowError("UNKNOWN", "Load of client-principal failed").
    
  &if defined(skipcontext) = 0 &then~
  contextObject = new srvdatacontext().
  contextObject:BindContext(dataset-handle contextDatasetHandle bind).  
  &endif
  implementation = cast(ServiceManager:StartService("{&classname}"), {&classname}).  
  
  &if defined(returnparam) > 0 &then {&returnparam} = &endif implementation:{&method}(
    {&methodparams}
    &if defined(skipdataset) = 0 &then {&direction} dataset-handle dsdata by-reference &endif &if defined(skipcontext) = 0 &then , 
    contextObject
    &endif ~
  ).
  
end.

ServiceManager:ExceptionService:FetchException(output dataset-handle exceptionDatasetHandle by-reference).

&if defined(skipfinally) = 0 &then ~
finally:
  ServiceManager:StopService(implementation). 
  &if defined(skipcontext) = 0 &then ~ 
  delete object contextObject no-error.
&endif 
end.
&endif