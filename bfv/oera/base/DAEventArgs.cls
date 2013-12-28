 
 /*------------------------------------------------------------------------
    File        : DAEventArgs
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : rvkanten
    Created     : Wed Sep 15 15:51:36 CEST 2010
    Notes       : 
 ========================================================================
 $Log: /CURA91/bfv/oera/base/DAEventArgs.cls $
 
 1     15-09-10 16:27 Rvk
 T.b.v. publiceren van events vanuit dataaccessobject
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.System.EventArgs.

routine-level on error undo, throw.

class bfv.oera.base.DAEventArgs inherits EventArgs : 

	define public property RowState as integer no-undo get. set. 
	define public property BufferName as character no-undo get. set. 
	define public property BufferHandle as handle no-undo get. set. 

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public DAEventArgs (  ):
	    super().
	end constructor.


	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
		
	constructor public DAEventArgs (rowState as integer,  bufferName as character, bufferHandle as handle):
	     
		assign 
		  this-object:RowState     = rowState
		  this-object:BufferName   = bufferName
		  this-object:BufferHandle = bufferHandle 
		  .
		
	end constructor.

end class.