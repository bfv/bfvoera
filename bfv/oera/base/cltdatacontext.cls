/* cltdatacontext.cls: This is the client-side support class for context
   information. It uses an include file that defines a standard set of 
   methods (some of which are basic to the handling of context and 
   therefore are specified in an interface for the class) along with
   the context DataSet. As used on the client side, the DataSet is *not*
   REFERENCE-ONLY -- it holds the actual context data to be passed to the
   Service Provider on the server.
 */
USING bfv.oera.interfaces.*.
 
CLASS bfv.oera.base.cltdatacontext
  IMPLEMENTS idatacontext
  USE-WIDGET-POOL :

    /* This is the context DataSet instance created on the client: */
    {bfv/oera/base/dscontext.i}

    /* This handle is defined to allow the client to extract the DataSet
       to pass to the Service Interface. */
    DEFINE PUBLIC PROPERTY dsContext AS HANDLE NO-UNDO
        GET.    /* Others should be able to read the property value... */
        PRIVATE SET.    /* ... but not set it. This is done below. */
      
    CONSTRUCTOR PUBLIC cltdatacontext():
      dsContext = DATASET dsContext:HANDLE.
    END CONSTRUCTOR.

	/*------------------------------------------------------------------------------
			Purpose:  																	  
			Notes:  																	  
	------------------------------------------------------------------------------*/
	DESTRUCTOR PUBLIC cltdatacontext ( ):
	    
        DATASET dsContext:EMPTY-DATASET().
	END DESTRUCTOR.

 {bfv/oera/base/datacontext.i}

 END CLASS.

   
