 
 /*------------------------------------------------------------------------
    File        : TestForm
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : bronco
    Created     : Mon Jan 27 17:04:53 CET 2014
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.



class bfv.designpatterns.decorator.treeview.TestForm inherits Form: 
	
  define private variable bfvTreeview1 as bfv.designpatterns.decorator.treeview.BfvTreeview no-undo.
	define private variable components as System.ComponentModel.IContainer no-undo.

/*	define private variable treecomp as*/
		
	constructor public TestForm (  ):
		
		
    super().
    InitializeComponent().
    
    initUI().
    
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

	end constructor.

	method private void InitializeComponent(  ):
		
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
    this-object:bfvTreeview1 = new bfv.designpatterns.decorator.treeview.BfvTreeview().
    this-object:SuspendLayout().
    /*  */
    /* bfvTreeview1 */
    /*  */
    this-object:bfvTreeview1:BorderStyle = System.Windows.Forms.BorderStyle:FixedSingle.
    this-object:bfvTreeview1:Location = new System.Drawing.Point(87, 55).
    this-object:bfvTreeview1:Name = "bfvTreeview1".
    this-object:bfvTreeview1:Size = new System.Drawing.Size(239, 199).
    this-object:bfvTreeview1:TabIndex = 0.
    /*  */
    /* TestForm */
    /*  */
    this-object:ClientSize = new System.Drawing.Size(608, 367).
    this-object:Controls:Add(this-object:bfvTreeview1).
    this-object:Name = "TestForm".
    this-object:Text = "TestForm".
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
	end method.

	destructor public TestForm ( ):

	end destructor.
  
  method private void initUI():
    
    
  end method. 
  
end class.