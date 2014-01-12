 
 /*------------------------------------------------------------------------
    File        : HttpResponse
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Wed Jan 01 17:58:02 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using bfv.lib.web.HttpMessage.


class bfv.lib.web.HttpResponse inherits HttpMessage: 
  
  define public property BodyMemptr as memptr no-undo get. set.

  define public property ContentLength as integer no-undo get. private set.
  define public property StatusCode as character no-undo get. private set.
  define public property Location as character no-undo get. private set.
  define public property TransferEncoding as character no-undo get. private set.
  define public property HeaderString as character no-undo get. set.
  define public property Via as character no-undo get. set.
  
  destructor HttpResponse():
    set-size(this-object:BodyMemptr) = 0.
  end.
  
  method public void ProcessHeader(headerString as character):
    
    def var numLines as integer no-undo.
    def var i as integer no-undo.
    def var headerLine as character no-undo.
    def var fieldName as character no-undo.
    def var fieldValue as character no-undo.
    
    this-object:HeaderString = headerString.
    numLines = num-entries(headerString, HttpMessage:HttpNewline).
    do i = 1 to numLines:
      
      assign 
        headerLine = trim(entry(i, headerString, HttpMessage:HttpNewline), "~n")
        fieldName = entry(1, headerLine, ":")
        fieldValue = replace(headerLine, fieldName + ": ", "")
        .    
        
      if (fieldName begins "HTTP/1.0" or fieldName begins "HTTP/1.1") then
        this-object:StatusCode = entry(2, fieldName, " ").
      else
        processFields(fieldName, fieldValue).
              
    end.
    
  end method.
  
  
  method private void processFields(fieldName as character, fieldValue as character):
  
    case fieldName:
      
      when "Content-Type" then 
        this-object:ContentType = fieldValue.
                    
      when "Content-Length" then
        this-object:ContentLength = integer(fieldValue).
        
      when "Location" then 
        this-object:Location = fieldValue.
     
      when "Transfer-Encoding" then 
        this-object:TransferEncoding = fieldValue.
      
      when "Via" then
       this-object:Via = fieldValue.
       
    end case.
      
  end method.
  
  
  method  public override character ToString():
    
    define variable returnMessage as character no-undo.
    
    
    returnMessage =  
      substitute("Status code: &1~nContent-Length: &2~nContent-Type: &3",
        this-object:StatusCode,
        this-object:ContentLength,
        this-object:ContentType
        ) + 
        (if (this-object:Location > "") then "~nLocation: " + this-object:Location else "").
     
     return returnMessage.
        
  end method.
  
end class.