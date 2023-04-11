* @ValidationCode : MjoxNTI5MTYxNzQxOkNwMTI1MjoxNjgxMjE1MTQxNjQyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:21
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
SUBROUTINE REDO.S.OPERATION.TYPE(Y.OPERATION.TYPE)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Pradeep S
*Program   Name    :REDO.S.OPERATION.TYPE
*---------------------------------------------------------------------------------
*DESCRIPTION       :This program is used to get the branch code
*
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_REDO.DEAL.SLIP.COMMON

    GOSUB PROCESS
RETURN
**********
PROCESS:
**********

    Y.OPERATION.TYPE = VAR.RTE.POS<1>

    DEL VAR.RTE.POS<1>

RETURN
END
