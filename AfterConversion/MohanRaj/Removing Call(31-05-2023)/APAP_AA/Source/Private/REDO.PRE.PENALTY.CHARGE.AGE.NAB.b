* @ValidationCode : MjoxODUxNzA5MTMwOkNwMTI1MjoxNjg1NTMyMDI0MDcyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:50:24
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
SUBROUTINE REDO.PRE.PENALTY.CHARGE.AGE.NAB
*-------------------------------------------------------------
* Description: This is a Post-Routine for LENDING-AGE-APAP.OVERDUE*NAB*AGE.BILLS Activity
* to write the charge property name in Bill and Post an OFS message for LENDING-ADJUST.BILL-BALANCE.MAINTENANCE
* activity

*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : ACTIVITY.API.
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 01-NOV-2011     H GANESH     ODR-2011-08-0106 CR-PENALTY CHARGE            Initial Draft
*------------------------------------------------------------------------
*Modification History
*Date           Who                   Reference                                  Descripition
* 29-03-2023     Samaran T            Manaual R22 Code Conversion               Package Name Added APAP.AA
* 29-03-2023   Conversion Tool        Auto R22 Code Conversion                   FM TO @FM, VM TO @VM, SM TO @SM, CALL method format changed
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.PRODUCT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM


    IF c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'UNAUTH' THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN
*------------------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------------------

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT  = ''
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AC.BALANCE.TYPE = 'F.AC.BALANCE.TYPE'
    F.AC.BALANCE.TYPE = ''
    CALL OPF(FN.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE)

    FN.REDO.CONCAT.PENALTY.CHARGE = 'F.REDO.CONCAT.PENALTY.CHARGE'
    F.REDO.CONCAT.PENALTY.CHARGE = ''
    CALL OPF(FN.REDO.CONCAT.PENALTY.CHARGE,F.REDO.CONCAT.PENALTY.CHARGE)

    LOC.REF.APPLICATION="AA.PRD.DES.CHARGE":@FM:"AA.PRD.DES.BALANCE.MAINTENANCE"
    LOC.REF.FIELDS='L.PENALTY.FREQ':@FM:'L.BILL.REF':@VM:'L.BILL.AMOUNT'
    LOC.REF.POS=''
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
* Here the Main process Begin

    ARR.ID       = c_aalocArrId ;* Arrangement ID
    Y.PRODUCT.ID = c_aalocArrProductId    ;* Product ID
*    CALL F.READ(FN.AA.PRODUCT,Y.PRODUCT.ID,R.PRODUCT,F.AA.PRODUCT,PROD.ERR)
    CALL CACHE.READ(FN.AA.PRODUCT, Y.PRODUCT.ID, R.PRODUCT, PROD.ERR) ;*AUTO R22 CODE CONVERSION
    Y.PRODUCT.GROUP.ID = R.PRODUCT<AA.PDT.PRODUCT.GROUP>      ;* Product Group ID
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY.PARAM,PROP.PARAM.ERR)
    IF R.REDO.APAP.PROPERTY.PARAM THEN
        Y.PENAL.PROPERTY        = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>       ;* Penalty Charge Property
        Y.BALANCE.MAIN.PROPERTY = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.BAL.MAIN.PROPERTY>    ;* Balance Main Property
    END ELSE
        RETURN
    END

    LOCATE Y.PENAL.PROPERTY IN c_aalocProductRecord<AA.PRD.PROPERTY,1> SETTING PP.POS ELSE
        GOSUB END1
    END
    LOCATE Y.BALANCE.MAIN.PROPERTY IN c_aalocProductRecord<AA.PRD.PROPERTY,1> SETTING PP.POS ELSE
        GOSUB END1
    END

    R.AA.ACCOUNT.DETAILS = c_aalocAccountDetails    ;* AA.ACCOUNT.DETAILS record

    GOSUB GET.BILL.ID ;* To get the Bill ID for which the aging activity triggers

RETURN
*----------------------------------------------------------
GET.BILL.ID:
*----------------------------------------------------------
* To get the Bill ID for which the aging activity triggers

    Y.BILL.IDS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.SETTLE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    Y.BILL.TYPE =     R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>
    CHANGE @SM TO @VM IN Y.BILL.IDS
    CHANGE @SM TO @VM IN Y.SETTLE.STATUS
    CHANGE @SM TO @VM IN Y.BILL.TYPE
    Y.BILL.IDS.CNT = DCOUNT(Y.BILL.IDS,@VM)
    Y.UNPAID.BILLS.CNT = 0
    Y.UNPAID.BILLS.IDS = ''
    Y.VAR3 =1
    LOOP
    WHILE Y.VAR3 LE Y.BILL.IDS.CNT
        IF Y.SETTLE.STATUS<1,Y.VAR3> EQ 'UNPAID' AND Y.BILL.TYPE<1,Y.VAR3> EQ 'PAYMENT' THEN
            Y.UNPAID.BILLS.IDS<-1> = Y.BILL.IDS<1,Y.VAR3>
            Y.UNPAID.BILLS.CNT += 1
        END

        Y.VAR3 += 1
    REPEAT
    Y.AGING.STATUS = FIELD(c_aalocCurrActivity,'*',2)
    Y.VAR4 = 1
    LOOP
    WHILE Y.VAR4 LE Y.UNPAID.BILLS.CNT
        BILL = Y.UNPAID.BILLS.IDS<Y.VAR4>
        CALL F.READ(FN.AA.BILL.DETAILS,BILL,R.BILL,F.AA.BILL.DETAILS,BILL.ERR)
        LOCATE Y.AGING.STATUS IN R.BILL<AA.BD.AGING.STATUS,1> SETTING AGE.POS THEN
            IF R.BILL<AA.BD.AGING.ST.CHG.DT,AGE.POS> EQ c_aalocActivityEffDate THEN
                Y.BILL.ID = BILL      ;* Bill ID for which aging activity triggers
*Y.VAR4 = Y.UNPAID.BILLS.CNT+1
                CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)

                IF c_aalocActivityStatus EQ 'UNAUTH' THEN

                    LOCATE Y.PENAL.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS ELSE
                        R.BILL.DETAILS<AA.BD.PROPERTY,-1> = Y.PENAL.PROPERTY
                        R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,-1> = 0
                        R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,-1> = 0
*R.BILL.DETAILS<AA.BD.PAY.PROPERTY,DCOUNT(R.BILL.DETAILS<AA.BD.PAY.PROPERTY>,VM),-1> = Y.PENAL.PROPERTY
*R.BILL.DETAILS<AA.BD.OR.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OR.PR.AMT>,VM),-1> = 0
*R.BILL.DETAILS<AA.BD.OS.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OS.PR.AMT>,VM),-1> = 0
                        R.BILL.DETAILS<AA.BD.PAYMENT.TYPE,DCOUNT(R.BILL.DETAILS<AA.BD.PAYMENT.TYPE>,@VM)+1>    = 'MORA'
                        R.BILL.DETAILS<AA.BD.PAY.PROPERTY,DCOUNT(R.BILL.DETAILS<AA.BD.PAY.PROPERTY>,@VM)+1,-1> = Y.PENAL.PROPERTY
                        R.BILL.DETAILS<AA.BD.OR.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OR.PR.AMT>,@VM)+1,-1>       = 0
                        R.BILL.DETAILS<AA.BD.OS.PR.AMT,DCOUNT(R.BILL.DETAILS<AA.BD.OS.PR.AMT>,@VM)+1,-1>       = 0


                        CALL F.WRITE(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DETAILS)
                    END
                    GOSUB RAISE.CHARGE
                END
                IF c_aalocActivityStatus EQ 'AUTH' THEN
                    GOSUB RAISE.CHARGE
                END
            END
        END
        Y.VAR4 += 1
    REPEAT
    IF Y.OFS.DATA THEN

        ARR.PROPERTY.LIST = Y.BALANCE.MAIN.PROPERTY
        AAA.FIELDS.REC = ""
        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)
        NEW.ACTIVITY.ID = 'MORA.CHARGE.ADJUSTMENT'
        RETURN.ERROR = ''
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)
    END

RETURN
*----------------------------------------------------------
RAISE.CHARGE:
*----------------------------------------------------------
* In this part we trigger the LENDING-ADJUST.BILL-BALANCE.MAINTENANCE as a Secondary activity to adjust the bill

    GOSUB GET.CHARGE.DETAILS
    Y.CHARGE.PER  = R.CONDITION<AA.CHG.CHARGE.RATE,1>         ;* Charge Percentage
    Y.CHARGE.FREQ = R.CONDITION<AA.CHG.LOCAL.REF,POS.L.PENALTY.FREQ>    ;* Charge Calculating Frequency
    Y.PAYMENT.DATE = R.BILL.DETAILS<AA.BD.PAYMENT.DATE>       ;* Payment Date of the Bill

    IF Y.CHARGE.PER AND Y.CHARGE.FREQ AND Y.PAYMENT.DATE ELSE
        GOSUB END1
    END

    LOCATE Y.PENAL.PROPERTY IN c_aalocProductRecord<AA.PRD.CALC.PROPERTY,1> SETTING POS THEN
        Y.SOURCE.BALANCE = c_aalocProductRecord<AA.PRD.SOURCE.BALANCE,POS>          ;* Source Balance for Penalty Charge
    END

    GOSUB GET.PROPERTIES
    GOSUB CALC.NO.OF.CYCLES
*GOSUB GET.PROPERTIES.AMT
*GOSUB CALC.CHARGE.AMT
    IF Y.CHARGE.AMT GT 0 THEN
*Y.CHARGE.AMT = Y.CHARGE.AMT + (Y.CHARGE.AMT/Y.CYCLE)
        CALL EB.ROUND.AMOUNT(c_aalocArrCurrency,Y.CHARGE.AMT,"","")
        GOSUB POST.OFS
    END

    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB UPDATE.CONCAT       ;* To update the Concat file for further raise of charge on Freq Basis
    END

RETURN
*------------------------------------------------------------------------
CALC.NO.OF.CYCLES:
*------------------------------------------------------------------------
* This Part Calculates the cycles of terms that has been crossed
    Y.CYCLE = 1
*Y.CNT = 1
    IF Y.PAYMENT.DATE NE '' AND Y.CHARGE.FREQ NE '' ELSE
        RETURN
    END

    Y.DETAILS    = ''
    Y.DETAILS    = Y.CHARGE.FREQ:'*':Y.PROPERTY.LIST:'*':Y.CHARGE.PER
    Y.ID.DETAILS = ''
    Y.ID.DETAILS = ARR.ID:'*':Y.BILL.ID

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
*Y.FREQ.NUM = Y.FREQ.NUM*Y.CYCLE
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

    Y.PROPERTY.LIST = ''
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
GET.PROPERTIES.AMT:
*------------------------------------------------------------------------

    Y.BILL.AMT = 0
    Y.VAR2 = 1
    Y.PROPERTIES.CNT = DCOUNT(Y.PROPERTY.LIST,@FM)
    LOOP
    WHILE Y.VAR2 LE Y.PROPERTIES.CNT
        Y.PROP = Y.PROPERTY.LIST<Y.VAR2>
        LOCATE Y.PROP IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING PROP.POS THEN
            Y.BILL.AMT += R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,PROP.POS>
        END
        Y.VAR2 += 1
    REPEAT

RETURN
*------------------------------------------------------------------------
CALC.CHARGE.AMT:
*------------------------------------------------------------------------

    Y.CHARGE.AMT = ((Y.BILL.AMT*Y.CHARGE.PER)/100)*Y.CYCLE
*CALL EB.ROUND.AMOUNT(c_aalocArrCurrency,Y.CHARGE.AMT,"","")
RETURN
*------------------------------------------------------------------------
POST.OFS:
*------------------------------------------------------------------------
* Here Secondary activity will be triggered


    LOCATE Y.PENAL.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS.PROP THEN
        Y.REPAY.AMT = SUM(R.BILL.DETAILS<AA.BD.REPAY.AMOUNT,POS.PROP>)
        IF Y.CHARGE.AMT EQ (R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,POS.PROP> + Y.REPAY.AMT) THEN
            RETURN
        END
    END
*    Y.CHARGE.AMT = Y.CHARGE.AMT - Y.REPAY.AMT
    Y.CHARGE.AMT -= Y.REPAY.AMT ;*AUTO R22 CODE CONVERSION

    ARR.FIELD.NAME.LIST<1,1,-1> = "LOCAL.REF:":POS.L.BILL.REF:':':Y.FIELD.CNT++
    ARR.FIELD.VALUE.LIST<1,1,-1> = Y.BILL.ID:"*":Y.CHARGE.AMT
    Y.OFS.DATA<-1> = Y.BILL.ID:'*':Y.CHARGE.AMT

RETURN
*------------------------------------------------------------------------
UPDATE.CONCAT:
*------------------------------------------------------------------------
    R.REDO.CONCAT.PENALTY.CHARGE = ''
    CALL F.READ(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE,F.REDO.CONCAT.PENALTY.CHARGE,CNCT.PEN.ERR)
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
    CALL F.WRITE(FN.REDO.CONCAT.PENALTY.CHARGE,ARR.ID,R.REDO.CONCAT.PENALTY.CHARGE)
RETURN
*------------------------------------------------------------------------
GET.CHARGE.DETAILS:
*------------------------------------------------------------------------

    EFF.DATE = ''
    PROP.CLASS='CHARGE'
    PROPERTY = Y.PENAL.PROPERTY
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);*R22 Manual conversion
    IF ERR.MSG THEN
        GOSUB END1
    END

    EFF.DATE = ''
    PROP.CLASS='PAYMENT.SCHEDULE'
    PROPERTY = ''
    ERR.MSG = ''
    R.PAY.SCH = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.PAY.SCH,ERR.MSG);* R22 Manual conversion

RETURN
*------------------------------------------------------------------------
END1:
*------------------------------------------------------------------------
END
