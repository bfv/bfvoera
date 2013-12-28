using bfv.oera.base.*.
using bfv.oera.service.*.
    
{bfv/oera/service/dsexception.i}    
{bfv/oera/service/dschangepassword.i}


define output       parameter DATASET for dsException.
define input-output parameter DATASET for dsChangePassword.
define input-output parameter DATASET-HANDLE phdsContext.

define variable contextInstance       as srvdatacontext.


do on stop undo, leave:
     
    /* Create a server-side instance of the datacontext class and bind the context DataSet
    received from the client to that object. */
    contextInstance = new srvdatacontext().
    contextInstance:bindContext(input DATASET-HANDLE phdsContext bind).
    
/*    servicemgr:getInstance():authenticationService:serverChangePassword(input-output dataset dsChangePassword by-reference,*/
/*        contextInstance).                                                                                                  */
        
end.

servicemgr:getInstance():exceptionService:fetchException(output DATASET dsException).
servicemgr:getInstance():exceptionService:emptyException().
delete object contextInstance.

