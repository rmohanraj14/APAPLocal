* @ValidationCode : Mjo5NTM5NDczNDg6Q3AxMjUyOjE2ODE3MzIzNTUwNDI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:22:35
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
SUBROUTINE REDO.V.INP.PREV.REQ.UNCLOSED
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
* PROGRAM NAME : REDO.V.INP.PREV.REQ.UNCLOSED
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE              WHO                REFERENCE         DESCRIPTION
* 25-AUG-2010       RENUGADEVI B       ODR-2009-12-0283  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.REQUESTS

    GOSUB INIT
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.REDO.ISSUE.REQUESTS  = 'F.REDO.ISSUE.REQUESTS'
    F.REDO.ISSUE.REQUESTS   = ''
    CALL OPF(FN.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS)

RETURN

********
PROCESS:
********
    Y.CUS.ID           = R.NEW(ISS.REQ.CUSTOMER.CODE)
    Y.PRODUCT.TYPE     = R.NEW(ISS.REQ.PRODUCT.TYPE)
    Y.TYPE             = R.NEW(ISS.REQ.TYPE)
    Y.TXN.AMOUNT       = R.NEW(ISS.REQ.TRANSACTION.AMOUNT)
    SEL.CMD = "SELECT ":FN.REDO.ISSUE.REQUESTS:" WITH CUSTOMER.CODE EQ ":Y.CUS.ID
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,RET.CODE)
    LOOP
        REMOVE Y.CL.ID FROM SEL.LIST SETTING REQ.POS
    WHILE Y.CL.ID:REQ.POS
        CALL F.READ(FN.REDO.ISSUE.REQUESTS,Y.CL.ID,R.REDO.ISSUE.REQUESTS,F.REDO.ISSUE.REQUESTS,REQ.ERR)
        IF R.REDO.ISSUE.REQUESTS THEN
            Y.REQ.PRODUCT.TYPE = R.REDO.ISSUE.REQUESTS<ISS.REQ.PRODUCT.TYPE>
            Y.REQ.TYPE         = R.REDO.ISSUE.REQUESTS<ISS.REQ.TYPE>
            Y.REQ.TXN.AMT      = R.REDO.ISSUE.REQUESTS<ISS.REQ.TRANSACTION.AMOUNT>
        END
        IF R.NEW(ISS.REQ.STATUS) EQ "OPEN" THEN
            IF Y.PRODUCT.TYPE EQ Y.REQ.PRODUCT.TYPE AND Y.TYPE EQ Y.REQ.TYPE AND Y.TXN.AMOUNT EQ Y.REQ.TXN.AMT THEN
                CURR.NO=DCOUNT(R.NEW(ISS.REQ.OVERRIDE),@VM)+1
                TEXT = "REDO-PRODUCT.AND.AMT.SAME"
                CALL STORE.OVERRIDE(CURR.NO)
            END
        END
    REPEAT
RETURN
END
