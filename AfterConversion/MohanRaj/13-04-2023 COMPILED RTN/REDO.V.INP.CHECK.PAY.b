* @ValidationCode : MjotMTE1MDcyNDAxMzpDcDEyNTI6MTY4MTM4OTc4NDE3NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:13:04
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
SUBROUTINE REDO.V.INP.CHECK.PAY
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.INP.CHECK.PAY
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is a validation routine attached to install payment version of FT and TELLER
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 3-JUN-2010        Prabhu.N       ODR-2010-01-0081    Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,SM TO @SM,FM TO @FM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    IF V$FUNCTION EQ 'I' THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN
*----
INIT:
*----

    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.ARRANGEMENT='F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT=''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.BILL.DETAILS='F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS=''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    LREF.APP=APPLICATION
    LREF.FIELDS='L.NO.OF.INSTAL'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        VAR.AC.ID=R.NEW(FT.CREDIT.ACCT.NO)
        VAR.CREDIT.AMOUNT=R.NEW(FT.CREDIT.AMOUNT)
        VAR.NO.INSTAL=R.NEW(FT.LOCAL.REF)<1,LREF.POS>
        AF=FT.CREDIT.AMOUNT
        GOSUB PROCESS
    END
    IF APPLICATION EQ 'TELLER' THEN
        VAR.AC.ID=R.NEW(TT.TE.ACCOUNT.2)
        VAR.CREDIT.AMOUNT= R.NEW(TT.TE.AMOUNT.LOCAL.1)
        AF=TT.TE.AMOUNT.LOCAL.1
        AV=1
        VAR.NO.INSTAL=R.NEW(TT.TE.LOCAL.REF)<1,LREF.POS>
        GOSUB PROCESS
    END
RETURN
*-------
PROCESS:
*-------
    CALL F.READ(FN.ACCOUNT,VAR.AC.ID,R.ACCOUNT,F.ACCOUNT,ERR)
    VAR.AA.ID=R.ACCOUNT<AC.ARRANGEMENT.ID>
    CALL F.READ(FN.AA.ARRANGEMENT,VAR.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,READ.ERR)
    BALANCE.TYPE='CURACCOUNT'
    Y.BAL.AMOUNT=''
    Y.REQ.TYPE = ''
    START.DATE= R.AA.ARRANGEMENT<AA.ARR.START.DATE>
    END.DATE=TODAY
    EFFECTIVE.DATE = TODAY
    CHARGEOFF.TYPE = ''
    CALL AC.GET.PERIOD.BALANCES(VAR.AC.ID,BALANCE.TYPE, Y.REQ.TYPE, START.DATE, END.DATE ,EFFECTIVE.DATE, CHARGEOFF.TYPE, Y.BAL.AMOUNT, ERR.MSG)
    Y.LIM.BALANCE = Y.BAL.AMOUNT<4>
    CHANGE @VM TO @FM IN Y.LIM.BALANCE
    Y.LIM.BALANCE.SIZE=DCOUNT(Y.LIM.BALANCE,@FM)
    Y.LIM.BALANCE=Y.LIM.BALANCE<Y.LIM.BALANCE.SIZE>
    Y.LIM.BALANCE = ABS(Y.LIM.BALANCE)
    VAR.COMMIT.BALANCE=Y.LIM.BALANCE
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,VAR.AA.ID,R.AA.ACCOUNT.DETAILS ,F.AA.ACCOUNT.DETAILS ,ERR)
    VAR.SET.LIST=R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    VAR.BILL.LIST=R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    CHANGE @VM TO @FM IN VAR.SET.LIST
    CHANGE @SM TO @FM IN VAR.SET.LIST
    CHANGE @SM TO @FM IN VAR.BILL.LIST
    CHANGE @VM TO @FM IN VAR.BILL.LIST
    VAR.SET.LIST.SIZE=DCOUNT(VAR.SET.LIST,@FM)

    VAR.CNT=1
    LOOP
    WHILE VAR.CNT LE VAR.SET.LIST.SIZE
        IF VAR.SET.LIST<VAR.CNT> EQ 'UNPAID' THEN
            VAR.BILL=VAR.BILL.LIST<VAR.CNT>
            CALL F.READ(FN.AA.BILL.DETAILS,VAR.BILL,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,ERR)
            VAR.BILL.AMOUNT=SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
            VAR.COMMIT.BALANCE+=VAR.BILL.AMOUNT
        END
        VAR.CNT += 1
    REPEAT

    IF VAR.CREDIT.AMOUNT GE VAR.COMMIT.BALANCE THEN
        ETEXT='EB-REDO.AMOUNT.PAID'
        CALL STORE.END.ERROR
    END
RETURN
END
