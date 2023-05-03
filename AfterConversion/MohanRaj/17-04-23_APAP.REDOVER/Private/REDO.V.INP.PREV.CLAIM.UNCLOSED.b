* @ValidationCode : MjozMDk3OTkzOTg6Q3AxMjUyOjE2ODE3MzIwMzgzMDU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:17:18
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
SUBROUTINE REDO.V.INP.PREV.CLAIM.UNCLOSED
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : This Input routine is used to check if the CUSTOMER has
* any previous claims in the same PRODUCT & TYPE & TRANSACTIOn.AMOUNT. If the same claim exits
* then OVERRIDE is displayed
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RENUGADEVI B
* PROGRAM NAME : REDO.V.INP.PREV.CLAIM.UNCLOSED
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE              WHO                REFERENCE         DESCRIPTION
* 25-AUG-2010       RENUGADEVI B       ODR-2009-12-0283  INITIAL CREATION
* 30-AUG-2011       PRADEEP S          PACS00071941      Logic changed for unclosed claims validations
*                                                        Select stmt removed and concat file used
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.REDO.ISSUE.CLAIMS

    IF cTxn_CommitRequests EQ '1' AND OFS$OVERRIDES<2> NE 'YES' AND NOT(R.NEW(ISS.CL.OVERRIDE)) THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN

*****
INIT:
*****

    FN.REDO.CLAIM.OPEN = 'F.REDO.CRM.CLAIMS.OPEN'
    F.REDO.CLAIM.OPEN = ''
    CALL OPF(FN.REDO.CLAIM.OPEN,F.REDO.CLAIM.OPEN)

RETURN

********
PROCESS:
********

    Y.CUS.ID           = R.NEW(ISS.CL.CUSTOMER.CODE)
    Y.PRODUCT.TYPE     = R.NEW(ISS.CL.PRODUCT.TYPE)
    Y.TYPE             = R.NEW(ISS.CL.TYPE)
    Y.TXN.AMOUNT       = R.NEW(ISS.CL.TRANSACTION.AMOUNT)
    Y.ACCT.NO          = R.NEW(ISS.CL.ACCOUNT.ID)
    Y.CC.NO            = R.NEW(ISS.CL.CARD.NO)

    IF Y.ACCT.NO THEN
        Y.VALUE = Y.ACCT.NO:"*":Y.TXN.AMOUNT
    END

    IF Y.CC.NO THEN
        Y.VALUE = Y.CC.NO:"*":Y.TXN.AMOUNT
    END

*PACS00071941 - S
    Y.CLAIM.ID = Y.CUS.ID:"-":Y.PRODUCT.TYPE
    R.CLAIM.OPEN = ''
    CALL F.READ(FN.REDO.CLAIM.OPEN,Y.CLAIM.ID,R.CLAIM.OPEN,F.REDO.CLAIM.OPEN,ERR.OPEN)
    IF R.CLAIM.OPEN THEN
        Y.CLAIM.TXN.AMT = FIELDS(R.CLAIM.OPEN,"*",2,99)
        LOCATE Y.VALUE IN Y.CLAIM.TXN.AMT SETTING AMT.POS THEN
            CURR.NO=DCOUNT(R.NEW(ISS.CL.OVERRIDE),@VM)+1
            TEXT = "REDO-PRODUCT.AND.AMT.SAME"
            CALL STORE.OVERRIDE(CURR.NO)
        END
    END
*PACS00071941 - E

RETURN
END
