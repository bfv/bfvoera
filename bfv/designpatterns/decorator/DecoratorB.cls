using bfv.designpatterns.decorator.AbcDecorator. 
using bfv.designpatterns.decorator.IComponent.



class bfv.designpatterns.decorator.DecoratorB inherits AbcDecorator: 

  constructor public DecoratorB (componentIn as IComponent):
    Component = componentIn.
  end constructor.

  method public override character Operation():
    
    define variable returnString as character no-undo.
    
    returnString = Component:Operation().
    returnString = returnString + "~nThis is added behavior bij DecoratorB".
    
    return returnString.
    
  end method.

end class.