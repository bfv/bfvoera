
routine-level on error undo, throw.


using bfv.oera.interfaces.icontextmanager.
using bfv.oera.interfaces.icomponent.
using bfv.oera.service.contextmanager.
using bfv.oera.service.IContextPersistence.

class bfv.oera.service.contextmanager implements icontextmanager, icomponent
  use-widget-pool :

  {bfv/oera/service/errorstatus.i}
  {bfv/oera/service/ttcontextblock.i &REFERENCE-ONLY=REFERENCE-ONLY}
  {bfv/oera/service/ttsessioncontext.i}
  {bfv/oera/service/contextscope.i}
  
  define protected      variable LastActiveSessionID as character      no-undo.
  define protected      variable XMLDocument         as memptr         no-undo.
  define private static variable Instance            as contextmanager no-undo.  

  define public property contextPersistence as IContextPersistence no-undo get. set.
  

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
		
  constructor private contextmanager (  ):
    super ().
		
    /* to be externalized: */
    /* contextPersistence = new ContextPersitence() */
  end constructor.


  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
	
  method public static final contextmanager getInstance(  ):
		
    if not valid-object(Instance)
      then
      Instance = new contextmanager().
            
    return Instance.

  end method.


 

  method public void initializeComponent():
    clearContext().
  end method.

  method public void destroyComponent():
    /*
     **	Remove all data from the local session context cache.
     */
    clearContext().

    delete object this-object.
  end method.

  method protected void clearContext():
    /*------------------------------------------------------------------------------
      Purpose:     Clear all context related data structures.
      Parameters:  <none>
      Notes:
    ----------------------------------------------------------------------------*/

    empty temp-table ttSessionContext.
  end method.

  method public void createSession(output opch_SessionID as character):
    /*------------------------------------------------------------------------------
    Purpose:     Create a new SessionID
    Parameters:  OUTPUT CHARACTER	- The newly created SessionID
    Notes:       This operation will generate a new SessionID and also create a
             default set of context values tied to this SessionID.
  
             The SessionID is a GUID character string (32 chars) and is unique
             no matter what according to the specs. For the sake of space
             taken to store this string, we will remove the '-' signs from the
             generated GUID string which is 36 chars long.
  ------------------------------------------------------------------------------*/

    define variable flatGUID as character no-undo.

    /*
    **	We would like to get a unique string like a GUID but without the extra
    **	'-' chars that are part of the standard GUID format. We call this a
    **	FlatGUID.
    */

    createFlatGUID( output flatGUID ).

    /*
    **	If we got a valid 'flat' GUID we will create a default set of context values
    **	that are scoped to this new logical session.
    */

    if ( length( flatGUID ) = 32 ) then
    do:
      opch_SessionID = flatGUID.
      createDefaultSessionContext( input flatGUID ).
    end.
    else
    do:
      setLastError ( input {&CMFormatError} ).
      opch_SessionID = ?.
    end.
  end method.

  method private void setLastError(input errorStatusNumber as integer):
  end method.

  method private void createFlatGUID(output flatGUID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Create a new Globally Unique Identifier or GUID but remove
             the '-' chars from the generated string.
      Parameters:  OUTPUT CHARACTER	- The FlatGUID which is a 32 chars string
      Notes:
    ------------------------------------------------------------------------------*/

    define variable newGUID as character no-undo.
    define variable counter as integer   no-undo.

    /*
    **	Get a normal GUID first. This is a standard GUID formatted string.
    **	GUID Format: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    */

    createGUID( output newGUID ).

    /*
    **	If the GUID generation fails, we need to return unknown (?) value and
    **	set the ErrorStatus indicating the problem.
    */

    if ( newGUID = ? ) then
    do:
      flatGUID = ?.
      setLastError( {&CMGUIDError} ).
    end.
    else
    do:
      if ( length( newGUID ) = 36 ) and ( num-entries( newGUID , '-' ) = 5 ) then
      do:
        /*
    **	Now, remove the '-' chars from the generated GUID (36 chars) to
    **	return the 32 chars string. This saves some space and does not add
    **	any value to the unique property.
    */
        flatGUID = "".
        do counter = 1 to 5:
          flatGUID = flatGUID + ENTRY( counter, newGUID, '-' ).
        end.
      end.
      else
      do:
        /*
      **	The GUID generation did something but not return a valid string
      **	of characters. Set errorstatus to CMFormatError and return.
      */
        flatGUID = ?.
        setLastError( {&CMFormatError} ).
      end.
    end.
  end method.

  method private void createGUID(output newGUID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Create a new Globally Unique Identifier or GUID.
      Parameters:  OUTPUT CHARACTER	- The GUID which is a 36 chars string with the
                      following format:
                      "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
      Notes:
    ------------------------------------------------------------------------------*/

    newGUID = guid( generate-uuid ).
  end method.

  method private void createDefaultSessionContext(input sessionID as character):
  /*------------------------------------------------------------------------------
    Purpose:     Create a default set of context values for a logical session.
    Parameters:  INPUT  CHARACTER	- The SessionID to create the context values for.
    Notes:
  ------------------------------------------------------------------------------*/

  /*
  **	This is the procedure to create a set of context values for a newly
  **	created SessionID (i.e. a logical session). The values can be anything
  **	that make sense for a logical session such as storing the CLIENT-PRINCIPAL
  **	object for example, or storing the language and numeric format settings etc.
  */
  end method.

  method public void restoreSession(input sessionID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Restore a logical session to its previous state.
      Parameters:  INPUT  CHARACTER	- The SessionID for which to restore the session.
      Notes:       If the given SessionID is the same as the previously restored
               session, then we just skip this.
    ------------------------------------------------------------------------------*/

    define variable isValidID as logical no-undo.

    /*
    **	Validate the provided SessionID.
    */

    validateSessionID( input sessionID, output isValidID ).

    /*
    **	If the given SessionID is not a valid one, we should create some sort
    **	of error and let the app know. This should also be logged somewhere.
    */

    if not isValidID then return.

    /*
    **	Skip the restore if the previously used SessionID is the same as
    **	the one provided now.
    */

    if ( sessionID = LastActiveSessionID ) then
      return.
    else
      LastActiveSessionID = sessionID.

    /*
    **	Clear context data structures to prepare for new logical session
    **	context data.
    */

    clearSession( input ? ).

    /*
    **	Get SessionID related data into the local ttSessionContext structure.
    */
    
    contextPersistence:GetSessionContext(sessionId, temp-table ttSessionContext:handle).
        
  end method.

  method private void validateSessionID(sessionID as character, output isValidID as logical):
    
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/

    define variable decodedValue as raw no-undo.


    if (sessionID = ? or length(sessionID) <> 32) then
      isValidID = false.
    else
      assign 
        decodedValue = hex-decode(sessionID)
        isValidID    = true
        .
    
    catch oError as Progress.Lang.Error:
      delete object oError no-error.
      isValidID = false.
    end catch.
    
  end method.

  method public void deleteSession(sessionID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Delete any context data related to given SessionID from local
             data structures and persistent storage.
      Parameters:  INPUT  CHARACTER	- The SessionID for which to delete context data.
      Notes:
    ------------------------------------------------------------------------------*/

    /*
    **	Remove context data from the local data structures.
    */

    clearSession(sessionID ).

    /*
    **	Remove context data from the persistent context data storage for
    **	given SessionID.
    */
    
    contextPersistence:DeleteSessionContext(sessionId).
    
  end method.

  method private void createContextCopy(sourceBufferHandle as handle, targetBufferHandle as handle):
    /*------------------------------------------------------------------------------
      Purpose:     Create a context record copy from source to destination
      Parameters:  INPUT  HANLDE	- Handle to source buffer
            INPUT  HANLDE	- Handle to destination buffer
      Notes:
    ------------------------------------------------------------------------------*/

    define variable isFound as logical no-undo.

    do transaction:

      isFound = targetBufferHandle:find-first("where sctx-id = '":U + sourceBufferHandle::sctx-id + "'", exclusive-lock) no-error.
      if ( not isFound ) then
        targetBufferHandle:buffer-create().

      targetBufferHandle:buffer-copy( sourceBufferHandle ).
    end.
  end method.

  method public void clearSession(input sessionID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Clear all context data from the local session context data
             structure that is related to a SessionID.
      Parameters:  INPUT  CHARACTER - The SessionID for which to clear the context.
      Notes:	   If the unknown (?) value is given, all context values related to
             any SessionID will be removed. This is not the same as removing
             all context values. If the ContextSessionID is se to unknown it
             can be scoped to something else so we need to leave it alone.
    ------------------------------------------------------------------------------*/

    if (sessionID = ?) then do:
      for each ttSessionContext where length(ttSessionContext.sctx-ch-sessie) > 1 exclusive-lock:
        delete ttSessionContext.
      end.
    end.
    else do:
      for each ttSessionContext where ttSessionContext.sctx-ch-sessie = sessionID exclusive-lock:
        delete ttSessionContext.
      end.
    end.
  end method.

  method public void getContextValue(contextName as character, contextGroupName as character, contextScope as integer,
                                     sessionID as character, contextUserID as character,     output contextValue as character):
    /*------------------------------------------------------------------------------
      Purpose:     Retrieve a context name/value pair from local data structure or,
                   if not found locally, from the persistent storage,
      Parameters:  INPUT  CHARACTER		- Name of the context value
            INPUT  CHARACTER		- Grouping name for the context value
            INPUT  INTEGER		- Scope of the context value
            INPUT  CHARACTER		- SessionID to relate context value to
            INPUT  CHARACTER		- UserID to relate context value to
            OUTPUT CHARACTER		- Place to store retrieved value
      Notes:       If the context value is not found locally but is found in the
                   persistent storage, it will be copied locally.
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.
    define variable isTTAvailable  as logical no-undo.
    define variable isDBAvailable  as logical no-undo.
    define variable isPersistent   as logical no-undo.

    /*
    **	Parameter check
    */

    if (contextName = ? or contextName = "") then do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    /*
    **	Default output value.
    **/

    contextValue = ?.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if (sessionID <> ?) then do:
      validateSessionID( input sessionID, output isValidID ).
      if (not isValidID) then return.
    end.

    /*
    **	This is the order of things:
    **
    **	If applicable then
    **      synchronize local store with persistent one.
    **  else
    **	    if available locally then
    **		    check expiration date
    **		    if valid date then
    **			    return value
    **		    else
    **			    delete context data
    */

    /*
    **	We set the CMNoError to start with. If we cannot find any value,
    **	the unknown return value together with the CMNoError code will
    **	indicate that the value does not exist. If any other code is set
    **	together with the unknown return value, it will indicate the problem
    **	at hand.
    */
    setLastError( {&CMNoError} ).

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */
    assign 
      dbBufferHandle = /*buffer cura.sctx:handle*/ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle
      isTTAvailable  = false
      isDBAvailable  = false
      isPersistent   = (IsBitSet(contextScope, {&ScopeBitGlobal}) or
                          IsBitSet(contextScope, {&ScopeBitApplication}) or
                          IsBitSet(contextScope, {&ScopeBitClientConnection}) or
                          IsBitSet(contextScope, {&ScopeBitUser})).

    createQuery(ttBufferHandle,
      contextName,
      contextGroupName,
      contextScope,
      sessionID,
      contextUserID,
      output ttQueryHandle).
      
    isTTAvailable = (ttQueryHandle:num-results > 0).

    if (isPersistent) then do:
      
      createQuery(dbBufferHandle,
        contextName,
        contextGroupName,
        contextScope,
        sessionID,
        contextUserID,
        output dbQueryHandle).
       
      isDBAvailable = (dbQueryHandle:num-results > 0).

      if (isDBAvailable) then do:
        
        if (dbBufferHandle::sctx-dz-eint < now) then do:
          setLastError({&CMDataExpired}).
          deleteBuffer(dbBufferHandle).
           
          isDBAvailable = false.
                
          if (isTTAvailable) then do:
            
            setLastError({&CMDataExpired}).
            deleteBuffer(ttBufferHandle).
            assign 
              isTTAvailable = false.
          end. /* (isTTAvailable) */
        end. /* expired */
        else do:
          contextValue = dbBufferHandle::sctx-ch-wrde.
          createContextCopy(dbBufferHandle, ttBufferHandle).
          ttBufferHandle:buffer-release().
        end. /* not expired */
      end. /* (isDBAvailable) */
    end. /* (isPersistent) */
    else if (isTTAvailable) then do:
        if (ttBufferHandle::sctx-dz-eint < now) then do:
          setLastError({&CMDataExpired}).
          deleteBuffer(ttBufferHandle).
          isTTAvailable = false.
        end. /* expired */
        else
          contextValue = ttBufferHandle::sctx-ch-wrde.
          
      end. /* (isTTAvailable) */

    /*
    **	Close the queries and delete the query objects.
    */
    deleteQuery(ttQueryHandle).
    deleteQuery(dbQueryHandle).
    
  end method.

  method private void deleteQuery(input  phQuery as handle):
    /*------------------------------------------------------------------------------
      Purpose:     Delete an existing query.
      Parameters:  INPUT  HANDLE	- Handle to the Query Object
      Notes:
    ------------------------------------------------------------------------------*/

    /*
    **	See if the handle given is a valid one. If it is, see whether the query
    **	is still open. If so close the query and finally delete the object.
    */

    if not can-query( phQuery, "QUERY-CLOSE":U ) then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    if valid-handle( phQuery ) then
    do:
      if ( phQuery:is-open ) then
        phQuery:query-close().
      delete object phQuery.
    end.
  end method.

  method private void createQuery(input  bufferHandle as handle,
    input  contextName as character,
    input  contextGroupName as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character,
    output queryHandle as handle):
    /*------------------------------------------------------------------------------
      Purpose:     Create a query on the context data store (local or persistent)
                   using provided parameters.
      Parameters:  INPUT  HANDLE		- Buffer to run query on
                   INPUT  CHARACTER		- Name of the context value
                   INPUT  CHARACTER		- Grouping name for the context value
                   INPUT  INTEGER		- Scope of the context value
                   INPUT  CHARACTER		- SessionID to relate context value to
                   INPUT  CHARACTER		- UserID to relate context value to
                   OUTPUT HANDLE		- Handle to created Query object
      Notes:       The query is created and opened. After that the handle of the
                   query will be returned to the caller.
    ------------------------------------------------------------------------------*/

    define variable queryString as character no-undo.
    define variable whereString as character no-undo.

    /*
    **	Parameter validation.
    */

    if ( bufferHandle:type ne "BUFFER" ) then
    do:
      queryHandle = ?.
      setLastError( {&CMInvalidParameter} ).
      return.
    end.

    /*
    **	Create the query to use for this operation. Depending on given Scope
    **	some parameters may come into play.
    */

    create query queryHandle.

    if not valid-handle( queryHandle ) then
    do:
      queryHandle = ?.
      setLastError( {&CMCreateQueryFailed} ).
      return.
    end.

    queryString = substitute( "for each &1":U, bufferHandle:name ).

    /*
    **	Check the scope bits and create the where string with the appropriate
    **	parameter values.
    */

    if (IsBitSet( contextScope, {&ScopeBitGlobal} )) then
    do:
      if (( contextName = "" ) or ( contextName = ? )) then
        whereString = substitute( "where sctx-ch-groep begins '&1'":U,
          contextGroupName ).
      else
        whereString = substitute( "where sctx-nm = '&1' AND sctx-ch-groep begins '&2'":U,
          contextName,
          contextGroupName ).
    end.
    else if ( IsBitSet( contextScope, {&ScopeBitApplication} )) then
      do:
        if (( contextName = "" ) or ( contextName = ? )) then
          whereString = substitute( "where sctx-ch-sessie = '&1' AND sctx-ch-groep begins '&2'":U,
            sessionID,
            contextGroupName ).
        else
          whereString = substitute( "where sctx-nm = '&1' AND sctx-ch-sessie = '&2' AND sctx-ch-groep begins '&3'":U,
            contextName,
            sessionID,
            contextGroupName ).
      end.
      else if ( IsBitSet( contextScope, {&ScopeBitClientConnection} )) then
        do:
          if (( contextName = "" ) or ( contextName = ? )) then
            whereString = substitute( "where sctx-ch-conn = '&1' AND sctx-ch-groep begins '&2'":U,
              session:server-connection-id,
              contextGroupName ).
          else
            whereString = substitute( "where sctx-nm = '&1' AND sctx-ch-conn = '&2' AND sctx-ch-groep begins '&3'":U,
              contextName,
              session:server-connection-id,
              contextGroupName ).
        end.
        else if ( IsBitSet( contextScope, {&ScopeBitServerSession} )) then
          do:
            if (( contextName = "" ) or ( contextName = ? )) then
              whereString = substitute( "where sctx-ch-groep begins '&1'":U,
                contextGroupName ).
            else
              whereString = substitute( "where sctx-nm = '&1' AND sctx-ch-groep begins '&2'":U,
                contextName,
                contextGroupName ).
          end.
          else if ( IsBitSet( contextScope, {&ScopeBitUser} )) then
            do:
              if (( contextName = "" ) or ( contextName = ? )) then
                whereString = substitute( "where sctx-cd-gebr = '&1' AND sctx-ch-groep begins '&2'":U,
                  contextUserID,
                  contextGroupName ).
              else
                whereString = substitute( "where sctx-nm = '&1' AND sctx-cd-gebr = '&2' AND sctx-ch-groep begins '&3'",
                  contextName,
                  contextUserID,
                  contextGroupName ).
            end.

    /*
    **	Add buffers to the query, prepare the query and open it.
    */

    queryHandle:set-buffers( bufferHandle ).
    queryHandle:query-prepare( queryString + " " + whereString ).
    queryHandle:query-open().
    queryHandle:get-first().
  end method.

  method private void deleteBuffer(input  bufferHandle as handle):
    /*------------------------------------------------------------------------------
      Purpose:     Delete given buffer
      Parameters:  INPUT  HANDLE	- Handle to the buffer to delete.
      Notes:
    ------------------------------------------------------------------------------*/

    /*
    **	Parameter check.
    */

    if not can-query( bufferHandle, "BUFFER-DELETE":U ) then
      return.

    /*
    **	We got a buffer, so start a transaction and delete the buffer.
    */

    do transaction:
      bufferHandle:find-current( exclusive-lock ).
      bufferHandle:buffer-delete().
    end.
  end method.

  method public void setContextValue(input  contextName as character,
    input  contextGroupName as character,
    input  contextValue as character,
    input  timeToLive as datetime-tz,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Store a given context value (in character format) into the local
                   context data structure.
      Parameters:  INPUT  CHARACTER		- Name of the context value
               INPUT  CHARACTER		- Grouping name for the context value
               INPUT  CHARACTER		- Value in character format of the context value
               INPUT  DATETIME-TZ	- Expiry date of the context value
               INPUT  INTEGER		- Scope of the context value
               INPUT  CHARACTER		- SessionID to relate context value to
               INPUT  CHARACTER		- UserID to relate context value to
      Notes:       Depending on the Scope parameter, the context value might also be
                   written to the persistent storage (maybe with some added information)
                   or be prepared to be sent back to the client session.
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.
    define variable isTTAvailable  as logical no-undo.
    define variable isDBAvailable  as logical no-undo.
    define variable isPersistent   as logical no-undo.

    /*
    **	Parameter check
    */

    if ( contextName = ? ) or
      ( contextName = "" ) or
      ( contextValue = ? ) or
      ( contextValue = "" ) then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */

    assign 
      dbBufferHandle = /*buffer cura.sctx:handle*/ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    /*
    **	This is the order of things:
    **
    **	Check local store for data
    **	If available locally then
    **		modify local and optionally persistent
    **	If not available locally and available persistent then
    **		modify persistent and copy locally
    **	If not available locally and not available persistent then
    **		create new local and optionally persist
    */

    assign 
      isTTAvailable = false
      isDBAvailable = false.

    createQuery( input  ttBufferHandle,
      input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    assign 
      isTTAvailable = ( ttQueryHandle:num-results > 0 )
      isPersistent  = ( IsBitSet( contextScope, {&ScopeBitGlobal} ) or
                          IsBitSet( contextScope, {&ScopeBitApplication} ) or
                          IsBitSet( contextScope, {&ScopeBitClientConnection} ) or
                          IsBitSet( contextScope, {&ScopeBitUser} )).

    if ( not isTTAvailable ) then
    do:
      createQuery( input  dbBufferHandle,
        input  contextName,
        input  contextGroupName,
        input  contextScope,
        input  sessionID,
        input  contextUserID,
        output dbQueryHandle ).

      assign 
        isDBAvailable = ( dbQueryHandle:num-results > 0 ).

      if ( isDBAvailable ) then
      do:
        createContextRecord( input  dbBufferHandle,
          input  contextName,
          input  contextGroupName,
          input  contextValue,
          input  0,
          input  timeToLive,
          input  contextScope,
          input  sessionID,
          input  contextUserID,
          input  no ).

        createContextCopy( dbBufferHandle, ttBufferHandle ).
      end.
    end.

    /*
    **	If the data is not available in the database (whether we actually
    **	physically checked or not is irrelevant) we either have to modify
    **	the local version or create a new local version. After that we check
    **	whether we need to create a copy in the persistent store or not.
    */

    if ( not isDBAvailable ) then
    do:
      createContextRecord( input  ttBufferHandle,
        input  contextName,
        input  contextGroupName,
        input  contextValue,
        input  0,
        input  timeToLive,
        input  contextScope,
        input  sessionID,
        input  contextUserID,
        input  not isTTAvailable ).

      if ( isPersistent ) then
      do:
        createContextCopy( ttBufferHandle, dbBufferHandle ).
      end.
    end.

    /*
    **	Release buffers.
    */
    ttBufferHandle:buffer-release().
    dbBufferHandle:buffer-release().

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).
  end method.

  method private void createContextRecord(input  bufferHandle as handle,
    input  contextName as character,
    input  contextGroupName as character,
    input  contextValue as character,
    input  ipin_ObjectSize as int64,
    input  timeToLive as datetime-tz,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character,
    input  iplg_CreateNew as logical):
    /*------------------------------------------------------------------------------
      Purpose:     Create a new Context record in given buffer and set the
             ContextID primary key field.
      Parameters:  INPUT  HANDLE		- Handle to the buffer to create a record in
         INPUT  CHARACTER		- Name of the context value
         INPUT  CHARACTER		- Grouping name for the context value
         INPUT  CHARACTER		- Value in character format of the context value
         INPUT  INT64  		- Size of the context object in bytes
         INPUT  DATETIME-TZ	- Expiry date of the context value
         INPUT  INTEGER		- Scope of the context value
         INPUT  CHARACTER		- SessionID to relate context value to
         INPUT  CHARACTER		- UserID to relate context value to
         INPUT  LOGICAL		- Flag indicating to create new record
      Notes:
    ------------------------------------------------------------------------------*/

    define variable mch_ContextID as character no-undo.

    /*
    **	Parameter check.
    */

    if ((( contextValue = ? ) or ( contextValue = "" )) and ( ipin_ObjectSize = 0 )) then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.


    /*
    **	NOTE:
    ** 	bufferHandle::sctx-id = mch_ContextID is similar to:
    ** 	bufferHandle:BUFFER-FIELD("sctx-id"):BUFFER-VALUE = mch_ContextID
    */

    /*
    **	Create a new record if iplg_CreateNew was set to TRUE and set the ContextID
    **	to a 'FlatGUID'. If we do not need to create a new record, we will be
    **	updating an existing one, so go get the first in the query.
    */

    do transaction:

      if ( iplg_CreateNew ) then
      do:
        createFlatGUID( output mch_ContextID ).
        if ( mch_ContextID ne ? ) then
        do:
          bufferHandle:buffer-create().
          bufferHandle::sctx-id = mch_ContextID.
        end.
      end.
      else
        bufferHandle:find-current( exclusive-lock ).

      /*
    **	Assign the rest of the fields except for the context value/object.
    */

      assign  
        bufferHandle::sctx-nm        = contextName
        bufferHandle::sctx-nr-bytes  = ipin_ObjectSize
        bufferHandle::sctx-nr-bereik = contextScope
        bufferHandle::sctx-dz-eint   = timeToLive
        bufferHandle::sctx-ch-sessie = sessionID
        bufferHandle::sctx-ch-groep  = contextGroupName
        bufferHandle::sctx-cd-gebr   = contextUserID.

      /*
  **	Do we have to store a context value or a context object?
  */

      if ( ipin_ObjectSize = 0 ) then
      do:
        bufferHandle::sctx-ch-wrde = contextValue.
      end.
      else
      do:
        bufferHandle::sctx-ch-wrde = "".
        copy-lob from object XMLDocument to bufferHandle::sctx-blob.
      end.
    end.
  end method.

  method public void deleteContextValue(input  contextName as character,
    input  contextGroupName as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Remove a specified context value from the local context data
             structures and the persistent context data structure.
      Parameters:  INPUT  CHARACTER		- Name of the context value
             INPUT  CHARACTER		- Grouping name for the context value
             INPUT  INTEGER		- Scope of the context value
             INPUT  CHARACTER		- SessionID to relate context value to
             INPUT  CHARACTER		- UserID to relate context value to
      Notes:
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.

    /*
    **	Parameter check
    */

    if ( contextName = ? ) or
      ( contextName = "" ) then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	This is the order of things:
    **
    **	Check local store for data
    **	If available then
    **		delete context data
    **
    **	Check persistent store for data
    **	If available then
    **		delete context data
    */

    assign 
      dbBufferHandle = /* buffer cura.sctx:handle */ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    createQuery( input  ttBufferHandle,
      input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    createQuery( input  dbBufferHandle,
      input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output dbQueryHandle ).

    if ( ttQueryHandle:num-results > 0 ) then
      deleteBuffer( ttBufferHandle ).

    if ( dbQueryHandle:num-results > 0 ) then
      deleteBuffer( dbBufferHandle ).

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).
  end method.

  method public void getContextObject(input  contextName as character,
    input  contextGroupName as character,
    input  contextObjectHandle as handle,
    input  ipch_RestoreMode as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Retrieve a context object from local data structure or,
             if not found locally, from the persistent storage,
      Parameters:  INPUT  CHARACTER		- Name of the context value
             INPUT  CHARACTER		- Grouping name for the context value
             INPUT  HANDLE		- Reference to existing object to restore into
             INPUT  CHARACTER		- Retore MODE of the object into existing
             INPUT  INTEGER		- Scope of the context object
             INPUT  CHARACTER		- SessionID to relate context value to
             INPUT  CHARACTER		- UserID to relate context value to
      Notes:       If the context object is not found locally but is found in the
             persistent storage, it will be copied locally.
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.
    define variable isTTAvailable  as logical no-undo.
    define variable isDBAvailable  as logical no-undo.
    define variable isSuccess      as logical no-undo.

    /*
    **	Parameter check
    */

    if ( contextName = ? ) or
      ( contextName = "" ) or
      ( contextObjectHandle = ? )then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	This is the order of things:
    **
    **	Check local store for data
    **
    **	If available locally then
    **		check expiration date
    **		if valid date then
    **			return value
    **		else
    **			delete context data
    **
    **	If not available locally but available persistent then
    **		check expiration date
    **		if valid date then
    **			make local copy
    **			return value
    **		else
    **			delete context data
    **			return unknown value
    */

    /*
    **	We set the CMNoError to start with. If we cannot find any value,
    **	the unknown return value together with the CMNoError code will
    **	indicate that the value does not exist. If any other code is set
    **	together with the unknown return value, it will indicate the problem
    **	at hand.
    */

    setLastError( {&CMNoError} ).

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */

    assign 
      dbBufferHandle = /* buffer cura.sctx:handle */ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    assign 
      isTTAvailable = false
      isDBAvailable = false.

    createQuery( input  ttBufferHandle,
      input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    assign 
      isTTAvailable = ( ttQueryHandle:num-results > 0 ).

    if ( isTTAvailable ) then
    do:
      if ( ttBufferHandle::sctx-dz-eint < now ) then
      do:
        setLastError( {&CMDataExpired} ).
        deleteBuffer( input ttBufferHandle ).
        isTTAvailable = false.
      end.
      else
      do:
        restoreObject( input  contextObjectHandle,
          input  ttBufferHandle,
          input  ipch_RestoreMode,
          output isSuccess ).
      end.
    end.

    if ( not isTTAvailable ) then
    do:
      createQuery( input  dbBufferHandle,
        input  contextName,
        input  contextGroupName,
        input  contextScope,
        input  sessionID,
        input  contextUserID,
        output dbQueryHandle ).

      assign 
        isDBAvailable = ( dbQueryHandle:num-results > 0 ).

      if ( isDBAvailable ) then
      do:
        if ( dbBufferHandle::sctx-dz-eint < now ) then
        do:
          setLastError( {&CMDataExpired} ).
          deleteBuffer( input dbBufferHandle ).
        end.
        else
        do:
          createContextCopy( input dbBufferHandle, input ttBufferHandle ).
          restoreObject( input  contextObjectHandle,
            input  ttBufferHandle,
            input  ipch_RestoreMode,
            output isSuccess ).
        end.
      end.
    end.

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).
  end method.

  method private void restoreObject(input  iphn_Object as handle,
    input  bufferHandle as handle,
    input  ipch_RestoreMode as character,
    output isSuccess as logical):
    /*------------------------------------------------------------------------------
      Purpose:     Restore serialized (into XML) object into handle
      Parameters:  INPUT  HANDLE	- Handle of existing object to restore into
             INPUT  HANDLE	- Handle of buffer holding object
             INPUT  CHARACTER	- Restore Mode (as in READ-XML())
             OUTPUT LOGICAL	- Flag indicating success
      Notes:
    ------------------------------------------------------------------------------*/

    /*
    **	Parameter check
    */

    if ( not valid-handle( iphn_Object )) or
      ( not valid-handle( bufferHandle )) then
    do:
      setLastError( {&CMParameterError} ).
      isSuccess = false.
      return.
    end.

    /* Move BLOB data into global MEMPTR variable for conversion */
    SET-SIZE( XMLDocument ) = 0.
    SET-SIZE( XMLDocument ) = bufferHandle::sctx-nr-bytes.
    copy-lob from object bufferHandle::ContextObject to object XMLDocument.

    convertXMLToObject( input  iphn_Object,
      input  ipch_RestoreMode,
      output isSuccess ).

    /* Release allocated memory */
    SET-SIZE( XMLDocument ) = 0.
  end method.

  method private void convertObjectToXML(input  iphn_Object as handle,
    output isSuccess as logical):
    /*------------------------------------------------------------------------------
      Purpose:     Convert a given object to XML document
      Parameters:  INPUT  HANDLE	- Reference to the object to convert
             OUTPUT LOGICAL	- Indicates whether the WRITE-XML worked
      Notes:       The XML Document will be created in the global MEMPTR variable
             that is scoped to the ContextManager to avoid copying between
             procedures.
    ------------------------------------------------------------------------------*/

    case iphn_Object:type :

      when "BUFFER" or
      when "TEMP-TABLE" or
      when "DATASET" then
        do:
          if can-query( iphn_Object, "WRITE-XML" ) then
          do:
            isSuccess = iphn_Object:write-xml( "MEMPTR",
              XMLDocument,
              yes,  /* formatted          */
              ?,    /* encoding           */
              ?,    /* schema-location    */
              true, /* write-xmlschema    */
              no,   /* min-xmlschema      */
              true  /* write-before-image */ ).
          end.
        end.
    end case.

  /*    COPY-LOB FROM XMLDocument TO FILE "D:\Temp\MemPtr.txt".*/
  end method.

  method private void convertXMLToObject(input  iphn_Object as handle,
    input  ipch_ReadMode as character,
    output isSuccess as logical):
    /*------------------------------------------------------------------------------
      Purpose:     Convert a MEMPTR value containing an XML Document back into
             a usable object such as a buffer, temp-table or dataset.
      Parameters:  INPUT  HANDLE	- Reference to existing object to restore into
             INPUT  CHARACTER	- Restore mode for the object
      Notes:
    ------------------------------------------------------------------------------*/

    case iphn_Object:type :

      when "BUFFER" or
      when "TEMP-TABLE" or
      when "DATASET" then
        do:
          if can-query( iphn_Object, "READ-XML":U ) and
            lookup( ipch_ReadMode, "APPEND,EMPTY,MERGE,REPLACE" ) > 0 then
          do:
            isSuccess = iphn_Object:read-xml( "MEMPTR":U,
              XMLDocument,
              ipch_ReadMode,
              ?,    /* schema-location          */
              no    /* override-default-mapping */ ).
          end.
        end.

    end case.
  end method.

  method public void setContextObject(input  contextName as character,
    input  contextGroupName as character,
    input  contextObjectHandle as handle,
    input  timeToLive as datetime-tz,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Store a given context object (buffer, temp-table or dataset) into
             the local context data structure.
      Parameters:  INPUT  CHARACTER		- Name of the context value
             INPUT  CHARACTER		- Grouping name for the context value
             INPUT  HANDLE		- Reference to the context object
             INPUT  DATETIME-TZ	- Expiry date of the context value
             INPUT  INTEGER		- Scope of the context value
             INPUT  CHARACTER		- SessionID to relate context value to
             INPUT  CHARACTER		- UserID to relate context value to
      Notes:       Depending on the Scope parameter, the context object might also be
             written to the persistent storage (maybe with some added information)
             or be prepared to be sent back to the client session.
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.
    define variable isTTAvailable  as logical no-undo.
    define variable isDBAvailable  as logical no-undo.
    define variable isPersistent   as logical no-undo.
    define variable isSuccess      as logical no-undo.

    /*
    **	Parameter check
    */

    if ( contextName = ? ) or
      ( contextName = "" ) or
      ( contextObjectHandle = ? ) then
    do:
      setLastError( {&CMParameterError} ).
      return.
    end.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	Convert the given object to an XML Document first.
    */

    convertObjectToXML( input contextObjectHandle, output isSuccess ).
    
    if ( not isSuccess ) then
    do:
      setLastError( {&CMConvertToXMLError} ).
      return.
    end.

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */

    assign 
      dbBufferHandle = /* buffer cura.sctx:handle */ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    /*
    **	This is the order of things:
    **
    **	Check local store for data
    **	If available locally then
    **		modify local and optionally persist
    **	If not available locally and available persistent then
    **		modify persistent and copy locally
    **	If not available locally and not available persistent then
    **		create new local and optionally persist
    */

    assign 
      isTTAvailable = false
      isDBAvailable = false.

    createQuery( input  ttBufferHandle,
      input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    assign 
      isTTAvailable = ( ttQueryHandle:num-results > 0 )
      isPersistent  = ( IsBitSet( contextScope, {&ScopeBitGlobal} ) or
                            IsBitSet( contextScope, {&ScopeBitApplication} ) or
                            IsBitSet( contextScope, {&ScopeBitClientConnection} ) or
                            IsBitSet( contextScope, {&ScopeBitUser} )).

    if ( not isTTAvailable ) then
    do:
      createQuery( input  dbBufferHandle,
        input  contextName,
        input  contextGroupName,
        input  contextScope,
        input  sessionID,
        input  contextUserID,
        output dbQueryHandle ).

      assign 
        isDBAvailable = ( dbQueryHandle:num-results > 0 ).

      if ( isDBAvailable ) then
      do:
        createContextRecord( input  dbBufferHandle,
          input  contextName,
          input  contextGroupName,
          input  "",
          input  get-size( XMLDocument ),
          input  timeToLive,
          input  contextScope,
          input  sessionID,
          input  contextUserID,
          input  no ).
        createContextCopy( dbBufferHandle, ttBufferHandle ).
      end.
    end.

    /*
    **	If the data is not available in the database (whether we actually
    **	physically checked or not is irrelevant) we either have to modify
    **	the local version or create a new local version. After that we check
    **	whether we need to create a copy in the persistent store or not.
    */

    if ( not isDBAvailable ) then
    do:
      createContextRecord( input  ttBufferHandle,
        input  contextName,
        input  contextGroupName,
        input  "",
        input  get-size( XMLDocument ),
        input  timeToLive,
        input  contextScope,
        input  sessionID,
        input  contextUserID,
        input  not isTTAvailable ).

      if ( isPersistent ) then
      do:
        createContextCopy( ttBufferHandle, dbBufferHandle ).
      end.
    end.

    /*
    **	Release buffers.
    */
    ttBufferHandle:buffer-release().
    dbBufferHandle:buffer-release().

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).

    /*
    **	Release allocated memory used with XML conversion.
    */

    SET-SIZE( XMLDocument ) = 0.
  end method.

  method public void deleteContextObject(input  contextName as character,
    input  contextGroupName as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Remove a specified context object from the local context data
             structures and the persistent context data structure.
      Parameters:  INPUT  CHARACTER		- Name of the context object
             INPUT  CHARACTER		- Grouping name for the context object
             INPUT  INTEGER		- Scope of the context object
             INPUT  CHARACTER		- SessionID to relate context object to
             INPUT  CHARACTER		- UserID to relate context object to
      Notes:
    ------------------------------------------------------------------------------*/

    /*
    **	This is exactly the same as for a name/value pair context data record.
    */

    deleteContextValue( input  contextName,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID ).
  end method.

  method public void getContextBlock(input TABLE for ttContextBlock,
    input  contextGroupName as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Retrieve a context block of name/value pairs from local data
             structure or, if not found locally, from the persistent storage,
      Parameters:  INPUT  TABLE FOR		- TEMP-TABLE Reference for context values
             INPUT  CHARACTER		- Grouping name for the context value
             INPUT  INTEGER		- Scope of the context value
             INPUT  CHARACTER		- SessionID to relate context value to
             INPUT  CHARACTER		- UserID to relate context value to
      Notes:       If the context value is not found locally but is found in the
             persistent storage, it will be copied locally.
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.
    define variable isTTAvailable  as logical no-undo.
    define variable isDBAvailable  as logical no-undo.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	We set the CMNoError to start with. If we cannot find any value,
    **	the unknown return value together with the CMNoError code will
    **	indicate that the value does not exist. If any other code is set
    **	together with the unknown return value, it will indicate the problem
    **	at hand.
    */

    setLastError( {&CMNoError} ).

    /*
    **	This is the order of things:
    **
    **	Synchronize local store with persistent one.
    **
    **	for each local context data
    **		check expiration date
    **		if valid date then
    **			add to block
    **		else
    **			delete context data
    */

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */

    assign 
      dbBufferHandle = /* buffer cura.sctx:handle */ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    assign 
      isTTAvailable = false
      isDBAvailable = false.

    /*
    **	First of all, we will synchronize the local context data structure with the
    **	persistent one. At the end we can iterate through the local context data and
    **	create our context block without worrying about the persistent store.
    */

    createQuery( input  dbBufferHandle,
      input  ?,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output dbQueryHandle ).

    do while not dbQueryHandle:query-off-end:
      if ( dbBufferHandle::sctx-dz-eint < now ) then
        deleteBuffer( dbBufferHandle ).
      else
      do:
        /*
        **	Is this a context object or a name/value.
        */
        if ( dbBufferHandle::sctx-nr-bytes = 0 ) then
        do:
          /*
          **	Do we have this available locally as well?
          */
          assign 
            isTTAvailable = ttBufferHandle:find-first(substitute("where sctx-id = &1", quoter(dbBufferHandle::sctx-id))) NO-ERROR.
          if ( not isTTAvailable ) then
          do:
            createContextCopy( input dbBufferHandle, input ttBufferHandle ).
          end.
        end.
      end.
      dbQueryHandle:get-next().
    end.

    /*
    **	We now go through the local context data store and gather up all values
    **	for inclusion in the context block.
    */

    createQuery( input  ttBufferHandle,
      input  ?,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    /*
    **	Round up all values from the local SessionContext and prepare to send
    **	them back in the Block TEMP-TABLE.
    */

    do while not ttQueryHandle:query-off-end:
      if ( ttBufferHandle::sctx-dz-eint < now ) then
        deleteBuffer( ttBufferHandle ).
      else
      do:
        if ( ttBufferHandle::sctx-nr-bytes = 0 ) then
        do:
          create ttContextBlock.
          assign 
            ttContextBlock.ContextName  = ttBufferHandle::sctx-nm
            ttContextBlock.ContextValue = ttBufferHandle::sctx-ch-wrde
            .
        end.
      end.
      ttQueryHandle:get-next().
    end.

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).
  end method.

  method public void setContextBlock(input TABLE for ttContextBlock,
    input  contextGroupName as character,
    input  timeToLive as datetime-tz,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Store a given context block (i.e. a set of context values ) into
             the local context data structure.
      Parameters:  INPUT  TABLE FOR		- Reference to TEMP-TABLE containing context values
             INPUT  CHARACTER		- Grouping name for the context value
             INPUT  DATETIME-TZ	- Expiry date of the context value
             INPUT  INTEGER		- Scope of the context value
             INPUT  CHARACTER		- SessionID to relate context value to
             INPUT  CHARACTER		- UserID to relate context value to
      Notes:       Depending on the Scope parameter, the context values might also be
             written to the persistent storage (maybe with some added information)
             or be prepared to be sent back to the client session.
             The name/value pairs in the TEMP-TABLE will all get the same
             attributes that are provided as parameters to this call.
    ------------------------------------------------------------------------------*/

    /*
    **	Iterate through the context values and set them.
    */

    for each ttContextBlock:
      setContextValue( input  ttContextBlock.ContextName,
        input  contextGroupName,
        input  ttContextBlock.ContextValue,
        input  timeToLive,
        input  contextScope,
        input  sessionID,
        input  contextUserID ).
    end.
  end method.

  method public void deleteContextBlock(input  contextGroupName as character,
    input  contextScope as integer,
    input  sessionID as character,
    input  contextUserID as character):
    /*------------------------------------------------------------------------------
      Purpose:     Remove specified context values from the local context data
                   structures and the persistent context data structure.
      Parameters:  INPUT  CHARACTER		- Grouping name for the context value
                 INPUT  INTEGER		- Scope of the context value
                   INPUT  CHARACTER		- SessionID to relate context value to
                   INPUT  CHARACTER		- UserID to relate context value to
      Notes:
    ------------------------------------------------------------------------------*/

    define variable ttQueryHandle  as handle  no-undo.
    define variable ttBufferHandle as handle  no-undo.
    define variable dbQueryHandle  as handle  no-undo.
    define variable dbBufferHandle as handle  no-undo.
    define variable isValidID      as logical no-undo.

    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */

    if ( sessionID ne ? ) then
    do:
      validateSessionID( input sessionID, output isValidID ).
      if ( not isValidID ) then return.
    end.

    /*
    **	This is the order of things:
    **
    **	Check local store for data
    **	If available then
    **		delete context data
    **
    **	Check persistent store for data
    **	If available then
    **		delete context data
    */

    assign 
      dbBufferHandle = /* buffer cura.sctx:handle */ temp-table ttSessionContext:default-buffer-handle
      ttBufferHandle = temp-table ttSessionContext:default-buffer-handle.

    createQuery( input  ttBufferHandle,
      input  ?,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output ttQueryHandle ).

    createQuery( input  dbBufferHandle,
      input  ?,
      input  contextGroupName,
      input  contextScope,
      input  sessionID,
      input  contextUserID,
      output dbQueryHandle ).

    /*
    **	If we found it in the local store delete it there first.
    */

    do while not ttQueryHandle:query-off-end:
      if ( ttBufferHandle::sctx-nr-bytes = 0 ) then
        deleteBuffer( input ttBufferHandle ).
      ttQueryHandle:get-next().
    end.

    /*
    **	Next, we iterate through the database records.
    */

    do while not dbQueryHandle:query-off-end:
      if ( dbBufferHandle::sctx-nr-bytes = 0 ) then
        deleteBuffer( input dbBufferHandle ).
      dbQueryHandle:get-next().
    end.

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( ttQueryHandle ).
    deleteQuery( dbQueryHandle ).
  end method.

  method private logical IsBitSet(input integerValue as integer,
    input bitNumber   as integer ):
    /*------------------------------------------------------------------------------
      Purpose:  Check for a bit in value and return whether it is set or
        not (TRUE/FALSE)
      Notes:
    ------------------------------------------------------------------------------*/

    return ( get-bits( integerValue, bitNumber, 1 ) > 0 ).
  end method.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  destructor public contextmanager ( ):
	    
    empty temp-table ttContextBlock no-error.
    empty temp-table ttSessionContext no-error.
  end destructor.
end class.
