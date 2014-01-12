
using bfv.lib.web.HttpRequest.
using bfv.lib.web.HttpResponse.

def var req as HttpRequest no-undo.
def var res as HttpResponse no-undo.


req = new HttpRequest().
res = req:Get("flickr.com").

copy-lob res:BodyMemptr to file "c:/tmp/responsebody.html".

message res:ToString() view-as alert-box.
        
        
