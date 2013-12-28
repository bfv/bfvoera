using bfv.oera.interfaces.*.
using bfv.oera.service.*.

class bfv.oera.service.exceptionservice
    implements iComponent:
  /* The following exceptions are allowed */
  &SCOPED-DEFINE FATALERROR 4
  &SCOPED-DEFINE SYSTEMERROR 3
  &SCOPED-DEFINE APPLICATIONERROR 2
  &SCOPED-DEFINE WARNING 1
  &SCOPED-DEFINE QUESTION 0
   
  /* The dataset is actually instantiated in the exceptionservice itself */
  {bfv/oera/service/dsexception.i}
 
  define private        variable immediateDisplay as logical          no-undo init no.
  define private        variable contextInfo      as character        no-undo.
  define private        variable contextBuffer    as handle           no-undo.
  define private        variable exceptionBuffer  as handle           no-undo.
  define private        variable numberExceptions as integer          no-undo.
  define private        variable translateService as itranslate       no-undo.
  define private static variable cob_ExceptionMgr as exceptionservice no-undo.

  constructor private exceptionService():
    exceptionBuffer = buffer ttException:HANDLE.
    /* Does not exist yet...
    translateService = NEW service.translateservice(). */
  end.


	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	
	method public static final exceptionservice getInstance(  ):
		
        if not valid-object(cob_ExceptionMgr)
        then
            cob_ExceptionMgr = new exceptionservice().
            
        return cob_ExceptionMgr.

	end method.


 

   method public void initializeComponent():
  end method.

  method public void destroyComponent():
      delete object this-object.
  end method.

  /* Methods to add or throw exceptions
   * add.... - just add the message to the queue
   * throw.. - add and signal a stop */
  method public void addQuestion(pcCode as character, pcParameters as character):
    registerException({&QUESTION}, pcCode, pcParameters).
  end method.
  
  method public void addWarning(pcCode as character, pcParameters as character):
    registerException({&WARNING}, pcCode, pcParameters).
  end method.
  
  method public void addError(pcCode as character, pcParameters as character):
    registerException({&APPLICATIONERROR}, pcCode, pcParameters).
  end method.

  method public void throwError(pcCode as character, pcParameters as character):
    registerException({&APPLICATIONERROR}, pcCode, pcParameters).
    stop.
  end method.
   
  method public void throwSystemError(pcCode as character, pcParameters as character):
    registerException({&SYSTEMERROR}, pcCode, pcParameters).
    stop.
  end method.
  
  method public void throwFatalError(pcCode as character, pcParameters as character):
    registerException({&FATALERROR}, pcCode, pcParameters).
    stop.
  end method.
  
  /* Methods to find out if there are messages in general or
   * a specific type of messages */
  method public logical anyMessage():
    return temp-table ttException:HAS-RECORDS.
  end.
  
  method public logical anyError():
    find first ttException where exceptionLevel >= {&APPLICATIONERROR} no-error.
    return available ttException.
  end.
  
  method public logical anySystemError():
    find first ttException where exceptionLevel >= {&SYSTEMERROR} no-error.
    return available ttException.
  end.
  
  /* Clean up the message queue */
  method public logical emptyException():
    return dataset dsException:EMPTY-DATASET.
  end. 
  
  /* Private method to actually register an excpetion.
   * used by all add and throw methods */
  method private character registerException(piLevel as integer, 
                                             pcCode as character, 
                                             pcParameters as character):
    define variable uuid as character  no-undo.
    define variable cShortMessage as character  no-undo.
    define variable cLongMessage as character  no-undo.
    define variable cProgressErrors as character  no-undo.
    define variable cStack as character  no-undo.
    define variable iMessage as integer    no-undo.
    
    define buffer bException for temp-table ttException.
    
    do iMessage = 1 to error-status:num-messages:
      cProgressErrors = cProgressErrors + '~n':U + error-status:get-message(iMessage).
    end.
    cProgressErrors = substring(cProgressErrors, 2).
     
    iMessage = 3.
    do while program-name(iMessage) <> ?:
      if num-entries(program-name(iMessage), ' ':U) > 1 then 
        cStack = SUBST('&1~n&2:&3', cStack, 
                       entry(2, program-name(iMessage), ' ':U),
                       entry(1, program-name(iMessage), ' ':U)).
      else
        cStack = SUBST('&1~n&2:CONSTRUCTOR', cStack, program-name(iMessage)).
      iMessage = iMessage + 1.
    end.
    cStack = substring(cStack, 2).
    
    translateMessage(pcCode, pcParameters, output cShortMessage, output cLongMessage).
    
    if (log-manager:logfile-name > "") then do:
      
      /* always logerrors, log warnings when log-level >= verbose */  
      if (piLevel > 1 or log-manager:logging-level > 2) then
        log-manager:write-message(cShortMessage + "|" + cLongMessage).
      
      if (log-manager:logging-level > 2) then 
        log-manager:write-message(cStack).
        
    end.


    create bException.
    assign
      uuid = base64-encode(generate-uuid)
      bException.exceptionId = uuid
      numberExceptions = numberExceptions + 1
      bException.exceptionSequence = numberExceptions
      bException.timeStamp = now
      bException.exceptionLevel = piLevel
      bException.shortMessage = cShortMessage
      bException.longMessage = cLongMessage
      bException.progressErrors = cProgressErrors
      bException.callstack = cStack
      bException.messageCode = pcCode
      bException.parameters = pcParameters
      bException.contextInfo = contextInfo.
      
    if valid-handle(contextBuffer) then
    do:
      contextBuffer:error = yes.
      contextBuffer:error-string = uuid.
      if contextBuffer:dataset <> ? then
        contextBuffer:dataset:ERROR = yes.
    end.
    if immediateDisplay then
      displayExceptions().
  end method.
  
  method public void fetchException(output DATASET dsException):
    /* Just return the dataset, primary usage is to fetch the messages
     * from the server and put them in the client queue */
  end.
  
  method public void mergeException(DATASET-HANDLE pdsException):
    /* Merge the exceptions from the appserver into the exception tables,
     * simple implementation = not merge but copy, should be a merge exceptionSequence 
       must be renumbered */
    if valid-handle (pdsException) then
        dataset dsException:COPY-DATASET(pdsException). 
    if immediateDisplay then
      displayExceptions().
  end.

  method public void translateMessage(pcCode as character, 
                                      pcParam as character, 
                                      output pcShort as character, 
                                      output pcLong as character).
    /* Translations are normally handled by a translation service */
    if valid-object(translateService) then
      translateService:translateMessage(pcCode, pcParam, output pcShort, output pcLong).
    else
    assign
      pcShort = SUBST('&1 [&2]', entry(1, pcParam, '~n'), pcCode)
      pcLong  = pcParam.
  end.

  method public void displayExceptions():
    /* Default mechanism to show exceptions */
    define buffer bException for temp-table ttException.
    for each bException:
      message 
        SUBST('Error code: &1, Level &2', bException.messageCode, bException.exceptionLevel) skip
          bException.shortMessage skip
          if bException.progressErrors <> '' then 
              'Error-status:~n' + bException.progressErrors else '' skip
          'Stack:~n' + bException.callStack
        view-as alert-box error.
    end.
  end.

  method public logical findQuestion():
    /* Retrieve the first question which is in the queue and returns 
     * Additional info for the question can be retrieved by using the 
     * fields of the selected buffer, e.g.
     * exceptionService:exceptionBuffer::messageCode */
    find first ttException where ttException.exceptionLevel = {&QUESTION} no-error.
    return available ttException.
  end.

  method public void deleteException(pcId as character):
    /* Delete the current exception OR the exception that is identified */
    if pcId <> ? then
      find ttException where ttException.exceptionId = pcId no-error.
    if available ttException then
      delete ttException.
  end.

  method public void bindException(output DATASET-HANDLE pdsException bind):
    /* Binding method to enable error handling mechanism to 
     * work on the entire queue */
    pdsException = dataset dsException:HANDLE.
  end.

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	destructor public exceptionservice ( ):

        dataset dsException:EMPTY-DATASET().
	end destructor.
end. 

