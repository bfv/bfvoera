
/* Het implementeren van IDisposable geeft de mogelijkheid om een 
 * "gracefull" end te programmeren. Dit kan niet altijd in de destrcutor.
 */
 
interface bfv.lib.system.IDisposable:  
  
  method public void Dispose().
  
end interface.