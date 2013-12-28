
/*------------------------------------------------------------------------
    File        : IContextPersistence
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bfv
    Created     : Sat Dec 28 12:05:32 CET 2013
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

interface bfv.oera.service.IContextPersistence:  
  
  method public void DeleteSessionContext(sessionId as character).
  method public void GetSessionContext(sessionId as character, ttcontextHandle as handle).
   
end interface.