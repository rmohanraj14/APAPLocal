* @ValidationCode : Mjo1MDg5MjI4NTI6Q3AxMjUyOjE2ODU1MzQxMTk5NzI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 17:25:19
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
SUBROUTINE REDO.CHECK.AA.IDS(AA.IDS,RETURN.AA.IDS)

* Description: This is a calling routine from nofile enquiry routine REDO.NOFILE.MASSIVE.RATE
* and it returns the AA IDS which matches the Condition.

* In  Argument: AA.IDS , RETURN.AA.IDS
* Out Argument: RETURN.AA.IDS

*------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                REFERENCE         DESCRIPTION
*10 Sep 2011     H Ganesh         Massive rate - B.16  INITIAL CREATION
* 29-MAR-2023   Conversion Tool                R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - CALL method format changed
* -----------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.COMPANY
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.REDO.RATE.CHANGE.CRIT
    $INSERT I_F.REDO.LOAN.MARGIN.RATE
    $USING APAP.TAM

    GOSUB OPENFILES
    GOSUB Y.GET.LOC.REF
    GOSUB PROCESS

RETURN
*---------------------------------------------------------
OPENFILES:
*---------------------------------------------------------

    RETURN.AA.IDS = ''
    Y.PRODUCT=''
    Y.LOC.AFF.COMP=''
    Y.UNPAID.BILL.IDS=''
    Y.UNPAID.BILL.CNT=0

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.REDO.RATE.CHANGE.CRIT = 'F.REDO.RATE.CHANGE.CRIT'
    F.REDO.RATE.CHANGE.CRIT  = ''
    CALL OPF(FN.REDO.RATE.CHANGE.CRIT,F.REDO.RATE.CHANGE.CRIT)

    FN.AA.INTEREST.ACCRUALS = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INTEREST.ACCRUALS = ''
    CALL OPF(FN.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS)

    FN.REDO.LOAN.MARGIN.RATE='F.REDO.LOAN.MARGIN.RATE'
    F.REDO.LOAN.MARGIN.RATE=''
    CALL OPF(FN.REDO.LOAN.MARGIN.RATE,F.REDO.LOAN.MARGIN.RATE)

    FN.REDO.MASSIVE.RATE.CHANGE = 'F.REDO.MASSIVE.RATE.CHANGE'
    F.REDO.MASSIVE.RATE.CHANGE = ''
    CALL OPF(FN.REDO.MASSIVE.RATE.CHANGE,F.REDO.MASSIVE.RATE.CHANGE)

RETURN
*---------------------------------------------------------
Y.GET.LOC.REF:
*---------------------------------------------------------
    LOC.REF.APPLICATION="AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS='L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    Y.LOAN.STATUS.1.POS = LOC.REF.POS<1,1>
    Y.LOAN.COND.POS     = LOC.REF.POS<1,2>

RETURN
*---------------------------------------------------------
PROCESS:
*---------------------------------------------------------
    Y.VAR = 1
    Y.IDS.CNT = DCOUNT(AA.IDS,@FM)
    LOOP
    WHILE Y.VAR LE Y.IDS.CNT
        Y.REJ.ID = 'NO'
        ARR.ID = FIELD(AA.IDS<Y.VAR>,'*',1)
        CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ERR)
        GOSUB GET.INT.PROPERTY
        GOSUB PROCESS.ID
        IF Y.REJ.ID EQ 'NO' THEN
            RETURN.AA.IDS<-1> = ARR.ID:'*':Y.MARGIN.OPER
            IF Y.MARGIN.RATE NE '' THEN
                RETURN.AA.IDS:= '*':Y.MARGIN.RATE
            END ELSE
                RETURN.AA.IDS:= '*':''
            END
            IF Y.INT.RATE NE '' THEN
                RETURN.AA.IDS:= '*':Y.INT.RATE
            END ELSE
                RETURN.AA.IDS:= '*':''
            END
        END
        Y.VAR += 1  ;*R22 Auto Conversion
    REPEAT
RETURN
*---------------------------------------------------------
GET.INT.PROPERTY:
*---------------------------------------------------------
    PROP.NAME='PRINCIPAL'       ;* Interest Property to obtain
    APAP.TAM.redoGetInterestProperty(ARR.ID,PROP.NAME,OUT.PROP,ERR);* R22 Manual conversion
    Y.PRIN.PROP=OUT.PROP        ;* This variable hold the value of principal interest property
RETURN
*---------------------------------------------------------
PROCESS.ID:
*---------------------------------------------------------

    Y.MARGIN.ID = FIELD(AA.IDS<Y.VAR>,'*',2)
    R.REDO.RATE.CHANGE = ''
    CALL F.READ(FN.REDO.RATE.CHANGE.CRIT,Y.MARGIN.ID,R.REDO.RATE.CHANGE,F.REDO.RATE.CHANGE.CRIT,Y.RRC.ERR)
    Y.REJ.ID = 'YES'
    IF R.REDO.RATE.CHANGE ELSE
        RETURN
    END
    GOSUB GET.TERM.AMOUNT
    GOSUB CHECK.AMOUNT

RETURN

*-----------------------------------------------------------------------------
GET.TERM.AMOUNT:
*-----------------------------------------------------------------------------
* This part gets the Loan amount

    EFF.DATE = TODAY
    PROP.CLASS='TERM.AMOUNT'
    PROPERTY = ''
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.TERM,ERR.MSG);* R22 Manual conversion
    Y.LOAN.AMOUNT=R.CONDITION.TERM<AA.AMT.AMOUNT>
    Y.MAT.DATE   =R.CONDITION.TERM<AA.AMT.MATURITY.DATE>
RETURN

*-----------------------------------------------------------------------------
CHECK.AMOUNT:
*-----------------------------------------------------------------------------

    Y.AMOUNT.START.RANGE = R.REDO.RATE.CHANGE<RATE.CHG.ORG.AMT.ST.RG>
    Y.AMOUNT.END.RANGE   = R.REDO.RATE.CHANGE<RATE.CHG.ORG.AMT.END.RG>
    Y.AMOUNT.RANGE.CNT=DCOUNT(Y.AMOUNT.START.RANGE,@VM)

    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.AMOUNT.RANGE.CNT
        Y.START.AMT = Y.AMOUNT.START.RANGE<1,Y.VAR1>
        Y.END.AMT   = Y.AMOUNT.END.RANGE<1,Y.VAR1>
        Y.REJ.ID = 'YES'
        IF Y.LOAN.AMOUNT GE Y.START.AMT AND Y.LOAN.AMOUNT LE Y.END.AMT THEN
            Y.MARGIN.OPER = R.REDO.RATE.CHANGE<RATE.CHG.MARGIN.OPERAND,Y.VAR1>
            Y.MARGIN.RATE = R.REDO.RATE.CHANGE<RATE.CHG.PROP.SPRD.CHG,Y.VAR1>
            Y.INT.RATE    = R.REDO.RATE.CHANGE<RATE.CHG.PROP.INT.CHG,Y.VAR1>
            GOSUB RATE.CHECK
            Y.VAR1 = Y.AMOUNT.RANGE.CNT+1     ;* Instead of break statement
        END
        Y.VAR1 += 1  ;*R22 Auto Conversion
    REPEAT

RETURN
*-----------------------------------------------------------------------------
RATE.CHECK:
*-----------------------------------------------------------------------------

    GOSUB GET.INTEREST.RATE

    Y.START.INT = R.REDO.RATE.CHANGE<RATE.CHG.RATE.ST.RG,Y.VAR1>
    Y.END.INT   = R.REDO.RATE.CHANGE<RATE.CHG.RATE.END.RG,Y.VAR1>
    IF (Y.INTEREST.RATE GE Y.START.INT AND Y.INTEREST.RATE LE Y.END.INT) OR (Y.START.INT EQ '' AND Y.END.INT EQ '') THEN
        GOSUB ORIG.AMT.CHECK
    END

RETURN
*-----------------------------------------------------------------------------
GET.INTEREST.RATE:
*-----------------------------------------------------------------------------

*Y.INT.ID=ARR.ID:'-':OUT.PROP
*CALL F.READ(FN.AA.INTEREST.ACCRUALS,Y.INT.ID,R.INT.ACCRUAL,F.AA.INTEREST.ACCRUALS,INT.ACC.ERR)
*Y.INTEREST.RATE=R.INT.ACCRUAL<AA.INT.ACC.RATE,1,1>

    APAP.TAM.redoGetInterestRate(ARR.ID,Y.INTEREST.RATE);* R22 Manual conversion

RETURN
*-----------------------------------------------------------------------------
ORIG.AMT.CHECK:
*-----------------------------------------------------------------------------

    OUT.PROP.ACC=''
    APAP.TAM.redoGetPropertyName(ARR.ID,'ACCOUNT',R.OUT.AA.RECORD,OUT.PROP.ACC,OUT.ERR);* R22 Manual conversion
    IN.ACC.ID=''
    APAP.TAM.redoConvertAccount(IN.ACC.ID,ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion
    BALANCE.TO.CHECK='CUR':OUT.PROP.ACC
    BALANCE.AMOUNT=''
    Y.TODAY = TODAY
    CALL AA.GET.ECB.BALANCE.AMOUNT(OUT.ID,BALANCE.TO.CHECK,Y.TODAY,BALANCE.AMOUNT,RET.ERROR)
    Y.OUTSTANDING.BAL=ABS(BALANCE.AMOUNT)

    Y.OS.START.AMT = R.REDO.RATE.CHANGE<RATE.CHG.OS.AMT.ST.RG,Y.VAR1>
    Y.OS.END.AMT   = R.REDO.RATE.CHANGE<RATE.CHG.OS.AMT.END.RG,Y.VAR1>

    IF (Y.OUTSTANDING.BAL GE Y.OS.START.AMT AND Y.OUTSTANDING.BAL LE Y.OS.END.AMT) OR (Y.OS.START.AMT EQ '' AND Y.OS.END.AMT EQ '') THEN
        GOSUB CHECK.LOAN.DATE
    END

RETURN
*-----------------------------------------------------------------------------
CHECK.LOAN.DATE:
*-----------------------------------------------------------------------------

    Y.LOAN.START.DATE=R.AA.ARRANGEMENT<AA.ARR.START.DATE>
    Y.START.DATE = R.REDO.RATE.CHANGE<RATE.CHG.LOAN.ST.DATE,Y.VAR1>
    Y.END.DATE   = R.REDO.RATE.CHANGE<RATE.CHG.LOAN.END.DATE,Y.VAR1>

    IF (Y.LOAN.START.DATE GE Y.START.DATE AND Y.LOAN.START.DATE LE Y.END.DATE) OR (Y.START.DATE EQ '' AND Y.END.DATE EQ '') THEN
        GOSUB EXCLUDE.CONDITION.START
    END

RETURN
*-----------------------------------------------------------------------------
EXCLUDE.CONDITION.START:
*-----------------------------------------------------------------------------
* Exclude condition starts here

    Y.REJ.ID = 'NO'
    GOSUB GET.OVERDUE.DETAILS
    Y.STATUS.CNT = DCOUNT(Y.LOAN.STATUS,@SM)
    Y.COND.CNT   = DCOUNT(Y.LOAN.COND,@SM)
    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.STATUS.CNT
        Y.LOAN.STATUS.INDV=Y.LOAN.STATUS<1,1,Y.VAR2>
        LOCATE Y.LOAN.STATUS.INDV IN R.REDO.RATE.CHANGE<RATE.CHG.LOAN.STATUS,Y.VAR1,1> SETTING STAT.POS THEN
            Y.REJ.ID = 'YES'
        END
        Y.VAR2 += 1   ;*R22 Auto Conversion
    REPEAT
    IF Y.REJ.ID EQ 'YES' THEN
        RETURN
    END
    Y.VAR3=1
    LOOP
    WHILE Y.VAR3 LE Y.COND.CNT
        Y.LOAN.COND.INDV=Y.LOAN.COND<1,1,Y.VAR3>
        LOCATE Y.LOAN.COND.INDV IN R.REDO.RATE.CHANGE<RATE.CHG.LOAN.COND,Y.VAR1,1> SETTING COND.POS THEN
            Y.REJ.ID = 'YES'
        END
        Y.VAR3 += 1   ;*R22 Auto Conversion
    REPEAT
    IF Y.REJ.ID EQ 'NO' THEN
        GOSUB CHECK.UNPAID.INSTALL
    END

RETURN
*-----------------------------------------------------------------------------
GET.OVERDUE.DETAILS:
*-----------------------------------------------------------------------------

    EFF.DATE = TODAY
    PROP.CLASS='OVERDUE'
    PROPERTY = ''
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.OVERDUE,ERR.MSG);* R22 Manual conversion
    Y.LOAN.STATUS = R.CONDITION.OVERDUE<AA.OD.LOCAL.REF,Y.LOAN.STATUS.1.POS>
    Y.LOAN.COND   = R.CONDITION.OVERDUE<AA.OD.LOCAL.REF,Y.LOAN.COND.POS>

RETURN
*-----------------------------------------------------------------------------
CHECK.UNPAID.INSTALL:
*-----------------------------------------------------------------------------

    R.AA.ACCOUNT.DETAILS = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ACT.DET.ERR)

    Y.BILL.ID    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.SET.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    Y.BILL.TYPE  = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>

    CHANGE @SM TO @FM IN Y.BILL.ID
    CHANGE @VM TO @FM IN Y.BILL.ID
    CHANGE @SM TO @FM IN Y.SET.STATUS
    CHANGE @VM TO @FM IN Y.SET.STATUS
    CHANGE @SM TO @FM IN Y.BILL.TYPE
    CHANGE @VM TO @FM IN Y.BILL.TYPE
    Y.UNPAID.BILL.IDS = ''
    Y.UNPAID.BILL.CNT = 0
    Y.BILL.COUNT=DCOUNT(Y.BILL.ID,@FM)
    Y.BILL=1
    LOOP
    WHILE Y.BILL LE Y.BILL.COUNT
        IF Y.SET.STATUS<Y.BILL> EQ 'UNPAID' AND Y.BILL.TYPE<Y.BILL> EQ 'PAYMENT' THEN
            Y.UNPAID.BILL.CNT += 1
            Y.UNPAID.BILL.IDS<-1>=Y.BILL.ID<Y.BILL>
        END
        Y.BILL += 1  ;*R22 Auto Conversion
    REPEAT
    Y.DEFINED.UNPAID.BILLS= R.REDO.RATE.CHANGE<RATE.CHG.UNPAID.INST,Y.VAR1>
    IF Y.DEFINED.UNPAID.BILLS THEN
        IF Y.UNPAID.BILL.CNT GE Y.DEFINED.UNPAID.BILLS THEN
            Y.REJ.ID = 'YES'
        END
    END
    IF Y.REJ.ID EQ 'NO' THEN
        GOSUB CHECK.OVERDUE.DAYS
    END

RETURN
*-------------------------------------------------------------
CHECK.OVERDUE.DAYS:
*-------------------------------------------------------------

    LOOP.BILL=1
    LOOP
    WHILE LOOP.BILL LE Y.UNPAID.BILL.CNT
        Y.AA.OVERDUE.DAYS=''
        BILL=Y.UNPAID.BILL.IDS<LOOP.BILL>
        Y.BILL.RET.ERR=''
        CALL AA.GET.BILL.DETAILS(ARR.ID,BILL,R.BILL.DETAILS,Y.BILL.RET.ERR)
*Y.AGING.DATE.ARR = R.BILL.DETAILS<AA.BD.AGING.ST.CHG.DT>
*Y.AGING.DATE.SORT =  SORT(Y.AGING.DATE.ARR)
*Y.AA.AGING.DATE = FIELD(Y.AGING.DATE.SORT,FM,1)
        Y.AA.AGING.DATE = ''
        LOCATE 'DUE' IN R.BILL.DETAILS<AA.BD.BILL.STATUS,1> SETTING DUE.POS THEN
            Y.AA.AGING.DATE = R.BILL.DETAILS<AA.BD.BILL.ST.CHG.DT,DUE.POS>
        END

        Y.DATE = TODAY
        IF Y.AA.AGING.DATE NE '' THEN
            Y.AA.OVERDUE.DAYS = 'C'
            CALL CDD('',Y.AA.AGING.DATE,Y.DATE,Y.AA.OVERDUE.DAYS)
        END
        Y.DEFINED.OVR.DAYS=R.REDO.RATE.CHANGE<RATE.CHG.OVERDUE.DAYS,Y.VAR1>
        IF Y.DEFINED.OVR.DAYS THEN
            IF Y.AA.OVERDUE.DAYS GE Y.DEFINED.OVR.DAYS THEN
                Y.REJ.ID = 'YES'
                RETURN
            END
        END
        LOOP.BILL += 1   ;*R22 Auto Conversion
    REPEAT
    Y.REJ.ID = 'NO'

RETURN
END
