
using bfv.lib.web.HttpMessage.
using bfv.lib.web.HttpRequest.
using bfv.lib.web.HttpResponse. 


define input parameter requestObject as HttpRequest no-undo.
define output parameter responseObject as HttpResponse no-undo.

define variable httpSocket as handle no-undo.
define variable socketConnected as logical no-undo.
define variable requestString as character no-undo.
define variable mHttpRequestHeader as memptr no-undo.
define variable headerComplete as logical no-undo.
define variable mResponseHeader as memptr no-undo.
define variable headerString as character no-undo.
define variable headerEndPosition as integer no-undo.
define variable headerCurrentPosition as integer no-undo.
define variable contentPosition as integer no-undo.
define variable contentCurrentPosition as integer no-undo.
define variable contentByteCount as integer no-undo.
define variable transferEncodingIsChunked as logical no-undo.
define variable chunkNumber as integer no-undo.
define variable chunkByteCountSum as integer no-undo.

define temp-table ttchunk no-undo
  field chunkorder as integer
  field chunksize as integer 
  field chunkdata as raw
  index chunkorder as primary unique chunkorder 
  .
  
do on error undo, throw:
  
  create socket httpSocket.
  httpSocket:set-read-response-procedure("readHandler", this-procedure).
  httpSocket:connect("-H " + requestObject:Host + " -S " + requestObject:Port + (if (requestObject:SSLConnection) then " -ssl -nohostverify" else "")).

  catch err1 as Progress.Lang.Error :
  	undo, throw err1.	
  end catch.
end.

requestString = requestObject:BuildRequestString().

set-size(mHttpRequestHeader) = length(requestString) + 1.
put-string(mHttpRequestHeader, 1) = requestString.
httpSocket:write(mHttpRequestHeader, 1, length(requestString)).
set-size(mHttpRequestHeader) = 0.               

/* there's a limit on the total amount of bytes in the header. 
 * This varies bij WebServer. IIS allows the most (=16kB)
 */
set-size(mResponseHeader) = 16384. 
headerCurrentPosition = 1.

messageloop:
repeat on stop undo, leave on quit undo, leave:

  if (httpSocket:connected()) then 
    wait-for read-response of httpSocket. 
  else
   leave messageloop. 
    
  if (not headerComplete) then do:
    
    headerEndPosition = index(headerString, HttpMessage:HttpNewline + HttpMessage:HttpNewline).
    if (headerEndPosition > 0) then do:
      
      headerComplete = true. 
      headerString = trim(substring(headerString, 1, headerEndPosition)).
      responseObject = new HttpResponse().
      responseObject:ProcessHeader(headerString).
      transferEncodingIsChunked = (responseObject:TransferEncoding = "chunked").
      
      message responseObject:HeaderString.
      
      if (responseObject:Via begins "HTTP/1.1" and responseObject:ContentLength = 0) then 
        transferEncodingIsChunked = true.
        
      /* content(length) is known, init the memptr to store the content and copy the 
       * already received content into this memptr 
       */
      contentPosition = headerEndPosition + 4.
      contentByteCount = headerCurrentPosition - contentPosition + 1.
      
      if (transferEncodingIsChunked) then do:     
                 
        run addChunk(
          get-bytes(mResponseHeader, contentPosition, contentByteCount),
          contentByteCount
        ).  
        
      end.
      else do:
        set-size(responseObject:BodyMemptr) = responseObject:ContentLength + 1.  
        put-bytes(responseObject:BodyMemptr, 1) = get-bytes(mResponseHeader, contentPosition, contentByteCount).
        contentCurrentPosition = contentByteCount + 1.
      end.
       
    end.
       
  end.  
  
end.

httpSocket:disconnect() no-error.
delete object httpSocket no-error.

if (transferEncodingIsChunked) then do:
  run concatCkunks.
end.

procedure readHandler private:
  
  define variable bytesAvail as integer no-undo.
  define variable mChunk as memptr no-undo.
  
  if (httpSocket:connected()) then 
    bytesAvail =  httpSocket:get-bytes-available().
  
  if (bytesAvail = 0) then 
    return.
  
  if (not headerComplete) then do:
    httpSocket:read(mResponseHeader, headerCurrentPosition, bytesAvail, 1).
    headerCurrentPosition = headerCurrentPosition + bytesAvail.
    headerString = headerString + get-string(mResponseHeader, 1).    
  end.
  else do:
       
    if (transferEncodingIsChunked) then do:
      httpSocket:read(mChunk, 1, bytesAvail, 1).
      run addChunk(mChunk, bytesAvail).
    end.
    else do:
      httpSocket:read(responseObject:BodyMemptr, contentCurrentPosition, bytesAvail, 1).
      contentCurrentPosition = contentCurrentPosition + bytesAvail.
    end.
   
  end.
  
end procedure.


procedure addChunk private:
  
  define input parameter mChunk as memptr no-undo.
  define input parameter chunkSize as integer no-undo.
   
  
  create ttchunk.
  assign 
    ttchunk.chunkorder = chunkNumber
    ttchunk.chunkdata = mChunk
    ttchunk.chunksize = chunkSize
    chunkNumber = chunkNumber + 1
    chunkByteCountSum = contentByteCount
    .
  
  set-size(mChunk) = 0.
  
end procedure.


procedure concatChunks:
  
  define variable currentPosition as integer no-undo.
  
  set-size(responseObject:BodyMemptr) = chunkByteCountSum + 1. 
  
  currentPosition = 1.
  for each ttchunk:
    put-bytes(responseObject:BodyMemptr, currentPosition) = ttchunk.chunkdata.
    currentPosition = currentPosition + ttchunk.chunksize.
    delete ttchunk. 
  end.
  
end procedure.
