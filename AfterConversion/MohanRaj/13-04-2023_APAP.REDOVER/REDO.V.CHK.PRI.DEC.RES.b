* @ValidationCode : MjotMjE1Mzg2NzA3OkNwMTI1MjoxNjgxMzkwMzQ2OTI5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:22:26
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.CHK.PRI.DEC.RES
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This routine is attached as validation routine for the field Arrangement in FUNDS.TRANSFER,AA.LS.LC.ACPD
* This routine checks whether any PRINCIPAL DECREASE restriction exists on the arrangement
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : REDO.V.DEF.FT.LOAN.STATUS.COND, REDO.V.CHK.NO.OVERDUE
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 07-JUN-2010   N.Satheesh Kumar   ODR-2009-10-0331      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON


    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END
    IF OFS$OPERATION EQ 'VALIDATE' THEN
        RETURN
    END
*Return in Commit stage
    IF cTxn_CommitRequests EQ '1' THEN
        RETURN
    END



    ARR.ID =  ECOMI
    PROP.CLASS = 'ACTIVITY.RESTRICTION'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    EFF.DATE = ''
    CALL APAP.REDOVER.REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified

    IF R.Condition NE '' THEN
        V$ERROR = 1
        MESSAGE = 'ERROR'
        ETEXT = "En este momento su transaccisn no puede ser realizada, favor contactar  Servicio al Cliente al Telif. 809-687-2727. "
        ETEXT := "(estos mensajes deben poder mantenerse)"
        CALL STORE.END.ERROR
    END ELSE
        CALL APAP.REDOVER.REDO.V.DEF.FT.LOAN.STATUS.COND ;* R22 Manual Conversion - CALL method format modified
        CALL APAP.REDOVER.REDO.V.CHK.NO.OVERDUE ;* R22 Manual Conversion - CALL method format modified
    END
RETURN

END
