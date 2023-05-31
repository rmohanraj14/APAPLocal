* @ValidationCode : MjotODY1NTU3ODg6Q3AxMjUyOjE2ODU1MzAxMTg2OTE6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:18:38
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
SUBROUTINE REDO.FC.S.CL.DETAILS(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
* Date         : 15.06.2011
* Description  : NOFILE Enquiry Consulta de Saldo Disponible
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date            Who               Reference      Description
* 1.0       08.08.2011      lpazmino          CR.180         Initial Version
* 2.0       26.01.2012      lpazmino          PACS00171489   Resolve issues
* 3.0       09.02-2012      Silambarasan      PACS00568559   Resolve issues
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1, CHAR TO CHARX
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION         PACKAGE ADDED, CALL method format changed
*-----------------------------------------------------------------------------
* Input/Output: NA/ENQ.DATA (Enquiry Data Result)
* Dependencies: NA
*-----------------------------------------------------------------------------
*
* <region name="INCLUDES">
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
*
    $INSERT I_F.COLLATERAL
    $INSERT I_F.COLLATERAL.CODE
    $INSERT I_F.COLLATERAL.TYPE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL.RIGHT        ;*
    $INSERT I_F.AA.PRODUCT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.REDO.CREATE.ARRANGEMENT ;*
    $INSERT I_F.ACCOUNT       ;*
    $INSERT I_F.REDO.FC.CL.BALANCE
    $INSERT I_F.REDO.FC.LIMIT.AA
    $USING APAP.REDOSRTN
*
* </region>
*
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*
* <region name="GOSUBS" description="Gosub Blocks">
*****
INIT:
*****

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    R.COLLATERAL = ''

    FN.COLLATERAL.CODE = 'F.COLLATERAL.CODE'
    F.COLLATERAL.CODE = ''
    R.COLLATERAL.CODE = ''

    FN.COLLATERAL.TYPE = 'F.COLLATERAL.TYPE'
    F.COLLATERAL.TYPE = ''
    R.COLLATERAL.TYPE = ''

    FN.AA.PRD.CAT.ACCOUNT = 'F.AA.PRD.CAT.ACCOUNT'
    F.AA.PRD.CAT.ACCOUNT = ''
    R.AA.PRD.CAT.ACCOUNT = ''

    FN.REDO.FC.CL.BALANCE = 'F.REDO.FC.CL.BALANCE'
    F.REDO.FC.CL.BALANCE = ''
    R.REDO.FC.CL.BALANCE = ''

    FN.REDO.FC.LIMIT.AA = 'F.REDO.FC.LIMIT.AA'
    F.REDO.FC.LIMIT.AA = ''
    R.REDO.FC.LIMIT.AA = ''

    FN.AA.PRD.CAT.TERM.AMOUNT = 'F.AA.PRD.CAT.TERM.AMOUNT'
    F.AA.PRD.CAT.TERM.AMOUNT = ''
    R.AA.PRD.CAT.TERM.AMOUNT = ''
*
* PACS00281659 - S
    FN.COLLATERAL.RIGHT = 'F.COLLATERAL.RIGHT'
    F.COLLATERAL.RIGHT = ''
    R.COLLATERAL.RIGHT = ''

    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''

    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''
    R.REDO.CREATE.ARRANGEMENT = ''

* PACS00281659 - E
*
* PACS00307565 - S
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    FN.ALTERNATE.ACCOUNT = 'F.ALTERNATE.ACCOUNT'
    F.ALTERNATE.ACCOUNT = ''
    R.ALTERNATE.ACCOUNT = ''
* PACS00307565 - E
    FN.LIMIT = 'F.LIMIT'
    F.LIMIT = ''
    R.LIMIT = ''

    Y.ERR = ''

    Y.CL.ID = ''
    Y.CL.PRODUCT = ''

    Y.APPLICATION = 'COLLATERAL' : @FM : 'AA.PRD.CAT.TERM.AMOUNT'
    Y.CL.LOCAL.FIELD = 'LOCAL.REF'
    Y.AA.LOCAL.FIELD = 'LOCAL.REF'

    CALL EB.FIND.FIELD.NO('COLLATERAL', Y.CL.LOCAL.FIELD)
    CALL EB.FIND.FIELD.NO('AA.PRD.CAT.TERM.AMOUNT', Y.AA.LOCAL.FIELD)
* PACS00281659 - S/E  "No INSTRUMENTO USADO COMO GTIA" value field, according with current Collateral type
    Y.LOCAL.FIELDS = 'L.COL.TOT.VALUA' : @VM : 'L.COL.LN.MX.PER' : @VM : 'L.COL.LN.MX.VAL' : @VM : 'L.COL.NUM.INSTR' : @VM :'L.COL.SEC.IDEN' : @VM :'L.COL.INVST.NO' : @VM : 'L.AC.LK.COL.ID' : @VM : 'L.COL.SEC.STA' : @VM : 'L.COL.VAL.AVA' : @FM : 'L.AA.RISK.PER'
    Y.LOCAL.FIELDS.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.LOCAL.FIELDS,Y.LOCAL.FIELDS.POS)

    Y.CL.DATA = ''
    Y.TOT.COL.AMT = 0
    Y.TOT.AVA.BAL = 0
    Y.RISK.VAL = 0
    Y.STATUS = ''
    Y.CO.BAL = ""

    Y.VAL.AA.RISK.PER = ''
    Y.ACC.NUMBER      = ''
    Y.CO.AVA.BAL      = ''
    Y.AVA.BAL         = ''
    Y.FC.AA.ID        = ''
    Y.LIM.PROD        = ''
    Y.AA.NUM          = ''
    Y.LIM.FC.AA       = ''
    Y.CR.LIMREF.ID    = ''
*
    Y.TOT.UTIL.AMT    = ''
    Y.UTI.BAL         = ''
    Y.CO.MAX.AMT      = ''
    Y.AA.BAL.CO       = ''
    Y.CL.ID.TMP       = ''
*
RETURN

***********
OPEN.FILES:
***********
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.COLLATERAL.CODE,F.COLLATERAL.CODE)
    CALL OPF(FN.COLLATERAL.TYPE,F.COLLATERAL.TYPE)
    CALL OPF(FN.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA)
    CALL OPF(FN.AA.PRD.CAT.ACCOUNT,F.AA.PRD.CAT.ACCOUNT)
    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)
    CALL OPF(FN.LIMIT,F.LIMIT)
    CALL OPF(FN.AA.PRD.CAT.TERM.AMOUNT,F.AA.PRD.CAT.TERM.AMOUNT)
    CALL OPF(FN.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT)        ;* PACS00281659 - S
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT)
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)    ;* PACS00281659 - E
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)      ;* PACS00307565 - S/E

RETURN

********
PROCESS:
********

    LOCATE 'CL.DETAILS' IN D.FIELDS SETTING Y.POS THEN
        Y.CL.ID = D.RANGE.AND.VALUE<Y.POS>
    END

    LOCATE 'CL.PRODUCT' IN D.FIELDS SETTING Y.POS THEN
        Y.CL.PRODUCT = D.RANGE.AND.VALUE<Y.POS>
    END

    GOSUB GET.LIMIT.DATA

RETURN

***********
GET.HEADER:
***********
*
    GOSUB READ.COLLATERAL
*
* ID Garantia
    Y.CL.DATA<1> = Y.CL.ID

* Tipo de Garantia
    Y.CL.CODE = R.COLLATERAL<COLL.COLLATERAL.CODE>
    CALL CACHE.READ(FN.COLLATERAL.CODE,Y.CL.CODE,R.COLLATERAL.CODE,Y.ERR)
* Calculo de % de riesgo (utilizado para DI)
    GOSUB CALC.RISK.PERCENTAGE
    Y.CL.DATA<2> = R.COLLATERAL.CODE<COLL.CODE.DESCRIPTION>

* Clase de Garantia
    Y.CL.TYPE = R.COLLATERAL<COLL.COLLATERAL.TYPE>
    CALL CACHE.READ(FN.COLLATERAL.TYPE,Y.CL.TYPE,R.COLLATERAL.TYPE,Y.ERR)
    Y.CL.DATA<3> = R.COLLATERAL.TYPE<COLL.TYPE.DESCRIPTION>

* Num. Respaldo Garantia
    GOSUB SEL.NOINSR.COLLTYPE ;* PACS00281659 - S/E
    Y.CL.DATA<4> = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>

* Valor Nominal
    Y.CL.DATA<5> = R.COLLATERAL<COLL.NOMINAL.VALUE>

* % Maximo a Prestar
    Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,2>
    Y.CL.DATA<7> = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO> : '%'

* Monto Maximo a Prestar
    Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,3>
    GOSUB GET.TOT.AVA.BAL
    Y.CL.DATA<8> = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
* Category Code
    GOSUB GET.CATEGORY.CODE
    Y.CL.DATA<9> = Y.CATEGORY.CODE
* PACS00281659 - S
* Fecha creacion
    Y.DATE = R.COLLATERAL<COLL.VALUE.DATE>
    GOSUB FORMAT.DATE
    Y.CL.DATA<16> = Y.DATE
* CO Status
    Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,8>
    Y.CO.STATUS   = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
    Y.CL.DATA<18> = Y.CO.STATUS
* PACS00281659 - E

RETURN
*
********************
SEL.NOINSR.COLLTYPE:
********************
*
    BEGIN CASE
        CASE Y.CL.CODE EQ 150     ;* Depositos Internos (DI)
            Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,4>
        CASE Y.CL.CODE EQ 100     ;* Titulos Publicos (TP)
            Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,6>
        CASE Y.CL.CODE EQ 200     ;* Depositos externos (DE)
            Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,6>
        CASE OTHERWISE  ;* Bienes Raices (BR), Otras Garantias (OG), Vehiculos (VH)
            Y.FIELD.NO = Y.LOCAL.FIELDS.POS<1,5>
    END CASE
*
RETURN
*
***********
GET.ARR.ID:
***********
*
    SELECT.STATEMENT = 'SSELECT ':FN.REDO.CREATE.ARRANGEMENT
    SELECT.STATEMENT := ' WITH ID.ARRANGEMENT EQ ' : Y.AA
    SELECT.STATEMENT := " AND STATUS.TEMPLATE NE 'FAIL'"
    SELECT.STATEMENT := ' BY-DSND EFFECT.DATE'
*
    GOSUB EXEC.SEL.ARR
*
RETURN
*
*************
EXEC.SEL.ARR:
*************
*
    CALL EB.READLIST(SELECT.STATEMENT,SELECT.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
*
    IF SELECTED GT 0 THEN
        LOOP
            REMOVE FC.ID FROM SELECT.LIST SETTING FC.POS
        WHILE FC.ID:FC.POS
            CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,FC.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,Y.ERR)
            IF R.REDO.CREATE.ARRANGEMENT<REDO.FC.STATUS.TEMPLATE> NE'FAIL' AND R.REDO.CREATE.ARRANGEMENT<REDO.FC.STATUS.TEMPLATE> NE "" THEN
                Y.ARR = FC.ID
            END
        REPEAT
    END
    ELSE
        Y.ARR = Y.AA
    END
*
RETURN
*
***************
GET.LIMIT.DATA:
***************
*
    GOSUB LIMIT.DIFF.CTE
*
    IF Y.CL.DATA EQ '' THEN
        GOSUB GET.HEADER
        CHANGE @FM TO "*" IN Y.CL.DATA
        ENQ.DATA<-1> = Y.CL.DATA
    END

    GOSUB GET.TOTAL.VALUES

RETURN
*
***********
READ.LIMIT:
***********
*
    R.LIMIT = '' ; Y.ERR = ''
    CALL F.READ(FN.LIMIT,LIMIT.ID,R.LIMIT,F.LIMIT,Y.ERR)
*
RETURN
*
***************
LIMIT.DIFF.CTE:
***************
*
* Collateral Right ID
    Y.CR.ID = Y.CL.ID[".",1,1] :'.': Y.CL.ID[".",2,1]

    Y.ERR = ''
    CALL F.READ(FN.COLLATERAL.RIGHT,Y.CR.ID,R.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT,Y.ERR)
    IF Y.ERR EQ "" THEN
        Y.LIM.IDS = R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE>
        Y.LIM.NUM = DCOUNT(Y.LIM.IDS,@VM)
        Y.VAR1 = 1
        LOOP
        WHILE Y.VAR1 LE Y.LIM.NUM
            Y.LIM.ID = Y.LIM.IDS<1,Y.VAR1>
            LIMIT.ID = Y.LIM.ID
            GOSUB FC.LIM.AA
            IF Y.ERR.FCAA NE "" THEN    ;* Migrated loans
                GOSUB CAPTURE.ENQ.VALUES.MIG
            END
            ELSE
                GOSUB CAPTURE.ENQ.VALUES          ;* Non Migrated loans
            END
            Y.VAR1 += 1
        REPEAT
    END
*
RETURN
*
**********
FC.LIM.AA:
**********
*
    R.REDO.FC.LIMIT.AA = '' ; Y.ERR.FCAA = ''
    CALL F.READ(FN.REDO.FC.LIMIT.AA,LIMIT.ID,R.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA,Y.ERR.FCAA)
    Y.AA.NUM = DCOUNT(R.REDO.FC.LIMIT.AA,@FM)
*
RETURN
*
******************
GET.CATEGORY.CODE:
******************
    Y.CATEGORY.CODE = ''

    SEL.CMD  = 'SELECT ' : FN.AA.PRD.CAT.ACCOUNT
    SEL.CMD := '  LIKE ' : Y.CL.PRODUCT : '-... BY-DSND @ID'
    SEL.LIST = ''
    NO.REC   = ''
    SEL.ERR  = ''
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, SEL.ERR)
    IF SEL.ERR NE '' THEN
        REMOVE ID.PRODUCT FROM SEL.LIST SETTING POS
        CALL CACHE.READ(FN.AA.PRD.CAT.ACCOUNT, ID.PRODUCT, R.AA.PRD.CAT.ACCOUNT, Y.ERR)
        Y.CATEGORY.CODE = R.AA.PRD.CAT.ACCOUNT<AA.AC.CATEGORY>
    END ELSE
        Y.CATEGORY.CODE = ''
    END

RETURN

******************
GET.TOTAL.VALUES:
******************

* Total Monto Utilizado
    GOSUB GET.HEADER
* ID Limite
    Y.CL.DATA<10> = ""
* Fecha
    Y.CL.DATA<11> = ""
* Producto (Limite)
    Y.CL.DATA<15> = ""
* Prestamo
    Y.CL.DATA<12> = "Total Monto Utilizado: "
* Monto Utilizado
    Y.CL.DATA<14> = Y.TOT.COL.AMT

    CHANGE @FM TO "*" IN Y.CL.DATA
    ENQ.DATA<-1> = Y.CL.DATA

    IF Y.CL.CODE EQ 150 THEN
*
* Monto Utilizado
        Y.RISK.VAL = R.COLLATERAL<COLL.NOMINAL.VALUE> * ((Y.VAL.AA.RISK.PER - 100) / Y.VAL.AA.RISK.PER)

    END ELSE
        Y.RISK.VAL = 0
    END
* Total Saldo Disponible
    GOSUB GET.HEADER
* ID Limite
    Y.CL.DATA<10> = ""
* Fecha
    Y.CL.DATA<11> = ""
* Producto (Limite)
    Y.CL.DATA<15> = ""
* Prestamo
    Y.CL.DATA<12> = "Saldo Disponible Garantia: "
* Monto Utilizado
* PACS00307565 - S
    Y.FIELD.NO         = Y.LOCAL.FIELDS.POS<1,9>
    Y.CO.AVA.BAL       = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>    ;* CO Available amount
    Y.AVA.BAL = Y.CO.AVA.BAL
* PACS00307565 - E
    IF Y.TOT.COL.AMT LE 0 THEN
        Y.AVA.BAL = Y.CO.AVA.BAL
    END
*
    IF Y.CO.STATUS EQ "CANCELLED" THEN
        Y.AVA.BAL = 0
    END
* PACS00308600 - E
    Y.CL.DATA<14> = Y.AVA.BAL
    CHANGE @FM TO "*" IN Y.CL.DATA
    ENQ.DATA<-1> = Y.CL.DATA
*
RETURN
*
********************
CAPTURE.ENQ.VALUES:
********************
*
* PACS00349144 - S
    IF Y.AA.NUM EQ 1 THEN
        Y.AA = R.REDO.FC.LIMIT.AA<Y.AA.NUM>
    END
    IF Y.AA.NUM GT 1 THEN
        Y.AA = FIELD(R.REDO.FC.LIMIT.AA,@FM,Y.VAR1)
    END
*
    GOSUB GET.FC.CL.BAL
* PACS00349144 - E
    IF Y.ERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.REDO.FC.CL.BALANCE
        CALL STORE.END.ERROR
    END
*
    LOCATE Y.CL.ID IN R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID,1> SETTING CL.POS THEN
        GOSUB READ.LIMIT      ;* PACS00307565 - S/E
        IF Y.ERR THEN
            ETEXT = "EB-FC-READ.ERROR" : @FM : FN.LIMIT
            CALL STORE.END.ERROR
        END
* PACS00307565 - S
        GOSUB GET.HEADER
* Prestamo
        Y.FIELD.NO    = Y.LOCAL.FIELDS.POS<1,7>
        Y.AA.ID.TMP   = ''
        Y.AA.ID.TMP   = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
        Y.NUM.AA = '' ; Y.NUM.AA = DCOUNT(Y.AA.ID.TMP,@SM)
        GOSUB GET.HEADER
        GOSUB GET.AA.SUBVAL.NOMIG
* PACS00307565 - E
        IF Y.TOT.AVA.BAL LT 0 THEN
            Y.TOT.AVA.BAL = 0
        END
*
        CHANGE @FM TO "*" IN Y.CL.DATA
        ENQ.DATA<-1> = Y.CL.DATA
*
    END
*
RETURN
*
**************
GET.FC.CL.BAL:
**************
*
    Y.ERR = '' ; R.REDO.FC.CL.BALANCE = ''
    CALL F.READ(FN.REDO.FC.CL.BALANCE,Y.AA,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,Y.ERR)

RETURN
*
***********************
CAPTURE.ENQ.VALUES.MIG:
***********************
*
    Y.ERR = ''
    CALL F.READ(FN.LIMIT,LIMIT.ID,R.LIMIT,F.LIMIT,Y.ERR)
    IF Y.ERR EQ "" THEN
*
        GOSUB GET.HEADER
* Prestamo
        Y.FIELD.NO    = Y.LOCAL.FIELDS.POS<1,7>
* PACS00307565 - S
        Y.AA.ID.TMP   = ''
        Y.AA.ID.TMP   = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
*
        Y.NUM.AA = '' ; Y.NUM.AA = DCOUNT(Y.AA.ID.TMP,@SM)
        Y.VAR = 1     ; Y.CL.DATA.TMP = ''
        LOOP
        WHILE Y.VAR LE Y.NUM.AA
            Y.AA = '' ; Y.AA = Y.AA.ID.TMP<1,1,Y.VAR>
* PACS00349144 - S
            GOSUB GET.FC.CL.BAL
            IF Y.ERR NE "" THEN         ;* Only Migrated loans
* PACS00349144 - E
*
                GOSUB GET.HEADER
                GOSUB GET.AA.SUBVAL.MIG ;* PACS00307565 - S/E
*
                IF Y.TOT.AVA.BAL LT 0 THEN
                    Y.TOT.AVA.BAL = 0
                END
*
                CHANGE @FM TO "*" IN Y.CL.DATA
                ENQ.DATA<-1> = Y.CL.DATA
*
            END
            Y.VAR += 1
        REPEAT
*
* PACS00307565 - E
    END
*
RETURN
*
******************
GET.AA.SUBVAL.MIG:
******************
*
    GOSUB EVAL.INIT.COLL
*
    Y.CL.DATA<12> = Y.AA
* PACS00281659 - E
* ID Limite
    Y.CL.DATA<10> = Y.LIM.ID
* Producto (Limite)
    Y.CL.DATA<15> = R.LIMIT<LI.LIMIT.PRODUCT>
* Fecha Y.DATE = R.LIMIT<LI.APPROVAL.DATE> Fecha de creacion de la Garantia
* PACS00281659 - S
*         Y.DATE = R.COLLATERAL<COLL.VALUE.DATE>
    GOSUB GET.AA.DETAILS
    Y.DATE = Y.ARR.DATE
    GOSUB FORMAT.DATE
    Y.CL.DATA<11> = Y.DATE
* Monto Utilizado
* GOSUB GET.AA.CURBAL       ;* PACS00308600 - S/E
*PACS00384593 - 2014JUL16 - S
    GOSUB GET.AA.NO.COIDS
    Y.CL.DATA<14> = Y.AA.BAL.CO
    Y.TOT.COL.AMT += Y.AA.BAL.CO
*PACS00384593 - 2014JUL16 - E
*
* Arrangement template id
    GOSUB GET.ARR.ID
    Y.CL.DATA<17> = Y.ARR
* PACS00281659 - E
*
RETURN
*
********************
GET.AA.SUBVAL.NOMIG:
********************
*
    IF Y.NUM.AA GT 1 THEN
        GOSUB SEL.FC.LIMIT.AA
* ID Limite
        Y.CL.DATA<10> = Y.LIM.FC.AA
* Producto (Limite)
        Y.LIM.PROD = FIELD(Y.LIM.FC.AA,".",2)
        Y.LIM.PROD = Y.LIM.PROD[4,4]
        Y.CL.DATA<15> = Y.LIM.PROD
    END
*
    IF Y.NUM.AA EQ 1 THEN
* ID Limite
        Y.CL.DATA<10> = LIMIT.ID
* Producto (Limite)
        Y.CL.DATA<15> = R.LIMIT<LI.LIMIT.PRODUCT>
    END
* Fecha Y.DATE = R.LIMIT<LI.APPROVAL.DATE> Fecha de creacion de la Garantia
* PACS00281659 - S
*         Y.DATE = R.COLLATERAL<COLL.VALUE.DATE>
    GOSUB GET.AA.DETAILS
    Y.DATE = Y.ARR.DATE
* PACS00281659 - E
    GOSUB FORMAT.DATE
    Y.CL.DATA<11> = Y.DATE
* Prestamo
    Y.CL.DATA<12> = Y.AA
* Monto Utilizado
* Y.CL.AMT = (R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL,CL.POS> * Y.VAL.AA.RISK.PER) / 100
* PACS00281659 - S
* Arrangement template id
    GOSUB GET.ARR.ID
    Y.CL.DATA<17> = Y.ARR
* PACS00331722 - S
    Y.CL.AMT = R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL,CL.POS>
    Y.CL.DATA<14> = Y.CL.AMT
    Y.TOT.COL.AMT += Y.CL.AMT
* PACS00331722 - E
* PACS00281659 - E
*
RETURN

****************
SEL.FC.LIMIT.AA:
****************
*
    Y.AA.LIM.POS = ''
    SELECT.STATEMENT = 'SELECT ' : FN.REDO.FC.LIMIT.AA
*
    REDO.FC.LIMIT.AA.LIST = ''
    LIST.NAME = ''
    SEL = ''
    ERR.CODE = ''
    Y.ID.AA.LIM = ''
    CALL EB.READLIST(SELECT.STATEMENT, REDO.FC.LIMIT.AA.LIST, LIST.NAME,SEL, ERR.CODE)
*
    LOOP
        REMOVE Y.ID.AA.LIM FROM REDO.FC.LIMIT.AA.LIST SETTING Y.AA.LIM.POS
    WHILE Y.ID.AA.LIM:Y.AA.LIM.POS
        LIMIT.ID = ''
        LIMIT.ID = Y.ID.AA.LIM
        GOSUB FC.LIM.AA
        Y.FC.AA.ID = R.REDO.FC.LIMIT.AA<Y.AA.NUM>
        IF Y.FC.AA.ID EQ Y.AA THEN
            GOSUB GET.MATCH.CR
        END
*
    REPEAT
*
RETURN
*
*************
GET.MATCH.CR:
*************
*
    IF R.COLLATERAL.RIGHT NE "" THEN
        POS.1 = ''
        Y.CR.LIMREF.ID = R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE>
        CHANGE @VM TO @FM IN Y.CR.LIMREF.ID
        LOCATE LIMIT.ID IN Y.CR.LIMREF.ID SETTING POS.1 THEN
            Y.LIM.FC.AA = LIMIT.ID
        END
    END
*
RETURN
*
***************
EVAL.INIT.COLL:
***************
*
    IF Y.AA[1,2] NE 'AA' AND Y.AA[1,2] NE 'AR' THEN
        Y.ACCT.ID = '' ; Y.ACCT.ID = Y.AA
        GOSUB GET.AAID.ACCT
        Y.AA = '' ; Y.AA = Y.AA.ID
    END
*
RETURN
*
****************
GET.TOT.AVA.BAL:
****************
*
* PACS00281659 - S
    IF Y.AA.ID NE "" THEN
        GOSUB GET.AA.AMTORIG
    END
*
    IF Y.CL.CODE NE 150 THEN
* Utiliza el Monto Maximo a Prestar
        Y.TOT.AVA.BAL = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
    END ELSE
* Utilizada el Valor Nominal
*        Y.TOT.AVA.BAL = R.COLLATERAL<COLL.NOMINAL.VALUE>
        Y.TOT.AVA.BAL = Y.AA.AMT
* PACS00281659 - S
    END
RETURN

*********************
CALC.RISK.PERCENTAGE:
*********************
* Para el caso de Depositos Internos
* Debe calcular el Valor Nominal - el % de pignoracion por riesgo
    IF Y.CL.CODE EQ 150 THEN
        Y.CURRENCY = R.COLLATERAL<COLL.CURRENCY>
        Y.ID.ARR.PRD.CAT.TERM.AMOUNT = Y.CL.PRODUCT : '-COMMITMENT' : '-' : Y.CURRENCY:'...'
        SELECT.STATEMENT = 'SELECT ' : FN.AA.PRD.CAT.TERM.AMOUNT : ' WITH @ID LIKE ' : Y.ID.ARR.PRD.CAT.TERM.AMOUNT

        AA.PRD.CAT.TERM.AMOUNT.LIST = ''
        LIST.NAME = ''
        SELECTED = ''
        SYSTEM.RETURN.CODE = ''
        Y.ID.AA.PRD = ''
        CALL EB.READLIST(SELECT.STATEMENT, AA.PRD.CAT.TERM.AMOUNT.LIST, LIST.NAME,SELECTED, SYSTEM.RETURN.CODE)

        REMOVE Y.ID.AA.PRD FROM AA.PRD.CAT.TERM.AMOUNT.LIST SETTING POS
        CALL CACHE.READ(FN.AA.PRD.CAT.TERM.AMOUNT, Y.ID.AA.PRD, R.ARR.PRD.CAT.TERM.AMOUNT, Y.ERR)

* % de riesgo pignorado
        Y.VAL.AA.RISK.PER = R.ARR.PRD.CAT.TERM.AMOUNT<AA.AMT.LOCAL.REF,Y.LOCAL.FIELDS.POS<2,1>>
    END ELSE
        Y.VAL.AA.RISK.PER = 100
    END
RETURN
*
**************
GET.AAID.ACCT:
**************
*
    CALL F.READ(FN.ACCOUNT,Y.ACCT.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    IF R.ACCOUNT NE "" THEN
        Y.AA.ID = '' ; Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    END
*
RETURN
*
***************
GET.AA.DETAILS:
***************
    Y.ARR.DATE = ''
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.ERR)
    Y.ARR.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.BASE.DATE>
RETURN
*
*=============
GET.AA.CURBAL:
*=============
*
* Get outstanding from AA
    Y.AA.BAL = ''
    Y.AA.ID  = Y.AA
    APAP.REDOSRTN.redoSGetOutBalance(Y.AA.ID,TOTAL.AMT);* R22 Manual conversion
    Y.AA.BAL = TOTAL.AMT
*
RETURN
*
*==============
GET.AA.NO.COIDS:
*==============
*
    COL.ID.LINKED = ''
    APAP.AA.redoColAaGetLinksCol(Y.AA,COL.ID.LINKED);* R22 Manual conversion
*
    MMARK     = CHARX(251) ; Y.COL.IDS = ''
    Y.COL.IDS = CHANGE(COL.ID.LINKED, MMARK , @VM )
*
    Y.COL.NUM = DCOUNT(Y.COL.IDS<1>,@VM)
    Y.COL = 1
    LOOP
    WHILE Y.COL LE Y.COL.NUM
*
        Y.COL.ID = FIELD(Y.COL.IDS<1>,@VM,Y.COL)

        IF Y.COL.ID NE "" THEN
*
            GOSUB GET.CO.MAX.LEND
*
            IF Y.COL GT 1 THEN          ;* Only for Second, 3rd Collateral attached and so on...
                Y.UTI.BAL = TOTAL.AMT - Y.TOT.UTIL.AMT      ;* Getting remaining amount to be covered by COs followed.
            END
*
            Y.TOT.UTIL.AMT += Y.AA.BAL
*
            IF Y.COL GT 1 AND Y.AA.BAL GT 0 THEN  ;* Only for Second, 3rd CO record attached and so on... and Outstanding bal. amt. pending to be covered.
                IF Y.TOT.UTIL.AMT LT TOTAL.AMT AND Y.CO.MAX.AMT LT Y.UTI.BAL THEN         ;* Current utilized amount lesser than "Maximo a Prestar" CO val field.
                    Y.UTI.BAL = Y.CO.MAX.AMT
                END
*Y.AA.BAL = Y.UTI.BAL
                Y.AA.BAL = Y.TOT.UTIL.AMT - Y.AA.BAL

*
                IF Y.UTI.BAL LT 0 THEN
                    Y.AA.BAL = 0        ;* Flag to mark Outstanding amt is totally covered with record processed.
                END
*
            END
*
            IF Y.COL.ID EQ Y.CL.ID.TMP THEN
                Y.AA.BAL.CO = Y.AA.BAL
            END
*
            Y.CL.ID = Y.CL.ID.TMP
*
        END
*
        Y.COL += 1
    REPEAT
*
RETURN
*
*==============
GET.CO.MAX.LEND:
*==============
*
    Y.CO.MAX.AMT = ''
    Y.CL.ID.TMP  = Y.CL.ID
    Y.CL.ID      = Y.COL.ID
    GOSUB READ.COLLATERAL
    Y.FIELD.NO   = Y.LOCAL.FIELDS.POS<1,3>
    Y.CO.MAX.AMT = R.COLLATERAL<Y.CL.LOCAL.FIELD,Y.FIELD.NO>
*
    GOSUB GET.AA.CURBAL
*
    IF Y.CO.MAX.AMT LT Y.AA.BAL THEN
        Y.AA.BAL = Y.CO.MAX.AMT
    END
*
RETURN
*
*=============
GET.AA.AMTORIG:
*=============
*
    Y.AA.AMT = ''
    GOSUB GET.AA.PRODUCT
* Getting current AA Balance value
    Y.AA.AMOUNT = '' ; Y.AA.AMOUNT = AA.ARR
    APAP.AA.redoSFcAaAmount(Y.AA.ID, Y.AA.AMOUNT);* R22 Manual conversion
    Y.AA.AMOUNT = ABS(Y.AA.AMOUNT)
    IF Y.AA.AMOUNT EQ 'NULO' THEN
        Y.AA.AMOUNT = 0
    END
    Y.AA.AMT = Y.AA.AMOUNT
*
RETURN
*
*==============
GET.AA.PRODUCT:
*==============
*
    Y.ERR = '' ; AA.ARR = ''
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, AA.ARR, F.AA.ARRANGEMENT, Y.ERR)
*
RETURN
*
*******************
GET.ACCOUNT.NUMBER:
*******************
*
    CALL F.READ(FN.ALTERNATE.ACCOUNT, Y.AA.ID, R.ALTERNATE.ACCOUNT, F.ALTERNATE.ACCOUNT, Y.ERR)
    Y.ACC.NUMBER = R.ALTERNATE.ACCOUNT
*
RETURN
*
****************
READ.COLLATERAL:
****************
*
    R.COLLATERAL = '' ; Y.ERR = ''
    CALL F.READ(FN.COLLATERAL,Y.CL.ID,R.COLLATERAL,F.COLLATERAL,Y.ERR)
    IF Y.ERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.COLLATERAL
        CALL STORE.END.ERROR
    END
*
RETURN
*
************
FORMAT.DATE:
************

    Y.YEAR = Y.DATE[1,4]
    Y.MONTH = Y.DATE[5,2]
    Y.DAY = Y.DATE[7,2]
    Y.MMONTH = ''
    BEGIN CASE
        CASE Y.MONTH EQ '01'
*            Y.MMONTH = 'JAN' ;* PACS00281659 - S
            Y.MMONTH = 'ENE'
        CASE Y.MONTH EQ '02'
            Y.MMONTH = 'FEB'
        CASE Y.MONTH EQ '03'
            Y.MMONTH = 'MAR'
        CASE Y.MONTH EQ '04'
*            Y.MMONTH = 'APR'
            Y.MMONTH = 'ABR'
        CASE Y.MONTH EQ '05'
            Y.MMONTH = 'MAY'
        CASE Y.MONTH EQ '06'
            Y.MMONTH = 'JUN'
        CASE Y.MONTH EQ '07'
            Y.MMONTH = 'JUL'
        CASE Y.MONTH EQ '08'
*            Y.MMONTH = 'AUG'
            Y.MMONTH = 'AGO'
        CASE Y.MONTH EQ '09'
            Y.MMONTH = 'SEP'
        CASE Y.MONTH EQ '10'
            Y.MMONTH = 'OCT'
        CASE Y.MONTH EQ '11'
            Y.MMONTH = 'NOV'
        CASE Y.MONTH EQ '12'
*            Y.MMONTH = 'DEC' ;* PACS00281659 - E
            Y.MMONTH = 'DIC'
    END CASE
*
    Y.DATE = Y.DAY : ' ' : Y.MMONTH : ' ' : Y.YEAR
*
RETURN

* </region>

END
