/* Helper class to manipulate the data context dataset */
/* CLASS base.datacontext: */
/* new include file from that. */
  
    METHOD PUBLIC CHARACTER getContext
       ( pcGroup        AS CHARACTER,
         pcName         AS CHARACTER,
         pcOperator     AS CHARACTER) :
      FIND ttContext 
        WHERE ttContext.contextGroup    = pcGroup
          AND ttContext.contextName     = pcName
          AND ttContext.contextOperator = pcOperator NO-ERROR.
      ERROR-STATUS:ERROR = NO.
      RETURN (IF AVAILABLE ttContext THEN ttContext.contextValue ELSE  ?).
    END METHOD.
    
    METHOD PUBLIC VOID setContext 
       (pcGroup        AS CHARACTER,
        pcName         AS CHARACTER,
        pcOperator     AS CHARACTER,
        pcValue        AS CHARACTER) :
      FIND ttContext 
        WHERE ttContext.contextGroup    = pcGroup
          AND ttContext.contextName     = pcName
          AND ttContext.contextOperator = pcOperator NO-ERROR.
      ERROR-STATUS:ERROR = NO.
      
      IF NOT AVAILABLE ttContext AND pcValue <> ? THEN
        CREATE ttContext.
      IF pcValue = ? AND AVAILABLE ttContext THEN 
        DELETE ttContext.   
      IF AVAILABLE ttContext THEN 
        ASSIGN 
         ttContext.contextGroup = pcGroup
         ttContext.contextName = pcName
         ttContext.contextOperator = pcOperator
         ttContext.contextValue = pcValue.

      /* allow delete all from a group */
      IF pcValue = ? AND pcName = '*':U THEN
      DO:
        FOR EACH ttContext 
          WHERE ttContext.contextGroup    = pcGroup:
          DELETE ttContext.  
        END.
      END.
      /* allow delete all operators */
      ELSE IF pcValue = ? AND pcOperator = '*' THEN
      DO:
        FOR EACH ttContext 
          WHERE ttContext.contextGroup    = pcGroup
  	        AND ttContext.contextName     = pcName:
          DELETE ttContext.  
        END.
      END.
    END METHOD.
    
    METHOD PUBLIC VOID clearContext():
      EMPTY TEMP-TABLE ttContext.
    END METHOD.
    
    METHOD PUBLIC CHARACTER getQueryName():
       RETURN getContext('QUERY':U, 'name':U, ''). 
    END METHOD.
    
    METHOD PUBLIC VOID setQueryName(pcQueryName AS CHARACTER):
      setContext('QUERY', 'NAME', '', pcQueryName).
    END METHOD.
    
    METHOD PUBLIC VOID setParam(pcParam AS CHARACTER, pcValue AS CHARACTER):
      setContext('PARAM', pcParam, '', pcValue).
    END METHOD.
    
    METHOD PUBLIC CHARACTER getParam(pcParam AS CHARACTER):
       RETURN getContext('PARAM':U, pcParam, ''). 
    END METHOD.
    
    METHOD PUBLIC VOID setOption(pcOption AS CHARACTER, pcValue AS CHARACTER):
      setContext('OPTION', pcOption, '', pcValue).
    END METHOD.
    
    METHOD PUBLIC CHARACTER getOption(pcOption AS CHARACTER):
       RETURN getContext('OPTION':U, pcOption, ''). 
    END METHOD.
    
    METHOD PUBLIC VOID setFilter(pcName AS CHARACTER, pcOperator AS CHARACTER, pcValue AS CHARACTER).
      setContext('FILTER':U, pcName, pcOperator, pcValue).
    END METHOD.
    
    METHOD PUBLIC CHARACTER getFilter(pcName AS CHARACTER, pcOperator AS CHARACTER):
      RETURN getContext('FILTER':U, pcName, pcOperator).
    END. 

    METHOD PUBLIC VOID setSort (pcSort as char).
      setOption ('SORT':U, pcSort).
    END METHOD.
    
    METHOD PUBLIC CHARACTER getSort():
      RETURN getOption ('SORT':U).
    END. 
    
    METHOD PRIVATE VOID showError(pcMessage AS CHARACTER):
      DEFINE       VARIABLE  iStack    AS INTEGER  INIT 2 NO-UNDO.
      DEFINE       VARIABLE  cStack    AS CHARACTER       NO-UNDO.
      
      DO WHILE PROGRAM-NAME(iStack) <> ?:
        ASSIGN cStack = SUBST('&1~n&2':U, cStack, PROGRAM-NAME(iStack))
               iStack = iStack + 1.
      END.
      MESSAGE pcMessage SKIP(1) cStack VIEW-AS ALERT-BOX ERROR.
    END METHOD.
    
    METHOD PUBLIC VOID displayContext ():
        FOR EACH ttContext:
            MESSAGE 
                "Group : " ttContext.contextGroup SKIP
                "Name  : " ttContext.contextName SKIP
                "Operator : " ttContext.contextOperator SKIP
                "Value : " ttContext.contextValue.
        END.
    END METHOD.

