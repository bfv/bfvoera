
define temp-table ttSessionContext no-undo

    field sctx-id              as character        /* FlatGUID								*/
                               label "ContextID"
    field sctx-nm              as character        /* Any Name								*/
                               label "ContextName"
    field sctx-ch-wrde         as character        /* Value in char format					*/
                               label "ContextValue"
    field sctx-blob            as BLOB             /* Object 'serialized'   				*/
                               label "ContextObject"
    field sctx-nr-bytes        as int64            /* Number of bytes used to store object	*/
                               label "ContextObjectSize"
    field sctx-nr-bereik       as integer          /* Scope of the context data				*/
                               label "ContextScope"
    field sctx-ch-sessie       as character        /* ID for session identification			*/
                               label "ContextSessionID"
    field sctx-cd-gebr         as character        /* ID for user identification			*/
                               label "ContextUserID"
    field sctx-ch-conn         as character        /* ID for connection identification		*/
                               label "ContextConnectionID"
    field sctx-ch-groep        as character        /* ID for grouping context information	*/
                               label "ContextGroup"
    field sctx-dz-eint         as datetime-tz      /* Date-Time until when data is valid	*/
                               label "ContextTTL"

    index xpkContextID         is primary unique sctx-id
    index xieName              sctx-nm
    index xieSession           sctx-ch-sessie
    index xieUser              sctx-cd-gebr
    index xieConnection        sctx-ch-conn
    index xieGroup             sctx-ch-groep
    .
