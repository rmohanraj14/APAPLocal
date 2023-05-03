* @ValidationCode : MjotMTMxOTg2MDA3OkNwMTI1MjoxNjgxODE5ODYyOTc3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 17:41:02
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.VAL.CALCTOT
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.CALCTOT
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
*------------------------------------------------------------------------------

* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Pablo Castillo De La Rosa - TAM Latin America
* Date            :
*
*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_GTS.COMMON

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*------------------------------------------------------------------------------

PROCESS:
*======
*Get the values for the local fields and set the fields
    VAR1 = R.NEW(COLL.LOCAL.REF)<1,WPOSBLDA>
    VAR2 = R.NEW(COLL.LOCAL.REF)<1,WPOSBLDV>
    R.NEW(COLL.LOCAL.REF)<1,WPOTOTCO> = VAR1 * VAR2

*Get the values for the local fields and set the fields

    VAR4 = R.NEW(COLL.LOCAL.REF)<1,WPOLANVA>
    VAR.HOT = OFS$HOT.FIELD
    IF LEN(VAR.HOT) EQ 0 THEN
        VAR3 = R.NEW(COLL.LOCAL.REF)<1,WPOLANAR>
    END
    ELSE
        VAR3 = COMI
    END
    Y.TEST =  VAR3 * VAR4
    R.NEW(COLL.LOCAL.REF)<1,WPOTOTLA> = Y.TEST      ;*VAR3 * VAR4

*Calculate  the value of depreciation
    VAR.POR.DEP  = R.NEW(COLL.LOCAL.REF)<1,WPOPORDE>
    VAR.TOT.CON  = VAR1 * VAR2
    VAR.ANI.CON  = R.NEW(COLL.LOCAL.REF)<1,WPOYEABU>
    VAR.VAL.DEP  = ((VAR.POR.DEP)/100) * VAR.TOT.CON * VAR.ANI.CON
    R.NEW(COLL.LOCAL.REF)<1,WPOVALDE> = VAR.VAL.DEP

*Calculate the total value
    VAR.TOT.LAN = (VAR3 * VAR4)
    VAR.VAL.TOT = VAR.TOT.LAN + VAR.TOT.CON - VAR.VAL.DEP
    Y.VAL.TOT = R.NEW(COLL.LOCAL.REF)<1,WPOSTOTV>   ;*VALOR TOTAL TASACION PREVIO
    R.NEW(COLL.LOCAL.REF)<1,WPOSTOTV> =  VAR.VAL.TOT

*Set the value Valor Nominal De La Garantia
    R.NEW(COLL.NOMINAL.VALUE) = VAR.VAL.TOT
    Y.UPDATE.EX.VAL= ''
*JV 20-MAR-2013
    IF Y.VAL.TOT NE VAR.VAL.TOT THEN
        Y.UPDATE.EX.VAL = 1
    END
***JV 20-MAR-2013
*VALUES FOR LIBRO MAYOR
    R.NEW(COLL.GEN.LEDGER.VALUE) = R.NEW(COLL.NOMINAL.VALUE)


*SET THE MAXIMUN VALUE WHIT THE TOTAL VALUES
*R.NEW(COLL.MAXIMUM.VALUE)= R.NEW(COLL.NOMINAL.VALUE)
    R.NEW(COLL.MAXIMUM.VALUE) = ""        ;* if this is 0 or blank Allow to input Execution value grather than Nominal value other wise this show core validation

*VALOR DE EJECUCION = AL NOMINAL VALUE
    IF (R.NEW(COLL.EXECUTION.VALUE) EQ 0 OR NOT(R.NEW(COLL.EXECUTION.VALUE))OR Y.UPDATE.EX.VAL ) AND PGM.VERSION MATCHES '...,REDO.INGRESO...'  THEN
        R.NEW(COLL.EXECUTION.VALUE)= R.NEW(COLL.NOMINAL.VALUE)
    END

    IF (R.NEW(COLL.EXECUTION.VALUE) EQ 0 OR NOT(R.NEW(COLL.EXECUTION.VALUE)) ) AND PGM.VERSION MATCHES '...,REDO.MODIFICA.DI...'  THEN
        R.NEW(COLL.EXECUTION.VALUE)= R.NEW(COLL.NOMINAL.VALUE)
    END

*VALOR DE EJECUCION = AL NOMINAL VALUE
* 07/03/2013 - MGUDINO


    IF PGM.VERSION MATCHES '...,REDO.MODIFICA.BR...' THEN

        IF(R.NEW(COLL.NOMINAL.VALUE) NE R.OLD(COLL.NOMINAL.VALUE)) THEN
            R.NEW(COLL.EXECUTION.VALUE)= R.NEW(COLL.NOMINAL.VALUE)
        END
    END


RETURN
*------------------------------------------------------------------------

INITIALISE:
*=========

    PROCESS.GOAHEAD = 1
*Set the local fild for read
    WCAMPO     = "L.COL.BLD.AREA"
    WCAMPO<2>  = "L.COL.BLD.VALUE"
    WCAMPO<3>  = "L.COL.LAND.VAL"
    WCAMPO<4>  = "L.COL.LAND.AREA"
    WCAMPO<5>  = "L.COL.TOT.BD.AR"
    WCAMPO<6>  = "L.COL.TO.LND.VA"
    WCAMPO<7>  = "L.COL.TOTAL.DEP"
    WCAMPO<8>  = "L.COL.YR.BLDING"
    WCAMPO<9>  = "L.COL.DEP.VALUE"
    WCAMPO<10> = "L.COL.TOT.VALUA"
    WCAMPO<11> = "L.COL.LN.MX.VAL"


    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSBLDA  = YPOS<1,1>
    WPOSBLDV  = YPOS<1,2>
    WPOLANAR  = YPOS<1,3>
    WPOLANVA  = YPOS<1,4>
    WPOTOTCO  = YPOS<1,5>
    WPOTOTLA  = YPOS<1,6>
    WPOPORDE  = YPOS<1,7>
    WPOYEABU  = YPOS<1,8>
    WPOVALDE  = YPOS<1,9>
    WPOSTOTV  = YPOS<1,10>
    WPOSMXVA  = YPOS<1,11>


RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------
END
