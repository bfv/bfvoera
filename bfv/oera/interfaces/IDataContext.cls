/* idatacontext.cls -- interface for datacontext objects. */
interface bfv.oera.interfaces.IDataContext:

  method public character GetContext(pcGroup as character, pcName  as character, pcOperator as character).
  method public void SetContext(pcGroup as character, pcName as character, pcOperator as character, pcValue as character).

end interface.
