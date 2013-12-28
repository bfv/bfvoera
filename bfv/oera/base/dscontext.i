/* dsContext.i -- standard context temp-table include file, that allows
   multiple rows, each defining a single context value name and value. */
 
DEFINE TEMP-TABLE ttContext NO-UNDO {&REFERENCE-ONLY}
  FIELD contextGroup    AS CHARACTER
  FIELD contextName     AS CHARACTER
  FIELD contextValue    AS CHARACTER
  FIELD contextOperator AS CHARACTER
  FIELD contextType     AS CHARACTER
  INDEX ttContext IS PRIMARY UNIQUE
        contextGroup
        contextName
        contextOperator.
           
DEFINE DATASET dsContext {&REFERENCE-ONLY} FOR ttContext.
