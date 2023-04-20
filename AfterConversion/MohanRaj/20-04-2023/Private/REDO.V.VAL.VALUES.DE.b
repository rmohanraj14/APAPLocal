* @ValidationCode : MjoyMDg2NDEzOTc5OkNwMTI1MjoxNjgxOTc4MzA2MzM1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 13:41:46
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
SUBROUTINE REDO.V.VAL.VALUES.DE

*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.VALUES.DE
* Attached as     : ROUTINE
* Primary Purpose : INTEGRATE THE CALC VALUES
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
* Date            : 10/10/2011
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
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
    CALL APAP.REDO.VER.REDO.V.VAL.NOMINAL.VALUE ;* R22 Manual Conversion - CALL method format modified
    CALL APAP.REDO.VER.REDO.V.VAL.MAXIMUM.VALUE ;* R22 Manual Conversion - CALL method format modified
    CALL REDO.V.VAL.REA.COLLATERAL
    GOSUB DROUND.VALUES
RETURN

*----------------------------------------------------------------------------

INITIALISE:
*=========
    PROCESS.GOAHEAD = 1

*Set the local fild for read
    WCAMPO     = "L.COL.LAND.VAL":@VM:"L.COL.LN.MX.VAL":@VM:"L.COL.VAL.AVA":@VM:"L.AVA.AMO.INS"
    WCAMPO    := @VM:"L.COL.LAND.AREA":@VM:"L.COL.TO.LND.VA":@VM:"L.COL.BLD.AREA":@VM:"L.COL.BLD.VALUE"
    WCAMPO    := @VM:"L.COL.TOT.BD.AR":@VM:"L.COL.DEP.VALUE":@VM:"L.COL.TOT.VALUA":@VM:"L.COL.ENCUM.VAL"
    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSVALOR  = YPOS<1,1>
    LN.MX.VAL.POS = YPOS<1,2>
    AVAIL.AMT.POS = YPOS<1,3>
    AVA.AMT.INS.POS = YPOS<1,4>
    LAND.AREA.POS = YPOS<1,5>
    TOT.LND.VAL.POS =  YPOS<1,6>
    BLD.AREA.POS = YPOS<1,7>
    BLD.VALUE.POS = YPOS<1,8>
    TOT.BLD.VAL.POS = YPOS<1,9>
    DEP.BLD.VAL.POS = YPOS<1,10>
    TOT.AVALUA.POS = YPOS<1,11>
    ENCUM.VAL.POS =YPOS<1,12>


RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------

*================
DROUND.VALUES:
*================
******LEER CAMPO LOCAL
*Get the values from the local fields
    Y.VALOR = R.NEW(COLL.LOCAL.REF)<1,WPOSVALOR>
    LN.MX.VAL  = R.NEW(COLL.LOCAL.REF)<1,LN.MX.VAL.POS>
    AVAIL.AMT  = R.NEW(COLL.LOCAL.REF)<1,AVAIL.AMT.POS>
    AVA.AMT.INS  = R.NEW(COLL.LOCAL.REF)<1,AVA.AMT.INS.POS>

    LAND.AREA  = R.NEW(COLL.LOCAL.REF)<1,LAND.AREA.POS>
    TOT.LND.VAL  = R.NEW(COLL.LOCAL.REF)<1,TOT.LND.VAL.POS>

    BLD.AREA  = R.NEW(COLL.LOCAL.REF)<1,BLD.AREA.POS>
    BLD.VALUE  = R.NEW(COLL.LOCAL.REF)<1,BLD.VALUE.POS>
    TOT.BLD.VAL = R.NEW(COLL.LOCAL.REF)<1,TOT.BLD.VAL.POS>

    DEP.BLD.VAL = R.NEW(COLL.LOCAL.REF)<1,DEP.BLD.VAL.POS>
    TOT.AVALUA = R.NEW(COLL.LOCAL.REF)<1,TOT.AVALUA.POS>
    ENCUM.VAL = R.NEW(COLL.LOCAL.REF)<1,ENCUM.VAL.POS>
    VALOR.NOMINAL = R.NEW(COLL.NOMINAL.VALUE)
    VALOR.EJECUCION = R.NEW(COLL.EXECUTION.VALUE)
    VALOR.LIBRO.MAYOR = R.NEW(COLL.GEN.LEDGER.VALUE)
    VALOR.BCO.CENTRAL = R.NEW(COLL.CENTRAL.BANK.VALUE)
    IF Y.VALOR THEN
        Y.VALOR = DROUND(Y.VALOR,2)
        R.NEW(COLL.LOCAL.REF)<1,WPOSVALOR> = Y.VALOR
    END
    IF LN.MX.VAL THEN
        LN.MX.VAL = DROUND(LN.MX.VAL,2)
        R.NEW(COLL.LOCAL.REF)<1,LN.MX.VAL.POS> = LN.MX.VAL
    END

    IF AVAIL.AMT THEN
        AVAIL.AMT = DROUND(AVAIL.AMT,2)
        R.NEW(COLL.LOCAL.REF)<1,AVAIL.AMT.POS> = AVAIL.AMT
    END
    IF AVA.AMT.INS THEN
        AVA.AMT.INS = DROUND(AVA.AMT.INS,2)
        R.NEW(COLL.LOCAL.REF)<1,AVA.AMT.INS.POS> =  AVA.AMT.INS
    END

    IF LAND.AREA THEN
        LAND.AREA = DROUND(LAND.AREA,2)
        R.NEW(COLL.LOCAL.REF)<1,LAND.AREA.POS> =  LAND.AREA
    END

    IF TOT.LND.VAL THEN
        TOT.LND.VAL = DROUND(TOT.LND.VAL,2)
        R.NEW(COLL.LOCAL.REF)<1,TOT.LND.VAL.POS> =  TOT.LND.VAL
    END

    IF BLD.VALUE THEN
        BLD.VALUE = DROUND(BLD.VALUE,2)
        R.NEW(COLL.LOCAL.REF)<1,BLD.VALUE.POS> =  BLD.VALUE
    END

    IF BLD.AREA THEN
        BLD.AREA = DROUND(BLD.AREA,2)
        R.NEW(COLL.LOCAL.REF)<1,BLD.AREA.POS> =  BLD.AREA
    END

    IF TOT.BLD.VAL THEN
        TOT.BLD.VAL = DROUND(TOT.BLD.VAL,2)
        R.NEW(COLL.LOCAL.REF)<1,TOT.BLD.VAL.POS> =  TOT.BLD.VAL
    END

    IF DEP.BLD.VAL THEN
        DEP.BLD.VAL = DROUND(DEP.BLD.VAL,2)
        R.NEW(COLL.LOCAL.REF)<1,DEP.BLD.VAL.POS> =  DEP.BLD.VAL
    END
    IF TOT.AVALUA THEN
        TOT.AVALUA = DROUND(TOT.AVALUA,2)
        R.NEW(COLL.LOCAL.REF)<1,TOT.AVALUA.POS> =  TOT.AVALUA
    END

    IF ENCUM.VAL THEN
        ENCUM.VAL = DROUND(ENCUM.VAL,2)
        R.NEW(COLL.LOCAL.REF)<1,ENCUM.VAL.POS> =  ENCUM.VAL
    END

    IF VALOR.NOMINAL THEN
        VALOR.NOMINAL = DROUND(VALOR.NOMINAL,2)
        R.NEW(COLL.NOMINAL.VALUE) =  VALOR.NOMINAL
    END


    IF VALOR.EJECUCION THEN
        VALOR.EJECUCION = DROUND(VALOR.EJECUCION,2)
        R.NEW(COLL.EXECUTION.VALUE) =  VALOR.EJECUCION
    END

    IF VALOR.LIBRO.MAYOR THEN
        VALOR.LIBRO.MAYOR = DROUND(VALOR.LIBRO.MAYOR,2)
        R.NEW(COLL.GEN.LEDGER.VALUE) =  VALOR.LIBRO.MAYOR
    END

    IF VALOR.BCO.CENTRAL THEN
        VALOR.BCO.CENTRAL = DROUND(VALOR.BCO.CENTRAL,2)
        R.NEW(COLL.CENTRAL.BANK.VALUE) =  VALOR.BCO.CENTRAL
    END

RETURN
END
