* @ValidationCode : MjoxNzEyMzE4MTMyOkNwMTI1MjoxNjgxODE4NjY3MTg2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 17:21:07
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

*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.ACCOUNT.VP
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
*                TAM Latin America
* Client       : Asociacion Popular de Ahorro & Prestamo (APAP)
* Date         : 05.04.2013
* Description  : Routine for validating account details
* Type         : Validation Routine (attached to hotfield LR-27)
* Attached to  : VERSION > TELLER Vision Plus Versions
* Dependencies :
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date           Who            Reference         Description
* 1.0       04.30.2013     lpazmino       -                 Initial Version
*-----------------------------------------------------------------------------

* <region name="INSERTS">

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.ACCOUNT
    $INSERT I_F.TELLER

* </region>

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

* <region name="GOSUBS" description="Gosub blocks">

***********************
* Initialize variables
INIT:
***********************
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    Y.ERR = ''

    TT.APPLICATION = 'TELLER'
    TT.LOCAL.REF = 'LOCAL.REF'
    TT.LOCAL.FIELDS = ''
    TT.LOCAL.FIELDS.POS = ''

    TT.LOCAL.FIELDS<1,1> = 'L.TT.CR.ACCT.NO'

    CALL EB.FIND.FIELD.NO(TT.APPLICATION, TT.LOCAL.REF)
    CALL MULTI.GET.LOC.REF(TT.APPLICATION, TT.LOCAL.FIELDS, TT.LOCAL.FIELDS.POS)

* Obtain Credit Card Account from TT
    CR.ACCT.NO.POS = TT.LOCAL.FIELDS.POS<1,1>
    Y.ACCOUNT = R.NEW(TT.LOCAL.REF)<1,CR.ACCT.NO.POS>

    ACCT.APPLICATION = 'ACCOUNT'
    ACCT.LOCAL.REF = 'LOCAL.REF'
    ACCT.LOCAL.FIELDS = ''
    ACCT.LOCAL.FIELDS.POS = ''

    ACCT.LOCAL.FIELDS<1,1> = 'L.AC.STATUS1'
    ACCT.LOCAL.FIELDS<1,2> = 'L.AC.STATUS2'
    ACCT.LOCAL.FIELDS<1,3> = 'L.AC.NOTIFY.1'
    ACCT.LOCAL.FIELDS<1,4> = 'L.AC.AV.BAL'

    CALL EB.FIND.FIELD.NO(ACCT.APPLICATION, ACCT.LOCAL.REF)
    CALL MULTI.GET.LOC.REF(ACCT.APPLICATION, ACCT.LOCAL.FIELDS, ACCT.LOCAL.FIELDS.POS)

    AC.STATUS.1.POS = ACCT.LOCAL.FIELDS.POS<1,1>
    AC.STATUS.2.POS = ACCT.LOCAL.FIELDS.POS<1,2>
    AC.NOTIFY.1.POS = ACCT.LOCAL.FIELDS.POS<1,3>
    AC.AV.BAL.POS   = ACCT.LOCAL.FIELDS.POS<1,4>

RETURN

***********************
* Open Files
OPEN.FILES:
***********************
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN


***********************
* Main Process
PROCESS:
***********************
    CALL CACHE.READ(FN.ACCOUNT, Y.ACCOUNT, R.ACCOUNT, Y.ERR)

* Check Account Existence
    IF NOT(R.ACCOUNT) THEN
        ETEXT = 'ST-VP-NO.EXIST.ACCT' : @FM : Y.ACCOUNT
        AF = TT.LOCAL.REF
        AV = CR.ACCT.NO.POS

        CALL STORE.END.ERROR
    END ELSE
* Check Accout Balance
        GOSUB CHECK.ACCT.BALANCE
    END

RETURN


************************
* Check Account Balance
CHECK.ACCT.BALANCE:
************************
    TXN.PAYMENT.AMT = ''
    TXN.CURRENCY = R.NEW(TT.TE.CURRENCY.1)

    IF NOT(TXN.CURRENCY) THEN
        TXN.CURRENCY = R.NEW(TT.TE.CURRENCY.2)
        TXN.PAYMENT.AMT = R.NEW(TT.TE.AMOUNT.FCY.1)
    END ELSE
        IF TXN.CURRENCY EQ LCCY THEN
            TXN.PAYMENT.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)
        END ELSE
            TXN.PAYMENT.AMT = R.NEW(TT.TE.AMOUNT.FCY.1)
        END
    END

    Y.ACCT.BALANCE = R.ACCOUNT<ACCT.LOCAL.REF, AC.AV.BAL.POS>

    IF TXN.PAYMENT.AMT GT Y.ACCT.BALANCE THEN
        ETEXT = 'ST-VP-NO.AVAIL.BAL' : @FM : Y.ACCOUNT
        AF = TT.LOCAL.REF
        AV = CR.ACCT.NO.POS

        CALL STORE.END.ERROR
    END ELSE
* Check Account Status
        GOSUB CHECK.ACCT.STATUS
    END

RETURN


***********************
* Check Account Status
CHECK.ACCT.STATUS:
***********************
    Y.AC.STATUS.1 = R.ACCOUNT<ACCT.LOCAL.REF, AC.STATUS.1.POS>
    Y.AC.STATUS.2 = R.ACCOUNT<ACCT.LOCAL.REF, AC.STATUS.2.POS>
    Y.AC.NOTIFY.1 = R.ACCOUNT<ACCT.LOCAL.REF, AC.NOTIFY.1.POS>
    Y.AC.POST.RST = R.ACCOUNT<AC.POSTING.RESTRICT>


* Check L.AC.STATUS1
    IF Y.AC.STATUS.1 AND Y.AC.STATUS.1 NE 'ACTIVE' THEN
        Y.STATUS = Y.AC.STATUS.1
        GOSUB INVOKE.OVERRIDE
    END

* Check L.AC.STATUS2
    FIND 'DECEASED' IN Y.AC.STATUS.2 SETTING D.POS, D.VAL THEN
        Y.STATUS = 'DECEASED'
        GOSUB INVOKE.OVERRIDE
    END

    FIND 'GUARANTEE.STATUS' IN Y.AC.STATUS.2 SETTING GS.POS, GS.VAL THEN
        Y.STATUS = 'GUARANTEE.STATUS'
        GOSUB INVOKE.OVERRIDE
    END

* Check L.AC.NOTIFY.1
    FIND 'EMPLOYEE' IN Y.AC.NOTIFY.1 SETTING E.POS, E.VAL THEN
        Y.STATUS = 'EMPLOYEE'
        GOSUB INVOKE.OVERRIDE
    END

    FIND 'NOTIFY.OFFICER' IN Y.AC.NOTIFY.1 SETTING NO.POS, NO.VAL THEN
        Y.STATUS = 'NOTIFY.OFFICER'
        GOSUB INVOKE.OVERRIDE
    END

    FIND 'NOTIFY.MGMT.MONEY.LAUNDRY.PREV' IN Y.AC.NOTIFY.1 SETTING NAML.POS, NAML.VAL THEN
        Y.STATUS = 'NOTIFY.MGMT.MONEY.LAUNDRY.PREV'
        GOSUB INVOKE.OVERRIDE
    END

    FIND 'TELLER' IN Y.AC.NOTIFY.1 SETTING T.POS, T.VAL THEN
        Y.STATUS = 'TELLER'
        GOSUB INVOKE.OVERRIDE
    END

* Check posting restrict
    IF Y.AC.POST.RST THEN
        BEGIN CASE
* NO DEBITO
            CASE Y.AC.POST.RST EQ '1'
                GOSUB INVOKE.POSTING.ERR

* NO DEBITO NO CREDITO
            CASE Y.AC.POST.RST EQ 3
                GOSUB INVOKE.POSTING.ERR

* EMPLEADO-CAJERO
            CASE Y.AC.POST.RST EQ 4
                GOSUB INVOKE.POSTING.ERR
        END CASE
    END

RETURN

********************************
* Invoke Posting Restrict Error
INVOKE.POSTING.ERR:
********************************
    ETEXT = 'ST-VP-POST.REST.ACCT' : Y.ACCOUNT
    AF = TT.LOCAL.REF
    AV = CR.ACCT.NO.POS

    CALL STORE.END.ERROR

RETURN


***********************
* Invoke Override
INVOKE.OVERRIDE:
***********************
    TEXT = 'ST-VP-CHECK.ACCT.STATUS' : @FM : Y.ACCOUNT : @VM : Y.STATUS
    AF = TT.LOCAL.REF
    AV = CR.ACCT.NO.POS

    IF R.NEW(TT.TE.OVERRIDE) THEN
        Y.OV.POS = DCOUNT(R.NEW(TT.TE.OVERRIDE), @VM) + 1
    END ELSE
        Y.OV.POS = 1
    END

    CALL STORE.OVERRIDE(Y.OV.POS)

RETURN

* </region>

END
