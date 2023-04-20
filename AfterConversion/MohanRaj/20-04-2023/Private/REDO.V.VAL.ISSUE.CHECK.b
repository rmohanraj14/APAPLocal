* @ValidationCode : MjoxNTM3NjY1MDU1OkNwMTI1MjoxNjgxOTcwNjQyNjAzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:34:02
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
SUBROUTINE REDO.V.VAL.ISSUE.CHECK
*---------------------------------------------------------------------------
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.V.VAL.ISSUE.CHECK
* ODR NO      : ODR-2009-12-0285
*----------------------------------------------------------------------
*DESCRIPTION: This routine is validation routine to STATUS field in
* REDO.ADMIN.CHQ.DETAILS,REVOKE.PAY
* REDO.MANAGER.CHQ.DETAILS,REVOKE.PAY



*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: REDO.ADMIN.CHQ.DETAILS
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*19.02.2010  H GANESH     ODR-2009-12-0285  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
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
    Y.STATUS=COMI
    IF Y.STATUS NE 'ISSUED' THEN
        IF APPLICATION EQ 'REDO.ADMIN.CHQ.DETAILS' THEN
            AF=ADMIN.CHQ.DET.STATUS
        END
        IF APPLICATION EQ 'REDO.MANAGER.CHQ.DETAILS' THEN
            AF=MAN.CHQ.DET.STATUS
        END
        ETEXT='EB-ISSUED.ONLY.ALLOW'
        CALL STORE.END.ERROR
    END
RETURN
END
