using bfv.oera.base.srvdatacontext.

interface bfv.oera.base.IBusinessEntity:  
  
    method public void FetchData(output dataset-handle dsDataset, contextInstance as srvdatacontext).                                
    method public void StoreData(input-output dataset-handle phDataset, contextInstance as srvdatacontext).
                                 
end interface.
