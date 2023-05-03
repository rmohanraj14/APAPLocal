* @ValidationCode : MjotMzUyMzk0NTMyOkNwMTI1MjoxNjgxNzM0MDAyNjczOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:50:02
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
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.INP.SUP.OVR.AI

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER

    POS.FM.OVER = ''
    POS.VM.OVER = ''

*    FINDSTR 'TRANSACCION PENDIENTE DE AUTORIZACION' IN OFS$OVERRIDES SETTING POS.FM.OVER,POS.VM.OVER THEN
*        DEL OFS$OVERRIDES<1,POS.VM.OVER>
*        DEL OFS$OVERRIDES<2,POS.VM.OVER>
*    END

    T.OV.CLASS  = ''

RETURN
