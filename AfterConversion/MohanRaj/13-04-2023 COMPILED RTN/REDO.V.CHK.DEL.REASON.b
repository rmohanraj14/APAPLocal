* @ValidationCode : Mjo0ODI3MTg0NjI6Q3AxMjUyOjE2ODEzODU1MTI4MjY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:01:52
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

SUBROUTINE REDO.V.CHK.DEL.REASON
*********************************************************************************************************
*Company   Name    : APAP Bank
*Developed By      : Temenos Application Management
*Program   Name    : REDO.V.CHK.DEL.REASON
*--------------------------------------------------------------------------------------------------------
*Description       : This routine will nullify Movement reason field
*In  Parameter     :
*Out Parameter     :
*Files  Used       : COLLATERAL             As          I Mode
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
* 04/05/2011    Kavitha            PACS00054322 B.180C          Bug Fix
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
*--------------------------------------------------------------------------------------------------------
**********
MAIN.PARA:
**********


    APPL.ARRAY = 'COLLATERAL'
    FLD.ARRAY  = 'L.CO.REASN.MVMT':@VM:'L.CO.DATE.MVMT'
    FLD.POS    = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)
    LOC.L.CO.MVMT  = FLD.POS<1,1>
    LOC.L.DATE.MVT = FLD.POS<1,2>


    CURR.NO = R.NEW(COLL.CURR.NO)

    IF PGM.VERSION EQ ",DOC.RECEPTION" THEN
        IF CURR.NO NE '' THEN
            R.NEW(COLL.LOCAL.REF)<1,LOC.L.CO.MVMT> = ""
            R.NEW(COLL.LOCAL.REF)<1,LOC.L.DATE.MVT> = TODAY
        END
    END

RETURN
*---------------------------------------------------------------------------------------------------------------------------
END
