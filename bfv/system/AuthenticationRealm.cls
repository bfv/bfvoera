 
 /*------------------------------------------------------------------------
    File        : AuthenticationRealm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Sat Jan 18 16:34:41 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Security.Realm.IHybridRealm.


class bfv.system.AuthenticationRealm implements IHybridRealm: 
  
  method public logical ValidatePassword(theUserID as integer, theDigest as character, nonce as character, timestamp as character):
    
    message theUserID "~n" theDigest "~n" nonce "~n" timestamp .
    
    return true.

  end method.


  /******************************************************************************************************/

  method public character GetAttribute( input p0 as integer, input p1 as character ):
    message "GetAttribute, p0:" p0 "~np1:" p1. 
  end method.

  method public character extent GetAttributeNames( input p0 as integer ):
    
    undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

  end method.

  method public character extent GetUserNames(  ):
    
    undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

  end method.

  method public character extent GetUserNamesByQuery( input p0 as character ):
    
    undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

  end method.

  method public logical RemoveAttribute( input p0 as integer, input p1 as character ):
    
    undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

  end method.

  method public logical SetAttribute( input p0 as integer, input p1 as character, input p2 as character ):
    
    undo, throw new Progress.Lang.AppError("METHOD NOT IMPLEMENTED").

  end method.

  method public logical ValidatePassword(p0 as integer, p1 as character):
    
    message "p0:" p0 "~np1:" p1.
    return true.

  end method.

  method public integer ValidateUser(p0 as character):
    
    message "ValidateUser, p0:" p0.
    return 55.

  end method.

end class.