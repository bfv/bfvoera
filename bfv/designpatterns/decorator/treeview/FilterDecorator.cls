 
using bfv.designpatterns.decorator.treeview.ITreeviewComponent.
using bfv.designpatterns.decorator.treeview.AbcTreeviewDecorator.



class bfv.designpatterns.decorator.treeview.FilterDecorator inherits AbcTreeviewDecorator implements ITreeviewComponent: 
   
  constructor public FilterDecorator(component as ITreeviewComponent):
    TreeviewComponent = component.
  end.
  
	method public override void InitializeUI():
		TreeviewComponent:InitializeUI().
/*		TreeviewComponent:TreeviewControl:Location:X = TreeviewComponent:TreeviewControl:Location:X + 20.*/
		TreeviewComponent:TreeviewControl:Dock = System.Windows.Forms.DockStyle:Bottom.		
	end method.

end class.