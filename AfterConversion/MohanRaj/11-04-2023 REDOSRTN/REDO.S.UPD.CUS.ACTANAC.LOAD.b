* @ValidationCode : MjoxMzc0NDYzMzEwOkNwMTI1MjoxNjgxMjE1MzY2MzUzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:46:06
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
SUBROUTINE REDO.S.UPD.CUS.ACTANAC.LOAD

* Correction routine to update the file F.CUSTOMER.L.CU.ACTANAC
* It is one time service routine. It's not required for another migration environment
*------------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_REDO.S.UPD.CUS.ACTANAC.COMMON

    GOSUB INIT

RETURN

******
INIT:
******
*Initialise all the variable

    FN.CUS = 'F.CUSTOMER'
    F.CUS = ''
    CALL OPF(FN.CUS,F.CUS)

    FN.CUS.ACTANAC = 'F.CUSTOMER.L.CU.ACTANAC'
    F.CUS.ACTANAC = ''
    CALL OPF(FN.CUS.ACTANAC,F.CUS.ACTANAC)

    LRF.APP = 'CUSTOMER'
    LRF.FIELD = 'L.CU.ACTANAC'
    ACT.LRF.POS = ''
    CALL GET.LOC.REF(LRF.APP,LRF.FIELD,ACT.LRF.POS)

RETURN

END
