* @ValidationCode : Mjo1NTczNTM0MDM6Q3AxMjUyOjE2ODAxODc3NTc5ODA6SVRTUzotMTotMToxOTM6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 193
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.OVERPAYMENT.LOAD
*-------------------------------------------------
*Description: This batch routine is to post the FT OFS messages for overpayment
*             and also to credit the interest in loan.
*-------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       No changes
* 29-MAR-2023      Harishvikram C     Manual R22 conversion     No changes

*-------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_REDO.B.AA.OVERPAYMENT.COMMON

    GOSUB PROCESS
RETURN
*-------------------------------------------------
PROCESS:
*-------------------------------------------------

    FN.REDO.AA.OVERPAYMENT = 'F.REDO.AA.OVERPAYMENT'
    F.REDO.AA.OVERPAYMENT  = ''
    CALL OPF(FN.REDO.AA.OVERPAYMENT,F.REDO.AA.OVERPAYMENT)

    FN.REDO.AA.OVERPAYMENT.PARAM = 'F.REDO.AA.OVERPAYMENT.PARAM'
    F.REDO.AA.OVERPAYMENT.PARAM  = ''
    CALL OPF(FN.REDO.AA.OVERPAYMENT.PARAM,F.REDO.AA.OVERPAYMENT.PARAM)

    CALL CACHE.READ(FN.REDO.AA.OVERPAYMENT.PARAM,'SYSTEM',R.REDO.AA.OVERPAYMENT.PARAM,F.REDO.AA.OVERPAYMENT.PARAM)

RETURN
END
