* @ValidationCode : MjotMTAyNzEzNzM2MjpDcDEyNTI6MTY4MTg5MzY3MDQ1Njo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 14:11:10
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
SUBROUTINE REDO.V.VAL.DISPO.VALIDA
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.DISPO.VALIDA
* Attached as     : ROUTINE
* Primary Purpose : VALIDATE INFORMATION FOR ARRANGEMENT
*
* Incoming:
* ----------
*
* Outgoing:
* ----------
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
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*19-04-2023      Mohanraj R          R22 Manual code conversion  Call Method Format Modified
*-----------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.ACCOUNT
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
*
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
    IF Y.ACCOUNT.ID EQ "" THEN  ;* PACS00312875 - S/E
        AF = COLL.LOCAL.REF
        AV = YPOS<1,1>
        AS = Y.VAR      ;* PACS00312875 - S/E
        ETEXT = 'ST-ERROR.SEL.CRED'
        CALL STORE.END.ERROR
        RETURN
    END

*SET THE DISPONIBLE VALUE FOR COLLATERAL
    VAR.MAX   =  R.NEW(COLL.LOCAL.REF)<1,WPOS.MAX>
    VAR.TOTAL = VAR.MAX - P.TOTAL.OUT
    IF VAR.TOTAL GE 0 THEN
* PACS00296306 - S
        IF Y.VAR.TIPO NE "970" THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOS.DISP> = VAR.TOTAL
        END
    END
    ELSE
        IF Y.VAR.TIPO NE "970" THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOS.DISP> = 0
*show the warnig for balance arrangement and collatera
            GOSUB RAISE.BAL.CRED
            RETURN
        END
* PACS00296306 - E
    END
*
    IF Y.VAR.TIPO EQ "970" THEN
        Y.VAR.TOT.FS = Y.VAR.VNG.FS - P.TOTAL.OUT
        IF Y.VAR.TOT.FS LT 0 THEN
            GOSUB RAISE.BAL.CRED
        END
    END
*
RETURN
*----------------------------------------------------------------------------
*
RAISE.BAL.CRED:
*==============
*
    TEXT = "COLL.SALD.CRED"
    M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
    CALL STORE.OVERRIDE(M.CONT)
*
RETURN
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
        GOSUB GET.AA.CURBAL       ;* PACS00312875 - S/E
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
        GOSUB GET.CUS.OVERRIDE    ;* PACS00307565 - S/E
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

    FN.AA.ARRANGEMENT  = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    R.AA.ARRANGEMENT   = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''

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
    WCAMPO<5> = "L.COL.DEBTOR.ID"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOS.CRED    = YPOS<1,1>
    WPOS.MAX     = YPOS<1,2>
    WPOS.DISP    = YPOS<1,3>
    WPOS.CUST    = YPOS<1,4>
    WPOS.CUST.FS = YPOS<1,5>

    Y.VAR.TOT.FS = ''
    Y.VAR.VNG.FS = R.NEW(COLL.NOMINAL.VALUE)
* PACS00260025 - S
    Y.VAR.TIPO  =  R.NEW(COLL.COLLATERAL.CODE)
* PACS00260025 - E
RETURN

*------------------------


TIPO.PRODUCTO:
*=========
    IF VAR.CRED EQ '' THEN
        RETURN
    END

*VERIFY THAT THE CREDIT CORRESPOND TO COLLATERALS

    VAR.CONTADOR = 0
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

    SELECT.STATEMENT = 'SELECT ':FN.COLL.TIPO:' WITH @ID LIKE ':VAR.PRODUCTO :'... AND COLLATERAL.CODE EQ  ':Y.VAR.TIPO:' AND COLLATERAL.TYPE EQ ':VAR.CLASE
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
*
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
    CALL F.READ(FN.AA.ARRANGEMENT, Y.AA.ID, R.AA.ARRANGEMENT, F.AA.ARRANGEMENT, Y.ERR)      ;* PACS00312875 - S
    Y.ACCOUNT.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    VAR.CUS.CRED = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
RETURN

*=============================
GET.CUS.OVERRIDE:
*=============================
*Verify that customer credit is the same that customer collateral 20/03/2012
*
    IF Y.VAR.TIPO NE "970" THEN
        VAR.CUS.COLL = R.NEW(COLL.LOCAL.REF)<1,WPOS.CUST>
    END
*
    IF Y.VAR.TIPO EQ "970" THEN
        VAR.CUS.COLL = R.NEW(COLL.LOCAL.REF)<1,WPOS.CUST.FS>
    END
*
    IF (VAR.CUS.CRED NE VAR.CUS.COLL) THEN
        TEXT = "COLL.CUS.DIF"
        M.CONT = DCOUNT(R.NEW(COLL.VALUE.DATE),@VM) + 1
        CALL STORE.OVERRIDE(M.CONT)
    END
*
RETURN

*=============================
READ.ACCOUNT:
*=============================
* PACS00312875 - S
    CALL F.READ(FN.ACCOUNT,Y.AA.ID,R.ACCOUNT,F.ACCOUNT,Y.ERR)
    Y.ACCOUNT.ID = Y.AA.ID
    Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
* PACS00312875 - E
    GOSUB READ.AA.ARRANGEMENT
RETURN
END
