* @ValidationCode : MjotOTExODY1NDQ2OkNwMTI1MjoxNjg1NTMxMjQ1Njg5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:37:25
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
$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.PENALTY.NEXT.CYCLEDATE(Y.ID.DETAILS,Y.DETAILS,R.PAY.SCH,Y.CYCLE,Y.CHARGE.AMOUNT)
*-----------------------------------------------------------
* Description: Routine to calculate the no of cycle that has been crossed
*-----------------------------------------------------------

*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : Call Routine.
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 01-NOV-2011     H GANESH     ODR-2011-08-0106 CR-PENALTY CHARGE            Initial Draft
*29-03-2023      CONVERSION TOOL         AUTO R22 CODE CONVERSION          SM TO @SM, VM TO @VM ,++ TO +=1
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.OVERDUE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
*TUS AA Changes - 20161019
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
*TUS END

    GOSUB INIT
    GOSUB PROCESS
RETURN
*------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------
    Y.CHARGE.AMOUNT    = 0
    Y.CHARGE.FREQ      = FIELD(Y.DETAILS,'*',1)
    Y.PROPERTY.LIST    = FIELD(Y.DETAILS,'*',2)
    Y.CHARGE.PER       = FIELD(Y.DETAILS,'*',3)
    Y.AA.ID            = FIELD(Y.ID.DETAILS,'*',1)
    Y.BILL.ID          = FIELD(Y.ID.DETAILS,'*',2)
    Y.CHG.FLG = ''
    IF Y.AA.ID AND Y.BILL.ID ELSE
        RETURN
    END
    GOSUB GET.MATURITY.DATE

    GOSUB BILL.DETAILS
    Y.LEN = LEN(Y.CHARGE.FREQ)
    Y.FREQ = Y.CHARGE.FREQ[Y.LEN,1]
    Y.FREQ.TERM = Y.CHARGE.FREQ[1,Y.LEN-1]
*TUS AA Changes - 20161019
    EFF.DATE                        = ''
    PROP.CLASS        = 'ACCOUNT'
    PROPERTY          = ''
    R.AA.ACC  = ''
    ERR.MSG           = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.AA.ACC,ERR.MSG);* R22 Manual conversion

*  DATE.CONVENTION = R.PAY.SCH<AA.PS.DATE.CONVENTION>
*  DATE.ADJUSTMENT = R.PAY.SCH<AA.PS.DATE.ADJUSTMENT>
*  BUS.DAYS = R.PAY.SCH<AA.PS.BUS.DAY.CENTRES,1>

    DATE.CONVENTION = R.AA.ACC<AA.AC.DATE.CONVENTION>
    DATE.ADJUSTMENT = R.AA.ACC<AA.AC.DATE.ADJUSTMENT>
    BUS.DAYS = R.AA.ACC<AA.AC.BUS.DAY.CENTRES,1>
*TUS END
    IF DATE.CONVENTION ELSE
        DATE.CONVENTION = 'CALENDAR'
    END
    IF Y.CYCLE EQ 1 THEN
        GOSUB GET.OVERDUE.COND
    END
    GOSUB FIND.DATE

    IF Y.FINAL.DATE ELSE
        Y.FINAL.DATE = Y.PAYMENT.DATE
    END

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------

    Y.VAR1 = 1
    Y.CNT = 1
    LOOP
    WHILE Y.CNT
        GOSUB CALC.FREQ
        CALL AA.GET.RECALC.DATE(Y.FINAL.FREQ, DATE.CONVENTION, DATE.ADJUSTMENT, BUS.DAYS, Y.FINAL.DATE, NEXT.CYCLE.DATE, RETURN.ERROR)
        IF NEXT.CYCLE.DATE[1,6] EQ Y.FINAL.DATE[1,6] OR Y.MATURITY.DATE EQ Y.PAYMENT.DATE THEN          ;* In case of the Freq has 'On day' (...e1M...o16D...), In case of the bill which is not on the 'On day' lets say maturity date bill. then next
*       date falls on same month instead of next month. For mora calculation we need one month time. so we need to pass normal 1M freq to calculate next date.
*       For the PACS - PACS00344333, Last bill of the loan doesnt need to follow 'On date' frequency. consecutive mora needs to be calculated on same day of the last bill.

            GOSUB CALC.FREQ.NEW
            CALL AA.GET.RECALC.DATE(Y.FINAL.FREQ, DATE.CONVENTION, DATE.ADJUSTMENT, BUS.DAYS, Y.FINAL.DATE, NEXT.CYCLE.DATE, RETURN.ERROR)
        END
        IF NEXT.CYCLE.DATE GT TODAY THEN
            Y.CNT = 0
        END ELSE
            Y.BILL.CALC.DATE = NEXT.CYCLE.DATE
            GOSUB GET.BALANCE
            Y.CHARGE.AMOUNT += (Y.BALANCE*Y.CHARGE.PER)/100
*CRT Y.BILL.ID :"-":Y.PAYMENT.DATE:' - ':NEXT.CYCLE.DATE :' - ' :Y.CHARGE.AMOUNT
            Y.CYCLE += 1 ;*AUTO R22 CODE CONVERSION
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    IF Y.CHG.FLG NE '1' THEN

        Y.CHARGE.AMOUNT = 0

    END
RETURN

*------------------------------------------------------------------------
CALC.FREQ:
*------------------------------------------------------------------------
    Y.FREQ.NUM = Y.FREQ.TERM*Y.VAR1
    Y.REPLACE.VALUE = 'e0D'     ;* Since the day specified in payment schedule. we have prob.

    BEGIN CASE
        CASE Y.FREQ EQ 'Y'
            Y.FINAL.FREQ     = 'e':Y.FREQ.NUM:'Y e0M e0W e0D e0F'
            Y.REPLACED.VALUE = FIELD(Y.PAY.FREQ,' ',4)
            Y.FINAL.FREQ     = EREPLACE(Y.FINAL.FREQ,Y.REPLACE.VALUE,Y.REPLACED.VALUE)
        CASE Y.FREQ EQ 'M'
            Y.FINAL.FREQ = 'e0Y e':Y.FREQ.NUM:'M e0W e0D e0F'
            Y.REPLACED.VALUE = FIELD(Y.PAY.FREQ,' ',4)
            Y.FINAL.FREQ     = EREPLACE(Y.FINAL.FREQ,Y.REPLACE.VALUE,Y.REPLACED.VALUE)
        CASE Y.FREQ EQ 'W'
            Y.FINAL.FREQ = 'e0Y e0M e':Y.FREQ.NUM:'W e0D e0F'
            Y.REPLACED.VALUE = FIELD(Y.PAY.FREQ,' ',4)
            Y.FINAL.FREQ     = EREPLACE(Y.FINAL.FREQ,Y.REPLACE.VALUE,Y.REPLACED.VALUE)
        CASE Y.FREQ EQ 'D'          ;* No need in case of days.
            Y.FINAL.FREQ = 'e0Y e0M e0W e':Y.FREQ.NUM:'D e0F'
    END CASE

RETURN
*------------------------------------------------------------------------
CALC.FREQ.NEW:
*------------------------------------------------------------------------
* New frequency formation in case of the 'On day' issue - PACS00323888.
    Y.FREQ.NUM = Y.FREQ.TERM*Y.VAR1
    BEGIN CASE
        CASE Y.FREQ EQ 'Y'
            Y.FINAL.FREQ = 'e':Y.FREQ.NUM:'Y e0M e0W e0D e0F'
        CASE Y.FREQ EQ 'M'
            Y.FINAL.FREQ = 'e0Y e':Y.FREQ.NUM:'M e0W e0D e0F'
        CASE Y.FREQ EQ 'W'
            Y.FINAL.FREQ = 'e0Y e0M e':Y.FREQ.NUM:'W e0D e0F'
        CASE Y.FREQ EQ 'D'
            Y.FINAL.FREQ = 'e0Y e0M e0W e':Y.FREQ.NUM:'D e0F'
    END CASE

RETURN
*-----------------------------
FIND.DATE:
*-----------------------------
*TUS AA Changes - 20161019
    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.ACC.DET,F.AA.ACCOUNT.DETAILS,ACC.DET.ERR)

    Y.PAY.START.DATE = R.PAY.SCH<AA.PS.BASE.DATE>
*  Y.PAY.END.DATE   = R.PAY.SCH<AA.PS.PAYMENT.END.DATE>
    Y.PAY.END.DATE   = R.ACC.DET<AA.AD.PAYMENT.END.DATE>
*TUS END
    Y.PAY.FREQ       = R.PAY.SCH<AA.PS.PAYMENT.FREQ,1>
    Y.FINAL.DATE = ''
    IF Y.PAY.START.DATE AND Y.PAY.END.DATE AND Y.PAY.FREQ ELSE
        RETURN
    END

    Y.LOOP = 1
    LOOP
    WHILE Y.LOOP

        CALL AA.GET.RECALC.DATE(Y.PAY.FREQ, DATE.CONVENTION, DATE.ADJUSTMENT, BUS.DAYS, Y.PAY.START.DATE, NEXT.PAY.DATE, RETURN.ERROR)
        CALL AA.GET.RECALC.DATE(Y.PAY.FREQ, 'CALENDAR', DATE.ADJUSTMENT, BUS.DAY, Y.PAY.START.DATE, Y.CORRECT.DATE, RETURN.ERROR)
        IF NEXT.PAY.DATE EQ Y.PAYMENT.DATE THEN
            Y.FINAL.DATE = Y.CORRECT.DATE
            Y.LOOP = 0
        END
        Y.PAY.START.DATE = Y.CORRECT.DATE

        IF NEXT.PAY.DATE GT Y.PAY.END.DATE THEN
            Y.LOOP = 0
        END
    REPEAT
RETURN
*----------------------------------------------------------
BILL.DETAILS:
*----------------------------------------------------------
    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS  = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
    Y.PAYMENT.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>

RETURN
*----------------------------------------------------------
GET.BALANCE:
*----------------------------------------------------------
    Y.BALANCE = 0
    Y.BILL.AMT = 0
    Y.VAR2 = 1
    Y.PROPERTIES.CNT = DCOUNT(Y.PROPERTY.LIST,@FM) ;*AUTO R22 CODE CONVERSION
    LOOP
    WHILE Y.VAR2 LE Y.PROPERTIES.CNT
        Y.PROP = Y.PROPERTY.LIST<Y.VAR2>
        LOCATE Y.PROP IN R.AA.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING PROP.POS THEN
            GOSUB GET.AMOUNT

        END
        Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------
GET.AMOUNT:
*----------------------------------------------------------
    Y.ACTUAL.AMT = R.AA.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,PROP.POS>
    Y.OS.PROP.AMT = R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,PROP.POS>

    IF Y.PROP EQ 'ACCOUNT' OR Y.PROP EQ 'PRINCIPALINT' THEN
        IF Y.OS.PROP.AMT NE '0.00' THEN

            Y.CHG.FLG = 1

        END
    END

    Y.VAR3 = 1
    Y.REPAY.REF = R.AA.BILL.DETAILS<AA.BD.REPAY.REF,PROP.POS>
    Y.REPAY.AMT = R.AA.BILL.DETAILS<AA.BD.REPAY.AMOUNT,PROP.POS>
    IF Y.REPAY.REF EQ '' AND Y.REPAY.AMT EQ '' THEN
        Y.BALANCE+ = Y.ACTUAL.AMT
        RETURN
    END
    Y.REPAY.CNT = DCOUNT(Y.REPAY.REF,@SM) ;*AUTO R22 CODE CONVERSION
    LOOP
    WHILE Y.VAR3 LE Y.REPAY.CNT
        Y.REPAY.DATE = FIELD(Y.REPAY.REF<1,1,Y.VAR3>,'-',2)
        IF Y.BILL.CALC.DATE GE Y.REPAY.DATE THEN
            Y.BALANCE+ = Y.ACTUAL.AMT - Y.REPAY.AMT<1,1,Y.VAR3>
        END ELSE
            Y.BALANCE+ = Y.ACTUAL.AMT
        END
        Y.VAR3 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------
GET.OVERDUE.COND:
*----------------------------------------------------------

    IF c_aalocActivityEffDate THEN
        EFF.DATE     = c_aalocActivityEffDate
    END ELSE
        EFF.DATE     = ''
    END

    PROP.CLASS   = 'OVERDUE'
    PROPERTY     = ''
    R.CONDITION  = ''
    ERR.MSG      = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
    GOSUB GET.PENALTY.AGE
    LOCATE Y.PENALTY.AGE IN R.CONDITION<AA.OD.OVERDUE.STATUS,1,1> SETTING OVER.POS THEN
        Y.NO.OF.DAYS = R.CONDITION<AA.OD.AGEING,1,OVER.POS>
    END ELSE
        Y.NO.OF.DAYS = R.CONDITION<AA.OD.AGEING,1,1>    ;* If that is not parametered then 1st aging days will be taken.
    END
    IF Y.NO.OF.DAYS THEN
        YREGION = ''
        YDATE = Y.PAYMENT.DATE
        YDAYS.ORIG = '+':Y.NO.OF.DAYS:'C'
        CALL CDT(YREGION,YDATE,YDAYS.ORIG)

        IF LEN(YDATE) EQ 8 THEN
            Y.BILL.CALC.DATE = YDATE
            GOSUB GET.BALANCE
            Y.CHARGE.AMOUNT += (Y.BALANCE*Y.CHARGE.PER)/100
        END

    END

RETURN
*-----------------------------------------
GET.PENALTY.AGE:
*-----------------------------------------
    Y.PENALTY.AGE = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM  = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    Y.PENALTY.AGE = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.AGE>
RETURN
*-----------------------------------------
GET.MATURITY.DATE:
*-----------------------------------------
    IF c_aalocActivityEffDate THEN
        EFF.DATE      = c_aalocActivityEffDate
    END ELSE
        EFF.DATE      = ''
    END

    PROP.CLASS        = 'TERM.AMOUNT'
    PROPERTY          = ''
    R.CONDITION.TERM  = ''
    ERR.MSG           = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.TERM,ERR.MSG);* R22 Manual conversion

    Y.MATURITY.DATE   = R.CONDITION.TERM<AA.AMT.MATURITY.DATE>

RETURN
END
