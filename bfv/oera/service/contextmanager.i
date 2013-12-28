 
 /*------------------------------------------------------------------------
    File        : contextmanager
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rvkanten
    Created     : Mon Jun 25 16:48:14 CEST 2007
    Notes       : 
  ----------------------------------------------------------------------*/

  {OERA/service/errorstatus.i}       
  {OERA/service/ttcontextblock.i &REFERENCE-ONLY=REFERENCE-ONLY}
  {OERA/service/ttsessioncontext.i}
  {OERA/service/contextscope.i}
  DEFINE PROTECTED VARIABLE gcLastActiveSessionID    AS CHARACTER  NO-UNDO.
  DEFINE PROTECTED VARIABLE gmpXMLDocument           AS MEMPTR     NO-UNDO.
  
  METHOD PUBLIC VOID initializeComponent():
    clearContext().
  END METHOD.

  METHOD PUBLIC VOID destroyComponent():
    /*
     **	Remove all data from the local session context cache.
     */
    clearContext().

    DELETE OBJECT THIS-OBJECT.
  END METHOD.
  
  METHOD PROTECTED VOID clearContext():
  /*------------------------------------------------------------------------------
    Purpose:     Clear all context related data structures.
    Parameters:  <none>
    Notes:       
  ----------------------------------------------------------------------------*/
  
    EMPTY TEMP-TABLE ttSessionContext.
  END METHOD.
     
  METHOD PUBLIC VOID createSession(OUTPUT pcSessionID AS CHARACTER):
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

    DEFINE VARIABLE cFlatGUID    AS CHARACTER  NO-UNDO.
    
    /*
    **	We would like to get a unique string like a GUID but without the extra
    **	'-' chars that are part of the standard GUID format. We call this a
    **	FlatGUID.
    */

    createFlatGUID( OUTPUT cFlatGUID ).

    /*
    **	If we got a valid 'flat' GUID we will create a default set of context values
    **	that are scoped to this new logical session.
    */

    IF ( LENGTH( cFlatGUID ) = 32 ) THEN
    DO:
        pcSessionID = cFlatGUID.        
        createDefaultSessionContext( INPUT cFlatGUID ).
    END.
    ELSE
    DO:
        setLastError ( INPUT {&CMFormatError} ).
        pcSessionID = ?.
    END.    
  END METHOD.
  
  METHOD PRIVATE VOID setLastError(INPUT piErrorStatus AS INTEGER):
  END METHOD.
  
  METHOD PRIVATE VOID createFlatGUID(OUTPUT pcFlatGUID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Create a new Globally Unique Identifier or GUID but remove
  			   the '-' chars from the generated string.
    Parameters:  OUTPUT CHARACTER	- The FlatGUID which is a 32 chars string
    Notes:       
  ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cGUID                 AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE iLoop                 AS INTEGER    NO-UNDO.
    
    /*
    **	Get a normal GUID first. This is a standard GUID formatted string.
    **	GUID Format: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    */
    
    createGUID( OUTPUT cGUID ).

    /*
    **	If the GUID generation fails, we need to return unknown (?) value and
    **	set the ErrorStatus indicating the problem.
    */

    IF ( cGUID = ? ) THEN
    DO:
        pcFlatGUID = ?.    
        setLastError( {&CMGUIDError} ).
    END.
    ELSE
    DO:
        IF ( LENGTH( cGUID ) = 36 ) AND ( NUM-ENTRIES( cGUID , '-' ) = 5 ) THEN
        DO:
            /*
		    **	Now, remove the '-' chars from the generated GUID (36 chars) to
		    **	return the 32 chars string. This saves some space and does not add
		    **	any value to the unique property.
		    */
            pcFlatGUID = "".
            DO iLoop = 1 TO 5:
                pcFlatGUID = pcFlatGUID + ENTRY( iLoop, cGUID, '-' ).
            END.
        END.
        ELSE
        DO:
            /*
	        **	The GUID generation did something but not return a valid string
	        **	of characters. Set errorstatus to CMFormatError and return.
	        */
            pcFlatGUID = ?.
            setLastError( {&CMFormatError} ).
        END.
    END.
  END METHOD.
  
  METHOD PRIVATE VOID createGUID(OUTPUT pcGUID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Create a new Globally Unique Identifier or GUID.
    Parameters:  OUTPUT CHARACTER	- The GUID which is a 36 chars string with the
  								  following format:  								  
  								  "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
    Notes:       
  ------------------------------------------------------------------------------*/

    pcGUID = GUID( GENERATE-UUID ).
  END METHOD.
  
  METHOD PRIVATE VOID createDefaultSessionContext(INPUT pcSessionID AS CHARACTER):
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
  END METHOD.
  
  METHOD PUBLIC VOID restoreSession(INPUT pcSessionID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Restore a logical session to its previous state.
    Parameters:  INPUT  CHARACTER	- The SessionID for which to restore the session.
    Notes:       If the given SessionID is the same as the previously restored
    			   session, then we just skip this.
  ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lSessionIDIsValid      AS LOGICAL    NO-UNDO.
&IF DEFINED(server-side) <> 0 &THEN
    DEFINE BUFFER bContext FOR context.
&ENDIF

    /*
    **	Validate the provided SessionID.
    */
    
    validateSessionID( INPUT pcSessionID, OUTPUT lSessionIDIsValid ).

    /*
    **	If the given SessionID is not a valid one, we should create some sort
    **	of error and let the app know. This should also be logged somewhere.
    */
    
    IF NOT lSessionIDIsValid THEN RETURN.
        
    /*
    **	Skip the restore if the previously used SessionID is the same as
    **	the one provided now.
    */
    
    IF ( pcSessionID EQ gcLastActiveSessionID ) THEN
        RETURN.
    ELSE
        gcLastActiveSessionID = pcSessionID.
    
    /*
    **	Clear context data structures to prepare for new logical session
    **	context data.
    */
    
    clearSession( INPUT ? ).

    /*
    **	Get SessionID related data into the local ttSessionContext structure.
    */
&IF DEFINED(server-side) <> 0 &THEN
    FOR EACH bContext
        WHERE bContext.ContextSessionID = pcSessionID :

        CREATE ttSessionContext.
        BUFFER-COPY bContext TO ttSessionContext.
        
    END.
 &ENDIF
  END METHOD.
  
  METHOD PRIVATE VOID validateSessionID(INPUT  pcSessionID AS CHARACTER,
                                        OUTPUT plValidID AS LOGICAL):
  /*------------------------------------------------------------------------------
    Purpose:     
    Parameters:  <none>
    Notes:        
  ------------------------------------------------------------------------------*/

    /*
     **	Validate given SessionID. Not sure what to validate at this stage so
     **	we will just return TRUE for plValidID.
     */
    
    plValidID = TRUE.
  END METHOD.
  
  METHOD PUBLIC VOID deleteSession(INPUT pcSessionID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Delete any context data related to given SessionID from local
  			   data structures and persistent storage.
    Parameters:  INPUT  CHARACTER	- The SessionID for which to delete context data.
    Notes:       
  ------------------------------------------------------------------------------*/

    /*
    **	Remove context data from the local data structures.
    */
    
    clearSession( INPUT pcSessionID ).

    /*
    **	Remove context data from the persistent context data storage for
    **	given SessionID.
    */
&IF DEFINED(server-side) <> 0 &THEN
    FOR EACH context
        WHERE context.ContextSessionID = pcSessionID:

        DELETE context.             
    END.
&ENDIF
  END METHOD.
  
  METHOD PRIVATE VOID createContextCopy(INPUT  phSource AS HANDLE,
                                        INPUT  phDestination AS HANDLE):
  /*------------------------------------------------------------------------------
    Purpose:     Create a context record copy from source to destination
    Parameters:  INPUT  HANLDE	- Handle to source buffer
  		    INPUT  HANLDE	- Handle to destination buffer
    Notes:       
  ------------------------------------------------------------------------------*/

    DEFINE VARIABLE lFound    AS LOGICAL    NO-UNDO.
    
    DO TRANSACTION:
    
        lFound = phDestination:FIND-FIRST( "WHERE ContextID = '" + phSource::ContextID + "'" ) NO-ERROR.
        IF ( NOT lFound ) THEN
            phDestination:BUFFER-CREATE().
        phDestination:BUFFER-COPY( phSource ).

    END.
  END METHOD.
  
  METHOD PUBLIC VOID clearSession(INPUT pcSessionID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Clear all context data from the local session context data
  			   structure that is related to a SessionID.
    Parameters:  INPUT  CHARACTER - The SessionID for which to clear the context.
    Notes:	   If the unknown (?) value is given, all context values related to
  			   any SessionID will be removed. This is not the same as removing
  			   all context values. If the ContextSessionID is se to unknown it
  			   can be scoped to something else so we need to leave it alone.
  ------------------------------------------------------------------------------*/

    IF ( pcSessionID EQ ? ) THEN
    DO:
        FOR EACH ttSessionContext
            WHERE LENGTH( ttSessionContext.ContextSessionID ) > 1:
            
            DELETE ttSessionContext.            
        END.
    END.
    ELSE
    DO:
        FOR EACH ttSessionContext
            WHERE ttSessionContext.ContextSessionID = pcSessionID:

            DELETE ttSessionContext.
        END.
    END.
  END METHOD.
  
  METHOD PUBLIC VOID getContextValue(INPUT  pcContextName AS CHARACTER,
                                     INPUT  pcContextGroup AS CHARACTER,
                                     INPUT  piContextScope AS INTEGER,
                                     INPUT  pcSessionID AS CHARACTER,
                                     INPUT  pcUserID AS CHARACTER,
                                     OUTPUT pcContextValue AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lTTAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lDBAvailable    AS LOGICAL    NO-UNDO.
    
    /*
    **	Parameter check
    */
    
    IF ( pcContextName = ? ) OR
       ( pcContextName = "" ) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
    
    /*
    **	Default output value.
    **/
    
    ASSIGN pcContextValue = ?.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

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
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
    ASSIGN lTTAvailable = FALSE
           lDBAvailable = FALSE.

    createQuery( INPUT  hTTBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).
        
    ASSIGN lTTAvailable = ( hTTQuery:NUM-RESULTS > 0 ).

    IF ( lTTAvailable ) THEN
    DO:
        IF ( hTTBuffer::ContextTTL < NOW ) THEN
        DO:
            setLastError( {&CMDataExpired} ).
            deleteBuffer( INPUT hTTBuffer ).
            lTTAvailable = FALSE.
        END.
        ELSE
        DO:
            pcContextValue = hTTBuffer::ContextValue.
        END.
    END.
    
&IF DEFINED(server-side) <> 0 &THEN
    IF ( NOT lTTAvailable ) THEN
    DO:
        createQuery( INPUT  hDBBuffer,
                     INPUT  pcContextName,
                     INPUT  pcContextGroup,
                     INPUT  piContextScope,
                     INPUT  pcSessionID,
                     INPUT  pcUserID,
                     OUTPUT hDBQuery ).
    
        ASSIGN lDBAvailable = ( hDBQuery:NUM-RESULTS > 0 ).

        IF ( lDBAvailable ) THEN
        DO:
            IF ( hDBBuffer::ContextTTL < NOW ) THEN
            DO:
                setLastError( {&CMDataExpired} ).
                deleteBuffer( INPUT hDBBuffer ).
            END.
            ELSE
            DO:
                createContextCopy( INPUT hDBBuffer, INPUT hTTBuffer ).
                pcContextValue = hDBBuffer::ContextValue.
            END.
        END.
    END.
&ENDIF
        
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
&IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
&ENDIF
  END METHOD.
  
  METHOD PRIVATE VOID deleteQuery(INPUT  phQuery AS HANDLE):
  /*------------------------------------------------------------------------------
    Purpose:     Delete an existing query.
    Parameters:  INPUT  HANDLE	- Handle to the Query Object
    Notes:       
  ------------------------------------------------------------------------------*/

    /*
    **	See if the handle given is a valid one. If it is, see whether the query
    **	is still open. If so close the query and finally delete the object.
    */

    IF NOT CAN-QUERY( phQuery, "QUERY-CLOSE" ) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.

    IF VALID-HANDLE( phQuery ) THEN
    DO:
        IF ( phQuery:IS-OPEN ) THEN
            phQuery:QUERY-CLOSE().
        DELETE OBJECT phQuery.
    END.
  END METHOD.
  
  METHOD PRIVATE VOID createQuery(INPUT  phBuffer AS HANDLE,
                                  INPUT  pcContextName AS CHARACTER,
                                  INPUT  pcContextGroup AS CHARACTER,
                                  INPUT  piContextScope AS INTEGER,
                                  INPUT  pcSessionID AS CHARACTER,
                                  INPUT  pcUserID AS CHARACTER,
                                  OUTPUT phQuery AS HANDLE):
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

    DEFINE VARIABLE cQueryString           AS CHARACTER  NO-UNDO.
    DEFINE VARIABLE cWhereString           AS CHARACTER  NO-UNDO.

    /*
    **	Parameter validation.
    */
    
    IF ( phBuffer:TYPE NE "BUFFER" ) THEN
    DO:
        phQuery = ?.
        setLastError( {&CMInvalidParameter} ).
        RETURN.
    END.
    
    /*
    **	Create the query to use for this operation. Depending on given Scope
    **	some parameters may come into play.
    */

    CREATE QUERY phQuery.
    
    IF NOT VALID-HANDLE( phQuery ) THEN
    DO:
        phQuery = ?.
        setLastError( {&CMCreateQueryFailed} ).
        RETURN.
    END. 
    
    cQueryString = SUBSTITUTE( "FOR EACH &1", phBuffer:NAME ).
    
    /*
    **	Check the scope bits and create the where string with the appropriate
    **	parameter values.
    */
    
    IF (isBitSet( piContextScope, {&ScopeBitGlobal} )) THEN
    DO:
        IF (( pcContextName = "" ) OR ( pcContextName = ? )) THEN
            cWhereString = SUBSTITUTE( "WHERE ContextGroup BEGINS '&1'",
                                       pcContextGroup ).
        ELSE
            cWhereString = SUBSTITUTE( "WHERE ContextName = '&1' AND ContextGroup BEGINS '&2'",
                                       pcContextName,
                                       pcContextGroup ).
    END.
    ELSE IF ( isBitSet( piContextScope, {&ScopeBitApplication} )) THEN
    DO:
        IF (( pcContextName = "" ) OR ( pcContextName = ? )) THEN
            cWhereString = SUBSTITUTE( "WHERE ContextSessionID = '&1' AND ContextGroup BEGINS '&2'",
                                       pcSessionID,
                                       pcContextGroup ).
        ELSE
            cWhereString = SUBSTITUTE( "WHERE ContextName = '&1' AND ContextSessionID = '&2' AND ContextGroup BEGINS '&3'",
                                       pcContextName,
                                       pcSessionID,
                                       pcContextGroup ).
    END.
    ELSE IF ( isBitSet( piContextScope, {&ScopeBitClientConnection} )) THEN
    DO:
        IF (( pcContextName = "" ) OR ( pcContextName = ? )) THEN
            cWhereString = SUBSTITUTE( "WHERE ContextConnectionID = '&1' AND ContextGroup BEGINS '&2'",
                                       SESSION:SERVER-CONNECTION-ID,
                                       pcContextGroup ).
        ELSE
            cWhereString = SUBSTITUTE( "WHERE ContextName = '&1' AND ContextConnectionID = '&2' AND ContextGroup BEGINS '&3'",
                                       pcContextName,
                                       SESSION:SERVER-CONNECTION-ID,
                                       pcContextGroup ).
    END.
    ELSE IF ( isBitSet( piContextScope, {&ScopeBitServerSession} )) THEN
    DO:
        IF (( pcContextName = "" ) OR ( pcContextName = ? )) THEN
            cWhereString = SUBSTITUTE( "WHERE ContextGroup BEGINS '&1'",
                                       pcContextGroup ).
        ELSE
            cWhereString = SUBSTITUTE( "WHERE ContextName = '&1' AND ContextGroup BEGINS '&2'",
                                       pcContextName,
                                       pcContextGroup ).
    END.
    ELSE IF ( isBitSet( piContextScope, {&ScopeBitUser} )) THEN
    DO:
        IF (( pcContextName = "" ) OR ( pcContextName = ? )) THEN
            cWhereString = SUBSTITUTE( "WHERE ContextUserID = '&1' AND ContextGroup BEGINS '&2'",
                                       pcUserID,
                                       pcContextGroup ).
        ELSE
            cWhereString = SUBSTITUTE( "WHERE ContextName = '&1' AND ContextUserID = '&2' AND ContextGroup BEGINS '&3'",
                                       pcContextName,
                                       pcUserID,
                                       pcContextGroup ).
    END.

    /*
    **	Add buffers to the query, prepare the query and open it.
    */
    
    phQuery:SET-BUFFERS( phBuffer ).
    phQuery:QUERY-PREPARE( cQueryString + " " + cWhereString ).
    phQuery:QUERY-OPEN().
    phQuery:GET-FIRST().
  END METHOD.
  
  METHOD PRIVATE VOID deleteBuffer(INPUT  phBuffer AS HANDLE):
  /*------------------------------------------------------------------------------
    Purpose:     Delete given buffer
    Parameters:  INPUT  HANDLE	- Handle to the buffer to delete.
    Notes:       
  ------------------------------------------------------------------------------*/

    /*
    **	Parameter check.
    */
    
    IF NOT CAN-QUERY( phBuffer, "BUFFER-DELETE" ) THEN
        RETURN.

    /*
    **	We got a buffer, so start a transaction and delete the buffer.
    */
            
    DO TRANSACTION:
        phBuffer:FIND-CURRENT( EXCLUSIVE-LOCK ).
        phBuffer:BUFFER-DELETE().
    END.
  END METHOD.
  
  METHOD PUBLIC VOID setContextValue(INPUT  pcContextName AS CHARACTER,
                                     INPUT  pcContextGroup AS CHARACTER,
                                     INPUT  pcContextValue AS CHARACTER,
                                     INPUT  pdtzContextTTL AS DATETIME-TZ, 
                                     INPUT  piContextScope AS INTEGER,
                                     INPUT  pcSessionID AS CHARACTER,
                                     INPUT  pcUserID AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lTTAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lDBAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lPersist        AS LOGICAL    NO-UNDO.
    
    /*
    **	Parameter check
    */
    
    IF ( pcContextName = ? ) OR
       ( pcContextName = "" ) OR
       ( pcContextValue = ? ) OR
       ( pcContextValue = "" ) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */
    
    ASSIGN hDBBuffer    = BUFFER context:HANDLE
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
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
    
    ASSIGN lTTAvailable = FALSE
           lDBAvailable = FALSE.

    createQuery( INPUT  hTTBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).
        
    ASSIGN lTTAvailable = ( hTTQuery:NUM-RESULTS > 0 )
           lPersist     = ( isBitSet( piContextScope, {&ScopeBitGlobal} ) OR
                            isBitSet( piContextScope, {&ScopeBitApplication} ) OR
                            isBitSet( piContextScope, {&ScopeBitClientConnection} ) OR
                            isBitSet( piContextScope, {&ScopeBitUser} )).

&IF DEFINED(server-side) <> 0 &THEN
    IF ( NOT lTTAvailable ) THEN
    DO:
        createQuery( INPUT  hDBBuffer,
                     INPUT  pcContextName,
                     INPUT  pcContextGroup,
                     INPUT  piContextScope,
                     INPUT  pcSessionID,
                     INPUT  pcUserID,
                     OUTPUT hDBQuery ).
    
        ASSIGN lDBAvailable = ( hDBQuery:NUM-RESULTS > 0 ).

        IF ( lDBAvailable ) THEN
        DO:
            createContextRecord( INPUT  hDBBuffer,
                                 INPUT  pcContextName,
                                 INPUT  pcContextGroup,
                                 INPUT  pcContextValue,
                                 INPUT  0,
                                 INPUT  pdtzContextTTL,
                                 INPUT  piContextScope,
                                 INPUT  pcSessionID,
                                 INPUT  pcUserID,
                                 INPUT  NO ).

            createContextCopy( hDBBuffer, hTTBuffer ).
        END.
    END.
&ENDIF

    /*
    **	If the data is not available in the database (whether we actually
    **	physically checked or not is irrelevant) we either have to modify
    **	the local version or create a new local version. After that we check
    **	whether we need to create a copy in the persistent store or not.
    */
    
    IF ( NOT lDBAvailable ) THEN
    DO:
        createContextRecord( INPUT  hTTBuffer,
                             INPUT  pcContextName,
                             INPUT  pcContextGroup,
                             INPUT  pcContextValue,
                             INPUT  0,
                             INPUT  pdtzContextTTL,
                             INPUT  piContextScope,
                             INPUT  pcSessionID,
                             INPUT  pcUserID,
                             INPUT  NOT lTTAvailable ).

&IF DEFINED(server-side) <> 0 &THEN
        IF ( lPersist ) THEN
        DO:
            createContextCopy( hTTBuffer, hDBBuffer ).
        END.
&ENDIF
    END.
    
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
&IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
&ENDIF                                     
  END METHOD.
  
  METHOD PRIVATE VOID createContextRecord(INPUT  phBuffer AS HANDLE,
                                          INPUT  pcContextName AS CHARACTER,
                                          INPUT  pcContextGroup AS CHARACTER,
                                          INPUT  pcContextValue AS CHARACTER,
                                          INPUT  piObjectSize AS INT64,
                                          INPUT  pdtzContextTTL AS DATETIME-TZ,
                                          INPUT  piContextScope AS INTEGER,
                                          INPUT  pcSessionID AS CHARACTER,
                                          INPUT  pcUserID AS CHARACTER,
                                          INPUT  plCreateNew AS LOGICAL):
  /*------------------------------------------------------------------------------
    Purpose:     Create a new Context record in given buffer and set the
  			   ContextID primary key field.
    Parameters:  INPUT  HANDLE		- Handle to the buffer to create a record in
		   INPUT  CHARACTER		- Name of the context value
		   INPUT  CHARACTER		- Grouping name for the context value
		   INPUT  CHARACTER		- Value in character format of the context value
		   INPUT  INTEGER		- Size of the context object in bytes
		   INPUT  DATETIME-TZ	- Expiry date of the context value
		   INPUT  INTEGER		- Scope of the context value
		   INPUT  CHARACTER		- SessionID to relate context value to
		   INPUT  CHARACTER		- UserID to relate context value to
		   INPUT  LOGICAL		- Flag indicating to create new record
    Notes:       
  ------------------------------------------------------------------------------*/

    DEFINE VARIABLE cContextID     AS CHARACTER  NO-UNDO.

    /*
    **	Parameter check.
    */
    
    IF ((( pcContextValue = ? ) OR ( pcContextValue = "" )) AND ( piObjectSize = 0 )) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
       
       
    /*
    **	NOTE:
    ** 	phBuffer::ContextID = cContextID is similar to:
    ** 	phBuffer:BUFFER-FIELD("ContextID"):BUFFER-VALUE = cContextID
    */

    /*
    **	Create a new record if plCreateNew was set to TRUE and set the ContextID
    **	to a 'FlatGUID'. If we do not need to create a new record, we will be
    **	updating an existing one, so go get the first in the query.
    */    
    
    DO TRANSACTION:

        IF ( plCreateNew ) THEN
        DO:
            createFlatGUID( OUTPUT cContextID ).
            IF ( cContextID NE ? ) THEN
            DO:
                phBuffer:BUFFER-CREATE().
                phBuffer::ContextID = cContextID.
            END.
        END.
        ELSE
            phBuffer:FIND-CURRENT( EXCLUSIVE-LOCK ).

        /*
	    **	Assign the rest of the fields except for the context value/object.
	    */
    
        ASSIGN  phBuffer::ContextName       = pcContextName
                phBuffer::ContextObjectSize = piObjectSize
                phBuffer::ContextScope      = piContextScope
                phBuffer::ContextTTL        = pdtzContextTTL
                phBuffer::ContextSessionID  = pcSessionID
                phBuffer::ContextGroup      = pcContextGroup
                phBuffer::ContextUserID     = pcUserID.

        /*
	  **	Do we have to store a context value or a context object?
	  */
        
        IF ( piObjectSize = 0 ) THEN
        DO:
            phBuffer::ContextValue = pcContextValue.
        END.
        ELSE
        DO:
            phBuffer::ContextValue = "".
            COPY-LOB FROM OBJECT gmpXMLDocument TO phBuffer::ContextObject.
        END.        
    END.
  END METHOD.
  
  METHOD PUBLIC VOID deleteContextValue(INPUT  pcContextName AS CHARACTER,
                                        INPUT  pcContextGroup AS CHARACTER,
                                        INPUT  piContextScope AS INTEGER,
                                        INPUT  pcSessionID AS CHARACTER,
                                        INPUT  pcUserID AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    
    /*
    **	Parameter check
    */
    
    IF ( pcContextName = ? ) OR
       ( pcContextName = "" ) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

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
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
    createQuery( INPUT  hTTBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).

    IF ( hTTQuery:NUM-RESULTS > 0 ) THEN
        deleteBuffer( hTTBuffer ).
                 
&IF DEFINED(server-side) <> 0 &THEN
    createQuery( INPUT  hDBBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hDBQuery ).

    IF ( hDBQuery:NUM-RESULTS > 0 ) THEN
        deleteBuffer( hDBBuffer ).
&ENDIF

    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).

&IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
&ENDIF                                        
  END METHOD.
  
  METHOD PUBLIC VOID getContextObject(INPUT  pcContextName AS CHARACTER,
                                      INPUT  pcContextGroup AS CHARACTER,
                                      INPUT  phContextObject AS HANDLE,
                                      INPUT  pcRestoreMode AS CHARACTER,
                                      INPUT  piContextScope AS INTEGER,
                                      INPUT  pcSessionID AS CHARACTER,
                                      INPUT  pcUserID AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lTTAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lDBAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lSuccess        AS LOGICAL    NO-UNDO.
    
    /*
    **	Parameter check
    */
    
    IF ( pcContextName = ? ) OR
       ( pcContextName = "" ) OR
       ( phContextObject = ? )THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

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
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF          
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
    ASSIGN lTTAvailable = FALSE
           lDBAvailable = FALSE.

    createQuery( INPUT  hTTBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).
        
    ASSIGN lTTAvailable = ( hTTQuery:NUM-RESULTS > 0 ).

    IF ( lTTAvailable ) THEN
    DO:
        IF ( hTTBuffer::ContextTTL < NOW ) THEN
        DO:
            setLastError( {&CMDataExpired} ).
            deleteBuffer( INPUT hTTBuffer ).
            lTTAvailable = FALSE.
        END.
        ELSE
        DO:
            restoreObject( INPUT  phContextObject,
                           INPUT  hTTBuffer,
                           INPUT  pcRestoreMode,
                           OUTPUT lSuccess ).
        END.
    END.

&IF DEFINED(server-side) <> 0 &THEN    
    IF ( NOT lTTAvailable ) THEN
    DO:
        createQuery( INPUT  hDBBuffer,
                     INPUT  pcContextName,
                     INPUT  pcContextGroup,
                     INPUT  piContextScope,
                     INPUT  pcSessionID,
                     INPUT  pcUserID,
                     OUTPUT hDBQuery ).
    
        ASSIGN lDBAvailable = ( hDBQuery:NUM-RESULTS > 0 ).

        IF ( lDBAvailable ) THEN
        DO:
            IF ( hDBBuffer::ContextTTL < NOW ) THEN
            DO:
                setLastError( {&CMDataExpired} ).
                deleteBuffer( INPUT hDBBuffer ).
            END.
            ELSE
            DO:
                createContextCopy( INPUT hDBBuffer, INPUT hTTBuffer ).
                restoreObject( INPUT  phContextObject,
                               INPUT  hTTBuffer,
                               INPUT  pcRestoreMode,
                               OUTPUT lSuccess ).
            END.
        END.
    END.
&ENDIF
        
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
&IF DEFINED(server-side) <> 0 &THEN    
    deleteQuery( hDBQuery ).
&ENDIF                                      
  END METHOD.
  
  METHOD PRIVATE VOID restoreObject(INPUT  phObject AS HANDLE,
                                    INPUT  phBuffer AS HANDLE,
                                    INPUT  pcRestoreMode AS CHARACTER,
                                    OUTPUT plSuccess AS LOGICAL):
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
    
    IF ( NOT VALID-HANDLE( phObject )) OR
       ( NOT VALID-HANDLE( phBuffer )) THEN
    DO:
        setLastError( {&CMParameterError} ).
        plSuccess = FALSE.
        RETURN.
    END.
    
    /* Move BLOB data into global MEMPTR variable for conversion */
    SET-SIZE( gmpXMLDocument ) = phBuffer::ContextObjectSize.
    COPY-LOB FROM OBJECT phBuffer::ContextObject TO OBJECT gmpXMLDocument.
    
    convertXMLToObject( INPUT  phObject,
                        INPUT  pcRestoreMode,
                        OUTPUT plSuccess ).
    
    /* Release allocated memory */
    SET-SIZE( gmpXMLDocument ) = 0.
  END METHOD.
  
  METHOD PRIVATE VOID convertObjectToXML(INPUT  phObject AS HANDLE,
                                         OUTPUT plSuccess AS LOGICAL):
  /*------------------------------------------------------------------------------
    Purpose:     Convert a given object to XML document
    Parameters:  INPUT  HANDLE	- Reference to the object to convert
  			   OUTPUT LOGICAL	- Indicates whether the WRITE-XML worked
    Notes:       The XML Document will be created in the global MEMPTR variable
  			   that is scoped to the ContextManager to avoid copying between
  			   procedures.
  ------------------------------------------------------------------------------*/
    
    CASE phObject:TYPE :

        WHEN "BUFFER" OR
        WHEN "TEMP-TABLE" OR
        WHEN "DATASET" THEN
        DO:
            IF CAN-QUERY( phObject, "WRITE-XML" ) THEN
            DO:
                plSuccess = phObject:WRITE-XML( "MEMPTR",
                                                gmpXMLDocument,
                                                YES,  /* formatted          */
                                                ?,    /* encoding           */
                                                ?,    /* schema-location    */
                                                TRUE, /* write-xmlschema    */
                                                NO,   /* min-xmlschema      */
                                                TRUE  /* write-before-image */ ).
            END.
        END.        
    END CASE.

    COPY-LOB FROM gmpXMLDocument TO FILE SESSION:TEMP-DIR + "MemPtr.txt".
  END METHOD.
  
  METHOD PRIVATE VOID convertXMLToObject(INPUT  phObject AS HANDLE,
                                         INPUT  pcReadMode AS CHARACTER,
                                         OUTPUT plSuccess AS LOGICAL):
  /*------------------------------------------------------------------------------
    Purpose:     Convert a MEMPTR value containing an XML Document back into
  			   a usable object such as a buffer, temp-table or dataset.
    Parameters:  INPUT  HANDLE	- Reference to existing object to restore into
  			   INPUT  CHARACTER	- Restore mode for the object
    Notes:       
  ------------------------------------------------------------------------------*/

    CASE phObject:TYPE :

        WHEN "BUFFER" OR
        WHEN "TEMP-TABLE" OR
        WHEN "DATASET" THEN
        DO:
            IF CAN-QUERY( phObject, "READ-XML" ) AND
               CAN-DO( "APPEND,EMPTY,MERGE,REPLACE", pcReadMode ) THEN
            DO:
                plSuccess = phObject:READ-XML( "MEMPTR",
                                               gmpXMLDocument,
                                               pcReadMode,
                                               ?,    /* schema-location          */
                                               NO    /* override-default-mapping */ ).
            END.
        END.
        
    END CASE.
  END METHOD.
  
  METHOD PUBLIC VOID setContextObject(INPUT  pcContextName AS CHARACTER,
                                      INPUT  pcContextGroup AS CHARACTER,
                                      INPUT  phContextObject AS HANDLE,
                                      INPUT  pdtzContextTTL AS DATETIME-TZ, 
                                      INPUT  piContextScope AS INTEGER,
                                      INPUT  pcSessionID AS CHARACTER,
                                      INPUT  pcUserID AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lTTAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lDBAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lPersist        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lSuccess        AS LOGICAL    NO-UNDO.

    /*
    **	Parameter check
    */
    
    IF ( pcContextName = ? ) OR
       ( pcContextName = "" ) OR
       ( phContextObject = ? ) THEN
    DO:
        setLastError( {&CMParameterError} ).
        RETURN.
    END.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

    /*
    **	Convert the given object to an XML Document first.
    */
    
    convertObjectToXML( INPUT phContextObject, OUTPUT lSuccess ).
    IF ( NOT lSuccess ) THEN
    DO:
        setLastError( {&CMConvertToXMLError} ).
        RETURN.
    END.

    /*
    **	Get buffer handles so we can create queries for them dynamically.
    */
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN 
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF           
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
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
    
    ASSIGN lTTAvailable = FALSE
           lDBAvailable = FALSE.

    createQuery( INPUT  hTTBuffer,
                 INPUT  pcContextName,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).
        
    ASSIGN lTTAvailable = ( hTTQuery:NUM-RESULTS > 0 )
           lPersist     = ( isBitSet( piContextScope, {&ScopeBitGlobal} ) OR
                            isBitSet( piContextScope, {&ScopeBitApplication} ) OR
                            isBitSet( piContextScope, {&ScopeBitClientConnection} ) OR
                            isBitSet( piContextScope, {&ScopeBitUser} )).

&IF DEFINED(server-side) <> 0 &THEN
    IF ( NOT lTTAvailable ) THEN
    DO:
        createQuery( INPUT  hDBBuffer,
                     INPUT  pcContextName,
                     INPUT  pcContextGroup,
                     INPUT  piContextScope,
                     INPUT  pcSessionID,
                     INPUT  pcUserID,
                     OUTPUT hDBQuery ).
    
        ASSIGN lDBAvailable = ( hDBQuery:NUM-RESULTS > 0 ).

        IF ( lDBAvailable ) THEN
        DO:
            createContextRecord( INPUT  hDBBuffer,
                                 INPUT  pcContextName,
                                 INPUT  pcContextGroup,
                                 INPUT  "",
                                 INPUT  GET-SIZE( gmpXMLDocument ),
                                 INPUT  pdtzContextTTL,
                                 INPUT  piContextScope,
                                 INPUT  pcSessionID,
                                 INPUT  pcUserID,
                                 INPUT  NO ).

            createContextCopy( hDBBuffer, hTTBuffer ).
        END.
    END.
&ENDIF

    /*
    **	If the data is not available in the database (whether we actually
    **	physically checked or not is irrelevant) we either have to modify
    **	the local version or create a new local version. After that we check
    **	whether we need to create a copy in the persistent store or not.
    */
    
    IF ( NOT lDBAvailable ) THEN
    DO:
        createContextRecord( INPUT  hTTBuffer,
                             INPUT  pcContextName,
                             INPUT  pcContextGroup,
                             INPUT  "",
                             INPUT  GET-SIZE( gmpXMLDocument ),
                             INPUT  pdtzContextTTL,
                             INPUT  piContextScope,
                             INPUT  pcSessionID,
                             INPUT  pcUserID,
                             INPUT  NOT lTTAvailable ).

&IF DEFINED(server-side) <> 0 &THEN
        IF ( lPersist ) THEN
        DO:
            createContextCopy( hTTBuffer, hDBBuffer ).
        END.
&ENDIF
    END.
    
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
 &IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
 &ENDIF
    
    /*
    **	Release allocated memory used with XML conversion.
    */
               
    SET-SIZE( gmpXMLDocument ) = 0.                                      
  END METHOD.
  
  METHOD PUBLIC VOID deleteContextObject(INPUT  pcContextName AS CHARACTER,
                                         INPUT  pcContextGroup AS CHARACTER,
                                         INPUT  piContextScope AS INTEGER,
                                         INPUT  pcSessionID AS CHARACTER,
                                         INPUT  pcUserID AS CHARACTER):
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
    
    deleteContextValue( INPUT  pcContextName,
                        INPUT  pcContextGroup,
                        INPUT  piContextScope,
                        INPUT  pcSessionID,
                        INPUT  pcUserID ).
  END METHOD.
  
  METHOD PUBLIC VOID getContextBlock(INPUT TABLE FOR ttContextBlock,
                                     INPUT  pcContextGroup AS CHARACTER,
                                     INPUT  piContextScope AS INTEGER,
                                     INPUT  pcSessionID AS CHARACTER,
                                     INPUT  pcUserID AS CHARACTER):
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

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lTTAvailable    AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE lDBAvailable    AS LOGICAL    NO-UNDO.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

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
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF    
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
    ASSIGN lTTAvailable = FALSE
           lDBAvailable = FALSE.

    /*
    **	First of all, we will synchronize the local context data structure with the
    **	persistent one. At the end we can iterate through the local context data and
    **	create our context block without worrying about the persistent store.
    */
&IF DEFINED(server-side) <> 0 &THEN
    createQuery( INPUT  hDBBuffer,
                 INPUT  ?,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hDBQuery ).

    DO WHILE NOT hDBQuery:QUERY-OFF-END:
        IF ( hDBBuffer::ContextTTL < NOW ) THEN
            deleteBuffer( hDBBuffer ).
        ELSE
        DO:
            /*
            **	Is this a context object or a name/value.
            */
            IF ( hDBBuffer::ContextObjectSize = 0 ) THEN
            DO:
                /*
                **	Do we have this available locally as well?
                */
                ASSIGN lTTAvailable = hTTBuffer:FIND-FIRST( "WHERE ContextID = '" + hDBBuffer::ContextID + "'" ) NO-ERROR.
                IF ( NOT lTTAvailable ) THEN
                DO:
                    createContextCopy( INPUT hDBBuffer, INPUT hTTBuffer ).
                END.
            END.
        END.
        hDBQuery:GET-NEXT().
    END.
 &ENDIF

    /*
    **	We now go through the local context data store and gather up all values
    **	for inclusion in the context block.
    */
    
    createQuery( INPUT  hTTBuffer,
                 INPUT  ?,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).

    /*
    **	Round up all values from the local SessionContext and prepare to send
    **	them back in the Block TEMP-TABLE.
    */
    
    DO WHILE NOT hTTQuery:QUERY-OFF-END:
        IF ( hTTBuffer::ContextTTL < NOW ) THEN
            deleteBuffer( hTTBuffer ).
        ELSE
        DO:
            IF ( hTTBuffer::ContextObjectSize = 0 ) THEN
            DO:
                CREATE ttContextBlock.
                ASSIGN ttContextBlock.ContextName  = hTTBuffer::ContextName
                       ttContextBlock.ContextValue = hTTBuffer::ContextValue
                       .
            END.
        END.
        hTTQuery:GET-NEXT().
    END.
    
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
 &IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
 &ENDIF
  END METHOD.
  
  METHOD PUBLIC VOID setContextBlock(INPUT TABLE FOR ttContextBlock,
                                     INPUT  pcContextGroup AS CHARACTER,
                                     INPUT  pdtzContextTTL AS DATETIME-TZ,
                                     INPUT  piContextScope AS INTEGER,
                                     INPUT  pcSessionID AS CHARACTER,
                                     INPUT  pcUserID AS CHARACTER):
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
    
    FOR EACH ttContextBlock:
        setContextValue( INPUT  ttContextBlock.ContextName,
                         INPUT  pcContextGroup,
                         INPUT  ttContextBlock.ContextValue,
                         INPUT  pdtzContextTTL,
                         INPUT  piContextScope,
                         INPUT  pcSessionID,
                         INPUT  pcUserID ).
    END.                                     
  END METHOD.
  
  METHOD PUBLIC VOID deleteContextBlock(INPUT  pcContextGroup AS CHARACTER,
                                        INPUT  piContextScope AS INTEGER,
                                        INPUT  pcSessionID AS CHARACTER,
                                        INPUT  pcUserID AS CHARACTER):
  /*------------------------------------------------------------------------------
    Purpose:     Remove specified context values from the local context data
  			   structures and the persistent context data structure.
    Parameters:  INPUT  CHARACTER		- Grouping name for the context value
			   INPUT  INTEGER		- Scope of the context value
  			   INPUT  CHARACTER		- SessionID to relate context value to
  			   INPUT  CHARACTER		- UserID to relate context value to
    Notes:       
  ------------------------------------------------------------------------------*/

    DEFINE VARIABLE hTTQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hTTBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBQuery        AS HANDLE     NO-UNDO.
    DEFINE VARIABLE hDBBuffer       AS HANDLE     NO-UNDO.
    DEFINE VARIABLE lValidID        AS LOGICAL    NO-UNDO.
    
    /*
    **	Check whether a SessionID was provided. If so we have to make sure this
    **	is OK. If it is not, we will simply return.
    */        

    IF ( pcSessionID NE ? ) THEN
    DO:
        validateSessionID( INPUT pcSessionID, OUTPUT lValidID ).
        IF ( NOT lValidID ) THEN RETURN.
    END.

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
    
    ASSIGN
&IF DEFINED(server-side) <> 0 &THEN     
           hDBBuffer    = BUFFER context:HANDLE
&ENDIF           
           hTTBuffer    = TEMP-TABLE ttSessionContext:DEFAULT-BUFFER-HANDLE.
        
    createQuery( INPUT  hTTBuffer,
                 INPUT  ?,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hTTQuery ).
                 
&IF DEFINED(server-side) <> 0 &THEN     
    createQuery( INPUT  hDBBuffer,
                 INPUT  ?,
                 INPUT  pcContextGroup,
                 INPUT  piContextScope,
                 INPUT  pcSessionID,
                 INPUT  pcUserID,
                 OUTPUT hDBQuery ).
&ENDIF
    /*
    **	If we found it in the local store delete it there first.
    */

    DO WHILE NOT hTTQuery:QUERY-OFF-END:
        IF ( hTTBuffer::ContextObjectSize = 0 ) THEN
            deleteBuffer( INPUT hTTBuffer ).
        hTTQuery:GET-NEXT().
    END.    

    /*
    **	Next, we iterate through the database records.
    */
&IF DEFINED(server-side) <> 0 &THEN
    DO WHILE NOT hDBQuery:QUERY-OFF-END:
        IF ( hDBBuffer::ContextObjectSize = 0 ) THEN
            deleteBuffer( INPUT hDBBuffer ).
        hDBQuery:GET-NEXT().
    END.    
&ENDIF
    /*
    **	Close the queries and delete the query objects.
    */

    deleteQuery( hTTQuery ).
&IF DEFINED(server-side) <> 0 &THEN
    deleteQuery( hDBQuery ).
&ENDIF
  END METHOD.
  
  METHOD PRIVATE LOGICAL isBitSet(INPUT piValue AS INTEGER,
                                  INPUT piBit   AS INTEGER ):
  /*------------------------------------------------------------------------------
    Purpose:  Check for a bit in value and return whether it is set or
  		not (TRUE/FALSE)
    Notes:
  ------------------------------------------------------------------------------*/

    RETURN ( GET-BITS( piValue, piBit, 1 ) > 0 ).
  END METHOD.
