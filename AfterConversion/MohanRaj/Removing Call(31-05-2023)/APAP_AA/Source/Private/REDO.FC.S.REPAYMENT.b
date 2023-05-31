* @ValidationCode : MjotOTkwMzM5MzI1OkNwMTI1MjoxNjg1NTMwODI0MzcxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:30:24
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
SUBROUTINE REDO.FC.S.REPAYMENT
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL       AUTO R22 CODE CONVERSION         ++ TO =1,SM TO @SM, VM TO @VM,FM TO @FM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------
*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.CREATE.ARRANGEMENT.AUTHORISE
* Attached as     : ROUTINE
* Primary Purpose : Catch the principal amount of payment then updating the balance (saldo disponible)
*                   in COLLATERAL application
*
* Incoming:
* ---------
*
*
* Outgoing:
* ---------
*
*
* Error Variables:
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            : 12 Septiembre 2011
* Ammended by     : Marcelo G. - TAM Latin America
* Date            : 11-11-11
*
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $USING APAP.TAM
    GOSUB INITIALISE
    GOSUB OPEN.FILES

* PACS00350509 - 2014SEP24 - S
    IF c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'AUTH-REV' OR c_aalocActivityStatus EQ 'REVERSE' THEN

        GOSUB GET.PROPERTY
        GOSUB CHECK.PRG

        IF TOTAL.ACC.AMT THEN
*Release the Capital Payment amount in the COLLATERAL
*If c_aalocActivityStatus = REVERSE, have to change the sign in the TOTAL.ACC.AMT amount
            IF c_aalocActivityStatus EQ 'AUTH-REV' OR c_aalocActivityStatus EQ 'REVERSE' THEN
* PACS00350509 - 2014SEP24 - E
                TOTAL.ACC.AMT = TOTAL.ACC.AMT * -1
            END
            R.REDO.FC.CL.BALANCE = ''
            YERR = ''
            CALL F.READ(FN.REDO.FC.CL.BALANCE,c_aalocArrId,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,YERR)
            IF R.REDO.FC.CL.BALANCE THEN
                APAP.AA.redoFcClPaymentAa(TOTAL.ACC.AMT, c_aalocArrId);* R22 Manual conversion
            END ELSE      ;* For Migrated contracts
                APAP.AA.redoFcClPaymentAa(TOTAL.ACC.AMT, c_aalocArrId);* PACS00350509 - S/E, ;* R22 Manual conversion
            END
*
        END ELSE
            CALL F.READ(FN.REDO.FC.CL.BALANCE,c_aalocArrId,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,YERR)
            IF R.REDO.FC.CL.BALANCE THEN
                APAP.AA.redoFcSPaymentAa();* R22 Manual conversion
            END ELSE      ;* For Migrated contracts
                APAP.AA.redoFcSPaymentAa();* PACS00350509 - S/E, ;* R22 Manual conversion
            END

        END

    END

RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------

*------------------------
INITIALISE:
*=========

    FN.REDO.FC.CL.BALANCE = 'F.REDO.FC.CL.BALANCE'
    F.REDO.FC.CL.BALANCE = ''

    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    FN.ACCT.ACTIVITY = 'F.ACCT.ACTIVITY'
    F.ACCT.ACTIVITY = ''
    Y.DISBURSE.AMT = 0
*****
RETURN
*----------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------
    CALL OPF(FN.REDO.FC.CL.BALANCE, F.REDO.FC.CL.BALANCE)
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.ACCT.ACTIVITY,F.ACCT.ACTIVITY)

RETURN
*----------------------------------------------------------------------
GET.PROPERTY:
*-----------------------------------------------------------------------
    VAR.ARR.ID =  c_aalocArrId
    IN.PROPERTY.CLASS='ACCOUNT'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.ACC.PROPERTY,OUT.ERR);* R22 Manual conversion
    IN.PROPERTY.CLASS='INTEREST'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.INT.PROPERTY,OUT.ERR);* R22 Manual conversion
    IN.PROPERTY.CLASS='TERM.AMOUNT'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.TERM.PROPERTY,OUT.ERR);* R22 Manual conversion
RETURN

*----------------------------------------------------------------------------------------
CHECK.PRG:
*----------------------------------------------------------------------------------------
    GOSUB GET.ACCOUNT
    GOSUB CHK.PRODUCT
RETURN
*--------------------------------------------------------------------------------------------------
GET.ACCOUNT:
*----------------------------------------------------------------------------------------------------

    Y.ARR.ID = c_aalocArrId
    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.ARR.ID,Y.ACCOUNT.ID,ERR.TEXT);* R22 Manual conversion
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    CU  = R.ACCOUNT<AC.CUSTOMER>
RETURN
*------------------------------------------------------------------------------------------------------
CHK.PRODUCT:
*----------------------------------------------------------------------------------------------------
    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
*    LOCATE Y.CATEGORY IN PRG.PRO SETTING CAT.POS THEN
    Y.TOT = 'TOT':Y.TERM.PROPERTY
    Y.CUR = 'CUR':Y.TERM.PROPERTY
    DATE.OPTIONS = ''
    EFFECTIVE.DATE = TODAY
    DATE.OPTIONS<4>  = 'ECB'
    BALANCE.AMOUNT = ""
    CALL AA.GET.PERIOD.BALANCES(Y.ACCOUNT.ID, Y.TOT, DATE.OPTIONS, EFFECTIVE.DATE, "", "", TOT.BAL.DETAILS, "")
    TOT.BAL.CNT = DCOUNT(TOT.BAL.DETAILS<IC.ACT.BALANCE>,@VM) ;*AUTO R22 CODE CONVERSION
    TOT.BAL = ABS(TOT.BAL.DETAILS<IC.ACT.BALANCE,TOT.BAL.CNT>)
    CALL AA.GET.PERIOD.BALANCES(Y.ACCOUNT.ID, Y.CUR, DATE.OPTIONS, EFFECTIVE.DATE, "", "", CUR.BAL.DETAILS, "")
    CUR.BAL.CNT = DCOUNT(CUR.BAL.DETAILS<IC.ACT.BALANCE>,@VM) ;*AUTO R22 CODE CONVERSION
    CUR.BAL = ABS(CUR.BAL.DETAILS<IC.ACT.BALANCE,CUR.BAL.CNT>)
    VAR.DISP.AMT = TOT.BAL - CUR.BAL
    IF VAR.DISP.AMT GE Y.DISBURSE.AMT THEN
        GOSUB PROCESS
    END
*END
RETURN
*-------------------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

    R.ACCOUNT.DETAILS = c_aalocAccountDetails
    Y.REPAY.REF=R.ACCOUNT.DETAILS<AA.AD.REPAY.REFERENCE>
    Y.REPAY.CNT=DCOUNT(Y.REPAY.REF,@VM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1=1 ; DELAYP = ''
    LOOP
    WHILE Y.VAR1 LE Y.REPAY.CNT
        Y.REPAY.REF.ID=FIELD(Y.REPAY.REF<1,Y.VAR1>,'-',1)
        Y.REPAY.DATE = FIELD(Y.REPAY.REF<1,Y.VAR1>,'-',2)
        IF Y.REPAY.REF.ID EQ c_aalocArrActivityId AND Y.REPAY.DATE EQ TODAY THEN
            Y.BILL.ID = R.ACCOUNT.DETAILS<AA.AD.RPY.BILL.ID,Y.VAR1>
            CHANGE @SM TO @FM IN Y.BILL.ID ;*AUTO R22 CODE CONVERSION
            CHANGE @VM TO @FM IN Y.BILL.ID ;*AUTO R22 CODE CONVERSION
            GOSUB BILL.DETAILS
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
    R.AA.ACTIVITY  = c_aalocArrActivityRec
RETURN
*----------------------------------------------------------------------
BILL.DETAILS:
*----------------------------------------------------------------------

    Y.BILL.COUNT=DCOUNT(Y.BILL.ID,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.BILL.COUNT
        BILL.ID=Y.BILL.ID<Y.VAR2>
        CALL F.READ(FN.AA.BILL.DETAILS,BILL.ID,R.BILL.DETAIL,F.AA.BILL.DETAILS,BILL.ERR)
        VAR.PROP = R.BILL.DETAIL<AA.BD.PROPERTY>
        VAR.BILL.DATE = R.BILL.DETAIL<AA.BD.BILL.DATE>
        CHANGE @VM TO @FM IN VAR.PROP ;*AUTO R22 CODE CONVERSION
        CHANGE @VM TO @FM IN VAR.BILL.DATE ;*AUTO R22 CODE CONVERSION
        IF DELAYP NE 'E' THEN
            GOSUB CHK.DELAY
        END
        GOSUB GET.INT.AMT
        GOSUB GET.ACC.AMT
        Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*---------------------------------------------------
CHK.DELAY:
*---------------------------------------------------
    Y.BILL.DATE = VAR.BILL.DATE<1>
    IF Y.BILL.DATE LT TODAY THEN
        DELAYP = 'E'
    END ELSE
        DELAYP = 'N'
    END
RETURN
*----------------------------------------------------------------------------------------
GET.ACC.AMT:
*----------------------------------------------------------------------------------------

    Y.ACC.PROPERTY.COUNT = DCOUNT(Y.ACC.PROPERTY,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR4=1
    LOOP
    WHILE Y.VAR4 LE Y.ACC.PROPERTY.COUNT
        Y.PROP = Y.ACC.PROPERTY<Y.VAR4>
        LOCATE Y.PROP IN VAR.PROP SETTING PROPERTY.POS THEN
            VAR.REPAY.REF = R.BILL.DETAIL<AA.BD.REPAY.REF,PROPERTY.POS>
            VAR.REPAY.CNT = DCOUNT(VAR.REPAY.REF,@SM) ;*AUTO R22 CODE CONVERSION
            Y.VAR5=1
            GOSUB GET.ACC.AMT.WHILE
        END
        Y.VAR4 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------------------------------------
GET.INT.AMT:
*----------------------------------------------------------------------------------------
    Y.INT.PROPERTY.COUNT= DCOUNT(Y.INT.PROPERTY,@FM)
    Y.VAR3=1
    LOOP
    WHILE Y.VAR3 LE Y.INT.PROPERTY.COUNT
        Y.PROPERTY = Y.INT.PROPERTY<Y.VAR3>
        LOCATE Y.PROPERTY IN VAR.PROP SETTING PROP.POS THEN
            VAR.REPAY.REF = R.BILL.DETAIL<AA.BD.REPAY.REF,PROP.POS>
            VAR.REPAY.CNT = DCOUNT(VAR.REPAY.REF,@SM) ;*AUTO R22 CODE CONVERSION
            Y.VAR6=1
            GOSUB GET.INT.AMT.WHILE
        END
        Y.VAR3 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN

*----------------------------------------------------------------------------------------
GET.INT.AMT.WHILE:
*----------------------------------------------------------------------------------------
    LOOP
    WHILE Y.VAR6 LE VAR.REPAY.CNT
        VAR.REPAY.REF.ID=FIELD(VAR.REPAY.REF<1,Y.VAR6>,'-',1)
        IF VAR.REPAY.REF.ID EQ c_aalocArrActivityId THEN
            TOT.INT.AMT = R.BILL.DETAIL<AA.BD.REPAY.AMOUNT,PROP.POS,Y.VAR6>
            TOTAL.INT.AMT+=TOT.INT.AMT
*                  BREAK
            Y.VAR6 = VAR.REPAY.CNT +1
        END
        Y.VAR6 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN

*----------------------------------------------------------------------------------------
GET.ACC.AMT.WHILE:
*----------------------------------------------------------------------------------------

    LOOP
    WHILE Y.VAR5 LE VAR.REPAY.CNT
        VAR.REPAY.REF.ID=FIELD(VAR.REPAY.REF<1,Y.VAR5>,'-',1)
        IF VAR.REPAY.REF.ID EQ c_aalocArrActivityId THEN
            TOT.ACC.AMT = R.BILL.DETAIL<AA.BD.REPAY.AMOUNT,PROPERTY.POS,Y.VAR5>
            TOTAL.ACC.AMT+=TOT.ACC.AMT
*                  BREAK
            Y.VAR5 = VAR.REPAY.CNT + 1
        END
        Y.VAR5 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN

END
