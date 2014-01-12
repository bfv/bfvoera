 
 /*------------------------------------------------------------------------
    File        : HttpMessage
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jan 01 17:57:33 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.



class bfv.lib.web.HttpMessage: 
  
  define public static property HttpNewline as character init "~r~n" get.
  define public property ContentType as character no-undo get. set.
  
end class.