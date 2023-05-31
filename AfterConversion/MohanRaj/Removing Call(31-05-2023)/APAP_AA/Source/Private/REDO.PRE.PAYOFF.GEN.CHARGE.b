$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.PRE.PAYOFF.GEN.CHARGE(CHG.PROP,R.CHG.RECORD,BASE.AMT,CHARGE.AMOUNT)
*-----------------------------------------------------------------------------
*This routine is charge calculating routine for the condition PRCANCANTIC
*-----------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 02-01-2012        S.MARIMUTHU    PACS00146863        Initial Creation
*---------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                     Descripition
* 29-03-2023     Samaran T         Manual R22 Code Conversion                Package Name Added APAP.AA
* 29-03-2023   Conversion Tool       Auto R22 Code Conversion                     FM TO @FM
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.PAYOFF.TERM.PARAM
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ACTIVITY.CHARGES
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.CHARGE
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.PAYMENT.SCHEDULE

MAIN:

    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PGM.END

OPENFILES:

    FN.REDO.PAYOFF.TERM.PARAM = 'F.REDO.PAYOFF.TERM.PARAM'
    F.REDO.PAYOFF.TERM.PARAM = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    APPL = 'AA.PRD.DES.CHARGE':@FM:'AA.PRD.DES.PAYMENT.SCHEDULE'
    L.FIELDS = 'L.AA.CHG.RATE':@FM:'L.MIGRATED.LN'
    CALL MULTI.GET.LOC.REF(APPL,L.FIELDS,POS.DD)
    Y.POS.CHG.RT = POS.DD<1,1>
    Y.POS.MIG = POS.DD<2,1>

RETURN

PROCESS:

    Y.AA.ID = c_aalocArrId
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARR,F.AA.ARRANGEMENT,AA.ARR.ERR)
    Y.PRODUCT = R.AA.ARR<AA.ARR.PRODUCT>
    Y.CURR = R.AA.ARR<AA.ARR.CURRENCY>
    Y.ARR.DATE = R.AA.ARR<AA.ARR.START.DATE>

    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,'PAYMENT.SCHEDULE','','',RET.PROP,RET.COND,RET.ERR)
    RET.COND = RAISE(RET.COND)
    Y.MIG.LN = RET.COND<AA.PS.LOCAL.REF,Y.POS.MIG>

    IF Y.MIG.LN EQ 'YES' THEN
        Y.DUP.DATE = R.AA.ARR<AA.ARR.ORIG.CONTRACT.DATE>
    END ELSE
        Y.DUP.DATE = Y.ARR.DATE
    END

    ACCOUNT.ID = R.AA.ARR<AA.ARR.LINKED.APPL.ID>

    CALL CACHE.READ(FN.REDO.PAYOFF.TERM.PARAM,'SYSTEM',R.PAYOFF.PARAM,PAR.PAY.ERR)
    Y.TERMS = R.PAYOFF.PARAM<RE.POFF.TERM>
    Y.PROD.TYPES = R.PAYOFF.PARAM<RE.POFF.PRODUCT>

    LOCATE Y.PRODUCT IN Y.PROD.TYPES<1,1> SETTING POS THEN
        Y.RES.TERM = Y.TERMS<1,POS>
    END ELSE
        RETURN
    END
    Y.LEN = LEN(Y.RES.TERM)
    Y.D.YR.MN = Y.RES.TERM[Y.LEN,-1]
    Y.NO = Y.RES.TERM[1,Y.LEN-1]

    BEGIN CASE

        CASE Y.D.YR.MN EQ 'D'
            CALL CDT('',Y.DUP.DATE,'+':Y.NO:'C')

        CASE Y.D.YR.MN EQ 'W'
            Y.NO = Y.NO * 7
            CALL CDT('',Y.DUP.DATE,'+':Y.NO:'C')

        CASE Y.D.YR.MN EQ 'M'
            Y.MNT = Y.DUP.DATE[5,2]
            Y.YR.TERM = Y.NO / 12
            Y.YR.TERM = FIELD(Y.YR.TERM,'.',1)
            Y.MN.TERM = MOD(Y.NO,12)
            Y.DUP.DATE = Y.DUP.DATE[1,4]+Y.YR.TERM:FMT(Y.DUP.DATE[5,2]+Y.MN.TERM,'R%2'):Y.DUP.DATE[7,8]
            IF Y.DUP.DATE[5,2] GT 12 THEN
                Y.DUP.DATE = Y.DUP.DATE[1,4]+1:FMT(Y.DUP.DATE[5,2]-12,'R%2'):Y.DUP.DATE[7,8]
            END

        CASE Y.D.YR.MN EQ 'Y'
            Y.DUP.DATE = Y.DUP.DATE[1,4]+Y.NO:Y.DUP.DATE[5,2]:Y.DUP.DATE[7,8]

    END CASE


    IF TODAY GT Y.DUP.DATE THEN
        CHARGE.AMOUNT = 0
    END ELSE
        BALANCE.TO.CHECK = 'TOTCOMMITMENT'
        DATE.OPTIONS = ''
        EFFECTIVE.DATE = TODAY
        DATE.OPTIONS<4>  = 'ECB'
        BALANCE.AMOUNT = ""
        CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")
        PRIN.BALANCE = BAL.DETAILS<IC.ACT.BALANCE>
        PRIN.BALANCE = ABS(PRIN.BALANCE)
        Y.RATE = R.CHG.RECORD<AA.CHG.LOCAL.REF,Y.POS.CHG.RT>
        CHARGE.AMOUNT = PRIN.BALANCE * (Y.RATE/100)
        CHARGE.AMOUNT = ABS(CHARGE.AMOUNT)
    END

RETURN

PGM.END:

END
