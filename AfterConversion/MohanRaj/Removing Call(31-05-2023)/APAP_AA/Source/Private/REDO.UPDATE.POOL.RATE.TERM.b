* @ValidationCode : MjotMTc0MjUzOTk5OTpDcDEyNTI6MTY4NTUzMjY3MzQxOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 17:01:13
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
SUBROUTINE REDO.UPDATE.POOL.RATE.TERM
*-------------------------------------------------------
*Description: This routine is to update pool rate when term of loan
* is changed. where loan is backed by savings product as collateral or
* review freq is fixed.
*Modification History
** 29-03-2023 Convesion tool        R22 Auto Conversion         FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda                R22 Manual Conversion       CALL method format changed
*-------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $USING APAP.TAM

    GOSUB GET.LOCAL.REF
    IF c_aalocActivityStatus EQ 'UNAUTH' AND c_aalocPropClassId EQ 'TERM.AMOUNT' THEN     ;* This needs to be attached for TERM AMOUNT prop.
        IF R.NEW(AA.AMT.TERM) NE R.OLD(AA.AMT.TERM) AND R.OLD(AA.AMT.TERM) NE '' THEN     ;* Needs to be triggered only when Term is changed.
            GOSUB PROCESS
        END
        IF R.NEW(AA.AMT.LOCAL.REF)<1,POS.L.AA.COL> NE R.OLD(AA.AMT.LOCAL.REF)<1,POS.L.AA.COL> AND c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-UPDATE-TERM.AMOUNT' THEN
            GOSUB PROCESS
        END
    END
RETURN

*-------------------------------------------------------
PROCESS:
*-------------------------------------------------------

    Y.AA.ID = c_aalocArrId
    GOSUB OPEN.FILES
    GOSUB GET.INTEREST.PROP

    IF R.PRIN.COND<AA.INT.LOCAL.REF,POS.L.AA.REV.RT.TY> EQ 'BACK.TO.BACK' THEN
        GOSUB BACK.TO.BACK.PROCESS
    END
    IF R.PRIN.COND<AA.INT.LOCAL.REF,POS.L.AA.REV.RT.TY> EQ 'FIJO' AND R.PRIN.COND<AA.INT.LOCAL.REF,POS.L.AA.REV.FORM> EQ 'MANUAL' THEN
        GOSUB FIXED.TYPE.PROCESS
    END

RETURN
*-------------------------------------------------------
BACK.TO.BACK.PROCESS:
*-------------------------------------------------------
    GOSUB GET.LIMIT.REF
    IF Y.LIMIT.REFERENCE ELSE
        RETURN      ;* No collateral attached.
    END
*AA Changes 20161013
*  REF.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',1,1),"7'0'R")
*  SEQ.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',2,1),"2'0'R")
    REF.NO = FMT(Y.LIMIT.REFERENCE,"7'0'R")
    SEQ.NO = Y.LIMIT.SERIAL
*AA Changes 20161013
    Y.LIMIT.ID = c_aalocArrangementRec<AA.ARR.CUSTOMER>:".":REF.NO:".":SEQ.NO
    CALL F.READ(FN.LI.COLLATERAL.RIGHT,Y.LIMIT.ID,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,ERR.LI.COLLATERAL.RIGHT)
    Y.COLLATERAL.IDS = ''
    Y.LI.COL.CNT=DCOUNT(R.LI.COLLATERAL.RIGHT,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.LI.COL.CNT
        Y.COLLATERAL.RIGHT.ID=R.LI.COLLATERAL.RIGHT<Y.VAR1>
        CALL F.READ(FN.RIGHT.COLLATERAL,Y.COLLATERAL.RIGHT.ID,R.RIGHT.COLLATERAL.ARR,F.RIGHT.COLLATERAL,ERR.RIGHT.COLLATERAL)
        Y.COLLATERAL.IDS<-1>=R.RIGHT.COLLATERAL.ARR
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
    Y.ACC.RATE = 0
    Y.SAVINGS.FLAG = ''
    Y.DEPOSIT.FLAG = ''
    Y.HIGH.AZ.RATE = ''
    Y.OLD.TERM     = ''
    Y.COLLATERAL.CNT=DCOUNT(Y.COLLATERAL.IDS,@FM)
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
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

    IF Y.SAVINGS.FLAG EQ 'YES' AND c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-CHANGE.TERM-TERM.AMOUNT' THEN     ;* When term of the loan is changed and it is backed by Savings acc as collateral then we need to update pool rate.
        GOSUB UPDATE.POOL.RATE
    END
    IF (Y.DEPOSIT.FLAG EQ 'YES' OR Y.SAVINGS.FLAG EQ 'YES') AND c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-UPDATE-TERM.AMOUNT' THEN
        GOSUB UPDATE.POOL.RATE
    END
RETURN
*------------------------------------------------------------------
FIXED.TYPE.PROCESS:
*------------------------------------------------------------------

* Pool rate needs to be calculated for the Loan's term and default as Pool rate.

    GOSUB GET.LOAN.TERM
    Y.CURRENCY    = c_aalocArrCurrency
    Y.REVIEW.FREQ = Y.LOAN.TERM
    Y.RATE.VALUE  = ''
    APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.RATE.VALUE);* R22 Manual conversion
    Y.ACC.RATE    = Y.RATE.VALUE<1>
    GOSUB UPDATE.POOL.RATE

RETURN
*-------------------------------------------------------
UPDATE.POOL.RATE:
*-------------------------------------------------------
    IF Y.ACC.RATE NE R.PRIN.COND<AA.INT.LOCAL.REF,POS.L.AA.POOL.RATE> THEN

        ARR.PROPERTY.LIST            =  Y.PRIN.PROP
        ARR.FIELD.NAME.LIST          = 'L.AA.POOL.RATE'
        ARR.FIELD.VALUE.LIST         =  Y.ACC.RATE
        AAA.FIELDS.REC               = ''
        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)

        NEW.ACTIVITY.ID = 'REDO.POOL.PRINCIPAL'
        RETURN.ERROR    = ''
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(c_aalocArrId, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)
    END
    IF Y.ACC.RATE NE R.PENAL.COND<AA.INT.LOCAL.REF,POS.L.AA.POOL.RATE> THEN

        ARR.PROPERTY.LIST            =  Y.PENALTY.PROP
        ARR.FIELD.NAME.LIST          = 'L.AA.POOL.RATE'
        ARR.FIELD.VALUE.LIST         =  Y.ACC.RATE
        AAA.FIELDS.REC               = ''
        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)

        NEW.ACTIVITY.ID = 'REDO.POOL.PENALTY'
        RETURN.ERROR    = ''
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(c_aalocArrId, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)
    END

RETURN
*-------------------------------------------------------
GET.RATE:
*-------------------------------------------------------

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    IF R.ACCOUNT ELSE
        RETURN
    END
    IF R.ACCOUNT<AC.ALL.IN.ONE.PRODUCT> EQ '' THEN          ;* Only when it is savings account.
        Y.SAVINGS.FLAG = 'YES'
        Y.ACC.CURRENCY = R.ACCOUNT<AC.CURRENCY>
        GOSUB GET.SAVINGS.RATE
    END ELSE
        Y.DEPOSIT.FLAG = 'YES'
        GOSUB GET.AZ.RATE

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
    END   ;* If the interest rate is greator than already process AZ then calculate the rate.

    IF Y.START.DATE AND Y.END.DATE THEN
        YREGION = ''
        YDAYS   = 'C'
        CALL CDD(YREGION,Y.START.DATE,Y.END.DATE,YDAYS)
    END
    IF Y.AZ.INTEREST EQ Y.HIGH.AZ.RATE AND Y.HIGH.AZ.RATE NE '' THEN  ;* here we check for cond with two deposit with same int rate but diff term
* We need to assign pool rate based on the lowest deposit term.
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
GET.LOAN.TERM:
*---------------------------------------------------------
* Get the Term of the Loan.

    Y.LOAN.TERM = R.NEW(AA.AMT.TERM)

RETURN
*-------------------------------------------------------
GET.LIMIT.REF:
*-------------------------------------------------------

    EFF.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'LIMIT'
    PROPERTY    = ''
    R.LIMIT.CONDITION = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,PROP.CLASS,PROPERTY,R.LIMIT.CONDITION,ERR.MSG)
    Y.LIMIT.REFERENCE = R.LIMIT.CONDITION<AA.LIM.LIMIT.REFERENCE>
*AA Chnages 20161013
    Y.LIMIT.SERIAL = R.LIMIT.CONDITION<AA.LIM.LIMIT.SERIAL>
*AA Chnages 20161013
RETURN
*-------------------------------------------------------
GET.INTEREST.PROP:
*-------------------------------------------------------
* Here we get the interest property.

    PROP.NAME   = 'PRINCIPAL'
    Y.PRIN.PROP = ''
    ERR         = ''
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,Y.PRIN.PROP,ERR);* R22 Manual conversion

    PROP.NAME      = 'PENALTY'
    Y.PENALTY.PROP = ''
    ERR            = ''
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,Y.PENALTY.PROP,ERR);* R22 Manual conversion

    EFF.DATE           = c_aalocActivityEffDate
    PROP.CLASS         = 'INTEREST'
    PROPERTY           = Y.PRIN.PROP
    R.PRIN.COND        = ''
    ERR.MSG            = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.PRIN.COND,ERR.MSG);* R22 Manual conversion

    EFF.DATE           = c_aalocActivityEffDate
    PROP.CLASS         = 'INTEREST'
    PROPERTY           = Y.PENALTY.PROP
    R.PENAL.COND       = ''
    ERR.MSG            = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.PENAL.COND,ERR.MSG);* R22 Manual conversion

RETURN
*------------------------------------------------------------
GET.LOCAL.REF:
*------------------------------------------------------------

    LOC.REF.APPLICATION   = "AA.PRD.DES.INTEREST":@FM:"COLLATERAL":@FM:"AA.PRD.DES.TERM.AMOUNT"
    LOC.REF.FIELDS        = 'L.AA.REV.RT.TY':@VM:'L.AA.REV.FORM':@VM:'L.AA.POOL.RATE':@FM:'L.COL.NUM.INSTR':@FM:'L.AA.COL'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.REV.RT.TY  = LOC.REF.POS<1,1>
    POS.L.AA.REV.FORM   = LOC.REF.POS<1,2>
    POS.L.AA.POOL.RATE  = LOC.REF.POS<1,3>
    CL.INST.POS         = LOC.REF.POS<2,1>
    POS.L.AA.COL        = LOC.REF.POS<3,1>
RETURN
*------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------

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
END
