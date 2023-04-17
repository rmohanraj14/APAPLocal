* @ValidationCode : MjotNTYxNjY4OTMzOkNwMTI1MjoxNjgxNzM2MDYyNDM2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 18:24:22
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
SUBROUTINE REDO.V.INP.STO.CHK.PAY
***********************************************************
*----------------------------------------------------------
* COMPANY NAME    : APAP
* DEVELOPED BY    : Prabhu N
* PROGRAM NAME    : REDO.V.INP.STO.CHK.PAY
*----------------------------------------------------------


* DESCRIPTION     : This routine is a input routine attached
* CPTY.ACCT.NO of STO version for validating limits
*------------------------------------------------------------

* LINKED WITH    : CREDIT.ACCOUNT.NO AS VALIDATION ROUTINE
* IN PARAMETER   : NONE
* OUT PARAMETER  : NONE

*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                    REFERENCE         DESCRIPTION
*01.01.2011     Prabhu N            ODR-2010-08-0031    INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    CONVERT TO CHANGE,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.TELLER
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.STANDING.ORDER

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*-------------------------------------------------------------
INIT:
*-------------------------------------------------------------
* intilaise the variables
    FN.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.ACCOUNT.DETAILS=''
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    FN.ACCT.ACTIVITY='F.ACCT.ACTIVITY'
    F.ACCT.ACTIVITY=''
    FN.ARRANGEMENT='F.AA.ARRANGEMENT'
    F.ARRANGEMENT=''
    Y.ARRANGEMENT.ID=''
    Y.NO.OF.DATE=''
    Y.VALUE.DATE=''
    Y.PAYMENT.DATE=''
    Y.TOTAL.DUE=''
    Y.NO.BILL=''
    Y.MAX.AMOUNT=''
    Y.MIN.AMOUNT=''
    Y.MAX.TIME=''
    Y.MIN.TIME=''
    Y.OVERDUE.AMT=0



RETURN
*-------------------------------------------------------------
OPENFILES:
*-------------------------------------------------------------
* To  open the files that are needed

    CALL OPF(FN.ACCOUNT.DETAILS,F.ACCOUNT.DETAILS)
    CALL OPF(FN.ACCT.ACTIVITY,F.ACCT.ACTIVITY)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.ARRANGEMENT,F.ARRANGEMENT)
RETURN
*-------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------

    LOC.REF.APPLICATION="FUNDS.TRANSFER":@FM:"AA.ARR.TERM.AMOUNT":@FM:"AA.ARR.PAYMENT.SCHEDULE"
    LOC.REF.FIELDS='L.FT.INSTAL.AMT':@VM:'L.FT.NEXT.PAY':@VM:'L.FT.BIL.OVRDUE':@VM:'L.FT.OVRDUE.AMT':@VM:'L.FT.MAX.AMOUNT':@VM:'L.FT.MIN.AMOUNT':@VM:'L.FT.MAX.TIME':@VM:'L.FT.MIN.TIME':@FM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.AMOUNT':@VM:'L.AA.MAX.TIME':@VM:'L.AA.MIN.TIME':@FM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.AMOUNT'
    LOC.REF.POS=''
    GOSUB LOC.REF
    GOSUB FUNDSTRANSFER
RETURN
*-------------------------------------------------------------
LOC.REF:
*-------------------------------------------------------------
* calling core routine to get the LOCAL.REF positions

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
RETURN

*-------------------------------------------------------------
FUNDSTRANSFER:
*-------------------------------------------------------------
* if repayment is made through FT
    Y.ACCOUNT.ID= R.NEW(STO.CPTY.ACCT.NO)
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACC,F.ACCOUNT,ERR.ACC)
    Y.ARRANGEMENT.ID=R.ACC<AC.ARRANGEMENT.ID>
    Y.VALUE.DATE=FIELD(R.NEW(STO.CURRENT.FREQUENCY),' ',1)
    POS.INSTAL.AMT=LOC.REF.POS<1,1>
    POS.NEXT.PAY=LOC.REF.POS<1,2>
    POS.BILL.OVERDUE=LOC.REF.POS<1,3>
    POS.OVRDUE.AMT=LOC.REF.POS<1,4>
    POS.MAX.AMT=LOC.REF.POS<1,5>
    POS.MIN.AMT=LOC.REF.POS<1,6>
    POS.MAX.TIME=LOC.REF.POS<1,7>
    POS.MIN.TIME=LOC.REF.POS<1,8>
    GOSUB INSTALLMENT
*    R.NEW(FT.LOCAL.REF)<1,POS.INSTAL.AMT>=Y.TOTAL.DUE
*    R.NEW(FT.LOCAL.REF)<1,POS.NEXT.PAY>=Y.NEXT.TOTAL.DUE
    GOSUB BILLOVERDUE
*    R.NEW(FT.LOCAL.REF)<1,POS.BILL.OVERDUE>=Y.AGE.STATUS
    GOSUB OVERDUEAMT
*    R.NEW(FT.LOCAL.REF)<1,POS.OVRDUE.AMT>=ABS(Y.OVERDUE.AMT)
    GOSUB OVERPAYRULES
*    R.NEW(FT.LOCAL.REF)<1,POS.MAX.AMT>=Y.MAX.AMOUNT
*    R.NEW(FT.LOCAL.REF)<1,POS.MIN.AMT>=Y.MIN.AMOUNT
*    R.NEW(FT.LOCAL.REF)<1,POS.MAX.TIME>=Y.MAX.TIME
*    R.NEW(FT.LOCAL.REF)<1,POS.MIN.TIME>=Y.MIN.TIME
    GOSUB CHECK.ERROR
RETURN
*-------------------------------------------------------------
INSTALLMENT:
*-------------------------------------------------------------
* To calculate the next payment amount
    CALL AA.SCHEDULE.PROJECTOR(Y.ARRANGEMENT.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    Y.NO.OF.DATE=DCOUNT(DUE.DATES,@FM)
    VAR1=1
    LOOP
    WHILE VAR1 LE Y.NO.OF.DATE
        Y.PAYMENT.DATE = DUE.DATES<VAR1>
        IF Y.PAYMENT.DATE GE Y.VALUE.DATE THEN
            Y.TOTAL.DUE = TOT.PAYMENT<VAR1>
            Y.NEXT.TOTAL.DUE=TOT.PAYMENT<VAR1+1>
            RETURN
        END
        VAR1 += 1
    REPEAT
RETURN
*-------------------------------------------------------------
BILLOVERDUE:
*-------------------------------------------------------------
* To calculate the no of bills that are overdue
    CALL F.READ(FN.ACCOUNT.DETAILS,Y.ARRANGEMENT.ID,R.ACCOUNT.DETAILS,F.ACCOUNT.DETAILS,ACT.DET.ERR)
    Y.BILL.STATUS = R.ACCOUNT.DETAILS<AA.AD.BILL.STATUS>
    CHANGE @SM TO @FM IN Y.BILL.STATUS ;*R22 Auto code conversion
    CHANGE @VM TO @FM IN Y.BILL.STATUS ;*R22 Auto code conversion
    Y.BILL.STATUS.CNT=DCOUNT(Y.BILL.STATUS,@FM)
    VAR2=1
    Y.AGE.STATUS=0
    LOOP
    WHILE VAR2 LE Y.BILL.STATUS.CNT
        IF Y.BILL.STATUS<VAR2> EQ 'AGING' THEN
            Y.AGE.STATUS += 1
        END
        VAR2 += 1
    REPEAT
RETURN
*-------------------------------------------------------------
OVERDUEAMT:
*-------------------------------------------------------------
* To calculate the overdue amount for overdue bills

    SEL.CMD =  "SELECT ":FN.ACCT.ACTIVITY:" WITH @ID LIKE ":Y.ACCOUNT.ID:".DEL... OR ":Y.ACCOUNT.ID:".GRC... OR ":Y.ACCOUNT.ID:".NAB..."
    CALL EB.READLIST(SEL.CMD,Y.ACCT.ACTIVITY,'',NOR,ACCT.ERR)
    GOSUB CALC
RETURN
*-------------------------------------------------------------
CALC:
*-------------------------------------------------------------
* To calculate the overdue amount for overdue bills

    VAR3=1
    LOOP
    WHILE VAR3 LE NOR
        Y.ACCT.ID=Y.ACCT.ACTIVITY<VAR3>
        CALL F.READ(FN.ACCT.ACTIVITY,Y.ACCT.ID,R.ACCT.ACTIVITY,F.ACCT.ACTIVITY,ACCT.AC.ERR)
        Y.NO.BALANCE=DCOUNT(R.ACCT.ACTIVITY<IC.ACT.BALANCE>,@VM)
        Y.OVERDUE.AMT=R.ACCT.ACTIVITY<IC.ACT.BALANCE,Y.NO.BALANCE>+Y.OVERDUE.AMT
        VAR3 += 1
    REPEAT
RETURN
*-------------------------------------------------------------
OVERPAYRULES:
*-------------------------------------------------------------
* To calculate the MIN & MAX amount and period for an arrangement

    PROP.CLASS="TERM.AMOUNT"
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    CALL F.READ(FN.ARRANGEMENT,Y.ARRANGEMENT.ID,R.ARRANGEMENT,F.ARRANGEMENT,ARR.ERR)
    Y.ARR.VALUE.DATE=R.ARRANGEMENT<AA.ARR.START.DATE>
    Y.TERM.AMOUNT=R.Condition<AA.AMT.AMOUNT>
    Y.TERM.DATE=R.Condition<AA.AMT.MATURITY.DATE>
    MAX.AMT.POS=LOC.REF.POS<2,1>
    MIN.AMT.POS=LOC.REF.POS<2,2>
    MAX.TIME.POS=LOC.REF.POS<2,3>
    MIN.TIME.POS=LOC.REF.POS<2,4>
    Y.TERM.MAX.AMT=R.Condition<AA.AMT.LOCAL.REF,MAX.AMT.POS>
    Y.TERM.MIN.AMT=R.Condition<AA.AMT.LOCAL.REF,MIN.AMT.POS>
    Y.TERM.MAX.TIME=R.Condition<AA.AMT.LOCAL.REF,MAX.TIME.POS>
    Y.TERM.MIN.TIME=R.Condition<AA.AMT.LOCAL.REF,MIN.TIME.POS>
    IF Y.TERM.MAX.AMT NE '' OR Y.TERM.MIN.AMT NE '' THEN
        Y.MAX.AMOUNT=(Y.TERM.MAX.AMT*Y.TERM.AMOUNT)/100
        Y.MIN.AMOUNT=(Y.TERM.MIN.AMT*Y.TERM.AMOUNT)/100
        Y.NO.OF.DAYS = 'C'
        CALL CDD('', Y.ARR.VALUE.DATE, Y.TERM.DATE, Y.NO.OF.DAYS)
        Y.MAX.TIME=(Y.NO.OF.DAYS*Y.TERM.MAX.TIME)/100
        Y.MIN.TIME=(Y.NO.OF.DAYS*Y.TERM.MIN.TIME)/100
    END
    ELSE
        PROP.CLASS="PAYMENT.SCHEDULE"
        CALL REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
        MAX.AMT.POS1=LOC.REF.POS<3,1>
        MIN.AMT.POS1=LOC.REF.POS<3,2>
        Y.TERM.MAX.AMT=R.Condition<AA.PS.LOCAL.REF,MAX.AMT.POS1>
        Y.TERM.MIN.AMT=R.Condition<AA.PS.LOCAL.REF,MIN.AMT.POS1>
        IF Y.TERM.MAX.AMT NE '' OR Y.TERM.MIN.AMT NE '' THEN
            Y.MAX.AMOUNT=Y.TOTAL.DUE*Y.TERM.MAX.AMT
            Y.MIN.AMOUNT=Y.TOTAL.DUE*Y.TERM.MIN.AMT
            Y.NO.OF.DAYS = 'C'
            CALL CDD('', Y.ARR.VALUE.DATE, Y.TERM.DATE, Y.NO.OF.DAYS)
            Y.MAX.TIME=(Y.NO.OF.DAYS*Y.TERM.MAX.TIME)/100
            Y.MIN.TIME=(Y.NO.OF.DAYS*Y.TERM.MIN.TIME)/100
        END
    END
RETURN
*-----------------------------------------------------------------
CHECK.ERROR:
*-----------------------------------------------------------------

    CREDIT.AMOUNT = R.NEW(STO.CURRENT.AMOUNT.BAL)
    IF CREDIT.AMOUNT GT Y.MAX.AMOUNT THEN
        AF=STO.CURRENT.AMOUNT.BAL
        ETEXT='FT-VERIFY.AMOUNT'
        CALL STORE.END.ERROR
    END

    IF CREDIT.AMOUNT LT Y.MIN.AMOUNT THEN
        ETEXT='FT-VERIFY.AMOUNT'
        AF=STO.CURRENT.AMOUNT.BAL
        CALL STORE.END.ERROR
    END

    CREDIT.ACCOUNT=R.NEW(STO.CPTY.ACCT.NO)
    SEL.CMD="SELECT ":FN.ARRANGEMENT :" WITH LINKED.APPL.ID EQ ": CREDIT.ACCOUNT
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,DATA.ERR)
    AA.ARRANGEMENT.ID=SEL.LIST
    CALL F.READ(FN.ARRANGEMENT,AA.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.ARRANGEMENT,ERR)
    AA.ARRANGEMENT.START.DATE=R.AA.ARRANGEMENT<AA.ARR.START.DATE>
    CREDIT.VALUE.DATE = R.NEW(STO.CURRENT.END.DATE)
    DIF.CREDIT.VALUE.DATE='C'
    CALL CDD('', AA.ARRANGEMENT.START.DATE, CREDIT.VALUE.DATE, DIF.CREDIT.VALUE.DATE)

    IF DIF.CREDIT.VALUE.DATE GT Y.MAX.TIME THEN
        ETEXT='FT-VERIFY.DATE'
        AF=STO.CURRENT.FREQUENCY
        CALL STORE.END.ERROR
    END
    CREDIT.VALUE.DATE=FIELD(R.NEW(STO.CURRENT.FREQUENCY),' ',1)
    DIF.CREDIT.VALUE.DATE='C'
    CALL CDD('', AA.ARRANGEMENT.START.DATE, CREDIT.VALUE.DATE, DIF.CREDIT.VALUE.DATE)
    IF DIF.CREDIT.VALUE.DATE LT Y.MIN.TIME  THEN
        ETEXT='FT-VERIFY.DATE'
        AF=STO.CURRENT.END.DATE
        CALL STORE.END.ERROR
    END
RETURN
END
