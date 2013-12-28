/* cltdatacontext.cls: This is the client-side support class for context
   information. It uses an include file that defines a standard set of 
   methods (some of which are basic to the handling of context and 
   therefore are specified in an interface for the class) along with
   the context DataSet. As used on the client side, the DataSet is *not*
   REFERENCE-ONLY -- it holds the actual context data to be passed to the
   Service Provider on the server.
 */
using bfv.oera.interfaces.*.
using bfv.oera.base.DataContext.

 
class bfv.oera.base.ClientDataContext inherits DataContext implements IDataContext use-widget-pool :

  define public property dsContext as handle no-undo get. private set.
      
      
  constructor public ClientDataContext():
    dsContext = dataset dsContext:handle.
  end constructor.


  destructor public ClientDataContext():
    dataset dsContext:empty-dataset().
  end destructor.

end class.

   
