* @ValidationCode : MjotMTA4MDk4ODM4ODpDcDEyNTI6MTY4MTg4NDY3NDAwNDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 11:41:14
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
SUBROUTINE REDO.V.VAL.CALCTOT.DI
*
* Subroutine Type : ROUTINE
* Attached to     : REDO.V.VAL.CALCTOT.DI
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
*
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : mgudino- TAM Latin America
* Date            :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_GTS.COMMON

    GOSUB INITIALISE

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN  ;* Program RETURN
*------------------------------------------------------------------------------
*
PROCESS:
*======
*
*UPDATE THE AMOUNTS WHEN NOMINAL VALIE IS CHANGED

    VAR.HOT = OFS$HOT.FIELD

    IF LEN(VAR.HOT) EQ 0 THEN
        R.NEW(COLL.GEN.LEDGER.VALUE) =  R.NEW(COLL.NOMINAL.VALUE)
        R.NEW(COLL.EXECUTION.VALUE) = R.NEW(COLL.NOMINAL.VALUE)
        R.NEW(COLL.CENTRAL.BANK.VALUE) = R.NEW(COLL.NOMINAL.VALUE)
    END ELSE
        R.NEW(COLL.GEN.LEDGER.VALUE) = COMI
        R.NEW(COLL.CENTRAL.BANK.VALUE) = COMI
        R.NEW(COLL.EXECUTION.VALUE)= COMI
        GOSUB EVA.MAX.VALUE       ;* PACS00255616 - S/E
    END

RETURN
*------------------------------------------------------------------------
*
EVA.MAX.VALUE:
*=============
*
    IF Y.COL.LN.INSA GE Y.COL.EXE.VAL THEN
        R.NEW(COLL.MAXIMUM.VALUE) = Y.COL.EXE.VAL
    END
*
RETURN
*
INITIALISE:
*=========
*
    PROCESS.GOAHEAD = 1
* PACS00255616 - S
*Valor Maximo a Prestar
    WCAMPO     = "L.COL.LN.MX.VAL":@VM:"L.AVA.AMO.INS"         ;* PACS00307565 - S/E
    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0
*
*Get the position for all fields
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOSMAXV  = YPOS<1,1>
    WPOSMINS  = YPOS<1,2>       ;* PACS00307565 - S/E
*
    Y.COL.LN.MXVA = ''
    Y.COL.LN.INSA = ''
    Y.COL.LN.MXVA = R.NEW(COLL.LOCAL.REF)<1,WPOSMAXV>
* PACS00307565 - S
    Y.COL.LN.INSA = R.NEW(COLL.LOCAL.REF)<1,WPOSMINS>
    Y.COL.EXE.VAL = COMI
* PACS00307565 - E
* PACS00255616 - E
RETURN
*
END
