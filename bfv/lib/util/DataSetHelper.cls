 
using Progress.Lang.*.

routine-level on error undo, throw.

class bfv.lib.util.DataSetHelper final: 

  constructor private DatasetHelper():
  /* niet instantieerbaar */  
  end.
  
  method public static void DisableDatasetForUpdate(datasetHandle as handle):
    setTrackingChanges(datasetHandle, false).  
  end method.


  method public static void EnableDatasetForUpdate(datasetHandle as handle):
		setTrackingChanges(datasetHandle, true).
  end method.
  
  
  method private static void setTrackingChanges(datasetHandle as handle, isTracked as logical):
    
    define variable i            as integer no-undo.
    define variable bufferHandle as handle  no-undo.
        
        
    do i = 1 to datasetHandle:num-buffers:           
      bufferHandle = datasetHandle:get-buffer-handle(i).
      bufferHandle:table-handle:tracking-changes = isTracked.
    end.
    
  end method.
  
  /*------------------------------------------------------------------------------
          Purpose:  	Unknown values in character velden naar initiele waarden zetten.																  
          Notes:  		Unknown values worden bijvoorbeeld door een service aangeleverd.															  
  ------------------------------------------------------------------------------*/

  method public static void SetUnknownsToInitialValue(datasetHandle as handle):		
      
    define variable numBuffers      as integer no-undo.
    define variable i       as integer no-undo.
    define variable bufferHandle    as handle  no-undo.
    define variable aantalVelden    as integer no-undo.
    define variable veldNummer      as integer no-undo.
    define variable aantalExtensies as integer no-undo.
    define variable extensieNummer  as integer no-undo.
    define variable huidigeExtensie as integer no-undo.
    define variable queryHandle as handle  no-undo.
    
        
    numBuffers = datasetHandle:num-buffers.
    create query queryHandle.
    
    do i = 1 to numBuffers:    
         
      assign 
        bufferHandle = datasetHandle:get-buffer-handle (i)
        aantalVelden = bufferHandle:num-fields.
        
      queryHandle:set-buffers(bufferHandle).
      queryHandle:query-prepare("for each " + bufferHandle:name).
      queryHandle:query-open().
      queryHandle:get-first().
        
      do while not queryHandle:query-off-end:  
        do veldNummer = 1 to aantalVelden:
          if bufferHandle:buffer-field(veldNummer):data-type <> "character" then
            next.
 
          assign 
            aantalExtensies = bufferHandle:buffer-field(veldNummer):extent.
          /* Geen extents: extent 0 wordt gebruikt. */  
          do extensieNummer = 1 to maximum(1, aantalExtensies):
            assign 
              huidigeExtensie = minimum(extensieNummer, aantalExtensies).

            if bufferHandle:buffer-field(veldNummer):buffer-value(huidigeExtensie) = "?" or /* Alleen CHAR velden komen voorbij */
              bufferHandle:buffer-field(veldNummer):buffer-value(huidigeExtensie) = ? 
              then
              assign bufferHandle:buffer-field(veldNummer):buffer-value(huidigeExtensie) = bufferHandle:buffer-field(veldNummer):default-value.

          end.
        end. /* do aantalVelden */
        
        queryHandle:get-next(). 
      end. /* query-off-end */
        
    end. /* aantal buffers */
    
    finally:
      queryHandle:query-close().
      delete object queryHandle no-error.
    end finally.

  end method.
	
  method public static void MarkDatasetAsNew(datasetHandle as handle):
    
    define variable bufferHandle as handle  no-undo.
    define variable i as integer no-undo.
	  
	
    do i = 1 to datasetHandle:num-buffers:
      bufferHandle = datasetHandle:get-buffer-handle(i).
      bufferHandle:mark-new().
    end.
    
  end method.
    
  method public static void SetRowStateAllBufferRecords(actie as integer, bufferHandle as handle):
    
    define variable queryHandle as handle no-undo.

    create query queryHandle.
    queryHandle:set-buffers(bufferHandle).
    queryHandle:query-prepare("for each " + bufferHandle:name).
    queryHandle:query-open().
    queryHandle:get-first().
    
    do while not queryHandle:query-off-end: 
 
      SetRowState(actie, bufferHandle).
      queryHandle:get-next(). 
    end. /* query-off-end */
    
    finally:
      queryHandle:query-close().
      delete object queryHandle no-error.
      bufferHandle:table-handle:tracking-changes = false.
    end finally.
      	  
  end.
	  
  method public static void SetRowState(actie as integer, bufferHandle as handle):
    
    bufferHandle:table-handle:tracking-changes = true.
      
    case actie:
      
      when row-created then do:
        bufferHandle:mark-row-state(row-created).
      end.  
      
      when row-modified then do:
        bufferHandle:buffer-field(1):buffer-value = bufferHandle:buffer-field(1):buffer-value.
      end.
      
      when row-deleted then do:
        bufferHandle:buffer-delete().
      end.
      
    end case.
    
  end method.  

  method public static void setRowStateAfterCompare(bufferChanged as handle,
    bufferDb as handle,
    idVeld as character,
    filterVeld as character,
    filterWaarde as character): 
                                               
    define variable queryHandle as handle  no-undo.
    define variable isFound         as logical no-undo.
    
    create query queryHandle.
    queryHandle:set-buffers(bufferChanged).
    queryHandle:query-prepare(substitute("for each &1 where &2.&3 = &4", bufferChanged:name, bufferChanged:name, filterVeld, quoter(filterWaarde))).
    queryHandle:query-open().
    queryHandle:get-first().

    do while not queryHandle:query-off-end:
      isFound = bufferDb:find-first(substitute("where &1.&2 = &3", bufferDb:name, idVeld, quoter(string(bufferChanged:buffer-field(idVeld):buffer-value))) ) no-error.             
      if isFound then
        SetRowState(row-modified, bufferChanged). 
      else
        SetRowState(row-created, bufferChanged).

      bufferChanged:table-handle:tracking-changes = false.  
      queryHandle:get-next(). 
    end. /* query-off-end */

    /* Check op deleted records */
    queryHandle:set-buffers(bufferDb).
    queryHandle:query-prepare("for each " + bufferDb:name).
    queryHandle:query-open().
    queryHandle:get-first().
    
    do while not queryHandle:query-off-end:
      isFound = bufferChanged:find-first(substitute("where &1.&2 = &3", bufferChanged:name, idVeld, quoter(string(bufferDb:buffer-field(idVeld):buffer-value))) ) no-error.
      if not isFound then 
      do:
        bufferChanged:buffer-create ().
        bufferChanged:buffer-copy(bufferDb).
        SetRowState(row-deleted, bufferChanged).
        bufferChanged:table-handle:tracking-changes = false.
      end.
       
      queryHandle:get-next(). 
    end. /* query-off-end */
    
    finally:
      queryHandle:query-close().
      delete object queryHandle no-error.
    end finally.
    
  end method.                                      
	
  method public static handle GetChanges(datasetInHandle as handle, includeParents as logical):
    
    define variable changedDatasetHandle as handle no-undo.
    
    create dataset changedDatasetHandle.
    changedDatasetHandle:create-like(datasetInHandle).
    changedDatasetHandle:get-changes(datasetInHandle, includeParents).
    
    return changedDatasetHandle.
    
  end method. 

  method public static void DeleteCascade(bufferHandle as handle):
    DeleteCascade(bufferHandle, true).
  end.  
  
  method public static void DeleteCascade(bufferHandle as handle, isDeleteTopBuffer as logical):
    
    define variable iRelation   as integer no-undo.
    define variable queryHandle as handle  no-undo.
      
    do iRelation = 1 to bufferHandle:num-child-relations:
      
      queryHandle = bufferHandle:get-child-relation(iRelation):query.
      queryHandle:query-open().
      queryHandle:get-first().
      
      do while (not queryHandle:query-off-end):
        DeleteCascade(queryHandle:get-buffer-handle(1)).
        queryHandle:get-next().
      end.           
                
    end.
    
    if isDeleteTopBuffer then
      bufferHandle:buffer-delete(). 
    
  end method.
  
  method public static void CopyCascade(bufferHandleFrom as handle, bufferHandleTo as handle):
    
    define variable relation            as integer   no-undo.
    define variable queryHandle         as handle    no-undo.
    define variable bufferHandleCh      as handle    no-undo.
    define variable relationField       as character no-undo.
    define variable relationFieldParent as character no-undo.
    define variable relationFieldChild  as character no-undo.
    define variable parentBufferHandle  as handle    no-undo.
    define variable primaryIndexField   as character no-undo.
    
      
    do relation = 1 to bufferHandleFrom:num-child-relations:
      
      queryHandle = bufferHandleFrom:get-child-relation(relation):query.
       
      bufferHandleCh = bufferHandleTo:get-child-relation(relation).

      queryHandle:query-open().
      queryHandle:get-first().
      
      do while (not queryHandle:query-off-end):
        
        CopyCascade(queryHandle:get-buffer-handle(1), bufferHandleTo:get-child-relation(relation):child-buffer).
        
        queryHandle:get-next().
      end.
      
    end.
    
    if valid-handle(bufferHandleFrom:parent-relation) then 
    do:
      assign
        parentBufferHandle  = bufferHandleTo:parent-relation:parent-buffer
        relationFieldParent = bufferHandleTo:parent-relation:relation-fields
        relationFieldChild  = entry(2, relationFieldParent)
        relationFieldParent = entry(1, relationFieldParent)
        primaryIndexField   = bufferHandleTo:primary
        primaryIndexField   = substring(primaryIndexField, 4) + "-id"
        .

      bufferHandleTo:buffer-create ().
      bufferHandleTo:buffer-copy(bufferHandleFrom).
      assign
        bufferhandleTo:buffer-field(primaryIndexField):buffer-value  = guid
        bufferHandleTo:buffer-field(relationFieldChild):buffer-value = parentBufferHandle:buffer-field(relationFieldParent):buffer-value
        .  
    end.
    
  end method.
  
end class.