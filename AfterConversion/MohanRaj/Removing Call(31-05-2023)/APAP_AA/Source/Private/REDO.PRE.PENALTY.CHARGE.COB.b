* @ValidationCode : MjotNTk0NTgxMjk1OkNwMTI1MjoxNjg1NTMyMTE4NTk4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:51:58
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
SUBROUTINE REDO.PRE.PENALTY.CHARGE.COB
*------------------------------------------------------------------------
* Description: This is post routine for the activity MORA.CHARGE.COB
* to raise the penalty charge on Frequency basis
*
*------------------------------------------------------------------------
* Input Argument : ARRANGEMENT.ID
* Out Argument   : NA
* Deals With     : ACTIVITY.API
*------------------------------------------------------------------------------------------------------
* Modification History :
*  DATE             WHO                   REFERENCE                  DESCRIPTION
* 06-FEB-2011     H GANESH     PACS00178946 CR-PENALTY CHARGE        Initial Draft
* 27-OCT-2017     Edwin Charles D        PACS00622410                Source balance referred from parent product
* 27-NOV-2017     Edwin Charles D        PACS00639396                Reversal of fix PACS00622410
*---------------------------------------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                    Descripition
* 29-03-2023     Samaran T           Manual R22 Code Conversion                package Name Added APAP.AA
* 29-03-2023   Conversion Tool        Auto R22 Code Conversion                 FM TO @FM, VM TO @VM, SM TO @SM,CALL method format changed
*----------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_REDO.B.PENALTY.CHARGE.COMMON
*   $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PRODUCT

    IF c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'UNAUTH' THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END
RETURN
*------------------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------------------
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AC.BALANCE.TYPE = 'F.AC.BALANCE.TYPE'
    F.AC.BALANCE.TYPE = ''
    CALL OPF(FN.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.REDO.CONCAT.PENALTY.CHARGE = 'F.REDO.CONCAT.PENALTY.CHARGE'
    F.REDO.CONCAT.PENALTY.CHARGE = ''
    CALL OPF(FN.REDO.CONCAT.PENALTY.CHARGE,F.REDO.CONCAT.PENALTY.CHARGE)

    LOC.REF.APPLICATION = "AA.PRD.DES.CHARGE":@FM:"AA.PRD.DES.BALANCE.MAINTENANCE"
    LOC.REF.FIELDS = 'L.PENALTY.FREQ':@FM:'L.BILL.REF':@VM:'L.BILL.AMOUNT'
    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.PENALTY.FREQ = LOC.REF.POS<1,1>
    POS.L.BILL.REF     = LOC.REF.POS<2,1>
    POS.L.BILL.AMOUNT  = LOC.REF.POS<2,2>
    Y.OFS.DATA = ''
    ARR.FIELD.NAME.LIST  = ''
    ARR.FIELD.VALUE.LIST = ''
    Y.FIELD.CNT = 1
RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------

    R.REDO.CONCAT.PENALTY.CHARGE = ''
    ARR.ID = c_aalocArrId     ;* Arrangement ID
    CALL F.READ(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE,F.REDO.CONCAT.PENALTY.CHARGE,CNCT.ERR)
    IF R.REDO.CONCAT.PENALTY.CHARGE<1> NE 'YES' THEN
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

        Y.VAR1 += 1
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

        Y.VAR2 += 1

    REPEAT
    IF Y.OFS.DATA THEN

        ARR.PROPERTY.LIST = Y.BALANCE.MAIN.PROP
        AAA.FIELDS.REC = ""
        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)
        NEW.ACTIVITY.ID = 'MORA.CHARGE.ADJUSTMENT'
        RETURN.ERROR = ''
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)
    END
    CALL F.WRITE(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE)


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
    IF Y.PAYMENT.DATE NE '' AND Y.CHARGE.FREQ NE '' ELSE
        RETURN
    END
    Y.DETAILS    = ''
    Y.DETAILS    = Y.CHARGE.FREQ:'*':Y.PROPERTY.LIST:'*':Y.CHARGE.PER
    Y.ID.DETAILS = ''
    Y.ID.DETAILS = ARR.ID:'*':Y.PROCESS.BILL.ID

    APAP.AA.redoPenaltyNextCycledate(Y.ID.DETAILS,Y.DETAILS,R.PAY.SCH,Y.CYCLE,Y.CHARGE.AMT);* R22 Manual conversion

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
        Y.VAR3 += 1
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
            RETURN
        END
    END
*	Y.CHARGE.AMT = Y.CHARGE.AMT - Y.REPAY.AMT
    Y.CHARGE.AMT -= Y.REPAY.AMT ;*AUTO R22 CODE CONVERSION

    ARR.FIELD.NAME.LIST<1,1,-1> = "LOCAL.REF:":POS.L.BILL.REF:':':Y.FIELD.CNT++
    ARR.FIELD.VALUE.LIST<1,1,-1> = Y.PROCESS.BILL.ID:"*":Y.CHARGE.AMT
    Y.OFS.DATA<-1> = Y.PROCESS.BILL.ID:'*':Y.CHARGE.AMT

    GOSUB UPDATE.CONCAT       ;* To update the Concat file for further raise of charge on Freq Basis

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
        GOSUB END1
    END

    EFF.DATE = ''
    PROP.CLASS='PAYMENT.SCHEDULE'
    PROPERTY = ''
    ERR.MSG = ''
    R.PAY.SCH = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.PAY.SCH,ERR.MSG);* R22 Manual conversion

    LOCATE Y.PENAL.PROPERTY IN c_aalocProductRecord<AA.PRD.CALC.PROPERTY,1> SETTING POS THEN
        Y.SOURCE.BALANCE = c_aalocProductRecord<AA.PRD.SOURCE.BALANCE,POS>      ;* Source Balance for Penalty Charge
    END

    GOSUB GET.PROPERTIES
RETURN

*------------------------------------------------------------------------
GET.PROPERTIES:
*------------------------------------------------------------------------

    Y.PROPERTY.LIST = ''
*	CALL F.READ(FN.AC.BALANCE.TYPE,Y.SOURCE.BALANCE,R.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE,AC.BAL.ERR)
    CALL CACHE.READ(FN.AC.BALANCE.TYPE, Y.SOURCE.BALANCE, R.AC.BALANCE.TYPE, AC.BAL.ERR) ;*AUTO R22 CODE CONVERSION
    Y.VIRTUAL.CNT = DCOUNT(R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL>,@VM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.VIRTUAL.CNT
        Y.PROPERTY.LIST<-1> = R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL,Y.VAR1>[4,LEN(R.AC.BALANCE.TYPE<AC.BT.VIRTUAL.BAL,Y.VAR1>)-3]
        Y.VAR1 += 1
    REPEAT

RETURN

*------------------------------------------------------------------------
UPDATE.CONCAT:
*------------------------------------------------------------------------
    IF R.REDO.CONCAT.PENALTY.CHARGE THEN
        R.REDO.CONCAT.PENALTY.CHARGE<1> = 'YES'
        LOCATE Y.BILL.ID IN R.REDO.CONCAT.PENALTY.CHARGE<2,1> SETTING POS THEN
            R.REDO.CONCAT.PENALTY.CHARGE<3,POS> = Y.CHARGE.AMT
        END ELSE
            R.REDO.CONCAT.PENALTY.CHARGE<2,-1> = Y.BILL.ID
            R.REDO.CONCAT.PENALTY.CHARGE<3,-1> = Y.CHARGE.AMT
        END
    END ELSE
        R.REDO.CONCAT.PENALTY.CHARGE<1> = 'YES'
        R.REDO.CONCAT.PENALTY.CHARGE<2> = Y.BILL.ID
        R.REDO.CONCAT.PENALTY.CHARGE<3> = Y.CHARGE.AMT
    END
RETURN
*---------------------------------------------------------------------------------
END1:
*---------------------------------------------------------------------------------
END
