/* idatacontext.cls -- interface for datacontext objects. */
INTERFACE bfv.oera.interfaces.idatacontext:

METHOD PUBLIC CHARACTER getContext
    (pcGroup AS CHARACTER,
     pcName  AS CHARACTER,
     pcOperator AS CHARACTER).

METHOD PUBLIC VOID setContext
    (pcGroup    AS CHARACTER,
     pcName     AS CHARACTER,
     pcOperator AS CHARACTER,
     pcValue    AS CHARACTER).

END INTERFACE.
