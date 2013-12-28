using bfv.oera.base.ComponentBase.
using bfv.oera.interfaces.IComponent.
using bfv.oera.service.servicemgr.

class bfv.oera.base.ComponentBase
    implements IComponent
    use-widget-pool :
/* Base class for all objects. Locates the service manager, which it expects
   some startup routine to have created.
*/

/*    define protected property servicemgr as servicemgr no-undo*/
/*        get.                                                  */
/*        private set.                                          */
     
    constructor protected componentbase():
/*        servicemgr = bfv.oera.service.servicemgr:getInstance().*/
    end constructor.

  method public void FatalError (pcMessage as char):
      message "Fatal error!" skip pcMessage view-as alert-box error.
  end.  

  method public void initializeComponent():
      /* Not yet defined. */
  end method.

  method public void destroyComponent():
      /* Not yet defined. */
  end method.


end class.      

