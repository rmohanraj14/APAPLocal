* @ValidationCode : MjotMTM2MTAwOTM1OTpDcDEyNTI6MTY4MTk3NDU2Njk4ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:39:26
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
SUBROUTINE REDO.V.VAL.SET.DETA

*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.VALUES
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
* Date            : INTEGRATE THE CALC VALUES
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     > TO GT,VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======

* GET THE INFORMATION FOR SET THE STRINGS
    VAR.MATRICULA = R.NEW(COLL.LOCAL.REF)<1,WPOSMATRICULA>
    VAR.PARCELA   = R.NEW(COLL.LOCAL.REF)<1,WPOSPARCELA>
    VAR.SOLAR     = R.NEW(COLL.LOCAL.REF)<1,WPOSSOLAR>
    VAR.MANZANA   = R.NEW(COLL.LOCAL.REF)<1,WPOSMAZANA>
    VAR.DISTRITO  = R.NEW(COLL.LOCAL.REF)<1,WPOSDISTRITO>
    VAR.PROVINCIA = R.NEW(COLL.LOCAL.REF)<1,WPOSPROVINCIA>
    VAR.CIUDAD    = R.NEW(COLL.LOCAL.REF)<1,WPOSCIUDAD>
    VAR.SECTOR    = R.NEW(COLL.LOCAL.REF)<1,WPOSSECTOR>
    VAR.COUNTRY   = R.NEW(COLL.COUNTRY)

*SET THE FIRTS STRING
    VAR.CONCATENA = VAR.MATRICULA : " " :VAR.PARCELA : " " : VAR.SOLAR : " " : VAR.MANZANA : " ": VAR.DISTRITO : " " : VAR.COUNTRY : " ": VAR.PROVINCIA : " " : VAR.CIUDAD : " " :VAR.SECTOR

*GET THE NUMBER OF ROWS THAT GENERATE
    VAR.CONTADOR = LEN(VAR.CONCATENA)
    VAR.DIFE = VAR.CONTADOR / 50
    VAR.FILAS  = INT(VAR.DIFE)  + 1

    VAR.POS = 0
    FOR VAR.I = 1 TO VAR.FILAS
        VAR.SUBCA = SUBSTRINGS(VAR.CONCATENA, VAR.POS + 1, VAR.POS + 50)
        IF LEN(VAR.SUBCA) GT 0 THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOSDESCRIP2,VAR.I> = VAR.SUBCA
            VAR.POS += 50 ;*R22 Auto code conversion
        END
    NEXT

* DEBUG

    VAR.J = VAR.FILAS

*CONCATENA THE ROWS FOR DIRECCION
*VAR.SUBCA
    VAR.DIRECCION =  R.NEW(COLL.ADDRESS)

    VAR.FILAS    = DCOUNT(VAR.DIRECCION,@VM)
    VAR.REGDIRE  = CHANGE(VAR.DIRECCION,@VM,@FM)

    VAR.CONCATENA = ''
    FOR VAR.I = 1 TO VAR.FILAS

        VAR.CADENA = VAR.REGDIRE<VAR.I>
        VAR.CONCATENA = VAR.CONCATENA : " " : VAR.CADENA
    NEXT

*CONCATENA THE LAST ROW AND DIRECTION AND SET THE NEW DATA
    VAR.CONCATENA = VAR.SUBCA :" " : VAR.CONCATENA
    VAR.POS = 0

    VAR.CONTADOR = LEN(VAR.CONCATENA)
    VAR.DIFE = VAR.CONTADOR / 50
    VAR.FILAS  = INT(VAR.DIFE)  + 1

    FOR VAR.I = VAR.J  TO VAR.J + VAR.FILAS
        VAR.SUBCA = SUBSTRINGS(VAR.CONCATENA, VAR.POS + 1, VAR.POS + 50)
        IF LEN(VAR.SUBCA) GT 0 THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOSDESCRIP2,VAR.I> = VAR.SUBCA
            VAR.POS += 50 ;*R22 Auto code conversion
        END
    NEXT

RETURN
*----------------------------------------------------------------------------

INITIALISE:
*=========
    PROCESS.GOAHEAD = 1
*Set the local fild for read

    WCAMPO    = "L.COL.SEC.IDEN"
    WCAMPO<2> = "L.COL.DESG.NO"
    WCAMPO<3> = "L.COL.SOLAR.NO"
    WCAMPO<4> = "L.COL.BLOCK.NO"
    WCAMPO<5> = "L.COL.CAD.DIST"
    WCAMPO<6> = "L.COL.PROVINCES"
    WCAMPO<7> = "L.COL.CITY"
    WCAMPO<8> = "L.COL.SECTOR"
    WCAMPO<9> = "L.COL.PRO.DESC2"


    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSMATRICULA  = YPOS<1,1>
    WPOSPARCELA    = YPOS<1,2>
    WPOSSOLAR      = YPOS<1,3>
    WPOSMAZANA     = YPOS<1,4>
    WPOSDISTRITO   = YPOS<1,5>
    WPOSPROVINCIA  = YPOS<1,6>
    WPOSCIUDAD     = YPOS<1,7>
    WPOSSECTOR     = YPOS<1,8>
    WPOSDESCRIP2   = YPOS<1,9>

RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------
END
