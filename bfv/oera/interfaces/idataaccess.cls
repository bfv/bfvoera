
using bfv.oera.base.srvdatacontext.


interface bfv.oera.interfaces.IDataAccess: 
  
  define public property hdsDataset as handle no-undo get. set.
  define public property ContextInstance as srvdatacontext no-undo get. set.
    
  method public void LoadData().
  method public void SaveData().
  
  method public void LoadRelated().
  method public void ResetDataset().
  
end interface.
