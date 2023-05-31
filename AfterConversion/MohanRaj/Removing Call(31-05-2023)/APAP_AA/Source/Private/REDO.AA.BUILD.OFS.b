$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.BUILD.OFS(ARR.ID,R.PROPERTY.COND,Y.PROP.ACTIVITY,OFS.MSG)

*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.AA.BUILD.OFS
*--------------------------------------------------------------------------------
* Description: This is call routine to build the OFS message for AA.ARRANGEMENT.ACTIVITY
* Input Arguments
* ARR.ID               -> Arrangement ID
* R.PROPERTY.COND      -> Product Condition record
* Y.PROP.ACTIVITY<1>   -> Property
* Y.PROP.ACTIVITY<2>   -> Activity
* Output Arguments
* OFS.MSG              -> OFS Message
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE                    DESCRIPTION
* 01-Jun-2011    H GANESH    PACS00032743 & PACS00055013    INITIAL CREATION
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023        Conversion Tool                    R22 Auto Code Conversion             FM to @FM 
*
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS

RETURN
*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------
    Y.PROPERTY = Y.PROP.ACTIVITY<1>
    Y.ACTIVITY = Y.PROP.ACTIVITY<2>

    CHANGE ',' TO '?' IN R.PROPERTY.COND

    APP.NAME = 'AA.ARR.INTEREST'
    OFSFUNCT=''
    PROCESS  = ''
    OFSVERSION = ''
    GTSMODE = ''
    TRANSACTION.ID=''
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    NO.OF.AUTH=0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.PROPERTY.COND,OFSRECORD)
    CHANGE ',' TO @FM IN OFSRECORD ;*R22 Auto Code Conversion
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    FIELD.COUNT=DCOUNT(OFSRECORD,@FM) ;*R22 Auto Code Conversion
    OFS.STRING=''
    VAR2=1
    LOOP
    WHILE VAR2 LE FIELD.COUNT
        IF OFSRECORD<VAR2> THEN
            OFS.STRING:='FIELD.NAME:1:':VAR2:'=':FIELD(OFSRECORD<VAR2>,'=',1):','
            OFS.STRING:='FIELD.VALUE:1:':VAR2:'=':FIELD(OFSRECORD<VAR2>,'=',2):','
        END
        VAR2 += 1 ;*R22 Auto Code Conversion
    REPEAT

    OFS.MSG="AA.ARRANGEMENT.ACTIVITY,APAP/I/PROCESS,,,ARRANGEMENT:1:1=":ARR.ID:",ACTIVITY:1:1=":Y.ACTIVITY:',PROPERTY:1:1=':Y.PROPERTY:',':OFS.STRING

RETURN
END
