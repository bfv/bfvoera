
using bfv.designpatterns.decorator.IComponent.
using bfv.designpatterns.decorator.Component.
using bfv.designpatterns.decorator.DecoratorA.
using bfv.designpatterns.decorator.DecoratorB.

define variable comp as IComponent no-undo.

comp = new Component().

message comp:Operation().

comp = new DecoratorA(comp).
message comp:Operation().

comp = new DecoratorB(comp).
message comp:Operation().


