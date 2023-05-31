* @ValidationCode : MjoxMTAyNTQzMzgxOkNwMTI1MjoxNjg1NTM0MTQ1MTE1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:25:45
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
$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.POST.POOL.RATE.UPDATION
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is the Post routine for LENDING-NEW-ARRANGEMENT activity
* It updates the value POOL.RATE as per the value SELL.RATE in the local Table REDO.POOL.RATE
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who           Reference            Description
* 01-JUL-2010    Kishore.SP    ODR-2009-10-0325      Initial Creation
* 13 OCT 2011    Prabhu             PACS00139279    Total logic modified
* 27 FEN 2013    Marimuthu S        PACS00250206
* 24 APR 2016    Simbu              PACS00584148
* 16 MAY 2017    Edwin Charles      PACS00585816
*------------------------------------------------------------------------------------
*Modification History:
*Date           Who                 Reference                                  Descripition
* 29-03-2023   Conversion Tool     Auto R22 Code Conversion                  FM TO @FM, VM TO @VM, SM TO @SM
* 29-03-2023     Samaran T          Manual R22 code conversion               Package Name Added APAP.AA, CALL method format changed
*---------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.REDO.POOL.RATE
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.ARRANGEMENT
    $USING APAP.TAM
*-----------------------------------------------------------------------------

    IF c_aalocActivityStatus NE 'UNAUTH' AND c_aalocActivityStatus NE 'UNAUTH-CHG' THEN
        RETURN
    END

    GOSUB INITIALISE
    GOSUB TRIGGER.CHG.PAYSCH.MIGRATE
    GOSUB GET.ACCT.ARRANG.DETAIL

    ARR.ID = Y.ARRG.ID
    Y.BRW = OFS$BROWSER
    Y.FREQ.REVIEW = R.NEW(AA.INT.LOCAL.REF)<1,Y.RATE.REV.FREQ.POS>
    Y.AA.REV.RT.TYPE = R.NEW(AA.INT.LOCAL.REF)<1,Y.REV.RT.TY.POS>
    Y.AA.REV.FORM = R.NEW(AA.INT.LOCAL.REF)<1,Y.REV.FORM.POS>
    IF Y.AA.REV.RT.TYPE EQ 'PERIODICO' AND Y.AA.REV.FORM EQ 'AUTOMATICA' ELSE
        RETURN
    END

    IF (OFS$BROWSER OR RUNNING.UNDER.BATCH) AND (c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> NE 'LENDING-NEW-ARRANGEMENT' AND c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> NE 'LENDING-TAKEOVER-ARRANGEMENT') AND Y.FREQ.REVIEW NE '' THEN
        FREQ = Y.FREQ.REVIEW
        Y.DATE = c_aalocActivityEffDate
        Y.OUT.DATE = ''
        APAP.TAM.redoGetNextCycledate(ARR.ID,FREQ,Y.DATE,Y.OUT.DATE);* R22 Manual conversion
* PACS00585816 - start
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.NXT.REV.DT> = Y.OUT.DATE
*        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.NXT.REV.DT> = Y.DATE
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.LST.REV.DT> = c_aalocActivityEffDate
* PACS00585816 - End
    END

RETURN
*-----------------------------------------------------------------------------
INITIALISE:
*----------
*Get the Needed Local Field Values
*

*
    LOC.REF.APPL="AA.PRD.DES.INTEREST":@FM:"AA.PRD.DES.PAYMENT.SCHEDULE":@FM:"COLLATERAL" ;*AUTO R22 CODE CONVERSION
    LOC.REF.FIELDS="L.AA.POOL.RATE":@VM:"L.AA.RT.RV.FREQ":@VM:'L.AA.LST.REV.DT':@VM:'L.AA.NXT.REV.DT':@VM:'L.AA.REV.FORM':@VM:'L.AA.REV.RT.TY':@FM:'L.MIGRATED.LN':@FM:'L.COL.NUM.INSTR' ;*AUTO R22 CODE CONVERSION
    LOC.REF.POS=""
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.POOL.RATE.POS      = LOC.REF.POS<1,1>
    Y.RATE.REV.FREQ.POS  = LOC.REF.POS<1,2>
    POS.L.AA.LST.REV.DT  = LOC.REF.POS<1,3>
    POS.L.AA.NXT.REV.DT  = LOC.REF.POS<1,4>
    Y.REV.RT.TY.POS      = LOC.REF.POS<1,6>
    Y.REV.FORM.POS       = LOC.REF.POS<1,5>
    POS.L.MIGRATED.LN    = LOC.REF.POS<2,1>
    CL.INST.POS          = LOC.REF.POS<3,1>
*
    Y.FLAG     = ''
    Y.DATE = ''

RETURN
*-----------------------------------------------------------------------------
GET.ACCT.ARRANG.DETAIL:
*----------------------
* Get the Account Details of the Arrangement
*


    Y.ARRG.ID      = c_aalocArrId
    Y.CURRENCY     = c_aalocArrCurrency

    GOSUB GET.INTEREST.DATA
*
* If Nothing matches with the local table then the pool rate is updated with '0' value
*
    IF Y.FLAG NE '1' THEN
        R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS>  = '0'
    END
RETURN
*-----------------------------------------------------------------------------
GET.INTEREST.DATA:
*----------------
*
*
    IF R.NEW(AA.INT.LOCAL.REF)<1,Y.REV.RT.TY.POS> EQ 'BACK.TO.BACK' THEN
        Y.RATE = ''
        GOSUB GET.BACK.TO.BANK.RATE
        IF Y.RATE<1> THEN
            Y.FLAG = 1
            GOSUB MULTI.IF
        END
        RETURN
    END

    IF R.NEW(AA.INT.LOCAL.REF)<1,Y.REV.RT.TY.POS> EQ 'FIJO' AND R.NEW(AA.INT.LOCAL.REF)<1,Y.REV.FORM.POS> EQ 'MANUAL' THEN
        GOSUB GET.FIXED.LOAN.RATE
        IF Y.RATE<1> THEN
            Y.FLAG = 1
            GOSUB MULTI.IF
        END
        RETURN
    END
    Y.REVIEW.FREQ =  R.NEW(AA.INT.LOCAL.REF)<1,Y.RATE.REV.FREQ.POS>
    IF Y.REVIEW.FREQ NE '' THEN
        Y.RATE = ''
        APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.RATE);* R22 Manual conversion
        IF Y.RATE<1> THEN
            Y.FLAG = 1
            GOSUB MULTI.IF
        END
    END


RETURN

MULTI.IF:

    IF R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> NE Y.RATE<1> THEN
        IF R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> EQ '' OR R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> EQ R.OLD(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> THEN
            R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> = Y.RATE<1>
        END
        IF R.NEW(AA.INT.LOCAL.REF)<1,Y.POOL.RATE.POS> NE Y.RATE<1> THEN
            Y.CUR.NO = ''
            TEXT = 'REDO.MOD.TASA.POOL'
            CALL STORE.OVERRIDE(Y.CUR.NO)
        END
    END

RETURN
*---------------------------------------------------
TRIGGER.CHG.PAYSCH.MIGRATE:
*---------------------------------------------------
* Trigger Change Pay sch activity to nullify the actual amount for constant payment type

    Y.TRIGGER.SECONDARY = ''

    IF (c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> NE 'LENDING-NEW-ARRANGEMENT') ELSE         ;* Skip the below part if that is lending new arrangement
        RETURN
    END
    IF R.NEW(AA.INT.EFFECTIVE.RATE) EQ R.OLD(AA.INT.EFFECTIVE.RATE) THEN
        RETURN
    END

    GOSUB GET.PAY.SCH

    Y.L.MIGRATED.LN = R.CONDITION<AA.PS.LOCAL.REF,POS.L.MIGRATED.LN>

    IF Y.L.MIGRATED.LN EQ 'YES' ELSE
        RETURN
    END
    Y.PAYMNT.TYPE = R.CONDITION<AA.PS.PAYMENT.TYPE>
    Y.CNT = DCOUNT(Y.PAYMNT.TYPE,@VM) ; FLG = '' ;*AUTO R22 CODE CONVERSION

    LOOP
    WHILE Y.CNT GT 0 DO
        FLG += 1
        Y.PROP.VLS = R.CONDITION<AA.PS.PROPERTY,FLG>
        Y.PROP.VLS = CHANGE(Y.PROP.VLS,@SM,@VM) ;*AUTO R22 CODE CONVERSION

        Y.SET = 'Y'
        LOCATE 'ACCOUNT' IN Y.PROP.VLS<1,1> SETTING POS.AC THEN
            LOCATE 'PRINCIPALINT' IN Y.PROP.VLS<1,1> SETTING POS.IN THEN
                IF R.CONDITION<AA.PS.ACTUAL.AMT,FLG> THEN
                    Y.TRIGGER.SECONDARY = 'YES'
                    Y.CNT = -1          ;* Break the loop
                END
            END
        END
        Y.CNT -= 1
    REPEAT
    IF Y.TRIGGER.SECONDARY EQ 'YES' THEN
        AAA.FIELDS.REC  = ''
        NEW.ACTIVITY.ID = 'CHANGE.PAYSCH.MIGRATED'
        RETURN.ERROR    = ''
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(c_aalocArrId, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)

    END

RETURN
*---------------------------------------------------
GET.PAY.SCH:
*---------------------------------------------------

    EFF.DATE     = c_aalocActivityEffDate
    PROP.CLASS   = 'PAYMENT.SCHEDULE'
    PROPERTY     = ''
    R.CONDITION  = ''
    ERR.MSG      = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

RETURN
*---------------------------------------------------
OPEN.FILES:
*---------------------------------------------------


    FN.RIGHT.COLLATERAL = 'F.RIGHT.COLLATERAL'
    F.RIGHT.COLLATERAL  = ''
    CALL OPF(FN.RIGHT.COLLATERAL,F.RIGHT.COLLATERAL)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL  = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.LI.COLLATERAL.RIGHT = 'F.LI.COLLATERAL.RIGHT'
    F.LI.COLLATERAL.RIGHT  = ''
    CALL OPF(FN.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT)
    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    F.AZ.ACCOUNT  = ''
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)

RETURN
*---------------------------------------------------
GET.BACK.TO.BANK.RATE:
*---------------------------------------------------
* Back to Back Loan, Pool rate Calculation

    GOSUB OPEN.FILES

    EFF.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'LIMIT'
    PROPERTY    = ''
    R.LIMIT.CONDITION = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,PROP.CLASS,PROPERTY,R.LIMIT.CONDITION,ERR.MSG);* R22 Manual conversion
    Y.LIMIT.REFERENCE = R.LIMIT.CONDITION<AA.LIM.LIMIT.REFERENCE>
*AA Changes 20161013
    Y.LIMIT.SERIAL = R.LIMIT.CONDITION<AA.LIM.LIMIT.SERIAL>
*AA Changes 20161013
    IF Y.LIMIT.REFERENCE EQ '' THEN
        RETURN
    END ELSE
*AA Changes 20161013
*    REF.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',1,1),"7'0'R")
*    SEQ.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',2,1),"2'0'R")
        REF.NO = FMT(Y.LIMIT.REFERENCE,"7'0'R")
        SEQ.NO = Y.LIMIT.SERIAL
*AA Changes 20161013
        Y.LIMIT.ID = c_aalocArrangementRec<AA.ARR.CUSTOMER>:".":REF.NO:".":SEQ.NO
    END
    CALL F.READ(FN.LI.COLLATERAL.RIGHT,Y.LIMIT.ID,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,ERR.LI.COLLATERAL.RIGHT)
    Y.COLLATERAL.IDS = ''
    Y.LI.COL.CNT=DCOUNT(R.LI.COLLATERAL.RIGHT,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.LI.COL.CNT
        Y.COLLATERAL.RIGHT.ID=R.LI.COLLATERAL.RIGHT<Y.VAR1>
        CALL F.READ(FN.RIGHT.COLLATERAL,Y.COLLATERAL.RIGHT.ID,R.RIGHT.COLLATERAL.ARR,F.RIGHT.COLLATERAL,ERR.RIGHT.COLLATERAL)
        Y.COLLATERAL.IDS<-1>=R.RIGHT.COLLATERAL.ARR
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    Y.ACC.RATE = ''
    Y.HIGH.AZ.RATE = ''
    Y.OLD.TERM     = ''
    Y.COLLATERAL.CNT=DCOUNT(Y.COLLATERAL.IDS,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.COLLATERAL.CNT
        Y.COLL.ID=Y.COLLATERAL.IDS<Y.VAR1>
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,ERR.COLLATERAL)
        Y.ACCOUNT.ID = R.COLLATERAL<COLL.APPLICATION.ID>
        IF Y.ACCOUNT.ID EQ '' THEN
            Y.ACCOUNT.ID = R.COLLATERAL<COLL.LOCAL.REF,CL.INST.POS>
        END
        IF Y.ACCOUNT.ID THEN
            GOSUB GET.RATE

        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

    Y.RATE = Y.ACC.RATE

RETURN
*-----------------------------------------------------------
GET.RATE:

*-----------------------------------------------------------
* Here we get the rate of individual account
*Note: Loan can either have Savings account or AZ as collateral. Not together

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    IF R.ACCOUNT ELSE
        RETURN
    END
    IF R.ACCOUNT<AC.ALL.IN.ONE.PRODUCT> THEN
        GOSUB GET.AZ.RATE
    END ELSE
        Y.ACC.CURRENCY = R.ACCOUNT<AC.CURRENCY>
        GOSUB GET.SAVINGS.RATE
    END

RETURN
*---------------------------------------------------------
GET.AZ.RATE:
*---------------------------------------------------------
    CALL F.READ(FN.AZ.ACCOUNT,Y.ACCOUNT.ID,R.AZ.ACCOUNT,F.AZ.ACCOUNT,ERR.AZ.ACCOUNT)
    Y.START.DATE = R.AZ.ACCOUNT<AZ.VALUE.DATE>
    Y.END.DATE   = R.AZ.ACCOUNT<AZ.MATURITY.DATE>
    Y.CURRENCY   = R.AZ.ACCOUNT<AZ.CURRENCY>
    Y.AZ.INTEREST= R.AZ.ACCOUNT<AZ.INTEREST.RATE>


    IF Y.AZ.INTEREST LT Y.HIGH.AZ.RATE AND Y.HIGH.AZ.RATE NE '' THEN
        RETURN
    END   ;* If the interest rate is greator than already process AZ then calculate the rate

    IF Y.START.DATE AND Y.END.DATE THEN
        YREGION = ''
        YDAYS   = 'C'
        CALL CDD(YREGION,Y.START.DATE,Y.END.DATE,YDAYS)
    END
    IF Y.AZ.INTEREST EQ Y.HIGH.AZ.RATE AND Y.HIGH.AZ.RATE NE '' THEN  ;* here we check for cond with two deposit with same int rate but diff term
* We need to assign pool rate based on the lowest deposit term
        IF Y.OLD.TERM LT YDAYS THEN
            RETURN  ;* We need to calculate the rate when deposit has short term
        END

    END
    IF YDAYS THEN
        Y.REVIEW.FREQ = YDAYS:'D'
        Y.AZ.RATE = ''
        APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.AZ.RATE);* R22 Manual conversion
        Y.ACC.RATE = Y.AZ.RATE<1>
        Y.HIGH.AZ.RATE = Y.AZ.INTEREST
        Y.OLD.TERM     = YDAYS
    END
RETURN
*---------------------------------------------------------
GET.SAVINGS.RATE:
*---------------------------------------------------------

    GOSUB GET.LOAN.TERM
    Y.CURRENCY    = c_aalocArrCurrency
    Y.REVIEW.FREQ = Y.LOAN.TERM
    Y.RATE.VALUE  = ''
    APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.RATE.VALUE);* R22 Manual conversion
    Y.ACC.RATE = Y.RATE.VALUE<1>

RETURN
*---------------------------------------------------------
GET.FIXED.LOAN.RATE:
*---------------------------------------------------------
* Pool rate needs to be calculated for the Loan's term and default as Pool rate

    GOSUB GET.LOAN.TERM
    Y.CURRENCY    = c_aalocArrCurrency
    Y.REVIEW.FREQ = Y.LOAN.TERM
    Y.RATE.VALUE  = ''
    APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.RATE.VALUE);* R22 Manual conversion
    Y.RATE = Y.RATE.VALUE

RETURN
*---------------------------------------------------------
GET.LOAN.TERM:
*---------------------------------------------------------
* Get the Term of the Loan

    APAP.TAM.redoGetLoanTerm(c_aalocArrId,c_aalocActivityEffDate,Y.LOAN.TERM);* R22 Manual conversion

RETURN
END
