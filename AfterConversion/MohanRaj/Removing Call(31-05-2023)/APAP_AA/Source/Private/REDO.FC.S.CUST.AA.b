* @ValidationCode : MjoxMDA3NTE4Mjc3OkNwMTI1MjoxNjg1NTMwMTUxMTQ0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:19:11
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
SUBROUTINE REDO.FC.S.CUST.AA(ENQ.DATA)
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
* Date         : 15.06.2011
* Description  : NOFILE Enquiry Consulta de Saldos Disponibles
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date            Who               Reference      Description
* 1.0       01.17.2012      lpazmino          CR.180         Initial Version
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1 , X to X.VAR
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION         PACKAGE ADDED, CALL method format changed
*-----------------------------------------------------------------------------
* Input/Output: NA/ENQ.DATA (Enquiry Data Result)
* Dependencies: N/A
*----------------------------------------------------------------------------
*
* <region name="INCLUDES">
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
*/////////////////////////////////////////
    $INSERT I_GTS.COMMON
    $INSERT I_S.COMMON
    $INSERT I_F.ENQUIRY
    $INSERT I_F.CONTEXT.ENQUIRY
*////////////////////////////////////////
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.PRODUCT
* PACS00281659 - S
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.CUSTOMER.ACCOUNT
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.REDO.FC.LIMIT.AA
* PACS00281659 - E
    $INSERT I_F.AA.ACCOUNT.DETAILS
*
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
* </region>
*
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*
* <region name="GOSUBS" description="Gosub blocks">
*****
INIT:
*****
    Y.CUST.DATA = ''
    Y.CUSTOMER = ''
    Y.CONTRACT.ID = ''
    Y.COLLATERAL.ID = ''

    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''
    R.REDO.CREATE.ARRANGEMENT = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    R.COLLATERAL = ''

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    R.AA.PRODUCT = ''

    FN.ALTERNATE.ACCOUNT = 'F.ALTERNATE.ACCOUNT'
    F.ALTERNATE.ACCOUNT = ''
    R.ALTERNATE.ACCOUNT = ''
* PACS00281659 - S
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''

    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT  = ''
    R.CUSTOMER.ACCOUNT  = ''

    FN.COLLATERAL.RIGHT = 'F.COLLATERAL.RIGHT'
    F.COLLATERAL.RIGHT = ''
    R.COLLATERAL.RIGHT = ''

    FN.REDO.FC.LIMIT.AA = 'F.REDO.FC.LIMIT.AA'
    F.REDO.FC.LIMIT.AA = ''
    R.REDO.FC.LIMIT.AA = ''
* PACS00281659 - E

    SELECT.STATEMENT = ''
    SELECT.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''

    Y.ERR = ''
    Y.AA.ID = ''
    Y.ACC.NUMBER = ''
    YPOS = 0
    Y.IS.FIND.BY.CUS = ''
* PACS00281659 - S
*Get the position for TERM.AMOUNT and COLLATERAL fields
*
    Y.FIELD = "L.AA.COL":@FM:"L.AC.LK.COL.ID"
    Y.APPLICATION = "AA.PRD.DES.TERM.AMOUNT":@FM:"COLLATERAL"
    Y.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,Y.FIELD,Y.POS)
    Y.COLL.FIELD.POS = Y.POS<1,1>
    WPOSCRED         = Y.POS<2,1>
    Y.COLL.ID.TMP    = ''
* PACS00281659 - E
*
RETURN

***********
OPEN.FILES:
***********
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)
    CALL OPF(FN.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
* PACS00281659 - S
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)
    CALL OPF(FN.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT)
    CALL OPF(FN.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA)
* PACS00281659 - E
RETURN

********
PROCESS:
********
    LOCATE 'CUSTOMER' IN D.FIELDS SETTING Y.POS THEN
        Y.CUSTOMER = D.RANGE.AND.VALUE<Y.POS>
    END

    LOCATE 'CONTRACT.ID' IN D.FIELDS SETTING Y.POS THEN
        Y.CONTRACT.ID = D.RANGE.AND.VALUE<Y.POS>
    END

    LOCATE 'COLLATERAL.ID' IN D.FIELDS SETTING Y.POS THEN
        Y.COLLATERAL.ID = D.RANGE.AND.VALUE<Y.POS>
        Y.COLL.ID.TMP   = Y.COLLATERAL.ID   ;* PACS00297652 - S/E
    END

    IF Y.CUSTOMER AND NOT(Y.CONTRACT.ID) AND NOT(Y.COLLATERAL.ID) THEN
        Y.IS.FIND.BY.CUS = "YES"
        GOSUB FIND.BY.CUS
        RETURN
    END

    IF Y.COLLATERAL.ID AND NOT(Y.CONTRACT.ID) THEN
        Y.SM.AA = ''
        GOSUB GET.COLLATERAL
* PACS00307565 - S
        GOSUB EVA.MULTI.AA
        IF R.COLLATERAL EQ "" OR Y.SM.AA GT 1 THEN
* PACS00307565 - E
            RETURN
        END
        Y.CR.ID = FIELD(Y.COLLATERAL.ID,".",1) : "." : FIELD(Y.COLLATERAL.ID,".",2)
        GOSUB FIND.BY.COLLRIGHT
        RETURN
    END

    IF Y.CONTRACT.ID THEN
        Y.AA.ID = Y.CONTRACT.ID
        GOSUB FIND.BY.CONTRACT.ID
        RETURN
    END

RETURN
*
************
FIND.BY.CUS:
************
*
    Y.CU.ID = '' ; Y.CU.ID = Y.CUSTOMER
    SELECT.STATEMENT = 'SELECT ':FN.COLLATERAL.RIGHT: ' WITH @ID LIKE ' : Y.CU.ID : '....'
    CR.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    CALL EB.READLIST(SELECT.STATEMENT,CR.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
    IF SELECTED GT 0 THEN
        LOOP
            REMOVE Y.CR.ID FROM CR.LIST SETTING CR.POS
        WHILE Y.CR.ID:CR.POS
*
            GOSUB FIND.BY.COLLRIGHT
        REPEAT
    END
*
RETURN
*
**************
GET.AA.MIG.ID:
**************
*
    IF Y.COLLATERAL.ID EQ "" THEN
        CO.POS = ''
        SELECT.STATEMENT = 'SELECT ':FN.COLLATERAL
        CO.LIST = '' ; LIST.NAME = '' ; SELECTED = '' ; SYSTEM.RETURN.CODE = ''
        CALL EB.READLIST(SELECT.STATEMENT,CO.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
*
        IF SELECTED GT 0 THEN
            LOOP
                REMOVE Y.COLLATERAL.ID FROM CO.LIST SETTING CO.POS
            WHILE Y.COLLATERAL.ID:CO.POS
*
                Y.CR.CL = FIELD(Y.COLLATERAL.ID,".",1) : "." :FIELD(Y.COLLATERAL.ID,".",2)
                IF Y.CR.CL EQ Y.CR.ID THEN      ;* Whether current Collateral belongs to CRight processed
                    Y.COLL.ID.TMP = Y.COLLATERAL.ID
                    GOSUB GET.AA.FROM.COL
                END
*
            REPEAT
        END
*
    END
    ELSE
        GOSUB GET.AA.FROM.COL
    END
*
RETURN
*
*************
EVA.MULTI.AA:
*************
*
    IF Y.SM.AA GT 1 THEN
        GOSUB GET.AA.FROM.COL
    END
*
RETURN
*
****************
GET.AA.FROM.COL:
****************
*
    GOSUB GET.COLLATERAL
    Y.AA.ID = Y.PRES.ID
    IF Y.AA.ID NE "" THEN
* PACS00307565 - S
        Y.SM.AA = DCOUNT(Y.AA.ID,@SM)
        A = 1
        LOOP
        WHILE A LE Y.SM.AA
            Y.AA.ID = '' ; Y.AA.ID = Y.PRES.ID<1,1,A>
            GOSUB GET.AA.DIRECTLY
            A += 1
        REPEAT
* PACS00307565 - E
    END
*
RETURN
*
********************
FIND.BY.CONTRACT.ID:
********************
* Identify which ID has been inserted
    Y.ID = Y.CONTRACT.ID[1,2]
    BEGIN CASE
* AA ID
        CASE Y.ID EQ 'AA'
            GOSUB GET.AA.DIRECTLY
            RETURN
* FC ID
        CASE Y.ID EQ 'AR'
            GOSUB FIND.BY.FC
            RETURN
* Default case (for accounts)
        CASE 1
            GOSUB FIND.BY.ACCOUNT
            RETURN
    END CASE

RETURN

***********
FIND.BY.AA:
***********

    SELECT.STATEMENT = 'SSELECT ':FN.REDO.CREATE.ARRANGEMENT
    SELECT.STATEMENT := ' WITH ID.ARRANGEMENT EQ ' : Y.CONTRACT.ID
    SELECT.STATEMENT := " AND STATUS.TEMPLATE NE 'FAIL'"
    SELECT.STATEMENT := ' BY-DSND EFFECT.DATE'
    GOSUB EXEC.SELECT
RETURN

***********
FIND.BY.FC:
***********
    Y.ERR = ''
    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,Y.CONTRACT.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,Y.ERR)
    IF NOT(Y.ERR) THEN
        IF  R.REDO.CREATE.ARRANGEMENT<REDO.FC.STATUS.TEMPLATE> EQ 'FAIL' THEN
            RETURN
        END
*
        Y.AA.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.ID.ARRANGEMENT>
        GOSUB GET.COLLAA.DIRECT
*
    END
*
RETURN
*
****************
FIND.BY.ACCOUNT:
****************
*
    CALL F.READ(FN.ACCOUNT,Y.CONTRACT.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    IF Y.ERR THEN
        RETURN
    END
    Y.CONTRACT.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    GOSUB FIND.BY.AA
    GOSUB GET.AA.COLL ;* PACS00281659 - S/E
RETURN
*
**********
FC.LIM.AA:
**********
*
    R.REDO.FC.LIMIT.AA = '' ; Y.ERR.FCAA = ''
    CALL F.READ(FN.REDO.FC.LIMIT.AA,Y.LIM.ID,R.REDO.FC.LIMIT.AA,F.REDO.FC.LIMIT.AA,Y.ERR.FCAA)
    IF R.REDO.FC.LIMIT.AA THEN
        Y.AA.NUM = DCOUNT(R.REDO.FC.LIMIT.AA,@FM)
        Y.VAR2 = 1
        LOOP
        WHILE Y.VAR2 LE Y.AA.NUM
            Y.CONTRACT.ID = FIELD(R.REDO.FC.LIMIT.AA,@FM,Y.VAR2)
            Y.VAR2 += 1
        REPEAT
    END
*
RETURN
*
**********************
FIND.BY.COLLATERAL.ID:
**********************
*
    GOSUB GET.COLLATERAL
    IF Y.ERR THEN
        RETURN
    END
*
    Y.COLL.FIELD = ''
    IF Y.PRES.ID THEN
        Y.CONTRACT.ID = Y.PRES.ID
        GOSUB FIND.BY.CONTRACT.ID
        Y.AA.ID = Y.CONTRACT.ID   ;* PACS00281659 - S
        GOSUB GET.COLLDATA        ;* PACS00281659 - E
        RETURN
    END
*
    SELECT.STATEMENT = 'SSELECT ':FN.REDO.CREATE.ARRANGEMENT
    SELECT.STATEMENT := ' WITH ' : Y.COLL.FIELD : ' EQ ' : Y.COLLATERAL.ID
    SELECT.STATEMENT := " AND STATUS.TEMPLATE NE 'FAIL'"
    SELECT.STATEMENT := ' BY-DSND EFFECT.DATE'
    GOSUB EXEC.SELECT
RETURN

************
EXEC.SELECT:
************
    CALL EB.READLIST(SELECT.STATEMENT,SELECT.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
    IF SELECTED GT 0 THEN
        LOOP
            REMOVE FC.ID FROM SELECT.LIST SETTING FC.POS
        WHILE FC.ID:FC.POS
            CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,FC.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,Y.ERR)
            IF NOT(Y.ERR) THEN
                Y.CUST.DATA<1> = R.REDO.CREATE.ARRANGEMENT<REDO.FC.CUSTOMER>
                Y.CUST.DATA<2> = FC.ID
                Y.AA.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.ID.ARRANGEMENT>
                Y.CUST.DATA<3> = Y.AA.ID
                Y.EFFECT.DATE = R.REDO.CREATE.ARRANGEMENT<REDO.FC.EFFECT.DATE>
                GOSUB FORMAT.DATE
                Y.CUST.DATA<4> = Y.EFFECT.DATE
                Y.PRODUCT.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.PRODUCT>
                GOSUB GET.PRODUCT.DESC
                Y.CUST.DATA<5> = Y.PRODUCT.DESCRIPTION
                GOSUB GET.ACCOUNT.NUMBER
                Y.CUST.DATA<6> = Y.ACC.NUMBER
* PACS00281659 - S
*               Y.COLLR.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.ID.COLLATERL.RIGHT>
                Y.COLLATERAL.ID = ''
                GOSUB GET.COLL.FC     ;* PACS00308600 - S/E
                Y.CUST.DATA<7> = Y.COLLATERAL.ID
* PACS00281659 - E
                IF Y.ACC.NUMBER THEN
* PACS00352738 - S
                    W.CUST.DATA.TMP = ''
                    W.CUST.DATA.TMP = ENQ.DATA
                    CHANGE '*' TO @FM IN W.CUST.DATA.TMP
                    W.AAID.POS = ''
                    LOCATE Y.AA.ID IN W.CUST.DATA.TMP SETTING W.AAID.POS ELSE
                        CHANGE @FM TO "*" IN Y.CUST.DATA
                        ENQ.DATA<-1> = Y.CUST.DATA
                    END
* PACS00352738 - E
                END
            END
        REPEAT
    END

RETURN
*
***************
GET.COLLATERAL:
***************
*
    Y.COLLATERAL.CODE = '' ; Y.PRES.ID = '' ; Y.ERR = ''
    CALL F.READ(FN.COLLATERAL,Y.COLLATERAL.ID,R.COLLATERAL,F.COLLATERAL,Y.ERR)
    Y.COLLATERAL.CODE = R.COLLATERAL<COLL.COLLATERAL.CODE>
    Y.PRES.ID = R.COLLATERAL<COLL.LOCAL.REF,WPOSCRED>
*
    GOSUB GET.SM.AA
*
RETURN
*
**********
GET.SM.AA:
**********
*
* PACS00307565 - S
    Y.SM.AA = DCOUNT(Y.PRES.ID,@SM)
    X.VAR = 1
    LOOP
    WHILE X.VAR LE Y.SM.AA
        Y.PRES.IN = '' ; Y.PRES.IN = Y.PRES.ID<1,1,X.VAR>[1,2]
        IF Y.PRES.IN NE 'AA' AND Y.PRES.IN NE 'AR' THEN
            Y.CONTRACT.ID = '' ; Y.CONTRACT.ID = Y.PRES.ID<1,1,X.VAR>
            GOSUB FIND.BY.ACCOUNT
            Y.PRES.ID = '' ; Y.PRES.ID = Y.CONTRACT.ID
        END
        X.VAR += 1
    REPEAT
* PACS00307565 - E
*
RETURN
*
************
GET.COLL.FC:
************
*
    IF Y.COLLATERAL.ID EQ "" THEN
*
        Y.CO.LAST = ''
        GOSUB GET.COLL.AA.IDS
        Y.CL.NUM = '' ; Y.CL.NUM = DCOUNT(Y.COL.ID.MIG<1>,@VM)
        W.CL     = 1
        LOOP
        WHILE W.CL LE Y.CL.NUM
            Y.CL.ID = '' ; Y.CL.ID = Y.COL.ID.MIG<1,W.CL>
            IF Y.CL.ID NE "" THEN
                Y.CO.LAST = W.CL
            END
            W.CL += 1
        REPEAT
*
        Y.COLLATERAL.ID = Y.COL.ID.MIG<1,Y.CO.LAST>
*
    END
*
RETURN
*
******************
GET.COLLAA.DIRECT:
******************
*
    Y.CO.AAFND = ''   ;* PACS00308600 - S/E
*
    IF Y.COLLATERAL.ID EQ "" THEN
*
        GOSUB GET.COLL.AA.IDS
*
        Y.CL.NUM     = '' ; Y.CL.NUM = DCOUNT(Y.COL.ID.MIG<1>,@VM)         ;* PACS00308600 - S/E
        Y.CL         = 1  ; Y.AA.CID = ''
        LOOP
        WHILE Y.CL LE Y.CL.NUM
            Y.CL.ID = '' ; Y.CL.ID = Y.COL.ID.MIG<1,Y.CL>         ;* PACS00308600 - S/E
            IF Y.CL.ID NE "" THEN
                Y.AA.CID = Y.CL.ID
                Y.CO.AAFND = Y.CL     ;* PACS00308600 - S/E
            END
            Y.CL += 1
        REPEAT
* PACS00308600 - S
        Y.CL.ID = '' ; Y.CL.ID = Y.COL.ID.MIG<1,Y.CO.AAFND>
        GOSUB FILL.RCA.REC
        Y.CL.ID = Y.AA.CID
* PACS00308600 - E
    END
*
RETURN
*
************
GET.COLLDATA:
************
*
    Y.FC.ID = ''
    Y.FC.ID = SELECT.LIST<1>
    IF Y.FC.ID[1,3] NE "ARR" THEN
        Y.FC.ID = SELECT.LIST<1>
    END
*
    IF SELECTED EQ 0 THEN
        Y.FC.ID = Y.AA.ID
    END
*
    R.COLLATERAL = '' ; Y.ERR.COL = ''
    CALL F.READ(FN.COLLATERAL,Y.COLLATERAL.ID,R.COLLATERAL,F.COLLATERAL,Y.ERR.COL)
    IF NOT(Y.ERR.COL) THEN
        Y.CUST.DATA<1> = FIELD(Y.COLLATERAL.ID,".",1)
        Y.CUST.DATA<2> = Y.FC.ID
        Y.CUST.DATA<3> = Y.AA.ID

        GOSUB GET.AA.PROD
        Y.EFFECT.DATE  = R.AA.ARRANGEMENT<AA.ARR.START.DATE>
        GOSUB FORMAT.DATE
        Y.CUST.DATA<4> = Y.EFFECT.DATE
        Y.PRODUCT.ID =  R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
        GOSUB GET.PRODUCT.DESC
        Y.CUST.DATA<5> = Y.PRODUCT.DESCRIPTION
        GOSUB GET.ACCOUNT.NUMBER
        Y.CUST.DATA<6> = Y.ACC.NUMBER
        IF Y.COLL.ID.TMP NE "" THEN
            Y.COLLATERAL.ID = Y.COLL.ID.TMP
        END
        Y.CUST.DATA<7> = Y.COLLATERAL.ID
        IF Y.ACC.NUMBER THEN
            CHANGE @FM TO "*" IN Y.CUST.DATA
            ENQ.DATA<-1> = Y.CUST.DATA
        END

    END
*
RETURN
*
************
GET.AA.COLL:
************
*
    LOCATE 'CONTRACT.ID' IN D.FIELDS SETTING Y.POS THEN
        Y.PRESTAMO.ID = D.RANGE.AND.VALUE<Y.POS>
        IF Y.PRESTAMO.ID[1,2] NE "AA" THEN  ;* Selection criteria given, by ACCOUNT ID
            Y.PRESTAMO.ID = Y.CONTRACT.ID
        END
*
        IF SELECTED EQ 0 AND Y.PRESTAMO.ID THEN
            Y.AA.ID = Y.PRESTAMO.ID
            GOSUB GET.AA.DIRECTLY
        END
*
    END
*
RETURN
*
******************
FIND.BY.COLLRIGHT:
******************
* As per a new client-collateral is added to AA and has not a link generated automatically (not generated via "AA template"),
* then related Limit is taken from Collateral.right record.
*

    Y.ERR = ''
    CALL F.READ(FN.COLLATERAL.RIGHT,Y.CR.ID,R.COLLATERAL.RIGHT,F.COLLATERAL.RIGHT,Y.ERR)
    IF Y.ERR EQ "" THEN
        LIMIT.ID = '' ; LIMIT.ID = R.COLLATERAL.RIGHT<COLL.RIGHT.LIMIT.REFERENCE>
        Y.LIM.NUM = DCOUNT(LIMIT.ID,@VM)
        IF Y.LIM.NUM GT 0 THEN
            GOSUB GET.MIG.NONM.AA
        END
* PACS00308600 - S
        ELSE
            IF Y.IS.FIND.BY.CUS THEN
                SELECTED = 0
                COLL.LIST.CMD = "SELECT ":FN.COLLATERAL : " WITH @ID LIKE " : Y.CR.ID: "...."

                CALL EB.READLIST(COLL.LIST.CMD,COLL.LIST,COLL.LIST.NAME,SELECTED.COLL,SYSTEM.RETURN.CODE.COLL)
                LOOP
                    REMOVE Y.COL.ID FROM COLL.LIST SETTING CR.POS
                WHILE Y.COL.ID:CR.POS
                    Y.COLLATERAL.ID = Y.COL.ID
                    GOSUB GET.COLLATERAL
                REPEAT
            END
            ELSE
                GOSUB GET.COLLATERAL
            END
            Y.AA.ID = Y.PRES.ID
            GOSUB GET.COLLDATA
* PACS00308600 - E
        END
    END
*
RETURN
*
****************
GET.MIG.NONM.AA:
****************
*
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.LIM.NUM
        Y.LIM.ID = '' ; Y.LIM.ID = LIMIT.ID<1,Y.VAR1>
        GOSUB FC.LIM.AA
        IF R.REDO.FC.LIMIT.AA EQ "" THEN
            GOSUB GET.AA.MIG.ID
        END
        ELSE
            GOSUB FIND.BY.AA
        END
        Y.VAR1 += 1
    REPEAT
*
RETURN
*
***************
GET.COLL.AA.IDS:
***************
*
    Y.COL.ID.MIG = '' ; COL.ID.LINKED = ''
    APAP.AA.redoColAaGetLinksCol(Y.AA.ID,COL.ID.LINKED);* R22 Manual conversion
    MMARK = CHARX(251)
    Y.COL.ID.MIG = CHANGE(COL.ID.LINKED, MMARK , @VM )
    IF COL.ID.LINKED EQ "ERROR" THEN
        Y.COL.ID.MIG = ''
    END
*
RETURN
*
************
GET.AA.PROD:
************
*
    Y.ERR = ''
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)
*
RETURN
*
****************
GET.AA.DIRECTLY:
****************
*
    Y.CO.FND = ''     ;* PACS00308600 - S/E
*
    GOSUB GET.ARR.ID
*
    GOSUB GET.COLL.AA.IDS
*
    Y.CL.NUM = '' ; Y.CL.NUM = DCOUNT(Y.COL.ID.MIG<1>,@VM)     ;* PACS00308600 - S/E
    Y.CL     = 1
    LOOP
    WHILE Y.CL LE Y.CL.NUM
        Y.CL.ID = '' ; Y.CL.ID = Y.COL.ID.MIG<1,Y.CL> ;* PACS00308600 - S/E
        IF Y.CL.ID NE "" THEN
            GOSUB EVAL.CRIT.SEL
            Y.CO.FND = Y.CL         ;* PACS00308600 - S/E
        END
        Y.CL += 1
    REPEAT
*
* PACS00308600 - S
    Y.CL.ID = '' ; Y.CL.ID = Y.COL.ID.MIG<1,Y.CO.FND>
    IF Y.COLL.ID.TMP EQ "" AND Y.CL.ID THEN         ;* Criteria without Collateral id
        Y.COLLATERAL.ID = Y.CL.ID
        GOSUB GET.COLLDATA
    END
* PACS00308600 - E
*
RETURN
*
**************
EVAL.CRIT.SEL:
**************
*
    IF Y.COLL.ID.TMP AND Y.CL.ID AND Y.COLL.ID.TMP EQ Y.CL.ID THEN      ;* Criteria with Co Id
        Y.COLLATERAL.ID = Y.CL.ID ;* PACS00308600 - S/E
        GOSUB GET.COLLDATA
    END
*
RETURN
*
************
FORMAT.DATE:
************
* PACS00281659 - S
*      Y.EFFECT.DATE = R.REDO.CREATE.ARRANGEMENT<REDO.FC.EFFECT.DATE>
* PACS00281659 - E

    Y.YEAR = Y.EFFECT.DATE[1,4]
    Y.MONTH = Y.EFFECT.DATE[5,2]
    Y.DAY = Y.EFFECT.DATE[7,2]
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

* Transform to Julian Format
    Y.DATE = Y.DAY : ' ' : Y.MMONTH : ' ' : Y.YEAR
* PACS00281659 - S
    Y.EFFECT.DATE = Y.DATE      ;* PACS00281659 - S/E
*
*     Y.JDATE = OCONV(Y.DATE,"DI")
*
*     Y.EFFECT.DATE = OCONV(Y.JDATE,"D")
* PACS00281659 - E
RETURN
*
***********
GET.ARR.ID:
***********
*
    SELECT.STATEMENT = 'SSELECT ':FN.REDO.CREATE.ARRANGEMENT
    SELECT.STATEMENT := ' WITH ID.ARRANGEMENT EQ ' :Y.AA.ID
    SELECT.STATEMENT := " AND STATUS.TEMPLATE NE 'FAIL'"
    SELECT.STATEMENT := ' BY-DSND EFFECT.DATE'
*
    SELECT.LIST =  '' ; LIST.NAME = '' ; SELECTED = 0 ; SYSTEM.RETURN.CODE = ""
    CALL EB.READLIST(SELECT.STATEMENT,SELECT.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)
*
RETURN
*
*****************
GET.PRODUCT.DESC:
*****************
* Producto
* PACS00281659 - S
*      Y.PRODUCT.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.PRODUCT>
* PACS00281659 - E
    CALL CACHE.READ(FN.AA.PRODUCT,Y.PRODUCT.ID,R.AA.PRODUCT,Y.ERR)

    Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,2)
    IF Y.PRODUCT.DESCRIPTION EQ '' THEN
        Y.PRODUCT.DESCRIPTION = FIELD(R.AA.PRODUCT<AA.PDT.DESCRIPTION>,@VM,1)
    END

RETURN
*
*************
FILL.RCA.REC:
*************
*
    IF Y.ID EQ 'AR' THEN
*
        Y.CUST.DATA<1> = R.REDO.CREATE.ARRANGEMENT<REDO.FC.CUSTOMER>
        Y.CUST.DATA<2> = Y.CONTRACT.ID
        Y.CUST.DATA<3> = Y.AA.ID
        Y.EFFECT.DATE = R.REDO.CREATE.ARRANGEMENT<REDO.FC.EFFECT.DATE>    ;* PACS00281659 - S
        GOSUB FORMAT.DATE
        Y.CUST.DATA<4> = Y.EFFECT.DATE
        Y.PRODUCT.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.PRODUCT>         ;* PACS00281659 - E
        GOSUB GET.PRODUCT.DESC
        Y.CUST.DATA<5> = Y.PRODUCT.DESCRIPTION
        GOSUB GET.ACCOUNT.NUMBER
        Y.CUST.DATA<6> = Y.ACC.NUMBER
        Y.COLLR.ID = R.REDO.CREATE.ARRANGEMENT<REDO.FC.ID.COLLATERL.RIGHT>          ;* PACS00281659 - S
        Y.COLLATERAL.ID = Y.AA.CID
        Y.CUST.DATA<7>  = Y.COLLATERAL.ID   ;* PACS00281659 - E
        IF NOT(Y.ACC.NUMBER) THEN
            RETURN
        END
*
        CHANGE @FM TO "*" IN Y.CUST.DATA
        ENQ.DATA<-1> = Y.CUST.DATA
*
    END
*
RETURN
*
*******************
GET.ACCOUNT.NUMBER:
*******************

    CALL F.READ(FN.ALTERNATE.ACCOUNT, Y.AA.ID, R.ALTERNATE.ACCOUNT, F.ALTERNATE.ACCOUNT, Y.ERR)
    Y.ACC.NUMBER = R.ALTERNATE.ACCOUNT

RETURN

* </region>

END
