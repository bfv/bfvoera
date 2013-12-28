/*------------------------------------------------------------------------
    File        : iservicemgr
    Purpose     : 
    Syntax      : 
    Description : Interface definition of a Service Manager
    Author(s)   : 
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

  INTERFACE bfv.oera.interfaces.iservicemgr: 
      METHOD PUBLIC VOID startServices().
      METHOD PUBLIC VOID stopServices().
      METHOD PUBLIC progress.lang.object startService 
          (pcServiceName AS CHARACTER, pcComponentType AS CHARACTER). 
      METHOD PUBLIC CHARACTER getServiceFile
          (pcServiceName AS CHARACTER, pcComponentType AS CHARACTER).
      METHOD PUBLIC VOID stopService(oObject AS progress.lang.object).
  END INTERFACE.
