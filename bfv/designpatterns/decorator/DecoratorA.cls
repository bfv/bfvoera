
using bfv.designpatterns.decorator.AbcDecorator. 
using bfv.designpatterns.decorator.IComponent.



class bfv.designpatterns.decorator.DecoratorA inherits AbcDecorator: 

	constructor public DecoratorA (componentIn as IComponent):
		Component = componentIn.
	end constructor.

	method public override character Operation():
    
    define variable returnString as character no-undo.
    
    returnString = Component:Operation().
    returnString = returnString + "~nThis is added behavior bij DecoratorA".
    
    return returnString.
    
	end method.

end class.