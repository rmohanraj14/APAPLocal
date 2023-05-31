* @ValidationCode : MjoxMjUwMTU1NzgwOkNwMTI1MjoxNjg1NTI4ODY3MjY0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 15:57:47
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
$PACKAGE APAP.AA
SUBROUTINE REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW.GET(Y.PROCESSED.IDS, Y.OUT.ARRAY)
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : T.Jeeva, Temenos Application Management
*Program   Name    : REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW.GET
*ODR Reference     : ODR-2010-03-0183
*--------------------------------------------------------------------------------------------------------
*Description  :REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW.GET is a mainline routine called within the routine
*              REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW, the routine fetches the record details required to
*              display in the enquiry
*In Parameter : Y.PROCESSED.IDS
*Out Parameter: Y.OUT.ARRAY
*--------------------------------------------------------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       FM TO @FM, VM to @VM, SM to @SM, ++ to+=
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   CALL routine format modified
*------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.EB.LOOKUP
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.INTEREST
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $USING APAP.TAM
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*--------------------------------------------------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------------------------------------------------

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS  = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.EB.LOOKUP = 'F.EB.LOOKUP'
    F.EB.LOOKUP  = ''
    CALL OPF(FN.EB.LOOKUP,F.EB.LOOKUP)

    FN.REDO.NOTIFY.RATE.CHANGE = 'F.REDO.NOTIFY.RATE.CHANGE'
    F.REDO.NOTIFY.RATE.CHANGE  = ''
    CALL OPF(FN.REDO.NOTIFY.RATE.CHANGE,F.REDO.NOTIFY.RATE.CHANGE)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS  = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    LOC.REF.APPLICATION   = "AA.PRD.DES.INTEREST":@FM:"AA.PRD.DES.CUSTOMER":@FM:"AA.PRD.DES.TERM.AMOUNT":@FM:"ACCOUNT":@FM:"AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS        = 'L.AA.FIR.REV.DT':@VM:'L.AA.LST.REV.DT':@VM:'L.AA.NXT.REV.DT':@FM:'L.AA.AFF.COM':@VM:'L.AA.CAMP.TY':@FM:'L.AA.COL':@FM:'L.OD.STATUS':@FM:'L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.FIR.REV.DT   = LOC.REF.POS<1,1>
    POS.L.AA.LST.REV.DT   = LOC.REF.POS<1,2>
    POS.L.AA.NXT.REV.DT   = LOC.REF.POS<1,3>
    POS.L.AA.AFF.COM      = LOC.REF.POS<2,1>
    POS.L.AA.CAMP.TY      = LOC.REF.POS<2,2>
    POS.L.AA.COL          = LOC.REF.POS<3,1>
    POS.L.OD.STATUS       = LOC.REF.POS<4,1>
    POS.L.LOAN.STATUS.1   = LOC.REF.POS<5,1>
    POS.L.LOAN.COND       = LOC.REF.POS<5,2>
RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------

    Y.VAR1 = 1
    Y.AA.IDS.CNT = DCOUNT(Y.PROCESSED.IDS,@FM)
    LOOP
    WHILE Y.VAR1 LE Y.AA.IDS.CNT
        Y.AA.ID = Y.PROCESSED.IDS<Y.VAR1>
        GOSUB GET.DETAILS
        IF MOD(Y.VAR1,25) EQ 0 THEN
            CALL OCOMO("Processed the ids - ":Y.VAR1:"/":Y.AA.IDS.CNT)
        END
        Y.VAR1 += 1
    REPEAT
RETURN
*--------------------------------------------------------------------------------------------------------
GET.DETAILS:
*--------------------------------------------------------------------------------------------------------
    GOSUB GET.ARRANGEMENT.DETAILS
    GOSUB GET.CUSTOMER.DETAILS
    GOSUB GET.ACCOUNT.DETAILS
    GOSUB GET.TERM.AMOUNT.DETAILS
    GOSUB GET.INTEREST.DETAILS
    GOSUB GET.PAYMENT.DETAILS
    GOSUB GET.LOAN.BALANCES
    GOSUB GET.OVERDUE.DETAILS

*Y.OUT.ARRAY<-1> := Y.RES.LOAN.ORG.AGENCY:'*':Y.RES.CCY:'*':Y.RES.AFF.COMP:'*': Y.RES.CAMP.TYPE:'*':Y.RES.LOAN.BOOK.TYPE:'*':Y.RES.LOAN.PROD.TYPE:'*':Y.FINAL.ARR.ID:'*':Y.RES.PREV.LOAN.NUM:"*"::Y.RES.CLIENT.NAME:'*':Y.RES.DIS.AMOUNT:'*':Y.RES.OPEN.DATE:'*':Y.RES.LOAN.EXP.DATE:'*':Y.RES.INT.RATE:'*':Y.RES.CALC.AMOUNT:'*':Y.RES.TOT.CAP.BAL:'*':Y.RES.TOT.EXP.AMT:'*':Y.RES.EXP.BILLS.COUNT:'*':Y.RES.LOAN.STATUS:'*':Y.RES.DAYS.OF.DELAY:'*':Y.RES.Y.GUARANT.NO:'*':Y.RES.TYPE.OF.GUAR:'*':Y.NEXT.REVIEW.DATE:'*':Y.RES.MOD.USER:'*':Y.RES.LAST.RATE.CHA.DATE:'*':Y.RES.LAST.REV.DATE:'*':Y.RES.PRE.RATE.LAST.REV:"*":Y.RES.LOAN.COND
    Y.OUT.ARRAY<-1> := Y.LOAN.CO.CODE:'*':Y.LOAN.CURRENCY:'*':Y.CUS.AFF.COMP:'*':Y.CUS.CAMP.TYPE:'*':Y.LOAN.PROD.GROUP:'*':Y.LOAN.PRODUCT:'*':Y.AA.ID:'*':Y.LEGACY.ID:'*':Y.OWNER.NAMES:'*':Y.TOTAL.DISB.AMT:'*':Y.OPEN.DATE:'*':Y.MATURITY.DATE:'*':Y.INT.RATE:'*':Y.BILL.AMOUNT:'*':Y.ACCOUNT.BAL:'*':Y.TOTAL.BAL:'*':Y.UNPAID.BILL.CNT:'*':Y.LOAN.STATUS:'*':Y.DAY.OF.DELAY:'*':Y.COLLATERAL:'*':Y.COLLATERAL:'*':Y.NEXT.REVIEW.DATE:'*':Y.RATE.CHANGE.USER:'*':Y.LAST.RATE.CHANGE.DATE:'*':Y.LAST.REVIEW.DATE:'*':Y.OLD.RATE:'*':Y.LOAN.COND.VALUES:'*':Y.AGING.STATUS
RETURN
*--------------------------------------------------------------------------------------------------------
GET.ARRANGEMENT.DETAILS:
*--------------------------------------------------------------------------------------------------------

    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.LOAN.CO.CODE        = R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
    Y.LOAN.CURRENCY       = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    Y.LOAN.PROD.GROUP     = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    Y.LOAN.PRODUCT        = R.AA.ARRANGEMENT<AA.ARR.PRODUCT,1>
    IF R.AA.ARRANGEMENT<AA.ARR.ORIG.CONTRACT.DATE> THEN
        Y.OPEN.DATE       = R.AA.ARRANGEMENT<AA.ARR.ORIG.CONTRACT.DATE>
    END ELSE
        Y.OPEN.DATE       = R.AA.ARRANGEMENT<AA.ARR.START.DATE>
    END
RETURN
*--------------------------------------------------------------------------------------------------------
GET.CUSTOMER.DETAILS:
*--------------------------------------------------------------------------------------------------------

    EFF.DATE        = ''
    PROP.CLASS      = 'CUSTOMER'
    PROPERTY        = ''
    R.CONDITION.CUS = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.CUS,ERR.MSG);* R22 Manual conversion
    Y.CUS.AFF.COMP  = R.CONDITION.CUS<AA.CUS.LOCAL.REF,POS.L.AA.AFF.COM>
    Y.CUS.CAMP.TYPE = R.CONDITION.CUS<AA.CUS.LOCAL.REF,POS.L.AA.CAMP.TY>
*Y.PRIM.OWNERS   = R.CONDITION.CUS<AA.CUS.PRIMARY.OWNER>:@VM:R.CONDITION.CUS<AA.CUS.OTHER.PARTY>
    Y.PRIM.OWNERS   = R.CONDITION.CUS<AA.CUS.CUSTOMER>:@VM:R.CONDITION.CUS<AA.CUS.OTHER.PARTY>;* R22 Manual conversion
    Y.OWNER.NAMES   = ''
    Y.OWNER.CNT     = DCOUNT(Y.PRIM.OWNERS,@VM)
    Y.PROCESSED.CUS = ''
    Y.OWN.CNT       = 1
    LOOP
    WHILE Y.OWN.CNT LE Y.OWNER.CNT
        Y.CUS.ID = Y.PRIM.OWNERS<1,Y.OWN.CNT>
        IF Y.CUS.ID THEN

            LOCATE Y.CUS.ID IN Y.PROCESSED.CUS<1> SETTING POS.CUS ELSE
                Y.PROCESSED.CUS<-1> = Y.CUS.ID
                CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
                IF R.CUSTOMER<EB.CUS.SHORT.NAME,1> THEN
                    Y.OWNER.NAMES<1,-1> = R.CUSTOMER<EB.CUS.SHORT.NAME,1>
                END
            END
        END

        Y.OWN.CNT += 1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
GET.ACCOUNT.DETAILS:
*--------------------------------------------------------------------------------------------------------

    IN.ACC.ID  = ''
    Y.LOAN.ACC = ''
    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.AA.ID,Y.LOAN.ACC,ERR.TEXT);* R22 Manual conversion

    CALL F.READ(FN.ACCOUNT,Y.LOAN.ACC,R.ACCOUNT,F.ACCOUNT,AC.ERR)
    Y.LEGACY.ID = R.ACCOUNT<AC.ALT.ACCT.ID,1>

RETURN
*--------------------------------------------------------------------------------------------------------
GET.TERM.AMOUNT.DETAILS:
*--------------------------------------------------------------------------------------------------------
    Y.ID = Y.AA.ID:@FM:'YES'
    APAP.TAM.redoGetDisbursementDetails(Y.ID,R.DISB.DETAILS,Y.COMMITED.AMT,Y.PEND.DISB);* R22 Manual conversion
    Y.TOTAL.DISB.AMT = R.DISB.DETAILS<3>

    EFF.DATE        = ''
    PROP.CLASS      = 'TERM.AMOUNT'
    PROPERTY        = ''
    R.CONDITION.TERM = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.TERM,ERR.MSG);* R22 Manual conversion
    Y.COLLATERAL     = R.CONDITION.TERM<AA.AMT.LOCAL.REF,POS.L.AA.COL>
    Y.MATURITY.DATE  = R.CONDITION.TERM<AA.AMT.MATURITY.DATE>

RETURN
*--------------------------------------------------------------------------------------------------------
GET.INTEREST.DETAILS:
*--------------------------------------------------------------------------------------------------------

    PROP.NAME = 'PRINCIPAL'
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,PRIN.PROP,ERR);* R22 Manual conversion

    EFF.DATE        = ''
    PROP.CLASS      = 'INTEREST'
    PROPERTY        = PRIN.PROP
    R.CONDITION.INT = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.INT,ERR.MSG);* R22 Manual conversion

    Y.INT.RATE          = R.CONDITION.INT<AA.INT.EFFECTIVE.RATE,1>
    Y.NEXT.REVIEW.DATE  = R.CONDITION.INT<AA.INT.LOCAL.REF,POS.L.AA.NXT.REV.DT>
    Y.LAST.REVIEW.DATE  = R.CONDITION.INT<AA.INT.LOCAL.REF,POS.L.AA.LST.REV.DT>
    CALL F.READ(FN.REDO.NOTIFY.RATE.CHANGE,Y.AA.ID,R.REDO.NOTIFY.RATE.CHANGE,F.REDO.NOTIFY.RATE.CHANGE,NOT.ERR)

    Y.LAST.RATE.CHANGE.DATE = R.REDO.NOTIFY.RATE.CHANGE<2>
    Y.RATE.CHANGE.USER      = R.REDO.NOTIFY.RATE.CHANGE<6>
    Y.OLD.RATE              = R.REDO.NOTIFY.RATE.CHANGE<3>



RETURN
*--------------------------------------------------------------------------------------------------------
GET.PAYMENT.DETAILS:
*--------------------------------------------------------------------------------------------------------

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ACD.ERR)
    Y.BILL.REFERECES = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.BILL.TYPE      = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>
    Y.SET.STATUS     = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    Y.BILL.DATE      = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.DATE>
    Y.BILL.AMOUNT    = ''
    RET.ERROR = ''
    CHANGE @SM TO @FM IN Y.BILL.REFERECES
    CHANGE @VM TO @FM IN Y.BILL.REFERECES
    CHANGE @SM TO @FM IN Y.BILL.TYPE
    CHANGE @VM TO @FM IN Y.BILL.TYPE
    CHANGE @SM TO @FM IN Y.SET.STATUS
    CHANGE @VM TO @FM IN Y.SET.STATUS
    CHANGE @SM TO @FM IN Y.BILL.DATE
    CHANGE @VM TO @FM IN Y.BILL.DATE

    APAP.TAM.redoGetReportLoanPayamt(Y.AA.ID,Y.REPAY.AMOUNT,Y.DUMMY.VAR1,Y.DUMMY.VAR2);* R22 Manual conversion
    Y.BILL.AMOUNT = Y.REPAY.AMOUNT<1>
*Y.BILL.REF.CNT = DCOUNT(Y.BILL.REFERECES,FM)
*LOOP
*WHILE Y.BILL.REF.CNT GE 1
*IF Y.BILL.TYPE<Y.BILL.REF.CNT> EQ 'PAYMENT' AND Y.BILL.AMOUNT EQ '' THEN
*Y.BILL.ID = Y.BILL.REFERECES<Y.BILL.REF.CNT>
*BILL.DETAILS = ''
*CALL AA.GET.BILL.DETAILS(Y.AA.ID, Y.BILL.ID, BILL.DETAILS, RET.ERROR)
*Y.BILL.AMOUNT = BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>       ;* Last bill amount.
*Y.BILL.REF.CNT = 0          ;* Break
*END
*Y.BILL.REF.CNT--
*REPEAT

    Y.TOTAL.BAL    = 0
    Y.DAY.OF.DELAY = 0
    Y.VAR2 = 1
    Y.BILL.REF.CNT = DCOUNT(Y.BILL.REFERECES,@FM)
    LOOP
    WHILE Y.VAR2 LE Y.BILL.REF.CNT
        Y.BILL.ID = Y.BILL.REFERECES<Y.VAR2>
        IF Y.BILL.TYPE<Y.VAR2> EQ 'PAYMENT' AND Y.SET.STATUS<Y.VAR2> EQ 'UNPAID' THEN
            IF Y.DAY.OF.DELAY ELSE
                YREGION = ''
                YDATE   = Y.BILL.DATE<Y.VAR2>
                YDATE2  = TODAY
                Y.DAY.OF.DELAY   = 'C'
                CALL CDD(YREGION,YDATE,YDATE2,Y.DAY.OF.DELAY)
            END
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
            Y.TOTAL.BAL += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
*Y.VAR2 = Y.BILL.REF.CNT+1
        END

        Y.VAR2 += 1
    REPEAT

    Y.UNPAID.BILL.CNT = COUNT(Y.SET.STATUS,"UNPAID")
RETURN
*-------------------------------------------------------------------------------
GET.LOAN.BALANCES:
*-------------------------------------------------------------------------------

    APAP.TAM.redoGetTotalOutstandingSinUncUnd(Y.AA.ID,Y.PROP.AMT,Y.TOTAL.AMT);* R22 Manual conversion
    Y.ACCOUNT.BAL = Y.PROP.AMT<1>
*Y.TOTAL.BAL   = Y.TOTAL.AMT
RETURN
*-------------------------------------------------------------------------------
GET.OVERDUE.DETAILS:
*-------------------------------------------------------------------------------
    Y.AGING.STATUS = ''
    EFF.DATE    = ''
    PROP.CLASS  = 'OVERDUE'
    PROPERTY    = ''
    R.CONDITION.OVERDUE = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.OVERDUE,ERR.MSG);* R22 Manual conversion
    Y.LOAN.STATUS = R.CONDITION.OVERDUE<AA.OD.LOCAL.REF,POS.L.LOAN.STATUS.1>
    Y.LOAN.COND   = R.CONDITION.OVERDUE<AA.OD.LOCAL.REF,POS.L.LOAN.COND>
    CHANGE @SM TO @VM IN Y.LOAN.COND

    Y.LN.STATUS.ID = 'L.LOAN.STATUS.1*':Y.LOAN.STATUS
    R.EB.LOOKUP = ''
    CALL F.READ(FN.EB.LOOKUP,Y.LN.STATUS.ID,R.EB.LOOKUP,F.EB.LOOKUP,LOOK.ERR)
    IF R.EB.LOOKUP THEN
        IF R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG> THEN
            Y.LOAN.STATUS = R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG>
        END ELSE
            Y.LOAN.STATUS =  R.EB.LOOKUP<EB.LU.DESCRIPTION,1>
        END
    END
    Y.LOAN.AGING.STATUS = R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS>
    Y.LN.AGING.ID       = 'AA.OVERDUE.STATUS*':Y.LOAN.AGING.STATUS
    R.EB.LOOKUP = ''
    CALL F.READ(FN.EB.LOOKUP,Y.LN.AGING.ID,R.EB.LOOKUP,F.EB.LOOKUP,LOOK.ERR)
    IF R.EB.LOOKUP THEN
        IF R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG> THEN
            Y.AGING.STATUS = R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG>
        END ELSE
            Y.AGING.STATUS = R.EB.LOOKUP<EB.LU.DESCRIPTION,1>
        END
    END
    Y.VAR5 = 1
    Y.LOAN.COND.VALUES = ''
    Y.LN.OVR.CNT = DCOUNT(Y.LOAN.COND,@SM)
    LOOP
    WHILE Y.VAR5 LE Y.LN.OVR.CNT
        Y.LOOK.ID = 'L.LOAN.COND*':Y.LOAN.COND<1,1,Y.VAR5>
        R.EB.LOOKUP = ''
        CALL F.READ(FN.EB.LOOKUP,Y.LOOK.ID,R.EB.LOOKUP,F.EB.LOOKUP,LOOK.ERR)
        IF R.EB.LOOKUP THEN
            IF R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG> THEN
                Y.LOAN.COND.VALUES<1,-1> = R.EB.LOOKUP<EB.LU.DESCRIPTION,LNGG>
            END ELSE
                Y.LOAN.COND.VALUES<1,-1> = R.EB.LOOKUP<EB.LU.DESCRIPTION,1>
            END
        END
        Y.VAR5 += 1
    REPEAT


RETURN
END
