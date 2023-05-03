* @ValidationCode : MjoxNjc1NzQzNTYxOkNwMTI1MjoxNjgxNzk3Mjg5MTIxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 11:24:49
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
SUBROUTINE REDO.V.INP.TT.DR.ACC.CHECK
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as input routine in TELLER versions used for loan re-payment
*
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date               who           Reference            Description
*   ~~~~               ~~~           ~~~~~~~~~            ~~~~~~~~~~~
* 22-APR-2010     SHANKAR RAJU     ODR-2009-10-0331     Initial Creation
* 28-APR-2011      H GANESH           CR009              Change the Vetting value of local field
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    SM TO @SM,FM TO @FM,VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.CHEQUE.COLLECTION
    $INSERT I_F.ACCOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES                ;*TUS S/E

    GOSUB GET.LOCAL.REF.POS
    GOSUB INITIALISE

    IF Y.LOAN.STATUS EQ '' AND Y.LOAN.COND EQ '' THEN
        RETURN
    END

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*-------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
*Initialise the Variables

    ACC1.INTERNAL = ''
    Y.LOAN.STATUS = R.NEW(TT.TE.LOCAL.REF)<1,POS.LOAN.STATUS>
    Y.LOAN.COND = R.NEW(TT.TE.LOCAL.REF)<1,POS.LOAN.COND>
    Y.TT.PROCESS = R.NEW(TT.TE.LOCAL.REF)<1,POS.TT.PROCESS>

    Y.ACCOUNT.1 = R.NEW(TT.TE.ACCOUNT.1)

RETURN
*-------------------------------------------------------------------------
GET.LOCAL.REF.POS:
*~~~~~~~~~~~~~~~~~
*Get the position of local reference fields for TELLER and ACCOUNT application

    LREF.APPLN = 'TELLER':@FM:'ACCOUNT'
    LREF.FLDS = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@VM:'L.TT.DUE.PRS':@FM:'L.AC.STATUS2'
    LREF.POS = ''

    CALL MULTI.GET.LOC.REF(LREF.APPLN,LREF.FLDS,LREF.POS)
    POS.LOAN.STATUS = LREF.POS<1,1>
    POS.LOAN.COND = LREF.POS<1,2>
    POS.TT.PROCESS = LREF.POS<1,3>
    POS.STATUS.2 = LREF.POS<2,1>

RETURN
*-------------------------------------------------------------------------
OPEN.FILES:
*~~~~~~~~~~
*Open the necessary files

    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    R.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CHEQUE.COLLECTION = 'F.CHEQUE.COLLECTION'
    F.CHEQUE.COLLECTION = ''
    R.CHEQUE.COLLECTION = ''
    CALL OPF(FN.CHEQUE.COLLECTION,F.CHEQUE.COLLECTION)

RETURN
*-------------------------------------------------------------------------
PROCESS:
*~~~~~~~


    Y.COMI.SAVE = COMI
    COMI = Y.ACCOUNT.1
    N.VAL = N(TT.TE.ACCOUNT.1)<1>
    T.VAL = T(TT.TE.ACCOUNT.1)<1>
    CALL IN2INT(N.VAL,T.VAL)
    COMI = Y.COMI.SAVE

    IF ETEXT NE '' THEN
        ACC1.INTERNAL = 0
    END ELSE
        ACC1.INTERNAL = 1
    END

    CHANGE @SM TO @VM IN Y.LOAN.STATUS
    CHANGE @SM TO @VM IN Y.LOAN.COND

    IF ('JudicialCollection' MATCHES Y.LOAN.STATUS) OR ('Write-off' MATCHES Y.LOAN.STATUS) OR ('Legal' MATCHES Y.LOAN.COND) THEN
        IF Y.TT.PROCESS EQ '' THEN
            TEXT = 'EB-REQ.COLL.AREA.AUTH'
            CURR.NO = DCOUNT(R.NEW(TT.TE.OVERRIDE),@VM)
            IF CURR.NO EQ 0 THEN
                CURR.NO = 1
            END
            CALL STORE.OVERRIDE(CURR.NO)
        END
    END

    IF 'ThreeReturnedChecks' MATCHES Y.LOAN.COND THEN
        IF R.NEW(TT.TE.CHEQUE.NUMBER) NE '' AND ACC1.INTERNAL THEN
*IF Y.TT.PROCESS EQ '' THEN
*ETEXT = 'EB-REQ.COLL.AREA.AUTH'
*CALL STORE.END.ERROR
*RETURN
*END

            CUR.NO=DCOUNT(R.NEW(TT.TE.OVERRIDE),@VM)+1
            TEXT='EB-CHK.PAY.AUT'
            CALL STORE.OVERRIDE(CUR.NO)

        END
    END

    IF NOT(ACC1.INTERNAL) THEN
        GOSUB CHECK.DR.ACC.BAL
    END

RETURN
*-------------------------------------------------------------------------
CHECK.DR.ACC.BAL:
*~~~~~~~~~~~~~~~~

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.1,R.ACCOUNT,F.ACCOUNT,ERR.ACC)
    CALL EB.READ.HVT ('EB.CONTRACT.BALANCES', Y.ACCOUNT.1, R.ECB, ECB.ERR)                ;*TUS (S/E)

    Y.STATUS.2 = R.ACCOUNT<AC.LOCAL.REF,POS.STATUS.2>
    IF Y.STATUS.2 NE '' THEN
        ETEXT = 'EB-DEB.AC.BLOCK.STATUS'
        CALL STORE.END.ERROR
        RETURN
    END

*Y.ONLINE.ACT.BAL = R.ACCOUNT<AC.ONLINE.ACTUAL.BAL>        ;*TUS START
    Y.ONLINE.ACT.BAL = R.ECB<ECB.ONLINE.ACTUAL.BAL>            ;*TUS END
    Y.LOCKED.AMOUNT = SUM(R.ACCOUNT<AC.LOCKED.AMOUNT>)

    Y.AVAIL.AMOUNT = Y.ONLINE.ACT.BAL - Y.LOCKED.AMOUNT

    Y.DEBIT.AMOUNT = R.NEW(TT.TE.AMOUNT.LOCAL.1)
    Y.CHARGE.AMOUNT = SUM(R.NEW(TT.TE.CHRG.AMT.LOCAL))
    Y.TOTAL.AMT = Y.DEBIT.AMOUNT + Y.CHARGE.AMOUNT

    IF Y.AVAIL.AMOUNT LT Y.TOTAL.AMT THEN
        ETEXT = 'EB-NO.SUFF.FUNDS'
        CALL STORE.END.ERROR
    END

    SELECT.CMD="SELECT ":FN.CHEQUE.COLLECTION:" WITH CREDIT.ACC.NO EQ ":Y.ACCOUNT.1:" AND EXPOSURE.DATE NE ":TODAY
    CALL EB.READLIST(SELECT.CMD,SELECT.LIS,'',NOR,ERR1)
    IF SELECT.LIS NE '' THEN
        ETEXT = 'EB-REQ.CHF.TELL.AUTH'
        CALL STORE.END.ERROR
    END


RETURN
*-------------------------------------------------------------------------
END
