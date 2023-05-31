* @ValidationCode : MjotMTIzNjQxNDQwMDpDcDEyNTI6MTY4NTUzMDA3OTY5ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:17:59
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
***r22 manual converstion***
$PACKAGE APAP.AA
*------------------------------------------------------------------------------
* <Rating>-442</Rating>
*------------------------------------------------------------------------------
SUBROUTINE REDO.FC.S.CL.BALANCE(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
* Date         : 15.06.2011
* Description  : NOFILE Enquiry Consulta de Saldos Disponibles
*----------------------------------------------------------------------------
* Modification History:
*
* Version   Date            Who               Reference      Description
* 1.0       08.08.2011      lpazmino          CR.180         Initial Version
* 2.0       26.01.2012      lpazmino          PACS00171489   Resolve issues
* 2.1       11.04.2012      jvalarezo         PACS00169926   Extract the correct limit reference
* 2.2       09.08.2013      vnava             PACS00297652   Taking data from Migrated and
* Non migrated records
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION         CALL method format changed
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
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.AA.PRODUCT
* PACS00281659 - S
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
* PACS00281659 - E
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.REDO.FC.CL.BALANCE
    $INSERT I_F.REDO.FC.LIMIT.AA
    $USING APAP.REDOSRTN
* </region>
*
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
    GOSUB PROCESS.MIG ;* PACS00281659 - S/E

RETURN
*
* <region name="INIT" description="Initialize variables">
INIT:
    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''
    R.REDO.CREATE.ARRANGEMENT = ''

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    R.COLLATERAL = ''

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    R.AA.PRODUCT = ''
* PACS00281659 - S
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''

    FN.COLLATERAL.RIGHT = 'F.COLLATERAL.RIGHT'
    F.COLLATERAL.RIGHT = ''
    R.COLLATERAL.RIGHT = ''

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    AA.ARR = ''

    FN.AA.PRD.CAT.ACCOUNT = 'F.AA.PRD.CAT.ACCOUNT'
    F.AA.PRD.CAT.ACCOUNT = ''
    R.AA.PRD.CAT.ACCOUNT = ''

    FN.REDO.FC.LIMIT.AA = 'F.REDO.FC.LIMIT.AA'
    F.REDO.FC.LIMIT.AA = ''
    R.REDO.FC.LIMIT.AA = ''

    FN.ALTERNATE.ACCOUNT = 'F.ALTERNATE.ACCOUNT'
    F.ALTERNATE.ACCOUNT = ''
    R.ALTERNATE.ACCOUNT = ''

* PACS00281659 - E
    FN.REDO.FC.CL.BALANCE = 'F.REDO.FC.CL.BALANCE'
    F.REDO.FC.CL.BALANCE = ''
    R.REDO.FC.CL.BALANCE = ''

    Y.ERR = ''

    Y.CUSTOMER = ''
    Y.CUST.AA  = ''
    Y.CR.DATA  = ''
    Y.CL.NOMINAL.VAL = ''
    Y.AA.ID = ''
    Y.MONTO.UTILIZADO = 0
    Y.FLG.RCA = ''
    Y.LIM.FC.AA  = ''
    Y.CR.LIMREF.ID = ''
    Y.FC.AA.ID = ''
    Y.AA.NUM = ''

* PACS00281659 - S
*
    Y.AA.TERM = ''
    Y.ACC.NUMBER = ''
    Y.FIELD = 'L.AA.COL' : @VM : 'L.AA.AV.COL.BAL' : @FM :'L.COL.LN.MX.VAL' : @VM : 'L.COL.VAL.AVA'
    Y.APPLICATION = "AA.PRD.DES.TERM.AMOUNT":@FM:"COLLATERAL"
    Y.LOCAL.FIELDS.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.FIELD,Y.LOCAL.FIELDS.POS)
    Y.MX.VAL.FIELD  = Y.LOCAL.FIELDS.POS<2,1>
    Y.VAL.AVA.FIELD = Y.LOCAL.FIELDS.POS<2,2>
    Y.CL.IDS.FIELD  = Y.LOCAL.FIELDS.POS<1,1>
    Y.AA.BAL.FIELD  = Y.LOCAL.FIELDS.POS<1,2>       ;* PACS00307565 - S/E
* PACS00281659 - E
*
* PACS00308600 - S
    Y.CRITERIA.FLD = ''
* PACS00308600 - E
    Y.AA.CO.BAL    = ''
    Y.AA.CO.IDS    = ''
    Y.CNT.COIDS    = ''
    Y.CO.AA.ID     = ''
*
    Y.COL.AVAI.DIFF= ''
    Y.NO.COIDS     = ''
*
    Y.TOT.UTIL.AMT = ''
    Y.UTI.BAL      = ''
*
RETURN
* </region>

* <region name="OPEN.FILES" description="Open Files">
OPEN.FILES:
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE)
    CALL OPF(FN.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT)
    CALL OPF(FN.AA.PRD.CAT.ACCOUNT, F.AA.PRD.CAT.ACCOUNT)
    CALL OPF(FN.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA)
    CALL OPF(FN.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT)
*
RETURN
* </region>

* <region name="PROCESS" description="Main Process">
PROCESS:
    LOCATE 'CL.BALANCE' IN D.FIELDS SETTING Y.POS THEN
        Y.RCA.ID = D.RANGE.AND.VALUE<Y.POS>
    END
* PACS00281659 - S
    Y.POS2 = ''
    LOCATE 'CL.DETAILS' IN D.FIELDS SETTING Y.POS2 THEN
        Y.COLLATERAL.ID = D.RANGE.AND.VALUE<Y.POS2>
    END
* PACS00281659 - E
*
* PACS00308600 - S
    LOCATE 'CL.CRITERIA' IN D.FIELDS SETTING Y.POS2 THEN
        Y.CRITERIA.FLD = D.RANGE.AND.VALUE<Y.POS2>
    END
* PACS00308600 - E
*
    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,Y.RCA.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,Y.ERR)  ;*(JV20121116)
    IF Y.ERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.REDO.FC.CL.BALANCE ;*(JV20121116)
        CALL STORE.END.ERROR
        Y.FLG.RCA = 1   ;* PACS00281659 - S/E
    END ELSE
        GOSUB GET.CR.DATA
    END

RETURN
* </region>

* <region name="GET.CR.DATA" description="Get Collateral Right Data">
GET.CR.DATA:
    Y.AA.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.ID.ARRANGEMENT>
    R.REDO.FC.CL.BALANCE = '' ; Y.ERR = '' ; Y.CR.DATA = ''
    CALL F.READ(FN.REDO.FC.CL.BALANCE,Y.AA.ID, R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,Y.ERR)       ;*(JV20121116)
*Y.CR.DATA = R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.RIGHT>
    Y.CR.DATA = R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID,Y.CR>
    Y.CR.NUM = DCOUNT(Y.CR.DATA,@VM)
    Y.CR = 1
    LOOP
    WHILE Y.CR LE Y.CR.NUM
        Y.CUST.AA = ''
        Y.CR.ID = FIELD(Y.CR.DATA,@VM,Y.CR)
        Y.CR.ID = Y.CR.ID[".",1,2]
* PACS00331722 - S
        Y.CL.ID = Y.CR.DATA<1,Y.CR>
* PACS00331722 - E
* PACS00308600 - S
* PACS00313341 - S
*        IF Y.COLLATERAL.ID EQ Y.CL.ID THEN   ;* PACS00281659 - S/E
* PACS00313341 - E
*
        GOSUB GET.HEADER
* Collateral Right ID
        Y.CUST.AA<5> = Y.CR.ID
* Limite
* PACS00307565 S
        GOSUB SEL.FC.LIMIT.AA
        Y.CUST.AA<6> = Y.LIM.FC.AA
* PACS00307565 E
*
* PACS00281659 - S
        GOSUB GET.COLLATERAL
        GOSUB GET.CL.DATA
* PACS00281659 - E
        CHANGE @FM TO "*" IN Y.CUST.AA
        IF NOT(YERR) THEN
            ENQ.DATA<-1> = Y.CUST.AA
        END
* PACS00313341 - S
*         END ;* PACS00308600 - S/E
* PACS00313341 - E
* PACS00308600 - E
        Y.CR ++
    REPEAT
RETURN
* </region>

* <region name="GET.CL.DATA" description="Get Collateral Data">
GET.CL.DATA:
*
    Y.CUST.AA<7> = Y.CL.ID
*
* Monto Max a Prestar
    Y.MX.VAL = R.COLLATERAL<COLL.LOCAL.REF,Y.MX.VAL.FIELD>
    Y.CUST.AA<8> = Y.MX.VAL
*
* Saldo Disponible
*    Y.AVA.VAL = R.COLLATERAL<COLL.LOCAL.REF,Y.VAL.AVA.FIELD>
*    IF Y.AVA.VAL EQ '' THEN
*
    GOSUB GET.AA.AVAIL
    Y.CUST.AA<10> = Y.AA.AVAMT
*    END
*    ELSE
*        Y.CUST.AA<10> = Y.AVA.VAL
*    END
*
*    GOSUB GET.AA.AVAIL
*    Y.CUST.AA<10> = Y.AA.AVAMT
*
* Monto Utilizado y Monto Garantizado
* PACS00331722 - S
    GOSUB GET.MONTO.UTILIZADO
    Y.CUST.AA<9>  = Y.MONTO.UTILIZADO
*      Y.CUST.AA<9>  = Y.AA.BAL
*
*      GOSUB GET.AA.AMT.COLL
*      GOSUB GET.COLL.AA.IDS
*      GOSUB GET.CUR.AABAL.NOMIG
*      Y.CUST.AA<14> = Y.AA.CO.BAL
    Y.CUST.AA<14> = Y.MONTO.ORIGINAL      ;* JV25042012 Monto Garantizado
* PACS00331722 - E
*    Y.CUST.AA<14> = Y.AA.BAL
* Plazo
    Y.CUST.AA<11> = R.REDO.CREATE.ARRANGEMENT<REDO.FC.TERM>

* Valor Nominal
    Y.CL.NOMINAL.VAL = R.COLLATERAL<COLL.NOMINAL.VALUE>
    Y.CUST.AA<12> = Y.CL.NOMINAL.VAL
*
RETURN
* </region>
*
* <region name="GET.HEADER" description="Build Header">
GET.HEADER:
* Prestamo
    Y.CUST.AA<1> = Y.AA.ID
* Revolvente
    Y.CUST.AA<2> = R.REDO.CREATE.ARRANGEMENT<REDO.FC.REVOLVING>
* Producto
    Y.PRODUCT.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.PRODUCT>
    CALL CACHE.READ(FN.AA.PRODUCT,Y.PRODUCT.ID,R.AA.PRODUCT,Y.ERR)

    Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,2)
    IF Y.PRODUCT.DESCRIPTION EQ '' THEN
        Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,1)
    END
* Product ID
    Y.CUST.AA<13> = Y.PRODUCT.ID
* Product Description
    Y.CUST.AA<3> = Y.PRODUCT.DESCRIPTION
* Monto
    Y.CUST.AA<4> = R.REDO.CREATE.ARRANGEMENT<REDO.FC.AMOUNT>
RETURN
* </region>

* <region name="GET.MONTO.UTILIZADO" description="Calcula Saldo Disponible">
GET.MONTO.UTILIZADO:
*  CALL F.READ(FN.REDO.FC.CL.BALANCE,Y.AA.ID,R.REDO.FC.CL.BALANCE,F.REDO.FC.CL.BALANCE,Y.ERR)
    LOCATE Y.CL.ID IN R.REDO.FC.CL.BALANCE<FC.CL.COLLATERAL.ID,1> SETTING CL.POS THEN
        Y.MONTO.UTILIZADO = R.REDO.FC.CL.BALANCE<FC.CL.MG.ACTUAL,CL.POS>
        Y.MONTO.ORIGINAL  = R.REDO.FC.CL.BALANCE<FC.CL.MG.ORIGINAL,CL.POS>          ;* JV25042012 Monto Garantizado
    END
RETURN
* </region>

** <region name= PROCESS.MIG>
PROCESS.MIG:
***
*
    IF Y.FLG.RCA THEN
        GOSUB GET.RCA.RECS        ;* Looking for loan, in local template way creation to be sure wheter we're processing a migrated loan
        IF SELECTED EQ 0 THEN
            GOSUB GET.CR.DATA.MIG
        END
    END
*
RETURN
*** </region>

** <region name= GET.RCA.RECS>
GET.RCA.RECS:
***
*
    SELECT.STATEMENT = 'SSELECT ':FN.REDO.CREATE.ARRANGEMENT
    SELECT.STATEMENT := ' WITH ID.ARRANGEMENT EQ ' : Y.RCA.ID
    SELECT.STATEMENT := " AND STATUS.TEMPLATE NE 'FAIL'"
    SELECT.STATEMENT := ' BY-DSND EFFECT.DATE'
*
    SELECT.LIST =  '' ; LIST.NAME = '' ; SELECTED = 0 ; SYSTEM.RETURN.CODE = ""
    CALL EB.READLIST(SELECT.STATEMENT,SELECT.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
*
RETURN
*** </region>

** <region name= GET.AA.AMT.COLL>
GET.AA.AMT.COLL:
***
*
    Y.CL.AMT.MIG = ''
    GOSUB GET.AA.PRODUCT
* Getting current AA Balance value
    Y.AA.AMOUNT = ''
    Y.AA.AMOUNT = AA.ARR
    APAP.AA.redoSFcAaAmount(Y.AA.ID, Y.AA.AMOUNT);* R22 Manual conversion
    Y.AA.AMOUNT = ABS(Y.AA.AMOUNT)
    IF Y.AA.AMOUNT EQ 'NULO' THEN
        Y.AA.AMOUNT = 0
    END
*
    Y.CL.AMT.MIG = Y.AA.AMOUNT
*
RETURN
*** </region>

** <region name= GET.COLL.AA.IDS>
GET.COLL.AA.IDS:
***
*
    COL.ID.LINKED = ''
    APAP.AA.redoColAaGetLinksCol(Y.AA.ID,COL.ID.LINKED);* R22 Manual conversion
    IF COL.ID.LINKED EQ "ERROR" THEN
        COL.ID.LINKED = ''
    END
*
    MMARK        = CHAR(251)
    Y.COL.ID.MIG = CHANGE(COL.ID.LINKED, MMARK , @VM )
*
RETURN
*** </region>

** <region name= GET.HEADER.MIG>
GET.HEADER.MIG:
***
* Prestamo Migrado
    Y.CUST.AA<1> = Y.RCA.ID
* Producto
    GOSUB GET.AA.PRODUCT
    Y.PRODUCT.ID = '' ; Y.PRODUCT.ID = AA.ARR<AA.ARR.PRODUCT>
    CALL CACHE.READ(FN.AA.PRODUCT,Y.PRODUCT.ID,R.AA.PRODUCT,Y.ERR)
    Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,2)
    IF Y.PRODUCT.DESCRIPTION EQ '' THEN
        Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,1)
    END
* Revolvente SI/NO
    GOSUB GET.AA.CATEG
    Y.CUST.AA<2>  = Y.CAT.REVOL
* Product ID
    Y.CUST.AA<13> = Y.PRODUCT.ID
* Product Description
    Y.CUST.AA<3>  = Y.PRODUCT.DESCRIPTION
* Monto
    Y.CUST.AA<4>  = Y.CL.AMT.MIG
*
RETURN
** </region>

** <region name= GET.CR.DATA.MIG>
GET.CR.DATA.MIG:
***
*
    Y.AA.ID = Y.RCA.ID
    GOSUB GET.AA.AMT.COLL
    GOSUB GET.COLL.AA.IDS       ;* PACS00331722 - S/E
    Y.CR.DATA    = Y.COL.ID.MIG
*
    Y.FLG.CO.FND = ''
    GOSUB GET.FILT.BY.CO
* PACS00308600 - S
    Y.CR.NUM     = DCOUNT(Y.CR.DATA<1>,@VM)
    Y.CR = 1
    LOOP
    WHILE Y.CR LE Y.CR.NUM
*
        Y.CR.ID = FIELD(Y.CR.DATA<1>,@VM,Y.CR)
        Y.CR.ID = Y.CR.ID[".",1,2]
        Y.CL.ID = FIELD(Y.CR.DATA<1>,@VM,Y.CR)
*
        IF Y.COLLATERAL.ID EQ "" AND Y.FLG.CO.FND EQ "" OR Y.COLLATERAL.ID NE "" AND Y.FLG.CO.FND THEN  ;* Filtering by CO or AA and CU
*
            Y.CUST.AA = ''
            GOSUB GET.HEADER.MIG
*
* Collateral Right ID
            Y.CUST.AA<5> = Y.CR.ID
            GOSUB GET.LIMIT.CRIGHT
* Limite
            Y.CUST.ID = FIELD(Y.LIMIT.ID,'.',1)
            Y.CUST.AA<6> = Y.LIMIT.ID
*
            GOSUB GET.CL.DATA.MIG
*
            CHANGE @FM TO "*" IN Y.CUST.AA
            IF NOT(YERR) THEN
                ENQ.DATA<-1> = Y.CUST.AA
            END
*
        END
* PACS00308600 - E
        Y.CR ++
    REPEAT
*
RETURN
** </region>

** <region name= GET.CL.DATA.MIG>
GET.CL.DATA.MIG:
***
*
    GOSUB GET.COLLATERAL
    Y.CUST.AA<7> = Y.CL.ID
* Monto Max a Prestar
    Y.MX.VAL = R.COLLATERAL<COLL.LOCAL.REF,Y.MX.VAL.FIELD>
    Y.CUST.AA<8> = Y.MX.VAL
* /////////////////
* PACS00308600 - S
* Saldo Disponible
*    Y.AVA.VAL = R.COLLATERAL<COLL.LOCAL.REF,Y.VAL.AVA.FIELD>
*    IF Y.AVA.VAL EQ '' THEN
    GOSUB GET.AA.AVAIL
    Y.CUST.AA<10> = Y.AA.AVAMT
*    END
*    ELSE
*        Y.CUST.AA<10> = Y.AVA.VAL
*    END
* PACS00308600 - E
*    GOSUB GET.AA.AVAIL
*    Y.CUST.AA<10> = Y.AA.AVAMT
*
* Monto Utilizado y Monto Garantizado
*      Y.CUST.AA<9>  = Y.CL.AMT.MIG
*      Y.CUST.AA<14> = Y.AVA.VAL
    GOSUB GET.UTIL.AMOUNT       ;* PACS00353808 - 2014JUN17 - S/E
    Y.CUST.AA<9>  = Y.AA.BAL
*    Y.CUST.AA<14> = Y.CL.AMT.MIG
* PACS00307565 - S
    GOSUB GET.CUR.AABAL
    Y.CUST.AA<14> = Y.AA.CO.BAL
* PACS00307565 - E
* /////////////////
* Plazo
    Y.ARR.ID = Y.RCA.ID ; Y.AA.TERM = AA.ARR
    APAP.AA.redoSFcAaTerm(Y.ARR.ID, Y.AA.TERM);* R22 Manual conversion
    Y.CUST.AA<11> = Y.AA.TERM
* Valor Nominal
    Y.CL.NOMINAL.VAL = R.COLLATERAL<COLL.NOMINAL.VALUE>
    Y.CUST.AA<12> = Y.CL.NOMINAL.VAL
*
RETURN
*** </region>

** <region name= GET.UTIL.AMOUNT>
GET.UTIL.AMOUNT:
***
** Remaining amount is considered to cover AA outstanding balance total amount an according with next attached COs (2nd, 3rd, ...)
*
    IF Y.CR GT 1 THEN ;* Only for Second, 3rd Collateral attached and so on..
        Y.UTI.BAL = TOTAL.AMT - Y.TOT.UTIL.AMT        ;* Getting remaining amount to be covered by COs followed
    END
*
    Y.TOT.UTIL.AMT = Y.TOT.UTIL.AMT + Y.AA.BAL
*
    IF Y.CR GT 1 AND Y.AA.BAL GT 0 THEN   ;* Only for Second, 3rd CO record attached and so on... and Outstanding bal. amt. pending to be covered

        IF Y.TOT.UTIL.AMT LT TOTAL.AMT AND Y.CUST.AA<8> LT Y.UTI.BAL THEN ;* Current utilized amount lesser than "Maximo a Prestar" CO val field
            Y.UTI.BAL = Y.CUST.AA<8>
        END
*
        Y.AA.BAL = Y.UTI.BAL
*
        IF Y.UTI.BAL LT 0 THEN
            Y.AA.BAL = 0  ;* Flag to mark Outstanding amt it is totally covered with record in process
        END
*
    END
*
RETURN
** </region>

** <region name= GET.CUR.AABAL>
GET.CUR.AABAL:
*
* Taking current balance of the Loan at the CO -> AA at attachment moment
    Y.AA.CO.BAL = ''
    Y.AA.CO.BAL = FIELD(Y.CR.DATA<4>,@VM,Y.CR)
* PACS00353808 - S
*      IF Y.CR EQ 1 THEN
* PACS00350509 - 20140616 - S
*      IF Y.AA.CO.BAL EQ "" THEN
*         Y.AA.CO.BAL = Y.AA.BAL
*      END
* PACS00350509 - 20140616 - E
*      END
*      IF Y.CR GT 1 THEN
*         Y.AA.CO.BAL = Y.AA.BAL
*      END
* PACS00353808 - E
*
RETURN
** </region>

** <region name= GET.CUR.AABAL.NOMIG>
GET.CUR.AABAL.NOMIG:
*
* Taking current balance of the Loan at the CO -> AA at attachment moment
    Y.CR.DATA = Y.COL.ID.MIG
    GOSUB GET.NO.COIDS
*
    Y.POS.COID  = ''
    CHANGE @VM TO @FM IN Y.AA.CO.IDS
    LOCATE Y.CL.ID IN Y.AA.CO.IDS SETTING Y.POS.COID THEN
        Y.AA.CO.BAL = ''
        Y.AA.CO.BAL = FIELD(Y.CR.DATA<4>,@VM,Y.POS.COID)
        IF Y.NO.COIDS EQ 1 THEN
            Y.AA.CO.BAL = Y.CL.AMT.MIG
        END
        IF Y.NO.COIDS GT 1 THEN
            Y.AA.CO.BAL = FIELD(Y.CR.DATA<4>,@VM,Y.POS.COID)
        END
*
    END
*
RETURN
** </region>

** <region name= GET.NO.COIDS>
GET.NO.COIDS:
***
*
    Y.AA.CO.IDS = Y.CR.DATA<1>
    Y.CNT.COIDS = DCOUNT(Y.AA.CO.IDS,@VM)
    Y.A=1
    LOOP
    WHILE Y.A LE Y.CNT.COIDS
        Y.CO.AA.ID = FIELD(Y.AA.CO.IDS,@VM,Y.A)
        IF Y.CO.AA.ID NE "" THEN
            Y.NO.COIDS++
        END
        Y.A++
    REPEAT
*
RETURN

** <region name= GET.COLLATERAL>
GET.COLLATERAL:
***
*
    R.COLLATERAL = '' ; YERR = ''
    CALL F.READ(FN.COLLATERAL,Y.CL.ID,R.COLLATERAL,F.COLLATERAL,YERR)
    IF YERR THEN
        ETEXT = "EB-FC-READ.ERROR" : @FM : FN.COLLATERAL
        CALL STORE.END.ERROR
        RETURN
    END
*
* Collateral
RETURN
** </region>

** <region name= GET.LIMIT.CRIGHT>
GET.LIMIT.CRIGHT:
**
* Filtering from MV set values whether Migrated or Non-Migrated CO & AA
*
    GOSUB READ.COLL.RIGHT
*
    IF Y.ERR EQ "" THEN
        LIMIT.ID = R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE>
        Y.LIM.NUM = DCOUNT(LIMIT.ID,@VM)
        Y.VAR1 = 1
        LOOP
        WHILE Y.VAR1 LE Y.LIM.NUM
            Y.LIM.ID = '' ; Y.LIM.ID = LIMIT.ID<1,Y.VAR1>
            GOSUB FC.LIM.AA
            IF Y.ERR.FCAA NE "" THEN
                Y.LIMIT.ID = Y.LIM.ID ;* Not Migrated AA
            END
            Y.VAR1++
        REPEAT
    END
*
RETURN
** </region>

** <region name= READ.COLL.RIGHT>
READ.COLL.RIGHT:
**
*
    Y.ERR = ''
    CALL F.READ(FN.COLLATERAL.RIGHT,Y.CR.ID,R.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT,Y.ERR)
*
RETURN
** </region>

** <region name= GET.AA.PRODUCT>
GET.AA.PRODUCT:
***
    Y.ERR = ''
    CALL F.READ(FN.AA.ARRANGEMENT, Y.RCA.ID, AA.ARR, F.AA.ARRANGEMENT, Y.ERR)
*
RETURN
** </region>

** <region name= GET.AA.CATEG>
GET.AA.CATEG:
*** Getting Revolving or Non-Revolving equivalence
*
    Y.LIMIT.CATEGORY.CODE = '' ; Y.CAT.REVOL = ''

    SEL.CMD  = 'SELECT ':FN.AA.PRD.CAT.ACCOUNT:' LIKE '
    SEL.CMD := Y.PRODUCT.ID:'-... BY-DSND @ID'
    SEL.LIST = ''
    NO.REC   = ''
    SEL.ERR  = ''

    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NO.REC, SEL.ERR)
    REMOVE ID.PRODUCT FROM SEL.LIST SETTING POS
    CALL CACHE.READ(FN.AA.PRD.CAT.ACCOUNT, ID.PRODUCT, R.AA.PRD.CAT.ACCOUNT, Y.ERR)
    Y.LIMIT.CATEGORY.CODE = R.AA.PRD.CAT.ACCOUNT<3>
*
*IF (Y.LIMIT.CATEGORY.CODE GE 3000 AND Y.LIMIT.CATEGORY.CODE LE 3049) OR (Y.LIMIT.CATEGORY.CODE GE 3100 AND Y.LIMIT.CATEGORY.CODE LE 3149) OR \
*(Y.LIMIT.CATEGORY.CODE GE 3200 AND Y.LIMIT.CATEGORY.CODE LE 3224) THEN
***R22 manual converstion removed / from previous line****
    IF (Y.LIMIT.CATEGORY.CODE GE 3000 AND Y.LIMIT.CATEGORY.CODE LE 3049) OR (Y.LIMIT.CATEGORY.CODE GE 3100 AND Y.LIMIT.CATEGORY.CODE LE 3149) OR (Y.LIMIT.CATEGORY.CODE GE 3200 AND Y.LIMIT.CATEGORY.CODE LE 3224) THEN
* SI es garantizado
        IF (Y.LIMIT.CATEGORY.CODE GE 3025 AND Y.LIMIT.CATEGORY.CODE LE 3049) OR (Y.LIMIT.CATEGORY.CODE GE 3125 AND Y.LIMIT.CATEGORY.CODE LE 3149) THEN
* SI es revolvente
            Y.CAT.REVOL = 'SI'
        END ELSE
* NO es revolvente
            Y.CAT.REVOL = 'NO'
        END
    END ELSE
* NO es garantizado
        IF (Y.LIMIT.CATEGORY.CODE GE 3075 AND Y.LIMIT.CATEGORY.CODE LE 3099) OR (Y.LIMIT.CATEGORY.CODE GE 3175 AND Y.LIMIT.CATEGORY.CODE LE 3199) THEN
* SI es revolvente
            Y.CAT.REVOL = 'SI'
        END ELSE
* NO es revolvente
            Y.CAT.REVOL = 'NO'
        END

    END
*
RETURN
** </region>

** <region name= FC.LIM.AA>
FC.LIM.AA:
***
*
    R.REDO.FC.LIMIT.AA = '' ; Y.ERR.FCAA = ''
    CALL F.READ(FN.REDO.FC.LIMIT.AA,Y.LIM.ID,R.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA,Y.ERR.FCAA)
    Y.AA.NUM = DCOUNT(R.REDO.FC.LIMIT.AA,@FM)
*
RETURN
*** </region>

** <region name= GET.AA.AVAIL>
GET.AA.AVAIL:
***
*
    GOSUB GET.AA.CURBAL         ;* PACS00308600 - S/E
*
    Y.AA.AVAMT = ''
    Y.AA.AVAMT = R.COLLATERAL<COLL.LOCAL.REF,Y.VAL.AVA.FIELD>
*
RETURN
*** </region>

** <region name= GET.AA.CURBAL>
GET.AA.CURBAL:
***
* Get outstanding from AA
    Y.AA.BAL = ''
    APAP.REDOSRTN.redoSGetOutBalance(Y.AA.ID,TOTAL.AMT);* R22 Manual conversion
    Y.AA.BAL    = TOTAL.AMT
    IF Y.CUST.AA<8> LT Y.AA.BAL THEN
        Y.AA.BAL = Y.CUST.AA<8>
    END
*
RETURN
*** </region>

** <region name= GET.ACCOUNT.NUMBER>
GET.ACCOUNT.NUMBER:
***
    CALL F.READ(FN.ALTERNATE.ACCOUNT, Y.AA.ID, R.ALTERNATE.ACCOUNT, F.ALTERNATE.ACCOUNT, Y.ERR)
    Y.ACC.NUMBER = R.ALTERNATE.ACCOUNT
*
RETURN
*** </region>

** <region name= GET.FILT.BY.CO>
GET.FILT.BY.CO:
***
    Y.ARR.CR = '' ; Y.ARR.CR = Y.CR.DATA<1>
    CHANGE @VM TO @FM IN Y.ARR.CR
    Y.POS.CO = ''
    LOCATE Y.COLLATERAL.ID IN Y.ARR.CR SETTING Y.POS.CO THEN
        Y.FLG.CO.FND = 1
    END
*
RETURN
*** </region>

** <region name= SEL.FC.LIMIT.AA>
SEL.FC.LIMIT.AA:
**
*
    Y.AA.LIM.POS = '' ; Y.LIM.ID     = ''
    SELECT.STATEMENT = 'SELECT ' : FN.REDO.FC.LIMIT.AA
*
    REDO.FC.LIMIT.AA.LIST = '' ; LIST.NAME = '' ; SEL = '' ; ERR.CODE = '' ; LIMIT.ID = ''
    CALL EB.READLIST(SELECT.STATEMENT, REDO.FC.LIMIT.AA.LIST, LIST.NAME,SEL, ERR.CODE)
*
    LOOP
        REMOVE LIMIT.ID FROM REDO.FC.LIMIT.AA.LIST SETTING Y.AA.LIM.POS
    WHILE LIMIT.ID:Y.AA.LIM.POS
        Y.LIM.ID = LIMIT.ID
        GOSUB FC.LIM.AA
        Y.FC.AA.ID = R.REDO.FC.LIMIT.AA<Y.AA.NUM>
        IF Y.FC.AA.ID EQ Y.AA.ID THEN
            GOSUB GET.MATCH.CR
        END
    REPEAT
*
RETURN
** </region>

** <region name= GET.MATCH.CR>
GET.MATCH.CR:
**
*
    GOSUB READ.COLL.RIGHT
*
    IF Y.ERR EQ "" THEN
        POS.1 = ''
        Y.CR.LIMREF.ID = R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE>
        CHANGE @VM TO @FM IN Y.CR.LIMREF.ID
        LOCATE Y.LIM.ID IN Y.CR.LIMREF.ID SETTING POS.1 THEN
            Y.LIM.FC.AA = Y.LIM.ID
        END
    END
*
RETURN
** </region>

END
