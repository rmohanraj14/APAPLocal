* @ValidationCode : MjoyOTk1Mjc2MTk6Q3AxMjUyOjE2ODU1MzA2NzY1NDA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:27:56
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
$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.FC.S.PAYMENT.AA
    
*-------------------------------------------------------------------------------------------------
*Modificationj history:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION        Package name added APAP.AA, CALL method format changed
*29-03-2023                        AUTO R22 CODE CONVERSION          VM TO @VM, SM TO @SM,++ TO +=1,> TO GT
*--------------------------------------------------------------------------------------------

    

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
* Development by  : Jorge Valarezo - TAM Latin America
* Date            : 12 December 2011
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : MGUDINO - TAM Latin America
* Date            : 17/05 2012


 


*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_AA.LOCAL.COMMON
***
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.REDO.FC.CL.BALANCE
    $INSERT I_System
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
*   $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.ACTIVITY.BALANCES
*   $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_GTS.COMMON
    $USING APAP.TAM

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'REVERSE' OR c_aalocActivityStatus EQ 'AUTH-REV' THEN

        GOSUB GET.PROPERT.ACCOUNT
        IF Y.PROPERTY.AMT AND Y.PROPERTY.AMT GT 0 THEN
            IF c_aalocActivityStatus EQ 'REVERSE' OR c_aalocActivityStatus EQ 'AUTH-REV' THEN
                Y.PROPERTY.AMT = -1 * Y.PROPERTY.AMT
            END
            APAP.AA.redoFcClPaymentAa(Y.PROPERTY.AMT, ID.ARR);* R22 Manual conversion
        END

        RETURN

    END
RETURN
INITIALISE:
*=========

    F.AA.ACTIVITY.HISTORY       = ''
    FN.AA.ACTIVITY.HISTORY      = 'F.AA.ACTIVITY.HISTORY'
    R.AA.ACTIVITY.HISTORY       = ''
    ID.AA.ACT                   = ''
    ID.AA.ACT.SESSION           = ''
    POS.SM                      = ''
    ID.ACTIVITY                 = ''
***
    FN.AC.BALANCE.TYPE          = 'F.AC.BALANCE.TYPE'
    F.AC.BALANCE.TYPE           = ''
    F.REDO.FC.CL.BALANCE        = ''
    FN.REDO.FC.CL.BALANCE       = 'F.REDO.FC.CL.BALANCE'
    R.REDO.FC.CL.BALANCE        = ''

    ID.ARR                      = ''
    ID.ARR = c_aalocArrId

    Y.AMOUNT                 = 0
**

    Y.PROCESS.DATE              = TODAY
    APAP.TAM.redoConvertAccount(IN.ACC.ID,ID.ARR,Y.ACCOUNT.ID,ERR.TEXT);* R22 Manual conversion

    Y.ACCOUNT.ID                = Y.ACCOUNT.ID
    Y.OUT.AA.AMOUNT             = 0
    Y.BALANCE.TO.CHECK          = ""
    Y.BAL.DETAILS               = ""
    Y.DATE.OPTIONS              = ''
    Y.DATE.OPTIONS<2>           = ""      ;* Request NAU movements
    Y.DATE.OPTIONS<4>           = "ECB"   ;*Type Of Balance
    Y.PRESENT.VALUE             = ''      ;* THe current balance figure
    Y.BALANCE.TYPE              = ''

    P.TOTAL.OUT                 = 0
    Y.MG.ACTUAL                   = ''
    Y.COLLATERAL.ID             = ''

    FN.AA.ACCOUNT.DETAILS = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACCOUNT.DETAILS = ""

    FN.AA.BILL.DETAILS = "F.AA.BILL.DETAILS"
    F.AA.BILL.DETAILS = ""

    FN.AA.ACTIVITY.BALANCES = 'F.AA.ACTIVITY.BALANCES'
    F.AA.ACTIVITY.BALANCES = ''

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''

RETURN
*----------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)
    CALL OPF(FN.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE)
    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)

    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
    CALL OPF(FN.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES)

    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

RETURN

*===================
GET.PROPERT.ACCOUNT:
*===================

    ARR.ID = c_aalocArrId
    CALL F.READ(FN.AA.ACTIVITY.BALANCES,ARR.ID,R.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES,AA.ACT.ERR)

    Y.PROPERTY.AMT = 0
    Y.LOOP1 = 1

    Y.AAA.ID.INDV =''
    Y.AAA.ID =  c_aalocArrActivityId

    Y.AAA.ID.INDV = c_aalocArrActivityId
    Y.CONT = 1
    LOCATE Y.AAA.ID.INDV IN R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.REF,1> SETTING POS2 THEN
        Y.PROPERTY     = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2>
        Y.PROPERTY.VAL = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2,1>
        Y.CONT.TOT = DCOUNT(R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2>, @SM) ;*AUTO R22 CODE CONVERSION
        LOOP
            Y.PROPERTY.VAL = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2,Y.CONT>
            Y.PROPERTY.TYPE = FIELDS(Y.PROPERTY.VAL,'.',2)
            Y.PROPERTY.VAL = FIELDS(Y.PROPERTY.VAL,'.',1)

            Y.PROPERTY.TYPE = SUBSTRINGS(Y.PROPERTY.TYPE ,1,3)
        WHILE Y.CONT LE Y.CONT.TOT
            IF Y.PROPERTY.VAL EQ 'ACCOUNT' AND Y.PROPERTY.TYPE NE 'UNC' AND  Y.PROPERTY.TYPE NE 'UND' THEN
                Y.PROPERTY.AMT += R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY.AMT,POS2,Y.CONT>
            END
            Y.CONT +=1
        REPEAT

    END
*         Y.LOOP1++
*      REPEAT

RETURN

*--------------------------------------------------------------------------------
GET.LIST.OF.AAA:
*--------------------------------------------------------------------------------
    Y.FINAL.AAA.ID = ''
    Y.LOOP.BRK = 1
    LOOP
    WHILE Y.LOOP.BRK
        Y.FINAL.AAA.ID<-1> = Y.AAA.ID
        R.AAA = ''
        CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,Y.AAA.ID,R.AAA,F.AA.ARRANGEMENT.ACTIVITY,AAA.ERR)
        Y.CHILD.ACTIVITY = R.AAA<AA.ARR.ACT.CHILD.ACTIVITY>
        Y.AAA.ID = Y.CHILD.ACTIVITY
        IF Y.CHILD.ACTIVITY ELSE
            Y.LOOP.BRK = 0
        END

    REPEAT
RETURN


*===================
VALIDATE.INFO:
*===================

    CALL CACHE.READ(FN.REDO.FC.CL.BALANCE,ID.ARR,R.REDO.FC.CL.BALANCE,YERR)
    IF NOT(R.REDO.FC.CL.BALANCE) THEN
        RETURN
    END

    Y.COLLATERAL.ID = R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID>
    PAY.AMOUNT.BALANCE = R.REDO.FC.CL.BALANCE<FC.CL.AA.BALANCE>

    IF NOT (Y.COLLATERAL.ID) THEN
        RETURN
    END
*MG START
    IF PAY.AMOUNT.BALANCE THEN
        IF Y.AMOUNT GE PAY.AMOUNT.BALANCE  THEN
            GOSUB CALCULATE.PAYOFF
            IF Y.VALUE.CAPITAL GT 0 THEN ;*AUTO R22 CODE CONVERSION
                APAP.AA.redoFcClPaymentAa(Y.VALUE.CAPITAL, ID.ARR);* R22 Manual conversion
            END ELSE
                APAP.AA.redoFcClPaymentAa(Y.AMOUNT, ID.ARR);* R22 Manual conversion
            END
        END ELSE
            APAP.AA.redoFcClPaymentAa(Y.AMOUNT, ID.ARR);* R22 Manual conversion
        END
    END
*MG END

RETURN
*=============
CALCULATE.PAYOFF:
*=============
    CALL F.READ(FN.AA.ACCOUNT.DETAILS, ID.ARR, R.AA.ACCOUNT.DETAILS, F.AA.ACCOUNT.DETAILS, Y.ERR)
    IF R.AA.ACCOUNT.DETAILS THEN
* Tomar el campo BILL.PAY.DATE
        Y.MAX.PAY = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>, @VM) ;*AUTO R22 CODE CONVERSION
        FOR Y.VAR = 1 TO Y.MAX.PAY
* Revisar que el campo BILL:TYPE sea PAYOFF
            Y.BILL.TYPE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE, Y.VAR, 1>
            IF Y.BILL.TYPE EQ 'PAYOFF' THEN
*Tomasr el ID BILL ID
                Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID, Y.VAR, 1>
                Y.VAR = Y.MAX.PAY
            END
        NEXT
    END ELSE
        RETURN
    END
    IF Y.BILL.ID THEN
* Quitar los slash al BILL.ID
        Y.ID.BILL = ''
        Y.SLASH.CONT = DCOUNT(Y.BILL.ID, '/')
        Y.SLASH.CONT += 1 ;*AUTO R22 CODE CONVERSION
        FOR Y.C = 1 TO Y.SLASH.CONT
            Y.ID.BILL := FIELD(Y.BILL.ID, '/', Y.C)
        NEXT

*Abrir el registro AA.BILL.DETAIL
        CALL F.READ(FN.AA.BILL.DETAILS, Y.ID.BILL, R.AA.BILL.DETAILS, F.AA.BILL.DETAILS, Y.ERR)
        IF R.AA.BILL.DETAILS THEN
            LOCATE 'ACCOUNT' IN R.AA.BILL.DETAILS<AA.BD.PROPERTY, 1> SETTING POS.AC THEN
                Y.VALUE.CAPITAL = R.AA.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT, POS.AC>
            END
        END
    END
RETURN
*=============
VERIFY.REVERSE:
*=============
    IF c_aalocActivityStatus EQ 'REVERSE' THEN
        Y.AMOUNT = Y.AMOUNT * -1
    END
RETURN
END
