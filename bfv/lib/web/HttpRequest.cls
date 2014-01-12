 
 /*------------------------------------------------------------------------
    File        : HttpRequest
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Thu Jan 02 10:13:04 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/

using bfv.lib.web.HttpMessage.
using bfv.lib.web.HttpResponse.


class bfv.lib.web.HttpRequest inherits HttpMessage final: 
	
  define public property RequestUrl as character no-undo get. 
    set(urlString as character):
      decomposeUrl(urlString).
      RequestUrl = urlString.
    end.
    
	define public property Host as character no-undo get. private set.
	define public property Port as character no-undo get. private set.
	define public property Path as character no-undo get. private set.
	define public property Protocol as character no-undo get. private set.
	define public property RequestMethod as character no-undo init "GET" get. private set.
	define public property SSLConnection as logical no-undo get. private set.
	define public property AcceptEncoding as character /*init "identity"*/ get. set.
	define public property Accept as character no-undo /*init "text/html"*/ get. set.
  define public property HttpVersion as character no-undo init "1.0" get. set.
		  
  method private void decomposeUrl(urlString as character):
    
    define variable positionSlash as integer no-undo.
    define variable positionColon as integer no-undo.
    
    this-object:Protocol = "http".
    if (urlString begins "http://") then do:
      urlString = substring(urlString, 8).
      this-object:SSLConnection = false.
    end.
    
    if (urlString begins "https://") then do:
      this-object:Protocol = "https".
      urlString = substring(urlString, 9).
      this-object:SSLConnection = true.
    end. 
    
    positionSlash = index(urlString, "/").
    if (positionSlash = 0) then 
      assign 
        urlString = urlString + "/"
        positionSlash = index(urlString, "/")
        .
        
    positionColon = index(urlString, ":").
     
    if (positionColon > 0) then do:               
      this-object:Port = substring(urlString, positionColon + 1, positionSlash - positionColon - 1).
      urlString = substring(urlString, 1, positionColon - 1) + substring(urlString, positionSlash).
      positionSlash = index(urlString, "/").
    end.
    else
      this-object:Port = "80".
         
    this-object:Host = substring(urlString, 1, positionSlash - 1).
    this-object:Path = (if (length(urlString) > positionSlash) then substring(urlString, positionSlash) else "/").
     
  end method.
  
  
  method public override character ToString():
    return substitute("URL: &1~nHost: &2~nPort:&3~nPath: &4~nSSL: &5", 
            this-object:RequestUrl, this-object:Host, this-object:Port, this-object:Path, string(this-object:SSLConnection, "true/false")
           ).  
  end.
  
  method public HttpResponse Get (requestUrl as character):
    
    this-object:RequestMethod = "GET".
    this-object:RequestUrl = requestUrl.
    
    return executeCall().
    
  end method.
  
  
  method private HttpResponse executeCall():
    
    define variable response as HttpResponse no-undo.
    
    run bfv/lib/web/httpcallimplementation.p (this-object, output response).
    
    return processResponse(response).
    
  end method.
  
  
 method private HttpResponse processResponse(responseIn as HttpResponse):
    
    define variable responseOut as HttpResponse no-undo.
    
    case responseIn:StatusCode:
      
      when "301" or when "302" then do:
        this-object:RequestUrl = responseIn:Location + this-object:Path.
        return executeCall().
      end.
      
      /* in case of a 200 or something which wasn't anticipated, just return the response */
      otherwise do:
        responseOut = responseIn.
      end.  
      
    end.
    
    return responseOut.
        
  end method. 
  
  
  method public character BuildRequestString():
    
    def var requestString as character no-undo.
    
    requestString =   
      this-object:RequestMethod + " " + this-object:Path + " HTTP/" + this-object:HttpVersion + HttpMessage:HttpNewline +
      "Host: " + this-object:Host + HttpMessage:HttpNewline +
      (if (this-object:Accept > "") then "Accept: " + this-object:Accept + HttpMessage:HttpNewline else "") + 
      (if (this-object:AcceptEncoding > "") then "Accept-Encoding: " + this-object:AcceptEncoding  + HttpMessage:HttpNewline else "") + 
      "User-Agent: OpenEdge " + proversion(1) + HttpMessage:HttpNewline +  
      "Connection: close" + HttpMessage:HttpNewline +  
      HttpMessage:HttpNewline 
      .

    return requestString.

  end method.
  
end class.