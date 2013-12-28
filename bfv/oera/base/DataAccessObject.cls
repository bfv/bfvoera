routine-level on error undo, throw.

using bfv.oera.base.ComponentBase.
using bfv.oera.base.DAEventArgs.
using bfv.oera.base.srvdatacontext.
using bfv.oera.base.ValidationManager.
using bfv.oera.interfaces.IDataAccess.
using bfv.oera.service.ServiceManager.
using Progress.Lang.AppError.


class bfv.oera.base.DataAccessObject inherits ComponentBase implements IDataAccess use-widget-pool abstract:
  
  define private variable ignoreTempTables as character no-undo.

  define public property Validations as ValidationManager no-undo 
    get():
      if (not valid-object(Validations)) then 
        Validations = new ValidationManager().
      return Validations.
    end. 
    private set.

  define protected event BeforeRowSave signature void (Sender as Progress.Lang.Object, EventArgs as DAEventArgs).
  define protected event AfterRowSave  signature void (Sender as Progress.Lang.Object, EventArgs as DAEventArgs).

  define public property DatasetHandle as handle no-undo
    get. 
    set (phDataSet as handle):
      if (valid-handle(phDataSet) and phDataSet:type = "DATASET") then
        DatasetHandle = phDataSet.
      else 
        undo, throw new AppError ("DAO: datasethandle not set", -1).
    end set.

  define public    property ContextInstance as srvdatacontext no-undo get. set.
  define protected property IgnoreWarning   as logical no-undo init false get. set.


  method protected character GetDSName():
    /* niet langer nodig, maar niet verwijderd ivm backward compatibility */ 
  end method.

  method public void LoadData():
    /* Load the data from the persistent store into the dataset
     * Entry point for the business entity 
     * Precondition: attributes DatasetHandle and context instance are valid handles to a real dataset */
     
    define variable emptyDataset as character no-undo.
    
    emptyDataset = ContextInstance:getOption("DoNotEmptyDataset").
    
    if (emptyDataset = "" or emptyDataset = ?) then    /* via optie ander breekt andere code misschien */
      DatasetHandle:empty-dataset().  /* Sometimes required since everything is BY-REFERENCE */
      
    SetFillMode("MERGE").
    AttachDatasource().     
    FillDataset().
    DetachDatasource().  
    
    catch err1 as Progress.Lang.Error:
      ServiceManager:ExceptionService:addError("DAO0001", err1:GetMessage(1)).  
      DatasetHandle:error = true.
    end catch.
    
  end method.
  
  method protected void SetFillMode(fillMode as character):
    /* Initialize all buffers in the dataset to a certain fill-mode */
    define variable i as integer no-undo.
    
    do i = 1 to DatasetHandle:num-buffers:
      DatasetHandle:get-buffer-handle(i):fill-mode = fillMode.
    end.
    
  end method.

  method public void SaveData ():
    /* Save the data from the dataset into the persistent store 
     * Entry point for the business entity
     * Precondition: attributes DatasetHandle and context instance are valid handles to a real dataset */  
  
    AttachDatasource ().  
    IgnoreWarning = contextInstance:getOption("ignoreWarning") = "YES".    
    ValidateData ().   
    BeforeCommit().   
    if (not DatasetHandle:error) then
      CommitData().     
    AfterCommit().
    DetachDatasource().    
    
    catch err1 as Progress.Lang.Error :
      message err1:GetMessage(1).
      ServiceManager:ExceptionService:addError("DAO0002", err1:GetMessage(1) + (if (err1:CallStack) > "" then "~n" + err1:CallStack else "")).	
      DatasetHandle:error = true.
    end catch.
    
  end method.
  
  method protected void FillDataset():
    /* Fill the dataset
     * Uses the context from the context dataset:
     * OPTION <tablename>.batchsize     - Maximum number of records to be loaded
     * OPTION <tablename>.restartRowid  - Context for batching
     * OPTION <tablename>.nextRowid     - Context for batching
     * Precondition: Data source or callback methods for the dataset are attached */
    define variable iBuffer           as integer no-undo.
    define variable iDataSourceBuffer as integer no-undo.
    define variable iBatchSize        as integer no-undo initial 0.  
    define variable cRowid            as char    no-undo.  
    
    /* Retrieve the batch size and nextRowid from the context for all buffers */
    do iBuffer = 1 to DatasetHandle:num-buffers:
    
      /* allow batch size at buffer level and top level */
      iBatchSize = integer(
        contextInstance:getContext(
          "OPTION", 
          DatasetHandle:get-buffer-handle(iBuffer):Name + ".batchSize",
          ""
        )
      ) no-error.

      if (error-status:error or iBatchSize = 0 or iBatchSize = ?) then do:
      
        iBatchSize = integer(contextInstance:getContext("OPTION", "batchSize", "")) no-error.
        if (error-status:error or iBatchSize = ?) then
          iBatchSize = 0.       
               
      end.
      
      DatasetHandle:get-buffer-handle(iBuffer):batch-size = iBatchSize.
      
      if valid-handle(DatasetHandle:get-buffer-handle(iBuffer):data-source) then do:
      
        do iDataSourceBuffer = 1 to DatasetHandle:get-buffer-handle(iBuffer):data-source:num-source-buffers:
          
          cRowid = contextInstance:getContext(
            "OPTION", 
            DatasetHandle:get-buffer-handle(iBuffer):Name + "_" + string(iDataSourceBuffer) + ".restartRowid", ""
          ).        
            
          if (cRowid <> "" and cRowid <> ?) then
            DatasetHandle:get-buffer-handle(iBuffer):data-source:restart-rowid(iDataSourceBuffer) = to-rowid(cRowid) no-error.
            
        end.
        
      end.
      
    end.  /* do iBuffer = 1 to DatasetHandle:num-buffers */
    
    /* Actual logic to fill the dataset */    
    DatasetHandle:fill(). 
    
    /* Return the nextRowid for every buffer */
    do iBuffer = 1 to DatasetHandle:num-buffers:     
      if (valid-handle (DatasetHandle:get-buffer-handle(iBuffer):data-source)) then do:        
        do iDataSourceBuffer = 1 to DatasetHandle:get-buffer-handle(iBuffer):data-source:num-source-buffers:
          
          contextInstance:setContext(
            "OPTION", 
            DatasetHandle:get-buffer-handle(iBuffer):Name + "_" + string(iDataSourceBuffer) + ".nextRowid":U,
            "",
            string(DatasetHandle:get-buffer-handle(iBuffer):data-source:next-rowid(iDataSourceBuffer))
          ) no-error.
        end.
      end.
    end.
    
    return.
    
  end method.  /* FillDataset */
  
  method protected void AttachDatasource():
    /* Abstract method to override with code to attach a datasource, identify a callback or set the buffers to NO-FILL */
    message program-name(1) 'must have an override' view-as alert-box.
  end.
  
  method protected void ValidateData():
    
    if (Validations:HasValidations) then
      Validations:RunValidations(dataset-handle DatasetHandle by-reference).
      
  end method.
  
  method protected void BeforeCommit():
  /* Empty method to override with code to for example assign some 'display-only' fields in the dataset */
  end method.  
  
  method protected void AfterCommit():
  /* Empty method to override with code to for example assign some 'display-only' fields in the dataset */
  end method.  
  
  method protected character addError(beforebuffer as handle, errorstring as character):
    assign 
      beforebuffer:error = true
      DatasetHandle:error   = true
      .
    return (if beforebuffer:error-string = ? then "" else (beforebuffer:error-string + "~n")) + errorstring.
           
  end method.    
  
  method protected character addWarning(beforebuffer as handle, warningstring as character):
    return (if beforebuffer:private-data = ? then "" else (beforebuffer:private-data + "~n")) + warningstring.
  end method.   
  
  method protected void CommitData():
    /* Actual commit of the dataset data into the database
     * Walk to the dataset buffers from top-level buffers down to child buffers in a 1..n relation
     * (the parent record is added to the database before the child record is added, but on an
     *  update the parent is not allways modified and in the dataset)
     */
    define variable hTopBuff         as handle    no-undo.
    define variable iBuff            as integer   no-undo.  
    
    /* ignoreTempTables kan gebruikt worden voor het beperken van de set temptables die moeten resulteren in een saveBuffer aanroep. 
       Bijvoorbeeld bij het opslaan van telkens een deel van een dataset via een businesstask / diverse businessentities 
       Voor de temptables die niet mogen resulteren in een savebuffer aanroep hoeven ook geen data-sources te worden aangemaakt
       (via methode AttachDatasource). */
    ignoreTempTables = contextInstance:getContext("OPTION", "IgnoreTempTables", "").
    if (ignoreTempTables = ?) then
      ignoreTempTables = "".    
    
    /* Walk down the table hierarchy starting at each top-level table
    (with no parent). */  
    do iBuff = 1 to DatasetHandle:num-top-buffers:
      
      hTopBuff = DatasetHandle:get-top-buffer(iBuff).
        
      /* Skip the reposition children. */
      if (hTopBuff:parent-relation <> ?) then 
        next.
        
      traverseBuffers (hTopBuff).
    end. 
    
  end method.
  
  method public void DetachDatasource():
    /* Clean up attached datasources and callback
     * Precondition: DatasetHandle must reference a valid dataset */
    define variable iBuffer           as integer no-undo.
    define variable hBuffer           as handle  no-undo.
    define variable datasourceHandle  as handle no-undo.
    define variable queryHandle       as handle no-undo.
    define variable i                 as integer no-undo.
    define variable numBuffers        as integer no-undo.
    
    do iBuffer = 1 to DatasetHandle:num-buffers:

      hBuffer = DatasetHandle:get-buffer-handle(iBuffer).
      datasourceHandle = hBuffer:data-source.
      hBuffer:detach-data-source().
      
      if (not valid-handle(datasourceHandle)) then
        return.
        
      datasourceHandle:query:query-close().

      numBuffers = datasourceHandle:query:num-buffers.
      do i = 1 to numBuffers:
        delete object datasourceHandle:query:get-buffer-handle(i) no-error.
      end.

      delete object datasourceHandle:query no-error.
      delete object datasourceHandle no-error.
      
    end.
    
  end method.
  
  method protected handle NewDataSource(pcTables as character, pcKeys as character,pcQuery as character):
    /* Define a datasource dynamically 
     * pcTables:   Comma list of the tables in the query, no spaces allowed 
     * pcKeys:     Key fields of the tables as used in ADD-SOURCE-BUFFER method of the data-source. Keys are separated by comma, tables are separated by | 
     * pcQuery:    Query string based on the tables in pcTables */
    define variable hSrc        as handle    no-undo.
    define variable hBuffer     as handle    no-undo.
    define variable iBuffer     as integer   no-undo.
    define variable hQuery      as handle    no-undo.
    define variable cBufferKeys as character no-undo.

    create data-source hSrc.
    if (pcQuery <> ? and pcQuery <> "") then
      create query hQuery.
 
    do iBuffer = 1 to num-entries(pcTables):
      create buffer hBuffer for table entry(iBuffer, pcTables).
      cBufferKeys = entry(iBuffer, pcKeys, "|").
      hSrc:add-source-buffer(hBuffer, cBufferKeys).
      if (pcQuery <> ? and pcQuery <> "") then
        hQuery:add-buffer(hBuffer).
    end.
    
    if pcQuery <> ? and pcQuery <> "" then
      hSrc:query = hQuery.
    
    return hSrc.
    
  end method. 

  method protected void BufferDataSource(pcEntityTable as character, pcDbTables as character, pcKeys as character, pcMap as character, pcQuery as character).
    /* Attach a new datasource to a buffer after applying the context from the context dataset to the query
     * pcEntityTable  Name of the table in the dataset
     * pcDbTables     Name of the tables that form the join to get the data out of the dataset
     * pcKeys         Key fields of the tables as used in ADD-SOURCE-BUFFER method of the data-source. Keys are separated by comma, tables are separated by |
     * pcMap          Field mapping as used in the ATTACH-data-source method of the BUFFER
     * pcQuery        Base query to be used. Will be manipulated using the context dataset */
     
    define variable hEntityBuffer as handle    no-undo.
    define variable hDataSource   as handle    no-undo.
    define variable cQuery        as character no-undo.
    define variable mlgSucces     as logical   no-undo.
    
    
    if (pcKeys = "") then 
      pcKeys = ?.
    if (pcMap  = "") then 
      pcMap = ?.
      
    hEntityBuffer = DatasetHandle:get-buffer-handle(pcEntityTable).
    
    if not valid-handle(hEntityBuffer) then 
      undo, throw new AppError(substitute("buffer &1 not found in dataset", quoter(pcEntityTable)), -1).
   
    hDatasource = newDataSource(pcDbTables, pcKeys, pcQuery).
    hEntityBuffer:attach-data-source(hDataSource, pcMap).
    cQuery = contextInstance:applyContext(
               (if (pcQuery > "") then pcQuery else hDataSource:query:prepare-string), 
               pcDbTables, 
               hEntityBuffer:data-source-complete-map
             ).
    
    if (cQuery <> "" and cQuery <> ?) then do:
      
      mlgSucces = hEntityBuffer:data-source:query:query-prepare(cQuery) no-error.
      
      if (not mlgSucces) then
        undo, throw new AppError(error-status:get-message(1), -1).
        
    end.
    
  end method.
  
  method public void BufferDataSource(entityTable as character, databaseTables as character):
    BufferDataSource(entityTable, databaseTables, "", "", "").
  end method.
  
  /* omdat mapping een veel gebruikte optie is en de keys minder is deze 3e parameter in deze overload op mapping ipv keys */  
  method public void BufferDataSource(entityTable as character, databaseTables as character, mappings as character):
    BufferDataSource(entityTable, databaseTables, "", mappings, "").
  end method.
  
  method private void saveBuffer (phBuffer as handle):
  
    /* See commitData, save the records in a single buffer */
    define variable hBeforeBuff    as handle    no-undo.
    define variable hBeforeQry     as handle    no-undo.
    define variable hDataSet       as handle    no-undo.
    define variable hDataSource    as handle    no-undo.
    define variable iBufferIndex   as integer   no-undo.
    define variable cIgnoreBuffers as character no-undo.
    define variable cSkipFields    as character no-undo.
     
    create query hBeforeQry.
    assign 
      hBeforeBuff    = phBuffer:before-buffer
      hDataSet       = phBuffer:dataset 
      /* See if all the buffers should be saved */
      cIgnoreBuffers = contextInstance:getContext("OPTION", "IgnoreBuffers", "")
      cIgnoreBuffers = (if cIgnoreBuffers = ? then "" else cIgnoreBuffers)
      .
      
    if valid-handle(hBeforeBuff) then do:
      
      hBeforeQry:set-buffers(hBeforeBuff).
      hBeforeQry:query-prepare("FOR EACH ":U + hBeforeBuff:name).
      hBeforeQry:query-open().
      hBeforeQry:get-first().

      /* Process all the updates for the current table. */
      do while not hBeforeQry:query-off-end transaction on error undo, throw: 
                    
        hDataSource = phBuffer:data-source.

        if not valid-handle(hDataSource) then do:
          message substitute('Before image records found, but no data-source defined (&1)', phBuffer:name).
          leave.
        end.
        
        beforeRowSave:Publish(
          this-object,
          new DAEventArgs(input hBeforeBuff:row-state,
          phBuffer:name,
          hBeforeBuff) 
          ).
             
        if not hBeforeBuff:error then 
        do iBufferIndex = 1 to hDataSource:num-source-buffers:        /* Additional code needed to handle multiple updatable buffers. */                
          
          do on error undo, leave:
            /* save changes to the buffers in the datasource that should not be ignored */
            if lookup(hDataSource:get-source-buffer(iBufferIndex):NAME, cIgnoreBuffers) = 0 then do:
              
              cSkipFields = contextInstance:getContext(
                                           "OPTION":U, 
                                           substitute("&1_&2.skipFields",
                                                      phBuffer:name,
                                                      string(iBufferIndex)
                                                     ),
                                           "").
              if (cSkipFields = ?) then
                cSkipFields = "".
 
              hBeforeBuff:save-row-changes(iBufferIndex, cSkipFields) no-error.

            end.
          end.

          if hBeforeBuff:error then do:

            if (hBeforeBuff:error-string = ?) then do:
              if (return-value > "") then 
                hBeforeBuff:error-string = return-value.
              else
                hBeforeBuff:error-string = error-status:get-message(1).
            end.
            
            hBeforeBuff:dataset:error = true.               
            error-status:error = false.
            
          end. /* error */
          
        end. /* NOT hBeforeBuff:ERROR ... */
             
        if not hBeforeBuff:error then do: 
        
          phBuffer:find-by-rowid(hBeforeBuff:after-rowid) no-error.
          afterRowSave:Publish(
            this-object,
            new DAEventArgs(hBeforeBuff:row-state, phBuffer:name, phBuffer) 
          ).
          
        end.                       

        hBeforeQry:get-next().
        
      end.  /* do while not hBeforeQry:query-off-end */
      
    end.  /* if valid-handle(hBeforeBuff)  */
    
    finally:
      hBeforeQry:query-close().
      delete object hBeforeQry no-error.
    end finally. 
    
  end method.
  
  
  method private void traverseBuffers(phBuffer as handle):
    
    define variable iChildRel as integer no-undo.

    if (lookup(phBuffer:name, ignoreTempTables) = 0) then 
      saveBuffer(phBuffer).
    
    do iChildRel = 1 to phBuffer:num-child-relations:
      traverseBuffers(phBuffer:get-child-relation(iChildRel):child-buffer).
    end. 

  end method.


  method public void ResetDataset():
  /* Not yet defined. */
  end method.
  
 
  method public void AfterRowFill (dataset-handle DatasetHandle):
  /* Placeholder for custom AFTER-ROW-FILL event handler in the
     Data Access Object to load data from related tables and any
     other calculations. */    
  end method.

  method public void LoadRelated():
    /* Find the related data for the dataset.
     * Default behavior is to 're-apply' the after-row-fill.
     */
    AttachDataSource().
    datasetBiCallback("AFTER-ROW-FILL").
    DetachDataSource().
  end method.

  method private void datasetBiCallback(pcEvent as character):
    
    define variable iTable  as integer no-undo.
    define variable hQuery  as handle  no-undo.
    define variable hBuffer as handle  no-undo.
    
    
    create query hQuery.
    
    do iTable = 1 to DatasetHandle:num-buffers:
      hBuffer = DatasetHandle:get-buffer-handle(iTable).
      
      if hBuffer:table-handle:has-records then do:
      
        hQuery:set-buffers(hBuffer:before-buffer).
        hQuery:query-prepare(
          substitute("for each &1 where row-state(&1) = row-created OR row-state(&1) = row-modified", hBuffer:before-buffer:name)
        ).
        hQuery:query-open().
        hQuery:get-first.
        
        do while not hQuery:query-off-end:
          hBuffer:find-by-rowid(hBuffer:before-buffer:AFTER-ROWID).
          hBuffer:apply-callback(pcEvent).
          hQuery:get-next().
        end.
      end.
    end.
    
    finally:
      delete object hQuery no-error.
    end.
    
  end method.
  
end class.  

