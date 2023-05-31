* @ValidationCode : MjotMTI2MjQ3NzAyMjpDcDEyNTI6MTY4NTUzNDAyODc1Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 17:23:48
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
$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE S.REDO.CCRG.AA.GET.BAL(P.CONTRACT.ID, R.AA, P.RETURN)
*-----------------------------------------------------------------------------------
* Modification History:
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023    Conversion Tool         AUTO R22 CODE CONVERSION            VM TO @VM,SM TO @SM
* 29/03/2023         SURESH             MANUAL R22 CODE CONVERSION        Package Name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------
*
*--------------------------------------------------------------------------------------------
* Company Name : Bank Name
* Developed By : Temenos Application Management
*--------------------------------------------------------------------------------------------
* Description: This program get the balances for the contract in ARRANGEMENT application
*
*
* Linked With:
*               SERVICE      REDO.CCRG.B.EXT
*               PARAMETER in REDO.CCRG.PARAMETERS field P.EVALUATOR.RTN
*
* In Parameter:
*               P.CONTRACT.ID    (in)  Contranct Id.
*               R.AA             (in)  Record of the contract in process
*
* Out Parameter:
*               P.RETURN         (out) Returns balances related: 1 Direct Balance, 2 Income Receivable, 3 Balance Contingent
*               E                (out) Message in case Error
*
*--------------------------------------------------------------------------------------------
* Modification Details:
*=====================
* 18/04/2011 - ODR-2011-03-0154
*              Description of the development associated
*              anoriega@temenos.com
* 22/07/2011 - ODR-2011-03-0154
*              New types of balances for calculation
*              avelasco@temenos.com
*REM Just for compile
*--------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
*
    $INSERT I_REDO.CCRG.CONSTANT.COMMON
    $USING APAP.TAM
*
*--------------------------------------------------------------------------------------------
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*
*--------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------

* Get Account number related to Arrangement Contract
    R.LINKED.APPL = ''
    R.LINKED.APPL = CHANGE(R.AA<AA.ARR.LINKED.APPL>, @VM, @FM) ;*AUTO R22 CODE CONVERSION
    LOCATE 'ACCOUNT' IN R.LINKED.APPL SETTING Y.POS THEN
        Y.ACCOUNT = ''
        Y.ACCOUNT = R.AA<AA.ARR.LINKED.APPL.ID,Y.POS>
    END
    IF NOT(Y.ACCOUNT) THEN
        E    = "ST-REDO.CCRG.AA.ACCOUNT.ID.NOT.FOUND"
        E<2> =  P.CONTRACT.ID : @VM : FN.AA.ARRANGEMENT ;*AUTO R22 CODE CONVERSION
        RETURN
    END

*Get Contract Balance for the Y.ACCOUNT
    R.ECB = ''
    YERR  = ''
    CALL F.READ(FN.EB.CONTRACT.BALANCES,Y.ACCOUNT,R.ECB,F.EB.CONTRACT.BALANCES,YERR)
    IF NOT(R.ECB) THEN
        E    = "ST-REDO.CCRG.NOT.CONTRACT.BAL.AA"
        E<2> =  Y.ACCOUNT : @VM : FN.EB.CONTRACT.BALANCES ;*AUTO R22 CODE CONVERSION
        RETURN
    END

*Get Balances
    Y.BD = 0
    Y.CB = 0
    Y.RB = 0

*Locate every balance from the R.ECB<ECB.TYPE.SYSDATE> field
*The field OPEN.BALANCE has the balance of the last day
*The field CREDIT.MVMT has the credit movements made during of the day
*The field DEBIT.MVM has the debit movements made during of the day

    Y.POS = ''
    R.TYPE.SYSDATE = CHANGE(R.ECB<ECB.TYPE.SYSDATE>, @VM, @FM) ;*AUTO R22 CODE CONVERSION
*
    LOCATE 'CURACCOUNT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD  = R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL = 'CURACCOUNT-':Y.PROCESS.DATE
    CALL OCOMO('BAL:':Y.TYP.BAL)
    LOCATE Y.TYP.BAL IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END
*
    LOCATE 'GRCACCOUNT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL = 'GRCACCOUNT-':Y.PROCESS.DATE
    LOCATE Y.TYP.BAL IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END
*
    LOCATE 'DE1ACCOUNT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL = 'DE1ACCOUNT-':Y.PROCESS.DATE
    LOCATE Y.TYP.BAL  IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END
*
    LOCATE 'DELACCOUNT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL =  'DELACCOUNT-':Y.PROCESS.DATE
    LOCATE Y.TYP.BAL  IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

*
    LOCATE 'NABACCOUNT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL =  'NABACCOUNT-':Y.PROCESS.DATE
    LOCATE Y.TYP.BAL  IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.BD += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.BD += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.BD += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END
*
    LOCATE 'CURCOMMITMENT' IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.CB  = R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.CB += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.CB += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

    Y.TYP.BAL = 'CURCOMMITMENT-':Y.PROCESS.DATE
    LOCATE Y.TYP.BAL IN  R.TYPE.SYSDATE SETTING Y.POS THEN
        Y.CB += R.ECB<ECB.OPEN.BALANCE,Y.POS,1>
        Y.CB += R.ECB<ECB.CREDIT.MVMT,Y.POS,1>
        Y.CB += R.ECB<ECB.DEBIT.MVMT,Y.POS,1>
    END

*Get Payments and acumlate the Y.RB balances
    R.AA.AD = ''
    YERR = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS, P.CONTRACT.ID, R.AA.AD, F.AA.ACCOUNT.DETAILS, YERR)
    Y.CNT.BILL.ID = DCOUNT(R.AA.AD<AA.AD.BILL.ID>, @VM) ;*AUTO R22 CODE CONVERSION
    FOR I.VAR = 1 TO Y.CNT.BILL.ID
        Y.IS.PAYMENT = ''
        Y.IS.PAYMENT = R.AA.AD<AA.AD.BILL.TYPE,I.VAR> EQ "PAYMENT";*AUTO R22 CODE CONVERSION
        Y.IS.PAYMENT = Y.IS.PAYMENT AND R.AA.AD<AA.AD.SET.STATUS,I.VAR,1> EQ 'UNPAID'
        Y.PAY.DATE = R.AA.AD<AA.AD.BILL.PAY.DATE,I.VAR>

*If the Pay date is greater than the date of proceeding go the next process BILL
        IF Y.IS.PAYMENT AND Y.PAY.DATE LE Y.PROCESS.DATE THEN
            GOSUB GET.BILL.AMT
        END
    NEXT I.VAR ;*AUTO R22 CODE CONVERSION

* Get values for balances in local currency
    Y.CURR.CONTRACT = R.ECB<ECB.CURRENCY>
*    Y.CURR.BILL     = BILL.DETAILS<AA.BD.CURRENCY>

    IF Y.CURR.CONTRACT NE LCCY THEN
        APAP.TAM.sRedoConvLocalCurr(Y.CURR.CONTRACT,1,P.REV.RATE);* R22 Manual conversion
        Y.BD = Y.BD * P.REV.RATE
        Y.CB = Y.CB * P.REV.RATE
        CALL EB.ROUND.AMOUNT(LCCY, Y.BD, "", "")
        CALL EB.ROUND.AMOUNT(LCCY, Y.CB, "", "")
    END

*Balances to send go out

    P.RETURN<1> = ABS(Y.BD)
    P.RETURN<2> = ABS(Y.RB)
    P.RETURN<3> = ABS(Y.CB)

RETURN

*--------------------------------------------------------------------------------------------
GET.BILL.AMT:
*--------------------------------------------------------------------------------------------
*Calculate number of days between PayDate and Today
    NO.OF.DAYS = ''
    CALL CDD('',Y.PAY.DATE,Y.PROCESS.DATE ,NO.OF.DAYS)
*if the NO.OF.DAYS es greater than 90, GET the next BILL
    IF NO.OF.DAYS GT 90 THEN
        RETURN
    END

*Get Bill Details
    BILL.REFERENCE = R.AA.AD<AA.AD.BILL.ID,I.VAR> ;*AUTO R22 CODE CONVERSION
    BILL.DETAILS   = ''
    RET.ERROR      = ''
    CALL AA.GET.BILL.DETAILS(P.CONTRACT.ID, BILL.REFERENCE, BILL.DETAILS, RET.ERROR)

    R.PAY.PROPERTY = BILL.DETAILS<AA.BD.PAY.PROPERTY>
    R.PAY.PROPERTY = CHANGE(R.PAY.PROPERTY,@SM,@FM) ;*AUTO R22 CODE CONVERSION
    Y.CURR.BILL     = BILL.DETAILS<AA.BD.CURRENCY>  ;* TEST

    Y.POS = 0
    LOOP
        REMOVE PROPERTY.ID FROM R.PAY.PROPERTY SETTING Y.PROPERTY.MARK
    WHILE PROPERTY.ID : Y.PROPERTY.MARK
        Y.POS += 1 ;*AUTO R22 CODE CONVERSION
        IF PROPERTY.ID EQ 'PRINCIPALINT' THEN
            Y.RB += BILL.DETAILS<AA.BD.OS.PR.AMT,1,Y.POS>
        END
    REPEAT

    IF  Y.CURR.BILL NE LCCY THEN          ;*
        P.REV.RATE = 1
        APAP.TAM.sRedoConvLocalCurr(Y.CURR.BILL,1,P.REV.RATE);* R22 Manual conversion
        Y.RB = Y.RB * P.REV.RATE
        CALL EB.ROUND.AMOUNT(LCCY,Y.RB, "", "")
    END
RETURN

*--------------------------------------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------------------------------------
*
    FN.EB.CONTRACT.BALANCES  = 'F.EB.CONTRACT.BALANCES'
    F.EB.CONTRACT.BALANCES   = ''
    CALL OPF(FN.EB.CONTRACT.BALANCES ,F.EB.CONTRACT.BALANCES )
*
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS  = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
***MANUAL R22 CODE CONVERSION*******
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
*

RETURN

*--------------------------------------------------------------------------------------------
INITIALISE:
*--------------------------------------------------------------------------------------------

    LOOP.CNT         = 1
    MAX.LOOPS        = 2
    PROCESS.GOAHEAD  = @TRUE
    P.RETURN         = ''

*Process Date
    Y.PROCESS.DATE   = TODAY
RETURN

*--------------------------------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*--------------------------------------------------------------------------------------------

    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1
                IF NOT(P.CONTRACT.ID) THEN
                    E = K.PARAMETER.IS.EMPTY : @FM : "P.CONTRACT.ID" : @VM : "S.REDO.CCRG.AA.GET.BAL" ;*AUTO R22 CODE CONVERSION
                    PROCESS.GOAHEAD = @FALSE
                END
            CASE LOOP.CNT EQ 2
                IF NOT(R.AA) THEN
                    E = K.PARAMETER.IS.EMPTY : @FM : "R.AA" : @VM : "S.REDO.CCRG.AA.GET.BAL" ;*AUTO R22 CODE CONVERSION
                    PROCESS.GOAHEAD = @FALSE
                END
        END CASE

        LOOP.CNT +=1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------

END
