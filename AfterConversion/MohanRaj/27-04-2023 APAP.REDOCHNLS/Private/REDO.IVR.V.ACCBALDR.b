* @ValidationCode : Mjo5NTE2MzAzMTM6Q3AxMjUyOjE2ODE3MzM2OTI1NzE6SVRTUzotMTotMToxNzk6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 179
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.V.ACCBALDR
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :RMONDRAGON
*Program Name :REDO.IVR.V.ACCBALDR based on REDO.V.VAL.ACC by PRABHU.N
*---------------------------------------------------------------------------------
*DESCRIPTION :It is routine to validate if balance in debit account is enough
* to cover the credit amount.
*
*LINKED WITH :
*
* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
* Date who Reference Description
* 08-MAR-2013 RMONDRAGON ODR-2010-08-0031 Initial Version
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT

    GOSUB INIT
    GOSUB PROCESS

RETURN

*----
INIT:
*----

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    LREF.APP = 'ACCOUNT'
    LREF.FIELDS = 'L.AC.AV.BAL'
    LREF.POS=''
    CALL GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    L.AC.AV.BAL.POS=LREF.POS<1,1>

*-------
PROCESS:
*-------

    Y.DEBIT.ACCT = R.NEW(FT.DEBIT.ACCT.NO)
    Y.REQ.AMOUNT = COMI

    R.ACCOUNT = ''; ERR = ''
    CALL F.READ(FN.ACCOUNT,Y.DEBIT.ACCT,R.ACCOUNT,F.ACCOUNT,ERR)
    IF R.ACCOUNT THEN
        GOSUB CHECK.BALANCE
    END

RETURN

*-------------
CHECK.BALANCE:
*-------------

    VAR.ONLINE.BAL = R.ACCOUNT<AC.LOCAL.REF><1,L.AC.AV.BAL.POS>

    IF VAR.ONLINE.BAL LT Y.REQ.AMOUNT THEN
        ETEXT = 'EB-AMT.NOT.AVAIL'
        CALL STORE.END.ERROR
        RETURN
    END

RETURN

END
