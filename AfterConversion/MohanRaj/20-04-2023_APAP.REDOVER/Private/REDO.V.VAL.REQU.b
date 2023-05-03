* @ValidationCode : MjotMTA1OTcyODYzOkNwMTI1MjoxNjgxOTc0MjU2NDg2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:34:16
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
SUBROUTINE REDO.V.VAL.REQU
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.REQU
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
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------



    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL

    GOSUB INITIALISE
    GOSUB OPEN.FILES

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END


RETURN  ;* Program RETURN
*------------------------------------------------------------------------------

PROCESS:
*======

*Get the values for the local fields (ENCUMBRANSE VALUE)
    VAR.VAL = R.NEW(COLL.LOCAL.REF)<1,WPOSENCVAL>

* CHECK IF THE GRAVAMEN VALUE IS SET THEN VERIFY THAT OTHERS FIELS WAS CREATED
    IF LEN(VAR.VAL) GT 0 THEN

        VAR.NUMBER = R.NEW(COLL.LOCAL.REF)<1,WPOSENCNUM>

        IF LEN(VAR.NUMBER) EQ 0 THEN
            AF = COLL.LOCAL.REF
            AV = YPOS<1,2>
            ETEXT = 'ST-ENC.NUMBER'
            CALL STORE.END.ERROR
        END

        VAR.ACRE = R.NEW(COLL.LOCAL.REF)<1,WPOSMORCRE>

        IF LEN(VAR.ACRE) EQ 0 THEN
            AF = COLL.LOCAL.REF
            AV = YPOS<1,3>
            ETEXT = 'ST-NA.MOR.CRE'
            CALL STORE.END.ERROR
        END

    END


RETURN
*------------------------------------------------------------------------

INITIALISE:
*=========

    PROCESS.GOAHEAD = 1
*Set the local fild for read
    WCAMPO     = "L.COL.ENCUM.VAL"
    WCAMPO<2>  = "L.ECN.NUMBER"
    WCAMPO<3>  = "L.NA.MOR.CRE"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSENCVAL  = YPOS<1,1>
    WPOSENCNUM  = YPOS<1,2>
    WPOSMORCRE  = YPOS<1,3>

RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------
END
