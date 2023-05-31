* @ValidationCode : MjotMTE4MjU4MjEwNTpDcDEyNTI6MTY4NTUyOTcwODUxMDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:11:48
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
SUBROUTINE REDO.COL.CALC.SALD.MOD

* Subroutine Type : ROUTINE
* Attached to     : REDO.COL.CALC.SALD.MOD
* Attached as     : ROUTINE
* Primary Purpose : Calculate the avail amount if NOMINAL.VALUA HAS BEEN CHANGED
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Jorge Valarezo - TAM Latin America
* Date            : 4-Mar-2013

* 29-MAR-2023   Conversion Tool            R22 Auto Conversion  - VM to @VM , SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion -  CALL method format changed
*-----------------------------------------------------------------------------------
* MM

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_System
    $INSERT I_F.REDO.FC.CL.BALANCE
    $USING APAP.REDOSRTN
    $USING APAP.TAM

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*-----------------------------------------------------------------------------------
PROCESS:
*======
* PACS00307565 - S
    IF NOT(Y.AA) THEN ;*IF THE CREDIT DOESN'T EXISTE EXIT
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = R.NEW(COLL.LOCAL.REF)<1,Y.LN.MX.VAL.POS>
        RETURN
    END

    GOSUB GET.AAID.SM
* PACS00307565 - E
    Y.MAX = R.NEW(COLL.LOCAL.REF)<1,Y.LN.MX.VAL.POS>

    IF R.NEW(COLL.COLLATERAL.CODE) NE '150' THEN
        GOSUB GET.NOTDI.CALC      ;* PACS00307565 - S/E
    END
    ELSE
        GOSUB GET.RISK.PERCENT
        Y.AVA.AMOUNT = (R.NEW(COLL.NOMINAL.VALUE)*100)/Y.RISK.PERC
        Y.AVAIL      = DROUND(Y.AVA.AMOUNT,2)
    END

    IF Y.AVAIL GT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = Y.AVAIL
    END
    IF Y.AVAIL NE "" AND Y.AVAIL LT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = 0.00
    END

RETURN
*----------------------------------------------------------------------------
*
GET.NOTDI.CALC:
*==============
*
    Y.MAX.OLD   = R.OLD(COLL.LOCAL.REF)<1,Y.LN.MX.VAL.POS>
    Y.MAX.NEW   = R.NEW(COLL.LOCAL.REF)<1,Y.LN.MX.VAL.POS>
    Y.AA.ID.OLD = R.OLD(COLL.LOCAL.REF)<1,Y.LOAN.ID>
    Y.AA.ID.NEW = R.NEW(COLL.LOCAL.REF)<1,Y.LOAN.ID>
    Y.AVBAL.OLD = R.OLD(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS>
    Y.AVBAL.NEW = R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS>      ;* PACS00350509 - 2014OCT13 - S/E
    Y.MAX.DIF   = Y.MAX.NEW - Y.MAX.OLD
*
    Y.ADD = Y.MAX.DIF + Y.AVBAL.OLD
*
    IF Y.AA.ID.OLD EQ Y.AA.ID.NEW AND Y.AVBAL.OLD THEN        ;* There is no change in arrangement id field
        GOSUB VAL.AAID.NOCHG
    END
    ELSE    ;* There is change in loan id field
        GOSUB VAL.AAID.CHG
    END
*
RETURN
*
VAL.AAID.NOCHG:
*==============
    IF Y.ADD LT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = 0.00
    END ELSE
        GOSUB GET.MULT.SING.CALC  ;* PACS00350509 - 2014OCT13 - S/E
    END
*
RETURN
*
VAL.AAID.CHG:
*============
*
    Y.BAL.CH = Y.MAX - Y.AA.BAL

    IF Y.BAL.CH GT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = Y.BAL.CH
    END
    ELSE
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = 0
    END
*
RETURN
*
GET.AAID.SM:
*===========
*
    Y.AA.NUM = DCOUNT(Y.AA,@SM)
    Y.VAR = 1
    LOOP
    WHILE Y.VAR LE Y.AA.NUM
        Y.AA.ID = FIELD(Y.AA,@SM,Y.VAR)
        GOSUB READ.AA.ACCT
        IF Y.ERR NE "" THEN
            BREAK
        END
*
        GOSUB READ.FC.MIG.BALANCE ;* PACS00350509 - 2014OCT13 - S/E

        Y.VAR += 1    ;*R22 Auto Conversion
    REPEAT
*
RETURN
*
READ.AA.ACCT:
*===========
*
    IF Y.AA.ID MATCHES "AA..." THEN       ;*GET THE INFORMATION FOR THE SALD FOR ARRANGEMENT
        GOSUB READ.AA.ARRANGEMENT
    END
    ELSE
        GOSUB READ.ACCOUNT
    END
*
RETURN
*
INITIALISE:
*=========

    Y.AVA.BAL.POS = ''
    Y.LN.MX.VAL.POS =  ''
    Y.AA.ID= ''
    Y.AVA.AMOUNT=''
    Y.RISK.PERC=0
    Y.PRODUCT.ID.CUR = ''
    Y.LOAN=''

    LOC.REF.FIELDS = 'L.COL.VAL.AVA':@VM:'L.COL.LN.MX.VAL':@VM:'L.AC.LK.COL.ID'
    LOC.REF.APPL = 'COLLATERAL'
    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)

    Y.AVA.BAL.POS = LOC.REF.POS<1,1>
    Y.LN.MX.VAL.POS  = LOC.REF.POS<1,2>
    Y.LOAN.ID = LOC.REF.POS<1,3>

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''
* PACS00350509 - 2014OCT13 - S
    FN.REDO.FC.CL.BALANCE = 'F.REDO.FC.CL.BALANCE'
    F.REDO.FC.CL.BALANCE = ''
    R.REDO.FC.CL.BALANCE = ''
*
    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)
* PACS00350509 - 2014OCT13 - E
    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.AA        = R.NEW(COLL.LOCAL.REF)<1,Y.LOAN.ID>
    Y.AA.ID     = ''
    Y.LOAN      = ''
    Y.AVAIL     = ''
    Y.AA.BAL    = ''
    TOTAL.AMT   = ''
* PACS00307565 - S
    Y.MAX       = ''
    Y.MAX.OLD   = ''
    Y.MAX.NEW   = ''
    Y.AA.ID.OLD = ''
    Y.AA.ID.NEW = ''
    Y.BAL.CH    = ''
    Y.MAX.DIF   = ''
    Y.AVBAL.OLD = ''
* PACS00307565 - E
    Y.AA.NUM    = ''
    Y.DIF.FC.ACTBAL = ''
    Y.CL.ID     = ID.NEW

RETURN

*==================================
READ.FC.MIG.BALANCE:
*==================================
    R.REDO.FC.CL.BALANCE = '' ; Y.ERR = ''
    CALL F.READ(FN.REDO.FC.CL.BALANCE,Y.AA.ID, R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,Y.ERR)
    IF R.REDO.FC.CL.BALANCE NE "" THEN
        Y.CL.POS = ''
        LOCATE Y.CL.ID IN R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID,1> SETTING Y.CL.POS THEN
            Y.AA.BAL += R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL,Y.CL.POS>
        END
    END ELSE          ;* Migrated COs and Loans
        GOSUB GET.AA.CURBAL
    END

RETURN

*==================================
GET.MULT.SING.CALC:
*==================================
    IF Y.AA.NUM EQ 1 THEN       ;* Single Loan for current CO.
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = Y.MAX.NEW - Y.AA.BAL
    END
*
    IF Y.AA.NUM GT 1 THEN       ;* Multiple Loans for current CO.
        GOSUB CALC.AVBAL.NOTDI.MULTI
    END
RETURN

*==================================
CALC.AVBAL.NOTDI.MULTI:
*==================================
    IF Y.AVBAL.NEW GT 0 THEN
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = Y.ADD
    END
*
    IF Y.AVBAL.NEW LT 0 THEN
        Y.DIF.FC.ACTBAL = Y.AA.BAL - Y.MAX.NEW
        R.NEW(COLL.LOCAL.REF)<1,Y.AVA.BAL.POS> = Y.MAX.DIF + Y.DIF.FC.ACTBAL
    END
RETURN

*==================================
GET.AA.CURBAL:
*==================================
    APAP.REDOSRTN.redoSGetOutBalance(Y.AA.ID,TOTAL.AMT);* R22 Manual conversion
    Y.AA.BAL += TOTAL.AMT
RETURN

*==================================
GET.RISK.PERCENT:
*==================================
    APAP.TAM.redoColGetRiskDi(Y.PRODUCT.ID.CUR,Y.RISK.PERC)  ;*Rutina para calcular el % de riesgo, R22 Manual conversion
    IF NOT(Y.RISK.PERC) THEN
        Y.RISK.PERC = 100
    END
RETURN
*=============================
READ.AA.ARRANGEMENT:
*=============================
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)
    IF R.AA.ARRANGEMENT THEN
        Y.PRODUCT.ID.CUR<1>  = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
        Y.PRODUCT.ID.CUR<2> = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    END
    ELSE
*        Y.PRODUCT.ID.CUR<1> = System.getVariable("CURRENT.PRODUCT")
*        Y.PRODUCT.ID.CUR<2> = System.getVariable("CURRENT.CURRENCY")
    END
RETURN
*=============================
READ.ACCOUNT:
*=============================
    CALL F.READ(FN.ACCOUNT,Y.AA.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.LOAN= R.ACCOUNT<AC.ARRANGEMENT.ID>
    Y.AA.ID = Y.LOAN
    GOSUB READ.AA.ARRANGEMENT
RETURN

END
