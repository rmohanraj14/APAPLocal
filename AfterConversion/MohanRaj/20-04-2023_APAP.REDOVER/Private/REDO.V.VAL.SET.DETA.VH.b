* @ValidationCode : Mjo1NjMyNTE5NTM6Q3AxMjUyOjE2ODE5OTIyMDk1NzQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2023 17:33:29
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
*-----------------------------------------------------------------------------
* <Rating>-60</Rating>
*-----------------------------------------------------------------------------
SUBROUTINE REDO.V.VAL.SET.DETA.VH

*
* Subroutine Type : ROUTINE
* Attached to     : COLLATERALS VH
* Attached as     : ROUTINE
* Primary Purpose : Copy information from various records from description row.
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
* Date            : 14/05/2012
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   /is removed,VM TO @VM,FM TO @FM
*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS         ;* PACS00306805 - S/E

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS:
*======
*
*SET THE FIRTS STRING
    VAR.CONCATENA = VAR.MATRICULA : " " :VAR.PARCELA : " " : VAR.SOLAR : " " : VAR.MANZANA : " ": VAR.DISTRITO : " " : VAR.TIPO : " ": VAR.PROVINCIA : " " : VAR.CIUDAD : " " :VAR.CONDICION

*GET THE NUMBER OF ROWS THAT GENERATE
    VAR.CONTADOR = LEN(VAR.CONCATENA)
    VAR.DIFE = VAR.CONTADOR / 50
    VAR.FILAS  = INT(VAR.DIFE)  + 1

    VAR.POS = 0
    FOR VAR.I = 1 TO VAR.FILAS
        VAR.SUBCA = SUBSTRINGS(VAR.CONCATENA, VAR.POS + 1, VAR.POS + 50)
        IF LEN(VAR.SUBCA) > 0 THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOSDESCRIP2,VAR.I> = VAR.SUBCA
            VAR.POS = VAR.POS + 50
        END
    NEXT



    VAR.J = VAR.FILAS

*CONCATENA THE ROWS FOR DIRECCION
*VAR.SUBCA
    VAR.DIRECCION =  R.NEW(COLL.ADDRESS)

    VAR.FILAS    = DCOUNT(VAR.DIRECCION,@VM) ;*R22 Manual code conversion
    VAR.REGDIRE  = CHANGE(VAR.DIRECCION,@VM,@FM) ;*R22 Manual code conversion

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
        IF LEN(VAR.SUBCA) > 0 THEN
            R.NEW(COLL.LOCAL.REF)<1,WPOSDESCRIP2,VAR.I> = VAR.SUBCA
            VAR.POS = VAR.POS + 50
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
    WCAMPO<8> = "L.COL.PRO.DESC2"
    WCAMPO<9> = "L.COL.SECTOR"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM) ;*R22 Manual code conversion
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
    WPOSDESCRIP2   = YPOS<1,8>
    WPOSCONDICION  = YPOS<1,9>
*
* GET THE INFORMATION FOR SET THE STRINGS
    VAR.MATRICULA = R.NEW(COLL.LOCAL.REF)<1,WPOSMATRICULA>
    VAR.PARCELA   = R.NEW(COLL.LOCAL.REF)<1,WPOSPARCELA>
    VAR.SOLAR     = R.NEW(COLL.LOCAL.REF)<1,WPOSSOLAR>
    VAR.MANZANA   = R.NEW(COLL.LOCAL.REF)<1,WPOSMAZANA>
    VAR.DISTRITO  = R.NEW(COLL.LOCAL.REF)<1,WPOSDISTRITO>
    VAR.PROVINCIA = R.NEW(COLL.LOCAL.REF)<1,WPOSPROVINCIA>
    VAR.CIUDAD    = R.NEW(COLL.LOCAL.REF)<1,WPOSCIUDAD>
    VAR.TIPO      = R.NEW(COLL.ADDRESS)
    VAR.CONDICION = R.NEW(COLL.LOCAL.REF)<1,WPOSCONDICION>
*
    Y.O.VAR.MATRICULA = R.OLD(COLL.LOCAL.REF)<1,WPOSMATRICULA>
    Y.O.VAR.PARCELA   = R.OLD(COLL.LOCAL.REF)<1,WPOSPARCELA>
    Y.O.VAR.SOLAR     = R.OLD(COLL.LOCAL.REF)<1,WPOSSOLAR>
    Y.O.VAR.MANZANA   = R.OLD(COLL.LOCAL.REF)<1,WPOSMAZANA>
    Y.O.VAR.DISTRITO  = R.OLD(COLL.LOCAL.REF)<1,WPOSDISTRITO>
    Y.O.VAR.PROVINCIA = R.OLD(COLL.LOCAL.REF)<1,WPOSPROVINCIA>
    Y.O.VAR.CIUDAD    = R.OLD(COLL.LOCAL.REF)<1,WPOSCIUDAD>
    Y.O.VAR.TIPO      = R.OLD(COLL.ADDRESS)
    Y.O.VAR.CONDICION = R.OLD(COLL.LOCAL.REF)<1,WPOSCONDICION>
*
RETURN
* ================
CONTROL.MSG.ERROR:
* ================
*

RETURN
*
*------------------------
OPEN.FILES:
*=========

RETURN
*------------
*
* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP.CNT  = 1   ;   MAX.LOOPS = 3
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
*
                IF  Y.O.VAR.MATRICULA EQ VAR.MATRICULA AND Y.O.VAR.PARCELA EQ VAR.PARCELA AND Y.O.VAR.SOLAR EQ VAR.SOLAR AND Y.O.VAR.MANZANA EQ VAR.MANZANA AND Y.O.VAR.DISTRITO EQ VAR.DISTRITO AND Y.O.VAR.PROVINCIA EQ VAR.PROVINCIA AND Y.O.VAR.CIUDAD EQ VAR.CIUDAD AND Y.O.VAR.TIPO EQ VAR.TIPO AND Y.O.VAR.CONDICION EQ VAR.CONDICION THEN ;*R22 Manual code conversion /is removed
                    PROCESS.GOAHEAD = ""
                END
*
            CASE LOOP.CNT EQ 2

            CASE LOOP.CNT EQ 3

        END CASE
*       Message Error
        GOSUB CONTROL.MSG.ERROR

*       Increase
        LOOP.CNT += 1
*
    REPEAT
*
RETURN
*
END
