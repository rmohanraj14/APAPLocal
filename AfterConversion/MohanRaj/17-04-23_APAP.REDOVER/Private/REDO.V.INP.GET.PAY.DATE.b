* @ValidationCode : MjotMzMwMTc3MDk0OkNwMTI1MjoxNjgxNzI5MTQwNDU1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:29:00
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
SUBROUTINE REDO.V.INP.GET.PAY.DATE
*-----------------------------------------------------------------
* Company Name  : APAP DEV2
* Developed By  : Marimuthu S
* Program Name  : REDO.V.INP.GET.PAY.DATE
*-----------------------------------------------------------------
* Description : This routine will get trigger while lending-applypayment, to store the paid date
*-----------------------------------------------------------------
* Linked With   : -NA-
* In Parameter  : -NA-
* Out Parameter : -NA-
*-----------------------------------------------------------------
* Modification History :
*-----------------------
* Reference              Date                Description
* ODR-2011-12-0017      17-MAR-2012          Initial draft
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON

    FN.REDO.GET.REPAID.DATE = 'F.REDO.GET.REPAID.DATE'
    F.REDO.GET.REPAID.DATE = ''
    CALL OPF(FN.REDO.GET.REPAID.DATE,F.REDO.GET.REPAID.DATE)

    Y.ARR.ID = c_aalocArrId
    Y.REPAY.DTE = c_aalocActivityEffDate

    CALL F.WRITE(FN.REDO.GET.REPAID.DATE,Y.ARR.ID,Y.REPAY.DTE)

RETURN

END
