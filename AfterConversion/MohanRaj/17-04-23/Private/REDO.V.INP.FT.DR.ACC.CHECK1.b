* @ValidationCode : MjoyMTEwMjcyMjI2OkNwMTI1MjoxNjgxNzI5MDI4MDQwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:27:08
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
SUBROUTINE REDO.V.INP.FT.DR.ACC.CHECK1
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as input routine in FUNDS.TRANSFER versions
* The functionality of this routine is to block the transaction when
*  Debit account has block status or insufficient balance
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
*17-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.CHEQUE.COLLECTION
    $INSERT I_F.ACCOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES                ;*TUS S/E

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*-------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
*Initialise the Variables

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER = ''
    R.FUNDS.TRANSFER = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CHEQUE.COLLECTION = 'F.CHEQUE.COLLECTION'
    F.CHEQUE.COLLECTION = ''
    R.CHEQUE.COLLECTION = ''
    CALL OPF(FN.CHEQUE.COLLECTION,F.CHEQUE.COLLECTION)

    LREF.APPLN = 'ACCOUNT':@FM:'FUNDS.TRANSFER'
    LREF.FLDS = 'L.AC.STATUS2':@FM
    LREF.FLDS := 'L.LOAN.COND':@VM:'L.LOAN.STATUS.1'
    LREF.POS = ''

    CALL MULTI.GET.LOC.REF(LREF.APPLN,LREF.FLDS,LREF.POS)
    POS.STATUS.2 = LREF.POS<1,1>
    FT.LOAN.COND.POS =  LREF.POS<2,1>
    FT.LOAN.STATUS.POS = LREF.POS<2,2>

RETURN
*-------------------------------------------------------------------------
PROCESS:
*~~~~~~~

    AF = FT.DEBIT.ACCT.NO
    LOAN.COND = R.NEW(FT.LOCAL.REF)<1,FT.LOAN.COND.POS>
    Y.LOAN.STATUS = R.NEW(FT.LOCAL.REF)<1,FT.LOAN.STATUS.POS>

    CHANGE @SM TO @VM IN Y.LOAN.STATUS
    CHANGE @SM TO @VM IN LOAN.COND

    IF ('JudicialCollection' MATCHES Y.LOAN.STATUS) OR ('Write-off' MATCHES Y.LOAN.STATUS) THEN
        ETEXT = 'EB-REQ.COLL.AREA.AUTH1'
* CURR.NO = DCOUNT(R.NEW(FT.OVERRIDE),VM)
* IF CURR.NO EQ 0 THEN
*     CURR.NO = 1
* END
        AF = FT.LOCAL.REF
        AV = FT.LOAN.STATUS.POS
        CALL STORE.END.ERROR
    END

    IF ('Legal' MATCHES LOAN.COND) THEN
        ETEXT = 'EB-REQ.COLL.AREA.AUTH1'
        AF = FT.LOCAL.REF
        AV = FT.LOAN.COND.POS
        CALL STORE.END.ERROR
    END

    Y.ACCOUNT.1 = R.NEW(FT.DEBIT.ACCT.NO)
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.1,R.ACCOUNT,F.ACCOUNT,ERR.ACC)
    CALL EB.READ.HVT ('EB.CONTRACT.BALANCES', Y.ACCOUNT.1, R.ECB, ECB.ERR)
    Y.STATUS.2 = R.ACCOUNT<AC.LOCAL.REF,POS.STATUS.2>
    IF Y.STATUS.2 NE '' THEN
        ETEXT = 'EB-DEB.AC.BLOCK.STATUS'
        CALL STORE.END.ERROR
        RETURN
    END

*Y.ONLINE.ACT.BAL = R.ACCOUNT<AC.ONLINE.ACTUAL.BAL                ;*TUS START
    Y.ONLINE.ACT.BAL = R.ECB<ECB.ONLINE.ACTUAL.BAL>                ;*TUS END
    Y.LOCKED.AMOUNT = SUM(R.ACCOUNT<AC.LOCKED.AMOUNT>)
    Y.AVAIL.AMOUNT = Y.ONLINE.ACT.BAL - Y.LOCKED.AMOUNT

    Y.DEBIT.AMOUNT = R.NEW(FT.DEBIT.AMOUNT)
    IF Y.DEBIT.AMOUNT EQ '' THEN
        Y.DEBIT.AMOUNT = R.NEW(FT.CREDIT.AMOUNT)
    END
    Y.CHARGE.AMOUNT = SUM(R.NEW(FT.TOTAL.CHARGE.AMOUNT)) + SUM(R.NEW(FT.TOTAL.TAX.AMOUNT))
    Y.TOTAL.AMT = Y.DEBIT.AMOUNT + Y.CHARGE.AMOUNT

    IF Y.AVAIL.AMOUNT LT Y.TOTAL.AMT THEN
        ETEXT = 'EB-DR.COND.FAIL'
        CALL STORE.END.ERROR
        RETURN
    END

    SELECT.CMD="SELECT ":FN.CHEQUE.COLLECTION:" WITH CREDIT.ACC.NO EQ ":Y.ACCOUNT.1:" AND EXPOSURE.DATE NE ":TODAY
    CALL EB.READLIST(SELECT.CMD,SELECT.LIS,'',NOR,ERR1)

    IF SELECT.LIS NE '' THEN
        ETEXT = 'EB-CHQUE.DEPOSIT'
        CALL STORE.END.ERROR
        RETURN
    END
RETURN
*-------------------------------------------------------------------------
END
