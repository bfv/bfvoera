/*------------------------------------------------------------------------
    File        : ttpatroon.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : shoutzag
    Created     : 15-5-2013
    Notes       :
  ----------------------------------------------------------------------*/
define {&access-mode} {&scope} temp-table ttpatroon{&ext} no-undo
  serialize-name "patroon"
  {&reference-only} 
  before-table btpatroon{&ext}  
  field resourcetype  as integer  
  field radioWeekdays as integer
  field weekdays      as integer
  field weekofmonth   as integer
  field month         as integer  
  field periodicity   as integer
  field dag-de        as integer
  field elke-de       as integer  
  field daynumber     as integer
  field zondag        as logical
  field maandag       as logical
  field dinsdag       as logical
  field woensdag      as logical
  field donderdag     as logical
  field vrijdag       as logical  
  field zaterdag      as logical   
  field id            as character
 .

