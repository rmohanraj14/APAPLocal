* @ValidationCode : Mjo4NTA5MjA2NTg6Q3AxMjUyOjE2ODE4OTAyMzQ4OTQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:13:54
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
SUBROUTINE REDO.V.VAL.DISPO.INSTRU
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.SEL.CLIE.CUEN
* Attached as     : ROUTINE
* Primary Purpose :
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
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,= TO EQ
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_GTS.COMMON

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

*LOCATE COLL.NOMINAL.VALUE IN R.GTS<1,3> SETTING Y.POSITION THEN
*Y.VAR=   R.GTS<Y.POSITION,2>
*RETURN
*END

* Get the account number (fix deposit or deposits )
*VAR.CUENTA = R.NEW(COLL.APPLICATION.ID)
    VAR.CUENTA = COMI
    VAR.TIPO = R.NEW(COLL.COLLATERAL.TYPE)
    Y.ERR = ""
    CALL F.READ(FN.ACCOUNT,VAR.CUENTA,R.ACCOUNT,F.ACCOUNT,Y.ERR)

*///ACCOUNTS///
    IF (VAR.TIPO EQ 151) OR (VAR.TIPO EQ 153) THEN
*Get the prymary key customer
        VAR.SALDO =  R.ACCOUNT<AC.LOCAL.REF,WPOS.AC.DIS>

*GET THE LOCKED VALUE
*         VAR.VAR.TOT.LOCK  =  SUM(R.ACCOUNT<AC.LOCKED.AMOUNT>)
*         CADENA = CHANGE(VAR.VAR.TOT.LOCK, VM, FM)
*         L1= DCOUNT(CADENA,FM)
*         FOR I = 1 TO L1
*           AUX_VAR = CADENA<I>
*         NEXT I
*         VAR.BLOQ  =  AUX_VAR
*         IF VAR.VAR.TOT.LOCK EQ '' THEN
*            VAR.BLOQ  = 0
*         END
        R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPONIBLE> =  0 ;*VAR.SALDO - VAR.BLOQ
        VAR.DISPO.GARA = R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPO.GARA>         ;*Set Avalaible instrument
        R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPO.GARA> = VAR.SALDO    ;*VAR.SALDO - VAR.BLOQ    ;*Set the avaliable amount
*Para que el ingreso sea manual
*      R.NEW(COLL.EXECUTION.VALUE)= VAR.SALDO - VAR.BLOQ ;*set the excecution value
*      R.NEW(COLL.NOMINAL.VALUE) = VAR.SALDO - VAR.BLOQ
    END


*///FIX DEPOSITS///
    IF (VAR.TIPO EQ 152) THEN

*         VAR.TOT.LOCK = 0
*Get the prymary key customer
*         CALL F.READ(FN.AZ,VAR.CUENTA,R.AZ,F.AZ,"")
*Value of fix deposit
        VAR.VALOR    =  R.ACCOUNT<AC.LOCAL.REF,WPOS.AC.DIS>

*GET THE LOCKED VALUE
*         VAR.VAR.TOT.LOCK  =  R.ACCOUNT<AC.LOCKED.AMOUNT>
*         CADENA = CHANGE(VAR.VAR.TOT.LOCK, VM, FM)
*         L1= DCOUNT(CADENA,FM)
*         FOR I = 1 TO L1
*            AUX_VAR = CADENA<I>
*         NEXT I
*         VAR.TOT.LOCK =  AUX_VAR
*         IF VAR.VAR.TOT.LOCK EQ '' THEN
*            VAR.TOT.LOCK = 0
*         END

*SET THE AVALIABLE VALUE IN THE COLLATERAL
*         VAR.TOT.DISPO = VAR.VALOR - VAR.TOT.LOCK
        R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPONIBLE> = 0  ;*VAR.TOT.DISPO
*Set the avaliable collateral
*         VAR.DISPO.GARA = R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPO.GARA> ;*Set the avaliable of instrument
        R.NEW(COLL.LOCAL.REF)<1,WPOS.DISPO.GARA> = VAR.VALOR    ;*VAR.TOT.DISPO   ;*Set the avaliable garantia
*Para que el ingreso sea manual
*       R.NEW(COLL.EXECUTION.VALUE) =  VAR.TOT.DISPO ; *Set the value execution
*       R.NEW(COLL.NOMINAL.VALUE) = VAR.TOT.DISPO

*Verify the balances available
*       IF VAR.TOT.DISPO EQ 0 THEN
*         R.NEW(COLL.NOMINAL.VALUE) = 0
*         ETEXT = 'ST-BLOQUEO'
*         CALL STORE.END.ERROR
*       END
    END

RETURN
*----------------------------------------------------------------------------


INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

    FN.ACCOUNT   = 'F.ACCOUNT'
    F.ACCOUNT    = ''
    R.ACCOUNT    = ''

    FN.LOCK1      = 'F.AC.LOCKED.EVENTS'
    F.LOCK1       = ''
    R.LOCK1       = ''

    FN.AZ        = 'F.AZ.ACCOUNT'
    F.AZ         = ''
    R.AZ         = ''

    FN.LOCKS     = 'F.AC.LOCKED.EVENTS'
    F.LOCKS      = ''
    R.LOCKS      = ''

*Read the local fields
    WCAMPO    = "L.COL.VAL.AVA"
    WCAMPO<2> = "L.AVA.AMO.INS"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    WCAMPO := @FM:"L.AC.AV.BAL"
    YPOS=0
    Y.APPLICATION = "COLLATERAL":@FM:"ACCOUNT"
*Get the position for all fields
    CALL MULTI.GET.LOC.REF(Y.APPLICATION,WCAMPO,YPOS)
    WPOS.DISPONIBLE  = YPOS<1,1>
    WPOS.DISPO.GARA  = YPOS<1,2>
    WPOS.AC.DIS      = YPOS<2,1>

RETURN

*------------------------
OPEN.FILES:
*=========
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.LOCK1,F.LOCK1)
    CALL OPF(FN.AZ,F.AZ)
    CALL OPF(FN.LOCKS,F.LOCKS)

RETURN
*------------
END
