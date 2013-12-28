/* ServerDataContext: overerving die er voor zorgt dat de consumer geen dscontext dataset 
 * definitie hoeft op te nemen in en ook niet de bindContext method hoeft aan te roepen
 */
 
using bfv.oera.base.srvdatacontext.


class bfv.oera.base.ServerDataContext inherits srvdatacontext: 
    
  constructor public ServerDataContext():
    bindContext(dataset dscontext bind).  
  end.
  
  constructor public ServerDataContext (filterName as character, operator as character, filterValue as character):
    this-object().
    SetFilter(filterName, operator, filterValue).
  end. 
  
  constructor public ServerDataContext (nameIn as character, valueIn as character, isParameter as logical):
    
    this-object().
    if (isParameter) then 
      SetParam(nameIn, valueIn).
    else
      SetOption(nameIn, valueIn).
      
  end.
  
end class.