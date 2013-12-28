 
/*------------------------------------------------------------------------
   File        : DataContext
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : bronco
   Created     : Sat Dec 28 13:35:19 CET 2013
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.



class bfv.oera.base.DataContext: 
  
  {bfv/oera/base/dscontext.i &reference-only=reference-only &access-mode=protected}
  
  method public character getContext ( pcGroup as character, pcName as character, pcOperator as character):
    
    find ttContext where ttContext.contextGroup    = pcGroup
                     and ttContext.contextName     = pcName
                     and ttContext.contextOperator = pcOperator 
                         no-error.                
    
    return (if available ttContext then ttContext.contextValue else ?).
  end method.
    
  method public void setContext (pcGroup as character, pcName as character, pcOperator as character, pcValue as character):
    
    find ttContext where ttContext.contextGroup    = pcGroup
                     and ttContext.contextName     = pcName
                     and ttContext.contextOperator = pcOperator 
                         no-error.

    if (not available ttContext and pcValue <> ?) then
      create ttContext.

    if (pcValue = ? and available ttContext) then 
      delete ttContext.   
      
    if (available ttContext) then
     
      assign 
        ttContext.contextGroup    = pcGroup
        ttContext.contextName     = pcName
        ttContext.contextOperator = pcOperator
        ttContext.contextValue    = pcValue
        .

    /* allow delete all from a group */
    if (pcValue = ? and pcName = "*") then do:
      for each ttContext where ttContext.contextGroup = pcGroup:
        delete ttContext.  
      end.
    end.
    /* allow delete all operators */
    else if pcValue = ? and pcOperator = "*" then do:
      for each ttContext where ttContext.contextGroup = pcGroup
                           and ttContext.contextName  = pcName:
        delete ttContext.  
      end.
    end.

  end method.
    
  method public void clearContext():
    empty temp-table ttContext.
  end method.
    
  method public character getQueryName():
    return getContext("QUERY", "name", ""). 
  end method.
    
  method public void setQueryName(pcQueryName as character):
    setContext("QUERY", "NAME", "", pcQueryName).
  end method.
    
  method public void setParam(pcParam as character, pcValue as character):
    setContext("PARAM", pcParam, "", pcValue).
  end method.
    
  method public character getParam(pcParam as character):
    return getContext("PARAM", pcParam, ""). 
  end method.
    
  method public void setOption(pcOption as character, pcValue as character):
    setContext("OPTION", pcOption, "", pcValue).
  end method.
    
  method public character getOption(pcOption as character):
    return getContext("OPTION", pcOption, ""). 
  end method.
    
  method public void setFilter(pcName as character, pcOperator as character, pcValue as character).
    setContext("FILTER", pcName, pcOperator, pcValue).
  end method.
    
  method public character getFilter(pcName as character, pcOperator as character):
    return getContext("FILTER", pcName, pcOperator).
  end. 

  method public void setSort (pcSort as char).
    setOption ("SORT", pcSort).
  end method.
    
  method public character getSort():
    return getOption ("SORT").
  end. 
    
  method private void showError(pcMessage as character):
    define variable iStack as integer   init 2 no-undo.
    define variable cStack as character no-undo.
      
    do while program-name(iStack) <> ?:
      assign 
        cStack = SUBST("&1~n&2", cStack, program-name(iStack))
        iStack = iStack + 1.
    end.
    message pcMessage skip(1) cStack view-as alert-box error.
  end method.
    
  method public void displayContext ():
    for each ttContext:
      message 
        "Group : " ttContext.contextGroup skip
        "Name  : " ttContext.contextName skip
        "Operator : " ttContext.contextOperator skip
        "Value : " ttContext.contextValue.
    end.
  end method.

end class.