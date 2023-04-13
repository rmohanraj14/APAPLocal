* @ValidationCode : MjotNzcwMjkxOTczOkNwMTI1MjoxNjgxMzg4OTM2NTY1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:58:56
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
SUBROUTINE  REDO.V.INP.ARC.MAND.OVERRIDE
*-------------------------------------------------------------------------
*DESCRIPTION:
*------------


* INPUT/OUTPUT:
*--------------

* OUT : N/A

* DEPENDDENCIES:
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER
    $INSERT I_F.ACCOUNT
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.STANDING.ORDER
    GOSUB PROCESS
RETURN

*~~~~~~~~~~~~~~~
PROCESS:
*~~~~~~~~~~~~~~~

    TEXT  = 'EB-MINIMUM.SIGNATORY.NOT.REACHED'      ;* Set TEXT for Override
    CALL STORE.OVERRIDE(CURR.NO)          ;* Raise the Override

RETURN
END
