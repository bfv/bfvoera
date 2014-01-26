 
using bfv.designpatterns.decorator.IComponent.



class bfv.designpatterns.decorator.Component implements IComponent: 

	constructor public Component (  ):
		super ().
	end constructor.

	method public character Operation(  ):
		return "this is the Default component behavior".
	end method.

end class.