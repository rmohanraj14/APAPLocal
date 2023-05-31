* @ValidationCode : MjoxNTcyNjY2Nzc6Q3AxMjUyOjE2ODU1MzE1MDIwMjU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:41:42
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
$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.POST.PAYOFF.REM.PAYSCH
*-------------------------------------------------
* Description: This CALL routine is to update the payment schedule property
*              by removing the scheduled charges after the payoff payment.
*              This is CALL routine from REDO.POST.CHEQUE.UPDATE.
*              Here we will check whether the transaction amt is greator than
*              the loan outstanding amount
*----------------------------------------------------------------------------------------------------
*Modification History:
*Date           Who                     Reference                                  Descripition
* 29-03-2023  Conversion Tool    Auto R22 code conversion                 FM TO @FM , VM TO @VM, SM TO @SM
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA, CALL method format changed
*-------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM

    GOSUB PROCESS

RETURN
*-------------------------------------------------
PROCESS:
*-------------------------------------------------
* Here the main process begins and we will check the loan outstanding amt & txn amount.

    Y.ID   = c_aalocArrId:"*":c_aalocActivityEffDate
    ARR.ID = c_aalocArrId
    GOSUB UPDATE.PAYMENT.SCHEDULE

* Following lines are commented cos this routine is called only when payoff activity is triggered. so we presume that
* during payoff all the balances will be settled hence we dont require to check balances. Note: During the cheque reversal
* We will not reapply the cash amount with payoff activity instead we will trigger FT based on REDO.H.AA.DIS.CHG>ACTUAL.FTTC.

*CALL REDO.GET.TOTAL.OUTSTANDING.SIN.UNC.UND(Y.ID,Y.PROP.AMT,Y.TOTAL.AMT)
*Y.TRANSACTION.AMOUNT = c_aalocArrActivityRec<AA.ARR.ACT.ORIG.TXN.AMT>
*IF Y.TRANSACTION.AMOUNT GE Y.TOTAL.AMT THEN   ;* Here we are checking whether transaction amount is greator than loan outstanding amt.
*END

RETURN
*-------------------------------------------------
UPDATE.PAYMENT.SCHEDULE:
*-------------------------------------------------
    Y.AA.ID     = c_aalocArrId
    EFF.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'PAYMENT.SCHEDULE'
    PROPERTY    = ''
    R.CONDITION.PAYSCH = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.PAYSCH,ERR.MSG);* R22 Manual conversion

    Y.ACCOUNT.PROP  = ''
    Y.INTEREST.PROP = ''
    APAP.TAM.redoGetPropertyName(Y.AA.ID,'ACCOUNT',R.OUT.AA.RECORD,Y.ACCOUNT.PROP,OUT.ERR);* R22 Manual conversion
    APAP.TAM.redoGetPropertyName(Y.AA.ID,'INTEREST',R.OUT.AA.RECORD,Y.INTEREST.PROP,OUT.ERR);* R22 Manual conversion

    Y.IMPORTANT.PROPERTY     = Y.ACCOUNT.PROP:@FM:Y.INTEREST.PROP ;*AUTO R22 CODE CONVERSION
    Y.IMPORTANT.PROPERTY.CNT = DCOUNT(Y.IMPORTANT.PROPERTY,@FM) ;*AUTO R22 CODE CONVERSION
    Y.DELETE.PAYPOS          = ''

    Y.PAYMENT.TYPE     = R.CONDITION.PAYSCH<AA.PS.PAYMENT.TYPE>
    Y.PAYMENT.TYPE.CNT = DCOUNT(Y.PAYMENT.TYPE,@VM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.PAYMENT.TYPE.CNT
        Y.PROPERTIES     = R.CONDITION.PAYSCH<AA.PS.PROPERTY,Y.VAR1>
        CHANGE @SM TO @VM IN Y.PROPERTIES ;*AUTO R22 CODE CONVERSION
        Y.VAR2 = 1
        LOOP
        WHILE Y.VAR2 LE Y.IMPORTANT.PROPERTY.CNT
            IF Y.IMPORTANT.PROPERTY<Y.VAR2> MATCHES Y.PROPERTIES THEN
                Y.VAR2 = Y.IMPORTANT.PROPERTY.CNT+1       ;* Instead of break.
            END ELSE
                IF Y.VAR2 EQ Y.IMPORTANT.PROPERTY.CNT THEN
*Y.DELETE.PAYPOS<-1> = Y.VAR1
                    GOSUB TRIGGER.SECONDARY.ACTIVITY
                    Y.VAR1 = Y.PAYMENT.TYPE.CNT + 1
                END
            END
            Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
        REPEAT
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

*IF Y.DELETE.PAYPOS THEN
*GOSUB FORM.OFS.MESSAGE
*GOSUB TRIGGER.SECONDARY.ACTIVITY
*END

RETURN
*-------------------------------------------------
*FORM.OFS.MESSAGE:
*-------------------------------------------------
*ARR.FIELD.NAME.LIST  = ""
*ARR.FIELD.VALUE.LIST = ""
*Y.DELETE.CNT = DCOUNT(Y.DELETE.PAYPOS,FM)
*Y.LOOP1 = 1
*LOOP
*WHILE Y.LOOP1 LE Y.DELETE.CNT
*Y.PROPERTY       = R.CONDITION.PAYSCH<AA.PS.PROPERTY,Y.DELETE.PAYPOS<Y.LOOP1>>
*Y.START.DATE     = R.CONDITION.PAYSCH<AA.PS.START.DATE,Y.DELETE.PAYPOS<Y.LOOP1>>
*Y.PROP.CNT       = DCOUNT(Y.PROPERTY,SM)
*Y.START.DATE.CNT = DCOUNT(Y.START.DATE,SM)
*IF Y.PROP.CNT EQ 1 AND Y.START.DATE.CNT EQ 1 THEN
*ARR.FIELD.NAME.LIST<1,1,-1>  = "PAYMENT.TYPE:":Y.DELETE.PAYPOS<Y.LOOP1>:":1"
*ARR.FIELD.VALUE.LIST<1,1,-1> = "|-|"
*END ELSE
*IF Y.PROP.CNT GT 1 THEN
*Y.SUB.CNT    = Y.PROP.CNT
*Y.FIELD.NAME = 'PROPERTY'
*GOSUB DELETE.SUB.VALUES
*END
*IF Y.START.DATE.CNT GT 1 THEN
*Y.SUB.CNT    = Y.START.DATE.CNT
*Y.FIELD.NAME = 'START.DATE'
*GOSUB DELETE.SUB.VALUES
*END
*ARR.FIELD.NAME.LIST<1,1,-1>  = "PAYMENT.TYPE:":Y.DELETE.PAYPOS<Y.LOOP1>:":1"
*ARR.FIELD.VALUE.LIST<1,1,-1> = "|-|"
*END
*Y.LOOP1++
*REPEAT
*RETURN
*-------------------------------------------------
*DELETE.SUB.VALUES:
*-------------------------------------------------
*LOOP
*WHILE Y.SUB.CNT GT 1
*ARR.FIELD.NAME.LIST<1,1,-1>  = Y.FIELD.NAME:":":Y.DELETE.PAYPOS<Y.LOOP1>:":":Y.SUB.CNT
*ARR.FIELD.VALUE.LIST<1,1,-1> =  "|-|"
*Y.SUB.CNT--
*REPEAT
*RETURN
*-------------------------------------------------
TRIGGER.SECONDARY.ACTIVITY:
*-------------------------------------------------
* Here we will trigger the secondary activity.

    ARR.FIELD.NAME.LIST  = ""
    ARR.FIELD.VALUE.LIST = ""
    APAP.TAM.redoGetPropertyName(Y.AA.ID,'PAYMENT.SCHEDULE',R.OUT.AA.RECORD,Y.PAYSCH.PROP,OUT.ERR);* R22 Manual conversion
    ARR.PROPERTY.LIST    = Y.PAYSCH.PROP
    AAA.FIELDS.REC = ""
    CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)

    NEW.ACTIVITY.ID = 'REDO.REMOVE.CHARGE'
    RETURN.ERROR = ''
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)

RETURN
END
