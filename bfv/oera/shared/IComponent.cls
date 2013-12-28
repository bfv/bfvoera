/*------------------------------------------------------------------------
    File        : IComponent
    Purpose     : Interface definition for base OERA component.
    Syntax      : 
    Description : 
    @author pjudge
    Created     : Thu Feb 18 14:25:00 EST 2010
    Notes       : 
  ---------------------------------------------------------------------- */
interface bfv.oera.shared.IComponent: /* moet nog een goede plek voor komen */

    /** Not InitializeComponent, since the Gui for .NET uses that name already, 
       as a PRIVATE member, and we want to have only 1 IComponent interface. */
    method public void Initialize().
end interface.
  
