
using bfv.oera.base.DataContext.

/* srvdatacontext.cls: Helper class to manipulate the data context dataset.
   This version used by the Service Provider components (in particular the
   Data ACcess Object) contains all the methods from the client version
   plus some additional methods used in processing where clauses and
   other server-side behavior. Its context DataSet definition is done
   REFERENCE-ONLY because the actual DataSet instance is passed from the
   client. */
   
class bfv.oera.base.srvdatacontext inherits DataContext use-widget-pool :
  
  /* Helper table for applyContext */
  define temp-table ttSubst no-undo
    field substStart as integer
    field substEnd   as integer
    field substParam as character
    field queryTable as character
    index substStart is primary unique substStart.
    
  method public void bindContext(input DATASET for dsContext bind).
  /* The BIND associates this dataset definition with the caller's 
     dataset instance. */
  end method.

  method public character applyContext(
    pcQuery as character,
    pcTables as character,
    pcMap    as character):
    /* Apply the context as provided in the dataset dsContext to the query defined in pcQuery
     * The following context is supported:
     * FILTER  <ttTableName>.<ttFieldName> <operator> <value> - Filter condition will be added to the query 
     * PARAM   <parameterName> <value>                        - Parameter in the form $[parameterName] will be replaced with the value */
  
    define variable iPos1     as integer   no-undo.
    define variable iPos2     as integer   no-undo.
    define variable iPosA     as integer   no-undo.
    define variable iPosB     as integer   no-undo.
    define variable iTable    as integer   no-undo.
    define variable iPosWhere as integer   no-undo.
    define variable iPosEach  as integer   no-undo.
    define variable iPosFirst as integer   no-undo.
    define variable iPosLast  as integer   no-undo.
    define variable iLength   as integer   no-undo.
    define variable cFilter   as character extent 100 no-undo.
    define variable cField    as character no-undo.
    define variable cTable    as character no-undo.
  
    /* Create a list with all substitutions */
    empty temp-table ttSubst.
    assign 
      pcQuery = replace(pcQuery, '~n':U, ' ':U)
      pcQuery = replace(pcQuery, '~r':U, ' ':U)
      pcQuery = replace(pcQuery, '~t':U, ' ':U).
  
    /* Figure out position of the modifications places */
    assign 
      iPos1 = index(pcQuery, '$[':U).
    do while iPos1 > 0:
      assign 
        iPos2 = index(pcQuery, ']':U, iPos1 + 2).
      if iPos2 = 0 then 
        leave.
      
      create ttSubst.
      assign 
        substStart = iPos1
        substEnd   = iPos2 + 1
        substParam = substring(pcQuery, iPos1 + 2, iPos2 - iPos1 - 2)
        iPos1      = index(pcQuery,  '$[':U, iPos2 + 1).
    end.
  
    /* Figure out the position of the additional conditions
     * - If there is a WHERE, immediately after the "WHERE"
     * - If there is no WHERE immediately after the "[FIRST|EACH|LAST] buffer"
     */
    do on error undo, leave:
      assign 
        iLength = length(pcQuery)
        iPos1   = index(pcQuery, ' EACH ':U).
      if iPos1 = 0 then
        leave.
      assign 
        iPos1 = iPos1 + 6.
      do iTable = 1 to num-entries(pcTables):
        assign 
          iPosWhere = index(pcQuery,' WHERE ':U, iPos1)
          iPosFirst = index(pcQuery,'FIRST ':U , iPos1)
          iPosLast  = index(pcQuery,'LAST ':U  , iPos1)
          iPosEach  = index(pcQuery,'EACH ':U  , iPos1).
        iPos2     = minimum((if iPosFirst = 0 
          then iLength 
          else iPosFirst),
          (if iPosLast  = 0 
          then iLength 
          else iPosLast),
          (if iPosEach  = 0 
          then iLength 
          else iPosEach)).
        if iPosWhere > 0 and iPosWhere < iPos2 then 
        do:
          create ttSubst.
          assign 
            substStart = iPosWhere
            substEnd   = substStart + 6
            substParam = 'WHERE':U
            queryTable = entry(iTable, pcTables).
        end.
        else 
        do:
          /* Skip buffername */
          assign 
            iPosA = index(pcQuery, ' ':U, iPos1)
            iPosB = index(pcQuery, ',':U, iPos1)
            iPos1 = if iPosA > 0 and iPosA < iPosB 
                    then iPosA
                    else iPosB.
          if iPos1 = 0 then 
            iPos1 = length(pcQuery) + 1.
          create ttSubst.
          assign 
            substStart = iPos1
            substEnd   = iPos1
            substParam = ''
            queryTable = entry(iTable, pcTables).
        end.
        if iPos2 > 0 then
          assign iPos1 = index(pcQuery, ' ':U, iPos2) + 1.
      end.
    end.
  
    /* Prepare the conditions to be inserted or added */
    for each ttContext where ttContext.contextGroup = 'FILTER':U:
        
      cField = mappedField(ttContext.contextName, pcMap).      
      if cField = ? then
        next.
      assign 
        iTable          = lookup(entry(1, cField, '.':U), pcTables)
        cFilter[iTable] = substitute('&1 AND &2 &3 &4':U,
                                            cFilter[iTable],
                                            cField,
                                            ttContext.contextOperator,
                                            quoter(ttContext.contextValue)).
        
    end.
  
    do iTable = num-entries(pcTables) to 1 by -1:
      assign 
        cFilter[iTable] = substring(cFilter[iTable], 6).
      if cFilter[iTable] <> '' then
        assign cFilter[iTable] = '(':U + cFilter[iTable] + ')':U.
    end.
  
    /* Actual substition, backwards since we have to mess with the query string and we don't
     * want to mess with the position we have to work later on */
    for each ttSubst by substStart descending:
      if ttSubst.queryTable = '' then 
      do: /* It is parameter */
        find ttContext
          where ttContext.contextGroup    = 'PARAM':U          and 
          ttContext.contextName     = ttSubst.substParam and 
          ttContext.contextOperator = ''
          no-lock no-error. 
        if not available ttContext then
          /* This should be a call to fatalError */
          message 'Parameter not part of the query'.
        else
          assign substring(pcQuery, substStart, substEnd - substStart) = quoter(ttContext.contextValue).
      end.
      else 
      do: /* Here we have to fit-in the extra conditions */
        assign 
          iTable = lookup(ttSubst.queryTable, pcTables).
        if cFilter[iTable] <> '' then 
        do:
          assign 
            substring(pcQuery, substStart, substEnd - substStart) = ' WHERE ':U + cFilter[iTable] +
                                                                            if substParam = 'WHERE':U then 
                                                                               ' AND':U 
                                                                            else ' ':U.
        end.
      end.
      pcQuery = addSort (pcQuery).    
    end.
  
    return pcQuery.
  end method.
    
  method private character mappedField( pcField as character, pcMap as character).
    /* Translate the temp-table field name in a database field name based on the map */
    define variable cEntry     as character no-undo.
    define variable iEntry     as integer   no-undo.
    define variable numEntries as integer   no-undo.
    
    numEntries = num-entries(pcMap).
    do iEntry = numEntries - 1 to 1 by -2:
      if entry(iEntry, pcMap) = pcField then
        return entry(iEntry + 1, pcMap) .
    end.
    
    return ?.
  end method.

  method private character addSort (pcQuery as char):
   
    define variable iByPos        as integer   no-undo.
    define variable iIdxPos       as integer   no-undo.
    define variable iLength       as integer   no-undo.
    define variable lOk           as logical   no-undo.
    define variable cSort         as char      no-undo.
    define variable cTableName    as character no-undo.
    define variable iTablenamePos as integer   no-undo.
    define variable iSpace        as integer   no-undo.   
   
    if pcQuery <> '':U then 
    do:
      cSort = getContext(
        'OPTION', 
        'SORT':U,"") no-error.
      if cSort = ? or cSort = '':U or index(pcQuery, ' each ') = 0 then 
        return pcQuery.
  
      /* check if the sort is on the table in the query */
      assign
        /* extract tablename from pcQuery */
        iTablenamePos = index(pcQuery, ' each ') + length(' each ') /* you do not sort with first or last */
        iSpace        = index(pcQuery, ' ', iTablenamePos)
        cTableName    = trim(substring(pcQuery, iTablenamePos, if iSpace = 0 then (length(pcQuery) + 1 - iTablenamePos) else (iSpace - iTablenamePos)))
        cTableName    = if num-entries(cTableName,'.') = 2 /* preceding dbname */ then entry(2,cTableName,'.') else cTableName.
      /* Remove BY */ 
      cSort         = if cSort begins "BY ":U 
        then trim(substring(cSort,3)) 
        else cSort.
      /* is the sort on another table then return */             
      if index(cSort,'.') > 0 and trim(entry(1,cSort,'.')) <> cTableName then return pcQuery.      
                 
      assign                 
        /* check for indexed-reposition */
        iIdxPos                                  = index(right-trim(pcQuery,". ") + " ":U,
                        " INDEXED-REPOSITION ":U)          
  
        /* If there was no INDEX-REPOS we set the iLlength (where to end insert)
           to the end of where-clause. (right-trim periods and blanks to find 
           the true end of the expression)
           Otherwise iLength is the position of INDEX-REPOS. */
        iLength                                  = (if iIdxPos = 0 
                   then length(right-trim(pcQuery,". ":U)) + 1     
                   else iIdxPos)    
        
        /* Any By ? */ 
        iByPos                                   = index(pcQuery," BY ":U)             
        
        /* Now find where we should start the insert; 
           We might have both a BY and an INDEXED-REPOSITION 
           or only one of them or none. 
           Just make sure we use the MINIMUM of whichever of those if they
           are <> 0. */
  
        iByPos                                   = MIN(if iByPos  = 0 then iLength else iByPos,
                      if iIdxPos = 0 then iLength else iIdxPos) 
        
        SUBSTR (pcQuery,iByPos,iLength - iByPos) = " BY ":U + cSort.
    end. /* if pcQuery = '' */

    return pcQuery.
  end method.

  /*------------------------------------------------------------------------------
      Purpose:  																	  
      Notes:  																	  
  ------------------------------------------------------------------------------*/
  destructor public srvdatacontext ( ):
	    
    empty temp-table ttSubst.
  end destructor.


end class.
