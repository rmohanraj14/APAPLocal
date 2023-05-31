* @ValidationCode : MjoyNjQ5NTc0NTU6Q3AxMjUyOjE2ODU1Mjk1Mjc1MjA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:08:47
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
SUBROUTINE REDO.B.PENALTY.CHARGE(ARRANGEMENT.ID)
*------------------------------------------------------------------------
* Description: This is a Main-Routine for BATCH>BNK/REDO.B.PENALTY.CHARGE in order
* to raise the penalty charge on Frequency basis
*
*------------------------------------------------------------------------
* Input Argument : ARRANGEMENT.ID
* Out Argument   : NA
* Deals With     : BATCH>BNK/REDO.B.PENALTY.CHARGE
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 07-NOV-2011     H GANESH     ODR-2011-08-0106 CR-PENALTY CHARGE            Initial Draft
* 13-Mar-2013     H GANESH               PACS00254645                   OFS Version changed to Post for All company
* 27-OCT-2017     Edwin Charles D        PACS00622410                   Source balance referred from parent product
* 29-Nov-2017     Edwin Charles D        PACS00639396                   Reversal of the fix PACS00622410
* 29-MAR-2023      Conversion Tool                R22 Auto Conversion  - VM to @VM ,SM to @SM , FM to @FM
* 29-MAR-2023      Harsha                R22 Manual Conversion          CALL method format changed
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_REDO.B.PENALTY.CHARGE.COMMON
    $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PRODUCT
    $INSERT I_AA.LOCAL.COMMON
    $USING APAP.TAM

    GOSUB PROCESS

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------
    CALL OCOMO("Started Processing the Arrangement - ":ARRANGEMENT.ID)
    ARR.ID = ARRANGEMENT.ID   ;* Arrangement ID
    CALL F.READ(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE,F.REDO.CONCAT.PENALTY.CHARGE,CNCT.ERR)
    IF R.REDO.CONCAT.PENALTY.CHARGE<1> NE 'YES' THEN
        CALL OCOMO("Processed the Arrangement - ":ARRANGEMENT.ID)
        RETURN
    END
    Y.BILL.IDS = R.REDO.CONCAT.PENALTY.CHARGE<2>  ;* List of Bill ids that are aged

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ACC.DET.ERR)
    IF R.AA.ACCOUNT.DETAILS THEN
        Y.ALL.BILL.IDS  = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
        Y.SETTLE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
        CHANGE @SM TO @FM IN Y.ALL.BILL.IDS
        CHANGE @VM TO @FM IN Y.ALL.BILL.IDS
        CHANGE @SM TO @FM IN Y.SETTLE.STATUS
        CHANGE @VM TO @FM IN Y.SETTLE.STATUS

        GOSUB CHECK.BILLS
    END
    CALL OCOMO("Processed the Loan ID - ":ARRANGEMENT.ID)
RETURN
*------------------------------------------------------------------------
CHECK.BILLS:
*------------------------------------------------------------------------
    Y.FINAL.BILL.IDS = ''
    Y.BILLS.CNT = DCOUNT(Y.BILL.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.BILLS.CNT
        Y.BILL.ID = Y.BILL.IDS<1,Y.VAR1>
        LOCATE Y.BILL.ID IN Y.ALL.BILL.IDS SETTING BILL.POS THEN
            IF Y.SETTLE.STATUS<BILL.POS> EQ 'UNPAID' THEN
                Y.FINAL.BILL.IDS<-1> = Y.ALL.BILL.IDS<BILL.POS>
            END
        END

        Y.VAR1 += 1   ;*R22 Auto Conversion
    REPEAT

    IF Y.FINAL.BILL.IDS THEN  ;*  If any one of the bill is unpaid then process the bill
        GOSUB PROCESS.BILLS
    END ELSE        ;* If all bills has been repaid then update the concat file and return
        R.REDO.CONCAT.PENALTY.CHARGE<1> = 'NO'
        CALL F.WRITE(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE)
    END
RETURN
*---------------------------------------------------------------------------------
PROCESS.BILLS:
*---------------------------------------------------------------------------------
* Process the each unpaid Bill

    GOSUB GET.PRODUCT.DETAILS
    Y.FINAL.BILL.IDS.CNT = DCOUNT(Y.FINAL.BILL.IDS,@FM)
    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.FINAL.BILL.IDS.CNT
        Y.PROCESS.BILL.ID = Y.FINAL.BILL.IDS<Y.VAR2>
        GOSUB FINAL.PROCESS

        Y.VAR2 += 1   ;*R22 Auto Conversion
    REPEAT

RETURN
*---------------------------------------------------------------------------------
FINAL.PROCESS:
*---------------------------------------------------------------------------------
* Final process of each unpaid bill and related details

    CALL F.READ(FN.AA.BILL.DETAILS,Y.PROCESS.BILL.ID,R.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
    IF R.BILL.DETAILS ELSE
        RETURN
    END
    Y.PAYMENT.DATE = R.BILL.DETAILS<AA.BD.PAYMENT.DATE>
    GOSUB CALC.NO.OF.CYCLES
*GOSUB GET.PROPERTIES.AMT
    GOSUB CALC.CHARGE.AMT
    IF Y.CHARGE.AMT GT 0 THEN
        GOSUB POST.OFS
    END
RETURN
*---------------------------------------------------------------------------------
CALC.NO.OF.CYCLES:
*---------------------------------------------------------------------------------
* Calculates the no. of cycles crossed the payment date

    Y.CYCLE = 1
*Y.CNT = 1

    IF Y.PAYMENT.DATE NE '' AND Y.CHARGE.FREQ NE '' ELSE
        RETURN
    END
    Y.DETAILS    = ''
    Y.DETAILS    = Y.CHARGE.FREQ:'*':Y.PROPERTY.LIST:'*':Y.CHARGE.PER
    Y.ID.DETAILS = ''
    Y.ID.DETAILS = ARR.ID:'*':Y.PROCESS.BILL.ID

    APAP.AA.redoPenaltyNextCycledate(Y.ID.DETAILS,Y.DETAILS,R.PAY.SCH,Y.CYCLE,Y.CHARGE.AMT);* R22 Manual conversion

*Y.LEN = LEN(Y.CHARGE.FREQ)
*Y.FREQ = Y.CHARGE.FREQ[Y.LEN,1]
*Y.FREQ.NUM = Y.CHARGE.FREQ[1,Y.LEN-1]
*DATE.CONVENTION = R.PAY.SCH<AA.PS.DATE.CONVENTION>
*DATE.ADJUSTMENT = R.PAY.SCH<AA.PS.DATE.ADJUSTMENT>
*BUS.DAYS = R.PAY.SCH<AA.PS.BUS.DAY.CENTRES,1>

*GOSUB CALC.FREQ
*LOOP
*WHILE Y.CNT
*CALL AA.GET.RECALC.DATE(Y.FINAL.FREQ, DATE.CONVENTION, DATE.ADJUSTMENT, BUS.DAYS, Y.PAYMENT.DATE, NEXT.CYCLE.DATE, RETURN.ERROR)
*Y.PAYMENT.DATE = NEXT.CYCLE.DATE
*IF NEXT.CYCLE.DATE GT TODAY THEN
*Y.CNT = 0
*END ELSE
*Y.CYCLE++
*END
*REPEAT

RETURN

*------------------------------------------------------------------------
*CALC.FREQ:
*------------------------------------------------------------------------

*BEGIN CASE
*CASE Y.FREQ EQ 'Y'
*Y.FINAL.FREQ = 'e':Y.FREQ.NUM:'Y e0M e0W e0D e0F'
*CASE Y.FREQ EQ 'M'
*Y.FINAL.FREQ = 'e0Y e':Y.FREQ.NUM:'M e0W e0D e0F'
*CASE Y.FREQ EQ 'W'
*Y.FINAL.FREQ = 'e0Y e0M e':Y.FREQ.NUM:'W e0D e0F'
*CASE Y.FREQ EQ 'D'
*Y.FINAL.FREQ = 'e0Y e0M e0W e':Y.FREQ.NUM:'D e0F'
*END CASE

*RETURN
*------------------------------------------------------------------------
GET.PROPERTIES:
*------------------------------------------------------------------------
* Get the Product details and solution document

    PRODUCT.OR.PROPERTY = 'PRODUCT'
    CURRENCY = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    ARR.START.DATE = R.AA.ARRANGEMENT<AA.ARR.START.DATE>
    DATE.TXN = ''
    STAGE = ''
    PRODUCT.ID = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
    CALL AA.GET.PRODUCT.PROPERTY.RECORD(PRODUCT.OR.PROPERTY, STAGE, PRODUCT.ID, PRODUCT.PROPERTY.NAME, CONDITION.ID, CURRENCY, ARR.START.DATE, DATE.TXN, PUBLISHED.RECORD, VAL.ERROR)         ;* get the relevant record

    LOCATE Y.PENAL.PROPERTY IN PUBLISHED.RECORD<AA.PRD.CALC.PROPERTY,1> SETTING POS THEN
        Y.SOURCE.BALANCE = PUBLISHED.RECORD<AA.PRD.SOURCE.BALANCE,POS>
    END

    Y.PROPERTY.LIST = ''
    CALL F.READ(FN.AC.BALANCE.TYPE,Y.SOURCE.BALANCE,R.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE,AC.BAL.ERR)
    Y.VIRTUAL.CNT = DCOUNT(R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL>,@VM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.VIRTUAL.CNT
        Y.PROPERTY.LIST<-1> = R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL,Y.VAR1>[4,LEN(R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL,Y.VAR1>)-3]
        Y.VAR1 += 1  ;*R22 Auto Conversion
    REPEAT

RETURN

*------------------------------------------------------------------------
GET.PROPERTIES.AMT:
*------------------------------------------------------------------------
* This part gets the amount of each property in bill

    Y.BILL.AMT = 0
    Y.VAR3 = 1
    Y.PROPERTIES.CNT = DCOUNT(Y.PROPERTY.LIST,@FM)
    LOOP
    WHILE Y.VAR3 LE Y.PROPERTIES.CNT
        Y.PROP = Y.PROPERTY.LIST<Y.VAR3>
        LOCATE Y.PROP IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING PROP.POS THEN
            Y.BILL.AMT += R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,PROP.POS>
        END
        Y.VAR3 += 1  ;*R22 Auto Conversion
    REPEAT

RETURN
*---------------------------------------------------------------------------------
CALC.CHARGE.AMT:
*---------------------------------------------------------------------------------
* Here we calculate the charge amount

*Y.CHARGE.AMT = ((Y.BILL.AMT*Y.CHARGE.PER)/100)*Y.CYCLE
    CALL EB.ROUND.AMOUNT(Y.CURRENCY,Y.CHARGE.AMT,"","")

RETURN
*---------------------------------------------------------------------------------
POST.OFS:
*---------------------------------------------------------------------------------
* This part Post the OFS for ADJUST.BILL activity to post the charge on Bill

    LOCATE Y.PENAL.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS THEN
        Y.REPAY.AMT = SUM(R.BILL.DETAILS<AA.BD.REPAY.AMOUNT,POS>)
        IF Y.CHARGE.AMT EQ (R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,POS> + Y.REPAY.AMT) THEN
            CALL OCOMO("Processed the Arrangement(Same Amount) - ":ARRANGEMENT.ID)
            RETURN
        END
    END
    Y.CHARGE.AMT -= Y.REPAY.AMT

    IN.PROPERTY.CLASS = 'OFFICERS'
    R.OUT.AA.RECORD = ''
    OUT.PROPERTY = ''
    OUT.ERR = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR);* R22 Manual conversion

    R.AAA = ''
    R.AAA<AA.ARR.ACT.ARRANGEMENT>     = ARR.ID
    R.AAA<AA.ARR.ACT.ACTIVITY>        = 'MORA.CHARGE.COB'
    R.AAA<AA.ARR.ACT.PROPERTY>        =  OUT.PROPERTY

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    OFSFUNCT='I'
    PROCESS  = 'PROCESS'
    OFSVERSION = 'AA.ARRANGEMENT.ACTIVITY,REDO.PENALTY'
    GTSMODE = ''
    TRANSACTION.ID=''
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    NO.OF.AUTH=0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.AAA,OFSRECORD)
    OFS.MSG.ID = ''
    OFS.SRC = 'REDO.PENALTY'
    OPTIONS = ''
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SRC,OPTIONS)

*Y.OFS.MSG.ID = OFS.MSG.ID:'-':OFS.SRC
*Y.CNCT.FILE.ID = TODAY:'-':'OFS'
*CALL F.READ(FN.REDO.AA.OFS.FAIL,Y.CNCT.FILE.ID,R.REDO.AA.OFS.FAIL,F.REDO.AA.OFS.FAIL,CNCT.ERR)
*R.REDO.AA.OFS.FAIL<-1> = Y.OFS.MSG.ID
*CALL F.WRITE(FN.REDO.AA.OFS.FAIL,Y.CNCT.FILE.ID,R.REDO.AA.OFS.FAIL)
    Y.VAR2 = Y.FINAL.BILL.IDS.CNT + 1   ;* To end the loop
RETURN
*---------------------------------------------------------------------------------
GET.PRODUCT.DETAILS:
*---------------------------------------------------------------------------------
* Here we get the Product related details and Charge frequency and Charge Percentage


    R.AA.ARRANGEMENT = ''
    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    Y.CURRENCY      = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    R.REDO.APAP.PROPERTY.PARAM = ''
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    Y.PENAL.PROPERTY = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>    ;* Penalty Charge Property
    Y.BALANCE.MAIN.PROP = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.BAL.MAIN.PROPERTY>

    EFF.DATE = ''
    PROP.CLASS='CHARGE'
    PROPERTY = Y.PENAL.PROPERTY
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.CHARGE.PER  = R.CONDITION<AA.CHG.CHARGE.RATE,1>       ;* Charge Percentage
    Y.CHARGE.FREQ = R.CONDITION<AA.CHG.LOCAL.REF,POS.L.PENALTY.FREQ>  ;* Charge Calculating Frequency

    IF Y.CHARGE.PER NE '' AND Y.CHARGE.FREQ NE '' ELSE
        CALL OCOMO("Processed the Arrangement(Pay Sch Not Found) - ":ARRANGEMENT.ID)
        GOSUB END1
    END

    EFF.DATE = ''
    PROP.CLASS='PAYMENT.SCHEDULE'
    PROPERTY = ''
    ERR.MSG = ''
    R.PAY.SCH = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.PAY.SCH,ERR.MSG);* R22 Manual conversion

    GOSUB GET.PROPERTIES
RETURN
*---------------------------------------------------------------------------------
END1:
*---------------------------------------------------------------------------------
END
