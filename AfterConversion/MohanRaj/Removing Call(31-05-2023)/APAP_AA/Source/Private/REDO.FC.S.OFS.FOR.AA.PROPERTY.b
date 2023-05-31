* @ValidationCode : MjotMTE4OTE3MjYxNzpDcDEyNTI6MTY4MDE4NDY3NDQyMjpJVFNTOi0xOi0xOi03MzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:54
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -73
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.FC.S.OFS.FOR.AA.PROPERTY(ID.APP.MAPPING, Y.PROPERTY, NO.POS, OFS.STR)

*
* Subroutine Type : ROUTINE
* Attached to     : ROUTINE REDO.CREATE.ARRANGEMENT.AUTHORISE
* Attached as     : ROUTINE
* Primary Purpose : Build OFS for AA
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
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : Juan Pablo Armas - TAM Latin America
* Date            : 02 Julio 2011
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1, I TO I.VAR
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION           NO CHANGE

*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.APP.MAPPING

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS.MAIN
    END

RETURN          ;* Program RETURN
*-----------------------------------------------------------------------------------
PROCESS.MAIN:
*=============

    CALL CACHE.READ(FN.REDO.APP.MAPPING, Y.IDAPP, R.REDO.APP.MAPPING, YERR)
    Y.APLICACION.FROM = R.REDO.APP.MAPPING<REDO.APP.APP.FROM>
    Y.APLICACION.TO = R.REDO.APP.MAPPING<REDO.APP.APP.TO>
    NRO.FIELDS = DCOUNT(R.REDO.APP.MAPPING<REDO.APP.FIELD.FROM>,@VM)

    GOSUB SET.OFS.HEADER
    I.VAR = 1

    FOR II =1 TO NRO.FIELDS
        YFIELDFROM = R.REDO.APP.MAPPING<REDO.APP.FIELD.FROM,II>
        YFIELDTO =  R.REDO.APP.MAPPING<REDO.APP.FIELD.TO,II>
        IF YFIELDFROM NE "ID.LIMIT"  THEN
            GOSUB SET.YFIELDFROM
            IF YFIELDFROM THEN
                GOSUB SET.OFS.BODY
                I.VAR += 1
            END
        END
    NEXT
    IF OFS.STR.BODY THEN
        OFS.STR = OFS.STR.HEAD:OFS.STR.BODY
    END

RETURN

*------------------------
SET.YFIELDFROM:
*================
    YOP = FIELD(YFIELDFROM,"*",1)

    BEGIN CASE
        CASE YOP EQ "VAR"
            YREST = FIELD(YFIELDFROM,"*",2)
            IF YREST EQ "ARRANGEMENT.ID" THEN
                CALL AA.GET.ARRANGEMENT.ID(ARRANGEMENT.ID)
                YFIELDFROM = ARRANGEMENT.ID
            END
        CASE YOP EQ "STR"
            YREST = FIELD(YFIELDFROM,"*",2)
            YFIELDFROM = YREST
        CASE YOP EQ "FLD.1"
            YREST = FIELD(YFIELDFROM,"*",2)
            YFIELDFROM = YREST
            GOSUB GETPOSVALFLD
            YREST = R.NEW(Y.FIELD.NO)
            Y.LIM.REF = FIELD(YREST,".",1)
            YFIELDFROM = Y.LIM.REF
        CASE YOP EQ "FLD.2"
            YREST = FIELD(YFIELDFROM,"*",2)
            YFIELDFROM = YREST
            GOSUB GETPOSVALFLD
            YREST = R.NEW(Y.FIELD.NO)
            Y.LIM.REF = FIELD(YREST,".",2)
            YFIELDFROM = Y.LIM.REF
        CASE 1
            GOSUB SET.VALUE.FLD
    END CASE

RETURN
*------------------
SET.VALUE.FLD:
*===============


    Y.LOCAL.F = SUBSTRINGS(YFIELDFROM,1,2)

    IF Y.LOCAL.F EQ 'L.' THEN

        LOC.REF.APPLICATION = Y.APLICACION.FROM
        LOC.REF.FIELDS      = YFIELDFROM
        LOC.REF.POS = ''
        Y.LOCAL.REF = "LOCAL.REF"
        CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

        Y.FIELD.FROM = LOC.REF.POS<1,1>

        CALL EB.GET.APPL.FIELD(Y.APLICACION.FROM,Y.LOCAL.REF,'',Y.APP.ERR)
        Y.ORIG.VALUE = R.NEW(Y.LOCAL.REF)<1,Y.FIELD.FROM>
        YFIELDFROM = Y.ORIG.VALUE
    END ELSE
        GOSUB GETPOSVALFLD
        Y.ORIG.VALUE = R.NEW(Y.FIELD.NO)
        IF  INDEX(YFIELDFROM, "DESC", 1) GT 0 THEN
            GOSUB REMOVE.MARKS
        END

        YFIELDFROM = Y.ORIG.VALUE

    END
RETURN
*----------------------
GETPOSVALFLD:
*===============
*Campos de la aplicacion
    Y.FIELD.NO = YFIELDFROM
    CALL EB.FIND.FIELD.NO(Y.APLICACION.FROM, Y.FIELD.NO)
RETURN
*------------------------
SET.OFS.HEADER:
*=============
    OFS.STR.HEAD  = ",PROPERTY:":NO.POS:":1=":Y.PROPERTY
RETURN
*------------------------
SET.OFS.BODY:
*=============

    IF  INDEX(YFIELDFROM, @VM, 1) GT 0 THEN
        GOSUB MV.VALUES
    END ELSE
        OFS.STR.BODY := ",FIELD.NAME"
        OFS.STR.BODY := ":":NO.POS:":":I.VAR:"="
        OFS.STR.BODY := YFIELDTO
        OFS.STR.BODY := ",FIELD.VALUE"
        OFS.STR.BODY := ":":NO.POS:":":I.VAR:"="
        OFS.STR.BODY := YFIELDFROM
    END
RETURN

*------------------------
INITIALISE:
*=========

    FN.REDO.APP.MAPPING = 'F.REDO.APP.MAPPING'
    R.REDO.APP.MAPPING  = ''

    Y.IDAPP = ID.APP.MAPPING
    OFS.STR.BODY  = ""
    OFS.STR = ""
    YERR = ''
    PROCESS.GOAHEAD = 1
RETURN

*------------------------

MV.VALUES:
*=========

    NRO.FIELDS.MV = DCOUNT(YFIELDFROM,@VM)
    NO.POS.TEMP = NO.POS
    Y.MV.TEMP = I.VAR
    FOR Y.MV  =  1 TO NRO.FIELDS.MV
        YFIELDFROM.TEMP = YFIELDFROM<1,Y.MV>
        OFS.STR.BODY := ",FIELD.NAME"
        OFS.STR.BODY := ":":NO.POS:":":Y.MV.TEMP:"="
        OFS.STR.BODY := YFIELDTO:":":Y.MV:":":1
        OFS.STR.BODY := ",FIELD.VALUE"
        OFS.STR.BODY := ":":NO.POS:":":Y.MV.TEMP:"="
        OFS.STR.BODY := YFIELDFROM.TEMP
        Y.MV.TEMP += 1

    NEXT Y.MV
    I.VAR = Y.MV.TEMP - 1
RETURN
*------------

REMOVE.MARKS:
*=========

    CHANGE @SM TO ' ' IN Y.ORIG.VALUE
    CHANGE @VM TO ' ' IN Y.ORIG.VALUE

    Y.ORIG.VALUE = SUBSTRINGS(Y.ORIG.VALUE,1, 65)

RETURN
*------------

OPEN.FILES:
*=========

RETURN
*------------
END
