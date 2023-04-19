* @ValidationCode : MjotNjUxODY4Mzg0OkNwMTI1MjoxNjgxODkzNTM0NzExOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 14:08:54
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
*-----------------------------------------------------------------------------
* <Rating>-139</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.V.VAL.DEF.LIM.AMT.PRIN
***********************************************************
*----------------------------------------------------------
* COMPANY NAME    : APAP
* DEVELOPED BY    : Prabhu N
* PROGRAM NAME    : REDO.V.VAL.DEFAULT.AMT
*----------------------------------------------------------


* DESCRIPTION     : This routine is a validation routine attached
* CREDIT.ACCOUNT.NO of FUNDS.TRANSFER version for defaulting limits
*------------------------------------------------------------

* LINKED WITH    : CREDIT.ACCOUNT.NO AS VALIDATION ROUTINE
* IN PARAMETER   : NONE
* OUT PARAMETER  : NONE

*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                    REFERENCE         DESCRIPTION
*20.11.2010     Prabhu N            ODR-2010-08-0031    INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   VM TO @VM,FM TO @FM,SM TO @SM,F.READ TO CACHE.READ,Call Method Format Modified
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
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.EB.LOOKUP
    $INSERT I_F.EB.CONTRACT.BALANCES

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

*TUS change START
    FN.EB.LOOKUP='F.EB.LOOKUP'
    F.EB.LOOKUP=''
    CALL OPF(FN.EB.LOOKUP,F.EB.LOOKUP)

    FN.ECB = 'F.EB.CONTRACT.BALANCES'
    F.ECB = ''
    CALL OPF(FN.ECB,F.ECB)

*TUS change END

RETURN
*-------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------

*TUS change START
    SEL.CMD1='SELECT ':FN.EB.LOOKUP:' WITH @ID LIKE AA.OVERDUE.STATUS...'
    CALL EB.READLIST(SEL.CMD1,SEL.LOOKUP,'',SEL.NO.LOOKUP,SEL.RET)
    CONVERT @FM TO @VM IN SEL.LOOKUP ;*R22 Manual Code Conversion-Call Method Format Modified

*TUS change END

    LOC.REF.APPLICATION="FUNDS.TRANSFER":@FM:"AA.ARR.TERM.AMOUNT":@FM:"AA.ARR.PAYMENT.SCHEDULE" ;*R22 Manual Code Conversion-Call Method Format Modified
    LOC.REF.FIELDS='L.FT.INSTAL.AMT':@VM:'L.FT.NEXT.PAY':@VM:'L.FT.BIL.OVRDUE':@VM:'L.FT.OVRDUE.AMT':@VM:'L.FT.MAX.AMOUNT':@VM:'L.FT.MIN.AMOUNT':@VM:'L.FT.MAX.TIME':@VM:'L.FT.MIN.TIME':@FM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.AMOUNT':@VM:'L.AA.MAX.TIME':@VM:'L.AA.MIN.TIME':@FM:'L.AA.MAX.AMOUNT':@VM:'L.AA.MIN.AMOUNT' ;*R22 Manual Code Conversion-Call Method Format Modified
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
GET.ECB:
*-------------------------------------------------------------
    R.ECB = ''
    CALL F.READ(FN.ECB,Y.ACCOUNT.ID,R.ECB,F.ECB.E.ECB)
    CALL AA.CONSOLIDATE.ECB.AMOUNTS(R.ECB)

RETURN

*----------------------------------------------------------------------
GET.BAL:
*----------------------------------------------------------------------

    DATE.OPTIONS = ''
    EFFECTIVE.DATE = TODAY
    DATE.OPTIONS<4>  = 'ECB'
    BAL.DETAILS = ''
    Y.AMT = ""
    CALL AA.GET.PERIOD.BALANCES(Y.ACCOUNT.ID, Y.BAL.TYPE, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")
    Y.AMT=BAL.DETAILS<IC.ACT.BALANCE>

RETURN


*-------------------------------------------------------------
FUNDSTRANSFER:
*-------------------------------------------------------------
* if repayment is made through FT
    Y.ACCOUNT.ID=COMI
    CALL CACHE.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACC,F.ACCOUNT,ERR.ACC) ;*R22 Manual Code Conversion-Call Method Format Modified
    Y.ARRANGEMENT.ID=R.ACC<AC.ARRANGEMENT.ID>
    Y.VALUE.DATE=R.NEW(FT.CREDIT.VALUE.DATE)
    POS.INSTAL.AMT=LOC.REF.POS<1,1>
    POS.NEXT.PAY=LOC.REF.POS<1,2>
    POS.BILL.OVERDUE=LOC.REF.POS<1,3>
    POS.OVRDUE.AMT=LOC.REF.POS<1,4>
    POS.MAX.AMT=LOC.REF.POS<1,5>
    POS.MIN.AMT=LOC.REF.POS<1,6>
    POS.MAX.TIME=LOC.REF.POS<1,7>
    POS.MIN.TIME=LOC.REF.POS<1,8>

    GOSUB GET.ECB

    GOSUB INSTALLMENT

    R.NEW(FT.LOCAL.REF)<1,POS.INSTAL.AMT>=Y.TOTAL.DUE
    IF R.NEW(FT.CREDIT.AMOUNT) EQ '' THEN
        R.NEW(FT.CREDIT.AMOUNT)=Y.TOTAL.DUE
    END
    R.NEW(FT.LOCAL.REF)<1,POS.NEXT.PAY>=Y.NEXT.TOTAL.DUE
    GOSUB BILLOVERDUE
    R.NEW(FT.LOCAL.REF)<1,POS.BILL.OVERDUE>=Y.AGE.STATUS
    GOSUB OVERDUEAMT
    R.NEW(FT.LOCAL.REF)<1,POS.OVRDUE.AMT>=ABS(Y.OVERDUE.AMT)
    GOSUB OVERPAYRULES
    R.NEW(FT.LOCAL.REF)<1,POS.MAX.AMT>=Y.MAX.AMOUNT
    R.NEW(FT.LOCAL.REF)<1,POS.MIN.AMT>=Y.MIN.AMOUNT
    R.NEW(FT.LOCAL.REF)<1,POS.MAX.TIME>=Y.MAX.TIME
    R.NEW(FT.LOCAL.REF)<1,POS.MIN.TIME>=Y.MIN.TIME

RETURN
*-------------------------------------------------------------
INSTALLMENT:
*-------------------------------------------------------------
* To calculate the next payment amount
    CALL AA.SCHEDULE.PROJECTOR(Y.ARRANGEMENT.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    Y.NO.OF.DATE=DCOUNT(DUE.DATES,@FM) ;*R22 Manual Code Conversion-Call Method Format Modified
    VAR1=1
    LOOP
    WHILE VAR1 LE Y.NO.OF.DATE
        Y.PAYMENT.DATE = DUE.DATES<VAR1>
        IF Y.PAYMENT.DATE GE Y.VALUE.DATE THEN
            Y.TOTAL.DUE = TOT.PAYMENT<VAR1>
            Y.NEXT.TOTAL.DUE=TOT.PAYMENT<VAR1+1>
            RETURN
        END
        VAR1++
    REPEAT
RETURN
*-------------------------------------------------------------
BILLOVERDUE:
*-------------------------------------------------------------
* To calculate the no of bills that are overdue
    CALL CACHE.READ(FN.ACCOUNT.DETAILS,Y.ARRANGEMENT.ID,R.ACCOUNT.DETAILS,F.ACCOUNT.DETAILS,ACT.DET.ERR) ;*R22 Manual Code Conversion-Call Method Format Modified
    Y.BILL.STATUS = R.ACCOUNT.DETAILS<AA.AD.BILL.STATUS>
    CONVERT @SM TO @FM IN Y.BILL.STATUS ;*R22 Manual Code Conversion-Call Method Format Modified
    CONVERT @VM TO @FM IN Y.BILL.STATUS ;*R22 Manual Code Conversion-Call Method Format Modified
    Y.BILL.STATUS.CNT=DCOUNT(Y.BILL.STATUS,@FM) ;*R22 Manual Code Conversion-Call Method Format Modified
    VAR2=1
    Y.AGE.STATUS=0
    LOOP
    WHILE VAR2 LE Y.BILL.STATUS.CNT
        IF Y.BILL.STATUS<VAR2> EQ 'AGING' THEN
            Y.AGE.STATUS++
        END
        VAR2++
    REPEAT
RETURN
*-------------------------------------------------------------
OVERDUEAMT:
*-------------------------------------------------------------
* To calculate the overdue amount for overdue bills

*TUS change START
    Y.ACCT.ACTIVITY=''
    NOR=''
*SEL.CMD =  "SELECT ":FN.ACCT.ACTIVITY:" WITH @ID LIKE ":Y.ACCOUNT.ID:".DEL... OR ":Y.ACCOUNT.ID:".GRC... OR ":Y.ACCOUNT.ID:".NAB..."
*CALL EB.READLIST(SEL.CMD,Y.ACCT.ACTIVITY,'',NOR,ACCT.ERR)
*GOSUB CALC

    TOT.BAL = COUNT(R.ECB<ECB.CURR.ASSET.TYPE>,@VM) + 1 ;*R22 Manual Code Conversion-Call Method Format Modified
    FOR BAL.TYPE.POS = 1 TO TOT.BAL
        Y.BAL.TYPE = ''
        Y.BAL.TYPE = R.ECB<ECB.TYPE.SYSDATE,BAL.TYPE.POS>

        IF Y.BAL.TYPE THEN
            BAL.PREFIX = Y.BAL.TYPE[1,3]
            IF BAL.PREFIX MATCHES SEL.LOOKUP AND BAL.PREFIX NE 'CUR' THEN
                GOSUB GET.BAL
                IF Y.AMT THEN
                    Y.OVERDUE.AMT=Y.OVERDUE.AMT+Y.AMT
                END
            END
        END
    NEXT BAL.TYPE.POS

*TUS change END

RETURN
*-------------------------------------------------------------
CALC:
*-------------------------------------------------------------
* To calculate the overdue amount for overdue bills

    VAR3=1
    LOOP
    WHILE VAR3 LE NOR
        Y.ACCT.ID=Y.ACCT.ACTIVITY<VAR3>
        CALL CACHE.READ(FN.ACCT.ACTIVITY,Y.ACCT.ID,R.ACCT.ACTIVITY,F.ACCT.ACTIVITY,ACCT.AC.ERR) ;*R22 Manual Code Conversion-Call Method Format Modified
        Y.NO.BALANCE=DCOUNT(R.ACCT.ACTIVITY<IC.ACT.BALANCE>,@VM) ;*R22 Manual Code Conversion-Call Method Format Modified
        Y.OVERDUE.AMT=R.ACCT.ACTIVITY<IC.ACT.BALANCE,Y.NO.BALANCE>+Y.OVERDUE.AMT
        VAR3++
    REPEAT
RETURN
*-------------------------------------------------------------
OVERPAYRULES:
*-------------------------------------------------------------
* To calculate the MIN & MAX amount and period for an arrangement

    PROP.CLASS="TERM.AMOUNT"
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;*R22 Manual Code Conversion-Call Method Format Modified
    CALL CACHE.READ(FN.ARRANGEMENT,Y.ARRANGEMENT.ID,R.ARRANGEMENT,F.ARRANGEMENT,ARR.ERR) ;*R22 Manual Code Conversion
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
        IF Y.ARR.VALUE.DATE AND Y.TERM.DATE THEN
            CALL CDD('', Y.ARR.VALUE.DATE, Y.TERM.DATE, Y.NO.OF.DAYS)
        END ELSE
            Y.NO.OF.DAYS = 0
        END
        Y.MAX.TIME=(Y.NO.OF.DAYS*Y.TERM.MAX.TIME)/100
        Y.MIN.TIME=(Y.NO.OF.DAYS*Y.TERM.MIN.TIME)/100
    END
    ELSE
        PROP.CLASS="PAYMENT.SCHEDULE"
        CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;*R22 Manual Code Conversion-Call Method Format Modified
        MAX.AMT.POS1=LOC.REF.POS<3,1>
        MIN.AMT.POS1=LOC.REF.POS<3,2>
        Y.TERM.MAX.AMT=R.Condition<AA.PS.LOCAL.REF,MAX.AMT.POS1>
        Y.TERM.MIN.AMT=R.Condition<AA.PS.LOCAL.REF,MIN.AMT.POS1>
        IF Y.TERM.MAX.AMT NE '' OR Y.TERM.MIN.AMT NE '' THEN
            Y.MAX.AMOUNT=Y.TOTAL.DUE*Y.TERM.MAX.AMT
            Y.MIN.AMOUNT=Y.TOTAL.DUE*Y.TERM.MIN.AMT
            Y.NO.OF.DAYS = 'C'
            IF Y.ARR.VALUE.DATE AND Y.TERM.DATE THEN
                CALL CDD('', Y.ARR.VALUE.DATE, Y.TERM.DATE, Y.NO.OF.DAYS)
            END ELSE
                Y.NO.OF.DAYS = 0
            END
            Y.MAX.TIME=(Y.NO.OF.DAYS*Y.TERM.MAX.TIME)/100
            Y.MIN.TIME=(Y.NO.OF.DAYS*Y.TERM.MIN.TIME)/100
        END
    END
RETURN
END
