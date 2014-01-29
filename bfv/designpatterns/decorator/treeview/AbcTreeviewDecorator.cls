 
using bfv.designpatterns.decorator.treeview.ITreeviewComponent.
using System.Windows.Forms.Control from assembly.
using System.Windows.Forms.TreeView from assembly.
 
class bfv.designpatterns.decorator.treeview.AbcTreeviewDecorator implements ITreeviewComponent: 
   
  define public property ComponentControl as Control get. private set.
  define public property TreeviewComponent as ITreeviewComponent get. protected set.
  define public property TreeviewControl as Treeview get. protected set.
  
  method public void InitializeUI():
    
  end method.
  
end class.