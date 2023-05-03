* @ValidationCode : Mjo4NDMyMzY0NDk6Q3AxMjUyOjE2ODE4OTM3NTAwMDk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 14:12:30
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.DISPO.VALIDA.DI
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.DISPO.VALIDA.DI
* Attached as     : ROUTINE
* Primary Purpose : VALIDATE INFORMATION FOR ARRANGEMENT
*
* Incoming:
* ---------
*
* Outgoing:
* ---------
*
*
* Error Variables:
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            : 22/03/2012
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCOUNT

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
        GOSUB TIPO.PRODUCTO
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

    VAR.CRED  =  R.NEW(COLL.LOCAL.REF)<1,WPOS.CRED>

*if the user change a creditos an delete the credit number
    IF VAR.CRED EQ '' THEN
        RETURN
    END
*
*GET THE INFORMATION FOR THE SALD FOR ARRANGEMENT
    GOSUB GET.AAID.SM ;* PACS00307565 - S/E
*
*ERROR MESSAGE WHEN THE ARRANGEMETN DO NOT EXIST
    IF Y.ACCOUNT.ID EQ 0 THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,1>
        ETEXT = 'ST-ERROR.SEL.CRED'
        CALL STORE.END.ERROR
        RETURN
    END
*Verify that customer credit is the same that customer collateral 20/03/2012

    VAR.CUS.COLL = R.NEW(COLL.LOCAL.REF)<1,WPOS.CUST>
    IF (VAR.CUS.CRED NE VAR.CUS.COLL) THEN
        TEXT = "COLL.CUS.DIF"
        M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
        CALL STORE.OVERRIDE(M.CONT)
    END

    P.TOTAL.OUT = ABS(P.TOTAL.OUT)
    P.TOTAL.OUT = (P.TOTAL.OUT * 105)/100

*SET THE DISPONIBLE VALUE FOR COLLATERAL

*    VAR.MAX   =  R.NEW(COLL.EXECUTION.VALUE)
    VAR.MAX   = R.NEW(COLL.LOCAL.REF)<1,WPOS.MAX>
    VAR.TOTAL = VAR.MAX - P.TOTAL.OUT

    IF VAR.TOTAL GE 0 THEN
*IS USED ONLY FOR VALIDATE
    END
    ELSE
        R.NEW(COLL.LOCAL.REF)<1,WPOS.DISP> = 0
        GOSUB RAISE.OVE.BALCRED
    END
*
RETURN
*
*================
RAISE.OVE.BALCRED:
*----------------------------------------------------------------------------
*show the warnig for balance arrangement and collatera
*
    TEXT = "COLL.SALD.CRED"
    M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
    CALL STORE.OVERRIDE(M.CONT)
*
RETURN
*
VAL.DATEEXP.AA:
*======
***For get the expiration date for arrangement and expiration for instrument.
    VAR.COL.TYPE = R.NEW(COLL.COLLATERAL.TYPE)
    IF VAR.COL.TYPE EQ 152 THEN
        Y.PROCESS.DATE              = TODAY ;* PACS00307565 - S/E
        P.AA.ID = Y.AA.ID
        idPropertyClass = "TERM.AMOUNT"     ;*SI Falla usar COMMITMENT
        ArrangementID = P.AA.ID ; idProperty = ''; effectiveDate = Y.PROCESS.DATE; returnIds = ''; R.CONDITION =''; returnConditions = ''; returnError = ''
        CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
        IF returnError THEN
            E = returnError
            RETURN
        END

        R.AA.TERM.AMOUNT = RAISE(returnConditions)

        Y.DAT.MAT = ""
        Y.DAT.MAT = R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>

*GET THE EXPIRATION DATE FOR DEPOSIT
        Y.FEC.VENC = R.NEW(COLL.LOCAL.REF)<1,WPOS.FECHA>
        IF Y.FEC.VENC LT Y.DAT.MAT THEN
            TEXT = "COLL.FECH.DEP"
            M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
            CALL STORE.OVERRIDE(M.CONT)
        END

    END
***End get expiration date

RETURN
*
*----------------------------------------------------------------------------
*
GET.AAID.SM:
*===========
*
    Y.AA.NUM = DCOUNT(VAR.CRED,@SM)
    Y.VAR = 1
    LOOP
    WHILE Y.VAR LE Y.AA.NUM
        Y.AA.ID = FIELD(VAR.CRED,@SM,Y.VAR)
        GOSUB READ.AA.ACCT
        IF Y.ERR NE "" THEN
            BREAK
        END
        GOSUB GET.AA.CURBAL       ;* PACS00307565 - S/E
        GOSUB VAL.DATEEXP.AA      ;* PACS00255616 - S/E
        Y.VAR += 1
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
    PROCESS.GOAHEAD = 1
    FN.SALD  = 'F.EB.CONTRACT.BALANCES'
    F.SALD   = ''
    R.SALD   = ''

    Y.ACCOUNT.ID = 0

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''

    VAR.COD.BALANCE = ''
    FN.AC.BALANCE.TYPE = 'F.AC.BALANCE.TYPE'
    F.AC.BALANCE.TYPE  = ''
    R.AC.BALANCE.TYPE  = ''

    FN.COLL.TIPO = 'F.REDO.FC.PROD.COLL.POLICY'
    F.COLL.TIPO  = ''
    R.COLL.TIPO  = ''

*Read the local fields
    WCAMPO = "L.AC.LK.COL.ID"
    WCAMPO<2> = "L.COL.LN.MX.VAL"
    WCAMPO<3> = "L.COL.VAL.AVA"
    WCAMPO<4> = "L.COL.SEC.HOLD"
    WCAMPO<5> = "L.COL.INVST.DT"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0
    P.TOTAL.OUT = 0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOS.CRED  = YPOS<1,1>
    WPOS.MAX   = YPOS<1,2>
    WPOS.DISP  = YPOS<1,3>
    WPOS.CUST  = YPOS<1,4>
    WPOS.FECHA = YPOS<1,5>
RETURN

*------------------------

TIPO.PRODUCTO:
*=========

    IF VAR.CRED EQ '' THEN
        RETURN
    END

*VERIFY THAT THE CREDIT CORRESPOND TO COLLATERALS

    VAR.CONTADOR = 0
    VAR.TIPO  =  R.NEW(COLL.COLLATERAL.CODE)
    VAR.CLASE =  R.NEW(COLL.COLLATERAL.TYPE)


*Para sacar el ultimo dato del registro
    VAR.FILAS    = DCOUNT(VAR.PRODUCTO,@SM)
    VAR.REGDIRE  = CHANGE(VAR.PRODUCTO,@SM,@FM)

    VAR.I =1
    LOOP
    WHILE VAR.I LE VAR.FILAS
        VAR.REG = VAR.REGDIRE<VAR.I>
        VAR.I+=1
    REPEAT
    VAR.PRODUCTO = VAR.REG
*fin sacarf producto

    SELECT.STATEMENT = 'SELECT ':FN.COLL.TIPO:' WITH @ID LIKE ':VAR.PRODUCTO :'... AND COLLATERAL.CODE EQ  ':VAR.TIPO:' AND COLLATERAL.TYPE EQ ':VAR.CLASE
    LOCK.LIST = ''
    LIST.NAME = ''
    SELECTED = ''
    SYSTEM.RETURN.CODE = ''
    Y.ID.PROD = ''

    CALL EB.READLIST(SELECT.STATEMENT,LOCK.LIST,LIST.NAME,SELECTED,SYSTEM.RETURN.CODE)

*GET ALL VALUES FROM THE LIST AND ADD THE LOCK VALUE
    LOOP
        REMOVE Y.ID.PROD FROM LOCK.LIST SETTING POS
    WHILE Y.ID.PROD:POS

        VAR.CONTADOR += 1 ;*R22 Auto Code Conversion
    REPEAT

    IF  VAR.CONTADOR EQ 0 THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,1>
        ETEXT = 'ST-CRED.CORR.COLLA'
        CALL STORE.END.ERROR
    END

RETURN
*------------

OPEN.FILES:
*=========
    CALL OPF(FN.SALD,F.SALD)
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)
    CALL OPF(FN.AC.BALANCE.TYPE,F.AC.BALANCE.TYPE)
    CALL OPF(FN.COLL.TIPO,F.COLL.TIPO)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*------------
*=============
GET.AA.CURBAL:
*=============
*
* Get outstanding from AA
    P.TOTAL.OUT = ''
    CALL APAP.SRTN.REDO.S.GET.OUT.BALANCE(Y.AA.ID,TOTAL.AMT) ;*R22 Manual Code Conversion-Call Method Format Modified
    P.TOTAL.OUT    += TOTAL.AMT
*
RETURN
*
*=============================
READ.AA.ARRANGEMENT:
*=============================
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)
    Y.ACCOUNT.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    VAR.CUS.CRED = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    VAR.PRODUCTO =  R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
RETURN
*=============================
READ.ACCOUNT:
*=============================
    CALL F.READ(FN.ACCOUNT,Y.AA.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.ACCOUNT.ID = Y.AA.ID      ;* PACS00307565 - S
    Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>          ;* PACS00307565 - E
    GOSUB READ.AA.ARRANGEMENT
RETURN
END
