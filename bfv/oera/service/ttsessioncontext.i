
/*------------------------------------------------------------------------
    File        : ttsessioncontext.i
    Purpose     : Keep track of active context data for the local session.
    			  The local session is the session where the Context Manager
    			  object is running in.

    Syntax      :

    Description : Session Context TEMP-TABLE Definition

    Author(s)   : rvkanten
    Created     : Mon Jun 25 17:18:03 CEST 2007
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

DEFINE TEMP-TABLE ttSessionContext NO-UNDO

    FIELD sctx-id              AS CHARACTER        /* FlatGUID								*/
                               LABEL "ContextID"
    FIELD sctx-nm              AS CHARACTER        /* Any Name								*/
                               LABEL "ContextName"
    FIELD sctx-ch-wrde         AS CHARACTER        /* Value in char format					*/
                               LABEL "ContextValue"
    FIELD sctx-blob            AS BLOB             /* Object 'serialized'   				*/
                               LABEL "ContextObject"
    FIELD sctx-nr-bytes        AS INT64            /* Number of bytes used to store object	*/
                               LABEL "ContextObjectSize"
    FIELD sctx-nr-bereik       AS INTEGER          /* Scope of the context data				*/
                               LABEL "ContextScope"
    FIELD sctx-ch-sessie       AS CHARACTER        /* ID for session identification			*/
                               LABEL "ContextSessionID"
    FIELD sctx-cd-gebr         AS CHARACTER        /* ID for user identification			*/
                               LABEL "ContextUserID"
    FIELD sctx-ch-conn         AS CHARACTER        /* ID for connection identification		*/
                               LABEL "ContextConnectionID"
    FIELD sctx-ch-groep        AS CHARACTER        /* ID for grouping context information	*/
                               LABEL "ContextGroup"
    FIELD sctx-dz-eint         AS DATETIME-TZ      /* Date-Time until when data is valid	*/
                               LABEL "ContextTTL"

    INDEX xpkContextID         IS PRIMARY UNIQUE sctx-id
    INDEX xieName              sctx-nm
    INDEX xieSession           sctx-ch-sessie
    INDEX xieUser              sctx-cd-gebr
    INDEX xieConnection        sctx-ch-conn
    INDEX xieGroup             sctx-ch-groep
    .

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
