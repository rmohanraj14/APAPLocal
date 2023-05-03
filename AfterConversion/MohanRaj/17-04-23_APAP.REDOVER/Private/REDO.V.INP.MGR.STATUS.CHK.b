* @ValidationCode : MjoyMDI1NTM2ODEwOkNwMTI1MjoxNjgxNzI5NDI2MjgxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:33:46
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
SUBROUTINE  REDO.V.INP.MGR.STATUS.CHK
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as the validation routine for the versions REDO.MGR.CHQ.DETAILS,STOP.PAY
*

*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date               who           Reference            Description
*   ~~~~               ~~~           ~~~~~~~~~            ~~~~~~~~~~~
* 12-May-2010      Bharath G         ODR-2010-03-0447     Initial Creation
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.MANAGER.CHQ.DETAILS

    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------
PROCESS:
    IF R.OLD(MAN.CHQ.DET.STATUS) EQ 'PAID' OR R.OLD(MAN.CHQ.DET.STATUS) EQ 'CANCELLED' OR R.OLD(MAN.CHQ.DET.STATUS) EQ 'REISSUED' OR R.OLD(MAN.CHQ.DET.STATUS) EQ 'REINSTATED' THEN
        IF R.NEW(MAN.CHQ.DET.STATUS) EQ 'STOP.PAID.CNFRM' OR R.NEW(MAN.CHQ.DET.STATUS) EQ 'STOP.PAID.NON.CNFRM' THEN
            AF=MAN.CHQ.DET.STATUS
            ETEXT='EB-REDO.ADMIN.BLOCK':@FM:R.OLD(MAN.CHQ.DET.STATUS)
            CALL STORE.END.ERROR
        END
    END
RETURN
END
