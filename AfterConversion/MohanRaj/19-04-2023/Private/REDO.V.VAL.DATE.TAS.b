* @ValidationCode : MjoxMjUyMzEyNDY6Q3AxMjUyOjE2ODE4ODg4ODY1NjU6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:51:26
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
SUBROUTINE REDO.V.VAL.DATE.TAS
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.DATE
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
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
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

    Y.ACTUAL = TODAY

*Get the values for the local fields (Granting Date)
    Y.FEC2 = R.NEW(COLL.LOCAL.REF)<1,WPOSVADA>

* CHECK THE DATE THAT NOT GREAT THAN THE ACTUAL DATE
    IF Y.FEC2 GT Y.ACTUAL THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,1>
        ETEXT = 'ST-REDO.COLLA.VALI.DATE'
        CALL STORE.END.ERROR
    END

    Y.FECHA.TAS.OLD = R.NEW(COLL.LOCAL.REF)<1,WPOSVADA>       ;* Verifica si el campo fecha de tasacion cambio de valor
    IF Y.FEC2 LT R.NEW(COLL.VALUE.DATE) AND PGM.VERSION MATCHES '...REDO.MODIFICA...' AND Y.FECHA.TAS.OLD NE Y.FEC2 THEN
        AF = COLL.LOCAL.REF
        AV = YPOS<1,1>
        ETEXT = 'ST-NO.ING'
        CALL STORE.END.ERROR
    END



RETURN
*------------------------------------------------------------------------

INITIALISE:
*=========

    PROCESS.GOAHEAD = 1
*Set the local fild for read
    WCAMPO     = "L.COL.VAL.DATE"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0

*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)

    WPOSVADA  = YPOS<1,1>
    Y.FECHA.TAS.OLD = ''
RETURN

*------------------------
OPEN.FILES:
*=========

RETURN
*------------
END
