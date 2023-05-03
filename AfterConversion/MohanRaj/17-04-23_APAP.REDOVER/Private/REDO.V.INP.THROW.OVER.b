* @ValidationCode : MjoxNjgyOTE3MTk3OkNwMTI1MjoxNjgxNzM0MTExNzk0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:51:51
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
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.INP.THROW.OVER
*---------------------------------------------------------------------------
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.V.INP.THROW.OVER
* ODR NO      : ODR-2009-12-0285
*----------------------------------------------------------------------
*DESCRIPTION: This routine is Input routine attached to REDO.ADMIN.CHQ.DETAILS,REVOKE.PAY
* To throw Override




*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: REDO.ADMIN.CHQ.DETAILS & REDO.MANAGER.CHQ.DETAILS
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*19.02.2010  H GANESH     ODR-2009-12-0285  INITIAL CREATION
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ADMIN.CHQ.DETAILS
    $INSERT I_F.REDO.MANAGER.CHQ.DETAILS

    GOSUB PROCESS
RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

    IF APPLICATION EQ 'REDO.ADMIN.CHQ.DETAILS' THEN
        CURR.NO=DCOUNT(R.NEW(ADMIN.CHQ.DET.OVERRIDE),@VM) + 1
    END
    IF APPLICATION EQ 'REDO.MANAGER.CHQ.DETAILS' THEN

        CURR.NO=DCOUNT(R.NEW(MAN.CHQ.DET.OVERRIDE),@VM) + 1
    END
    IF C$SPARE(110) EQ '' THEN
        TEXT='REVOKE.STOP.PAYMENT'
        CALL STORE.OVERRIDE(CURR.NO)
        C$SPARE(110) = 'REVOKE.STOP.PAYMENT'
    END
RETURN

END
