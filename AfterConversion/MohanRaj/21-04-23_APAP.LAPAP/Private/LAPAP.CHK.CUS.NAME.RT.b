* @ValidationCode : MjoxMjk2MzM2NDU4OkNwMTI1MjoxNjgyMDcwNjI5OTM4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:20:29
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CHK.CUS.NAME.RT

    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.TELLER

    GOSUB MAKE.NO.INPUT

RETURN

*------------
MAKE.NO.INPUT:
*------------
    LREF.POS   = ''
    LREF.FIELD = 'L.TT.CLIENT.NME'

    CALL MULTI.GET.LOC.REF('TELLER',LREF.FIELD,LREF.POS)
    POS.L.TT.CLIENT.NME = LREF.POS<1,1>

    T.LOCREF<POS.L.TT.CLIENT.NME,7> = 'NOINPUT'

RETURN

END
