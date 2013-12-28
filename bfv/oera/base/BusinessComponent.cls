using bfv.oera.base.Componentbase.
using bfv.oera.base.IBusinessEntity.
using bfv.oera.base.srvdatacontext.
using bfv.oera.base.ServerDataContext.
using bfv.lib.util.DataSetHelper.
/*using bfv.lib.util.DatasetDebug. */
using bfv.oera.service.ServiceManager.

routine-level on error undo, throw.


class bfv.oera.base.BusinessComponent inherits ComponentBase:

/* This is the top-level class for all types of Business Components,
   including Business Entities and Tasks. It is empty until
   specific methods and definitions can be filled in.
*/
  
  method public logical StoreChanges(dataset-handle datasetIn, be as IBusinessEntity, includeParents as logical):
    StoreChanges(dataset-handle datasetIn by-reference, be, new ServerDataContext(), includeParents).
  end method.
  
  method public logical StoreChanges(dataset-handle datasetIn, be as IBusinessEntity, ctx as srvdatacontext, includeParents as logical):

    define variable changes as handle no-undo.

    changes = DataSetHelper:GetChanges(datasetIn, includeParents).
    be:StoreData(input-output dataset-handle changes by-reference, ctx).
    
    changes:merge-changes(datasetIn, true).
    datasetIn:error = changes:error.
    
    finally:
      delete object changes no-error.
    end.

  end method.
  
end class.

