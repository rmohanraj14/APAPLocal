* @ValidationCode : MjotOTI0NzU2Mjg0OkNwMTI1MjoxNjgxNzMyMzA3OTU0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:21:47
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
SUBROUTINE REDO.V.INP.PREV.COMP.UNCLOSED
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
* PROGRAM NAME : REDO.V.INP.PREV.COMP.UNCLOSED
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
    $INSERT I_F.REDO.ISSUE.COMPLAINTS

    GOSUB INIT
    GOSUB PROCESS
RETURN
*****
INIT:
*****
    FN.REDO.ISSUE.COMPLAINTS  = 'F.REDO.ISSUE.COMPLAINTS'
    F.REDO.ISSUE.COMPLAINTS   = ''
    CALL OPF(FN.REDO.ISSUE.COMPLAINTS,F.REDO.ISSUE.COMPLAINTS)

RETURN

********
PROCESS:
********
    Y.CUS.ID           = R.NEW(ISS.COMP.CUSTOMER.CODE)
    Y.PRODUCT.TYPE     = R.NEW(ISS.COMP.PRODUCT.TYPE)
    Y.TYPE             = R.NEW(ISS.COMP.TYPE)
    Y.TXN.AMOUNT       = R.NEW(ISS.COMP.TRANSACTION.AMOUNT)
    SEL.CMD = "SELECT ":FN.REDO.ISSUE.COMPLAINTS:" WITH CUSTOMER.CODE EQ ":Y.CUS.ID
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,RET.CODE)
    LOOP
        REMOVE Y.CL.ID FROM SEL.LIST SETTING COMP.POS
    WHILE Y.CL.ID:COMP.POS
        CALL F.READ(FN.REDO.ISSUE.COMPLAINTS,Y.CL.ID,R.REDO.ISSUE.COMPLAINTS,F.REDO.ISSUE.COMPLAINTS,COMP.ERR)
        IF R.REDO.ISSUE.COMPLAINTS THEN
            Y.COMP.PRODUCT.TYPE = R.REDO.ISSUE.COMPLAINTS<ISS.COMP.PRODUCT.TYPE>
            Y.COMP.TYPE         = R.REDO.ISSUE.COMPLAINTS<ISS.COMP.TYPE>
            Y.COMP.TXN.AMT      = R.REDO.ISSUE.COMPLAINTS<ISS.COMP.TRANSACTION.AMOUNT>
        END
        IF R.NEW(ISS.COMP.STATUS) EQ "OPEN" THEN
            IF Y.PRODUCT.TYPE EQ Y.COMP.PRODUCT.TYPE AND Y.TYPE EQ Y.COMP.TYPE AND Y.TXN.AMOUNT EQ Y.COMP.TXN.AMT THEN
                CURR.NO=DCOUNT(R.NEW(ISS.COMP.OVERRIDE),@VM)+1
                TEXT = "REDO-PRODUCT.AND.AMT.SAME"
                CALL STORE.OVERRIDE(CURR.NO)
            END
        END
    REPEAT
RETURN
END
