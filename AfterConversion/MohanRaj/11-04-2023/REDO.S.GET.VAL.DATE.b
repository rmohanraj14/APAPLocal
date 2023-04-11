* @ValidationCode : MjoxMDMyMzk0NTcxOkNwMTI1MjoxNjgxMjE0OTQ4NDExOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:39:08
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
SUBROUTINE REDO.S.GET.VAL.DATE
*-------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.GET.VAL.DATE
*Reference Number  :ODR-2010-04-0424
*-------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the Opening date from Acco
*                   record and Value date from the AZ account record
*
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLOSURE
    $INSERT I_F.DATES
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ENQUIRY

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

OPEN.FILES:

    FN.AZ.ACCOUNT='F.AZ.ACCOUNT'
    F.AZ.ACCOUNT=''
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)

    FN.ACCOUNT.CLOSURE='F.ACCOUNT.CLOSURE'
    F.ACCOUNT.CLOSURE=''
    CALL OPF(FN.ACCOUNT.CLOSURE,F.ACCOUNT.CLOSURE)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN

PROCESS:
    REC.ID=O.DATA
    APPLN=R.ENQ<ENQ.FILE.NAME>
    IF APPLN EQ "AZ.ACCOUNT" THEN

        CALL F.READ(FN.AZ.ACCOUNT,REC.ID,R.AZ.ACCOUNT,F.AZ.ACCOUNT,AZ.ERR)
        VAR.DATE=R.AZ.ACCOUNT<AZ.VALUE.DATE>
        VAR.DATE=ICONV(VAR.DATE,"D2")
        O.DATA=OCONV(VAR.DATE,"D2")
    END
    ELSE
        IF APPLN EQ "ACCOUNT.CLOSURE" THEN
            CALL F.READ(FN.ACCOUNT,REC.ID,R.ACCOUNT,F.ACCOUNT,AC.ERR)
            VAR.DATE=R.ACCOUNT<AC.OPENING.DATE>
            VAR.DATE=ICONV(VAR.DATE,"D2")
            O.DATA=OCONV(VAR.DATE,"D2")
        END
    END

RETURN

END
