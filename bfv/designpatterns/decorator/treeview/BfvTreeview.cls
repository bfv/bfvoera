 

using Progress.Windows.UserControl.
using bfv.designpatterns.decorator.treeview.ITreeviewComponent.
using System.Windows.Forms.TreeView from assembly.
using System.Windows.Forms.Control from assembly.


class bfv.designpatterns.decorator.treeview.BfvTreeview inherits UserControl implements ITreeviewComponent: 
	
  define public property ComponentControl as Control get. private set.
  define public property TreeviewControl as Treeview get. private set.

	define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable treeviewControl1 as Treeview no-undo.
		

	constructor public BfvTreeview (  ):
		 	
    super().
    InitializeComponent().
    this-object:ComponentsCollection:Add(this-object:components).
    
    ComponentControl = this-object.
    TreeviewControl = treeviewControl1.
    
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

	end constructor.

	method private void InitializeComponent(  ):
		
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable treeNode1 as System.Windows.Forms.TreeNode no-undo.
    treeNode1 = new System.Windows.Forms.TreeNode("ChildNode1").
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as System.Windows.Forms.TreeNode extent 1 no-undo.
    arrayvar0[1] = treeNode1.
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable treeNode2 as System.Windows.Forms.TreeNode no-undo.
    treeNode2 = new System.Windows.Forms.TreeNode("root node", arrayvar0).
    this-object:treeviewControl1 = new System.Windows.Forms.TreeView().
    this-object:SuspendLayout().
    /*  */
    /* treeviewControl1 */
    /*  */
    this-object:treeviewControl1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:treeviewControl1:Location = new System.Drawing.Point(0, 0).
    this-object:treeviewControl1:Name = "treeviewControl1".
    treeNode1:Name = "Node1".
    treeNode1:Text = "ChildNode1".
    treeNode2:Name = "Node0".
    treeNode2:Text = "root node".
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as System.Windows.Forms.TreeNode extent 1 no-undo.
    arrayvar1[1] = treeNode2.
    this-object:treeviewControl1:Nodes:AddRange(arrayvar1).
    this-object:treeviewControl1:Size = new System.Drawing.Size(298, 298).
    this-object:treeviewControl1:TabIndex = 0.
    /*  */
    /* BfvTreeview */
    /*  */
    this-object:AutoScaleDimensions = new System.Drawing.SizeF(Progress.Util.CastUtil:ToSingle(6), Progress.Util.CastUtil:ToSingle(13)).
    this-object:BorderStyle = System.Windows.Forms.BorderStyle:FixedSingle.
    this-object:Controls:Add(this-object:treeviewControl1).
    this-object:Name = "BfvTreeview".
    this-object:Size = new System.Drawing.Size(298, 298).
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
	end method.

	destructor public BfvTreeview ( ):

	end destructor.
	
	method public void InitializeUI():
	  
	end.

end class.