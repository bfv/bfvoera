
using bfv.oera.base.srvdatacontext.
using bfv.oera.interfaces.IBusinessEntity.

interface bfv.oera.interfaces.IBusinessEntity:  
  
    method public void FetchData(output dataset-handle dsDataset, 
                                 input contextInstance as srvdatacontext).
                                 
    method public void StoreData(input-output dataset-handle phDataset, 
                                 input contextInstance as srvdatacontext).
                                 
end interface.
