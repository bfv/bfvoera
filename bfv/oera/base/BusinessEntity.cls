
routine-level on error undo, throw.

using bfv.oera.base.BusinessComponent.
using bfv.oera.interfaces.IBusinessEntity.
using bfv.oera.interfaces.IDataAccess.
using bfv.oera.base.srvdatacontext.
using bfv.oera.base.ServerDataContext.
using Progress.Lang.Class.
using bfv.oera.base.ValidationManager.
using bfv.oera.service.ServiceManager.

class bfv.oera.base.BusinessEntity inherits BusinessComponent implements IBusinessEntity:

  /* Standard business entity. 
   * - Since business logic is application dependent its main job
   *   is to fetch and store data via the DataAccess component
   * - Invoke validation at the appropriate times
   * - Keep state in attributes and make sure that the attributes are set on api calls
   */
  define protected    property hdsDataset      as handle no-undo get. set.
  define protected    property DataAccess      as IDataAccess no-undo get. set.
  
  define protected property CurrentDataContext as srvdatacontext get. set. 
  
  
  destructor BusinessEntity():
    if (valid-object(DataAccess)) then 
      ServiceManager:StopService(DataAccess).  
  end.
  
  define public property Validations as ValidationManager no-undo 
    get():
      if (not valid-object(Validations)) then 
        Validations = new ValidationManager().
      return Validations.
    end. 
    private set.

  method public void FetchData(output dataset-handle phDataset, 
                               contextInstance as srvdatacontext):
    /* API method to fetch data. Save attributes and continue stateful */
    hdsDataset = phDataset.
    CurrentDataContext = contextInstance.
    LoadData().
  end method.
  
  method public void StoreData(input-output dataset-handle phDataset, 
                               contextInstance as srvdatacontext):
    /* API method to store data. Save attributes and continue stateful */
    hdsDataset = phDataset.
    CurrentDataContext = contextInstance.
    SaveData().
  end method.
  
  method public void FetchRelated(input-output DATASET-HANDLE phDataset, 
                                  input contextInstance as srvdatacontext):
    /* API method to store data. Save attributes and continue stateful */
    hdsDataset = phDataset.
    CurrentDataContext = contextInstance.
    loadRelated().
  end method.

  method protected void LoadRelated():
    /* Call to state-aware standard */
    dataAccess:hdsDataset = hdsDataset.
    dataAccess:ContextInstance = CurrentDataContext.
    dataAccess:LoadRelated().
    dataAccess:ResetDataset().
  end method.

  method protected void LoadData():
    /* Set the dataset and context state in the default DataAccess component and 
       invoke the actual load */
    dataAccess:hdsDataset = hdsDataset.
    dataAccess:ContextInstance = CurrentDataContext.
    dataAccess:loadData().
    dataAccess:resetDataset().
  end method.    
  
  method protected void ValidateData():
    
    if (Validations:HasValidations) then
      Validations:RunValidations(dataset-handle hdsdataset by-reference).
      
  end method.
  
  method protected character AddError(beforebuffer as handle, errorstring as character):
    assign 
      beforebuffer:error = true
      hdsDataset:error   = true
      .
    return (if beforebuffer:error-string = ? then '' else (beforebuffer:error-string + '~n')) + errorstring.
  end method.  
  
  method protected character AddWarning(beforebuffer as handle, warningstring as character):
    return (if beforebuffer:private-data = ? then "" else (beforebuffer:private-data + "~n")) + warningstring.
  end method.    

  method protected void SaveData():
    /* Validate using the Business Logic and persistent store using the DataAccess Logic */
    ValidateData().
    PreTransaction().
    if not hdsDataset:error then do:
      dataAccess:hdsDataset = hdsDataset.
      dataAccess:ContextInstance = CurrentDataContext.
      dataAccess:saveData().
      dataAccess:resetDataset().
    end.
    PostTransaction().
  end method.

  method protected void PreTransaction():
    /* Place for implementing business logic before the actual transaction. Exists to be overridden */
  end method.

  method protected void PostTransaction():
    /* Place for implementing business logic after the actual transaction. Exists to be overridden */
  end method.
  
  method public void RegisterValidator(classname as character):
    Validations:RegisterValidator(classname).
  end method.
  
  method public logical StoreChanges(dataset-handle datasetIn, ctx as srvdatacontext, includeParents as logical):
    StoreChanges(dataset-handle datasetIn by-reference, this-object, ctx, includeParents).
  end method.
  
  method public logical StoreChanges(ctx as srvdatacontext, includeParents as logical):
    StoreChanges(dataset-handle hdsDataset by-reference, this-object, ctx, includeParents).
  end method.
  
  method public logical StoreChanges(includeParents as logical):
    StoreChanges(dataset-handle hdsDataset by-reference, this-object, includeParents).
  end method.
  
end class.   
