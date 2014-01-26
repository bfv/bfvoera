 
using bfv.designpatterns.decorator.IComponent.


class bfv.designpatterns.decorator.AbcDecorator implements IComponent: 
  
  define public property Component as IComponent no-undo get. set. 
  
  
  method public character Operation(). end.
  
end class.