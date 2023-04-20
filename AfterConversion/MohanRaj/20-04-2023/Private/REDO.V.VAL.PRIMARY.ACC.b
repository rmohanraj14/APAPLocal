* @ValidationCode : MjotNTIyNDM3NTg3OkNwMTI1MjoxNjgxOTczNzE2OTQwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:25:16
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
SUBROUTINE REDO.V.VAL.PRIMARY.ACC
*-----------------------------------------------------
*Decsription: This validation routine validates the entered account no.
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT

    GOSUB PROCESS
RETURN
*-----------------------------------------------------
PROCESS:
*-----------------------------------------------------

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT =  ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.ACC.NO = COMI
    CALL F.READ(FN.ACCOUNT,Y.ACC.NO,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    IF R.ACCOUNT THEN
        Y.ARR.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        IF Y.ARR.ID THEN          ;* If it is a Loan Acc No. then error.
            ETEXT = 'EB-REDO.LOAN.ACC.NOT.ALLOWED'
            CALL STORE.END.ERROR
        END
        Y.AZ.PROD = R.ACCOUNT<AC.ALL.IN.ONE.PRODUCT>
        IF Y.AZ.PROD THEN
            ETEXT = 'EB-REDO.DEPOSIT.ACC.NOT.ALLOWED'
            CALL STORE.END.ERROR
        END
    END
RETURN
END
