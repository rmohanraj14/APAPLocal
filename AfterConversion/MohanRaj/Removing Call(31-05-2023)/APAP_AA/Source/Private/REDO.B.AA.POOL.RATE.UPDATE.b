* @ValidationCode : MjoyMTE3NzkxMjQ5OkNwMTI1MjoxNjg1NTM0MTA0NTU0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:25:04
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
SUBROUTINE REDO.B.AA.POOL.RATE.UPDATE(Y.AA.ID)
*------------------------------------------------------
*Description: This batch routine is to update the pool rate
*             for back to back loans which has deposit as a collateral.
*------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       FM TO @FM, VM to @VM, SM to @SM, ++ to+=
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   CALL routine format modified
*------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_REDO.B.AA.POOL.RATE.UPDATE.COMMON
    $USING APAP.TAM
    GOSUB PROCESS
RETURN
*------------------------------------------------------
PROCESS:
*------------------------------------------------------
    CALL OCOMO("Processing the Loan - ":Y.AA.ID)

    GOSUB GET.LIMIT.REF
    IF Y.LIMIT.REFERENCE ELSE
        CALL OCOMO("Limit ref is missing - ":Y.AA.ID)
        RETURN
    END
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.CUS.ID = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
*AA Chnages 20161013
*  REF.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',1,1),"7'0'R")
*  SEQ.NO = FMT(FIELD(Y.LIMIT.REFERENCE,'.',2,1),"2'0'R")
    REF.NO = FMT(Y.LIMIT.REFERENCE,"7'0'R")
    SEQ.NO = FMT(Y.LIMIT.SERIAL,"2'0'R")
*AA Chnages 20161013
    Y.LIMIT.ID  = Y.CUS.ID:".":REF.NO:".":SEQ.NO

    CALL F.READ(FN.LI.COLLATERAL.RIGHT,Y.LIMIT.ID,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,ERR.LI.COLLATERAL.RIGHT)
    Y.COLLATERAL.IDS = ''
    Y.LI.COL.CNT=DCOUNT(R.LI.COLLATERAL.RIGHT,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.LI.COL.CNT
        Y.COLLATERAL.RIGHT.ID=R.LI.COLLATERAL.RIGHT<Y.VAR1>
        CALL F.READ(FN.RIGHT.COLLATERAL,Y.COLLATERAL.RIGHT.ID,R.RIGHT.COLLATERAL.ARR,F.RIGHT.COLLATERAL,ERR.RIGHT.COLLATERAL)
        Y.COLLATERAL.IDS<-1>=R.RIGHT.COLLATERAL.ARR
        Y.VAR1 += 1
    REPEAT
    Y.COLL.ACC.IDS  = ''
    Y.ROLLOVER.FLAG = ''
    Y.COLLATERAL.CNT=DCOUNT(Y.COLLATERAL.IDS,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.COLLATERAL.CNT
        Y.COLL.ID=Y.COLLATERAL.IDS<Y.VAR1>
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,ERR.COLLATERAL)
        Y.ACCOUNT.ID = R.COLLATERAL<COLL.APPLICATION.ID>
        IF Y.ACCOUNT.ID EQ '' THEN
            Y.ACCOUNT.ID = R.COLLATERAL<COLL.LOCAL.REF,POS.L.COL.NUM.INSTR>
        END
        Y.COLL.ACC.IDS<-1> = Y.ACCOUNT.ID
        LOCATE Y.ACCOUNT.ID IN R.REDO.AZ.CONCAT.ROLLOVER<1> SETTING POS1  THEN
            Y.ROLLOVER.FLAG = 'YES'
        END
        Y.VAR1 += 1
    REPEAT
    IF Y.ROLLOVER.FLAG EQ 'YES' THEN
        GOSUB UPDATE.POOL.RATE
    END ELSE
        CALL OCOMO("Rollover not happened for this Loan - Y.AA.ID")
    END

RETURN
*------------------------------------------------------
UPDATE.POOL.RATE:
*------------------------------------------------------
    Y.ACC.RATE = ''
    Y.HIGH.AZ.RATE = ''
    Y.OLD.TERM     = ''

    Y.VAR1 = 1
    Y.COLL.ACC.CNT = DCOUNT(Y.COLL.ACC.IDS,@FM)
    LOOP
    WHILE Y.VAR1 LE Y.COLL.ACC.CNT
        Y.ACCOUNT.ID = Y.COLL.ACC.IDS<Y.VAR1>
        GOSUB GET.RATE

        Y.VAR1 += 1
    REPEAT
    Y.RATE = Y.ACC.RATE
    IF Y.RATE THEN
        GOSUB POST.OFS
    END ELSE
        CALL OCOMO("Pool rate not obtained after calculation")
    END
RETURN
*-----------------------------------------------------------
POST.OFS:
*-----------------------------------------------------------
    Y.CURRENT.POOL.RATE = ''
    GOSUB GET.CURRENT.POOL.RATE
    IF Y.CURRENT.POOL.RATE EQ Y.RATE THEN
        CALL OCOMO("Loan has same pool after rollover - ":Y.AA.ID)
        RETURN
    END

    R.AAA = ''
    R.AAA<AA.ARR.ACT.ARRANGEMENT>      = Y.AA.ID
    R.AAA<AA.ARR.ACT.EFFECTIVE.DATE>   = TODAY
    R.AAA<AA.ARR.ACT.FIELD.NAME>       = 'L.AA.POOL.RATE'
    R.AAA<AA.ARR.ACT.FIELD.VALUE>      = Y.RATE

    R.PRIN.AAA                         = ''
    R.PRIN.AAA                         = R.AAA
    R.PRIN.AAA<AA.ARR.ACT.ACTIVITY>    = 'REDO.POOL.PRINCIPAL'
    R.PRIN.AAA<AA.ARR.ACT.PROPERTY>    = Y.PRIN.PROP

    R.PENAL.AAA                        = ''
    R.PENAL.AAA                        = R.AAA
    R.PENAL.AAA<AA.ARR.ACT.ACTIVITY>   = 'REDO.POOL.PENALTY'
    R.PENAL.AAA<AA.ARR.ACT.PROPERTY>   = Y.PENALTY.PROP

    APP.NAME       = 'AA.ARRANGEMENT.ACTIVITY'
    OFSFUNCT       = 'I'
    PROCESS        = 'PROCESS'
    OFSVERSION     = 'AA.ARRANGEMENT.ACTIVITY,APAP'
    Y.GTSMODE      = ''
    NO.OF.AUTH     = '0'
    TRANSACTION.ID = ''
    OFSRECORD.PRIN = ''
    OFSRECORD.PENAL= ''
    OFS.MSG.ID     = ''
    OFS.SOURCE.ID  = 'REDO.AA.POOL'
    OFS.ERR        = ''
    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,Y.GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.PRIN.AAA,OFSRECORD.PRIN)
    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,Y.GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.PENAL.AAA,OFSRECORD.PENAL)
    OFSRECORD = OFSRECORD.PRIN:@FM:OFSRECORD.PENAL
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
    CALL OCOMO("Pool rate updation Process completed")

RETURN
*-----------------------------------------------------------
GET.CURRENT.POOL.RATE:
*-----------------------------------------------------------
    PROP.NAME   = 'PRINCIPAL'
    Y.PRIN.PROP = ''
    ERR         = ''

    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,Y.PRIN.PROP,ERR);*Manual R22 conversion
    PROP.NAME      = 'PENALTY'
    Y.PENALTY.PROP = ''
    ERR            = ''
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,Y.PENALTY.PROP,ERR);*Manual R22 conversion
    IF Y.PENALTY.PROP ELSE
        CALL OCOMO("Penalty Interest property not found - ":Y.AA.ID)
    END

    IF Y.PRIN.PROP ELSE
        CALL OCOMO("Principal Interest property not found - ":Y.AA.ID)
        RETURN
    END

    EFF.DATE           = ''
    PROP.CLASS         = 'INTEREST'
    PROPERTY           = Y.PRIN.PROP
    R.INT.CONDITION    = ''
    ERR.MSG            = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.INT.CONDITION,ERR.MSG);*Manual R22 conversion
    Y.CURRENT.POOL.RATE = R.INT.CONDITION<AA.INT.LOCAL.REF,POS.L.AA.POOL.RATE>


RETURN
*-----------------------------------------------------------
GET.RATE:
*-----------------------------------------------------------
* Here we get the rate of individual account.
*Note: Loan can either have Savings account or AZ as collateral. Not together.

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
    IF R.ACCOUNT ELSE
        CALL OCOMO("Collateral Account Missing - ":Y.ACCOUNT.ID:" for the Loan - ":Y.AA.ID)
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
    Y.CURRENCY    = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    Y.REVIEW.FREQ = Y.LOAN.TERM
    Y.RATE.VALUE  = ''
    APAP.TAM.redoGetPoolRate(Y.CURRENCY,Y.REVIEW.FREQ,Y.RATE.VALUE);*Manual R22 conversion
    Y.ACC.RATE = Y.RATE.VALUE<1>

RETURN
*---------------------------------------------------------
GET.LOAN.TERM:
*---------------------------------------------------------
* Get the Term of the Loan.

*EFF.DATE           = ''
*PROP.CLASS         = 'TERM.AMOUNT'
*PROPERTY           = ''
*R.TERM.CONDITION   = ''
*ERR.MSG            = ''
*CALL REDO.CRR.GET.CONDITIONS(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.TERM.CONDITION,ERR.MSG)
    APAP.TAM.redoGetLoanTerm(Y.AA.ID,'TODAY',Y.LOAN.TERM);*Manual R22 conversion


RETURN

*------------------------------------------------------
GET.LIMIT.REF:
*------------------------------------------------------

    EFF.DATE    = ''
    PROP.CLASS  = 'LIMIT'
    PROPERTY    = ''
    R.LIMIT.CONDITION = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.LIMIT.CONDITION,ERR.MSG);*Manual R22 conversion
    Y.LIMIT.REFERENCE = R.LIMIT.CONDITION<AA.LIM.LIMIT.REFERENCE>
*AA Changes 20161013
    Y.LIMIT.SERIAL = R.LIMIT.CONDITION<AA.LIM.LIMIT.SERIAL>
*AA Chnages 20161013
RETURN
END
