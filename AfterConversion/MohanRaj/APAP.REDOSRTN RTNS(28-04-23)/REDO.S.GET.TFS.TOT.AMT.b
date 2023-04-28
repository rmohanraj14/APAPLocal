* @ValidationCode : MjotNDQzMTAyMDk1OkNwMTI1MjoxNjgyNjYwMDIyMjQ1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 28 Apr 2023 11:03:42
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
$PACKAGE APAP.REDOSRTN
*-----------------------------------------------------------------------------
* <Rating>-1</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.S.GET.TFS.TOT.AMT(Y.TOTAL.AMT)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.GET.TFS.TOT.AMT
*---------------------------------------------------------------------------------

*DESCRIPTION       :This routine is to get the total amount for TFS transaction
*
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   VM TO @VM
* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.T24.FUND.SERVICES


    Y.INIT.TXN = 1
    Y.TXN.AMT = 0
    Y.TOTAL.AMT = 0
    TXN.LIST = R.NEW(TFS.TRANSACTION)
    Y.TXN.COUNT = DCOUNT(TXN.LIST,@VM) ;*R22 Manual code conversion

    LOOP
        REMOVE Y.TXN.ID FROM TXN.LIST SETTING Y.TXN.POS
    WHILE Y.INIT.TXN LE Y.TXN.COUNT
        IF Y.TXN.ID NE 'NET.ENTRY' THEN
            Y.TXN.AMT = R.NEW(TFS.AMOUNT)<1,Y.INIT.TXN>
            Y.TOTAL.AMT += Y.TXN.AMT
        END
        Y.INIT.TXN++
    REPEAT

RETURN
END
