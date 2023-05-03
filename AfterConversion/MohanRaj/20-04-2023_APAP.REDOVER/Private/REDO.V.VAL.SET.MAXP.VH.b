* @ValidationCode : MjotNDEwMDAwNjQwOkNwMTI1MjoxNjgxOTc0ODEyOTcxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:43:32
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
SUBROUTINE REDO.V.VAL.SET.MAXP.VH
*
* ===================================================================================
*
* - Set information for "MAXIMO A PRESTAR" according with " % MAXIMO A PRESTAR "
*
*
* ===================================================================================
*
* Subroutine Type :
* Attached to     :
* Attached as     :
* Primary Purpose : Set computed values for collateral VH
*
* Incoming:
* ---------
*
* Outgoing:
*
* ---------
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : APAP
* Development by  : Pablo Castillo De La Rosa RTam
* Date            : 08/FEB/2012
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COLLATERAL
    $INSERT I_GTS.COMMON
*
*************************************************************************

    GOSUB INITIALISE

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

* =========
PROCESS:
* =========
*EXCECUTE ONLY IF PRESS HOT FIELD
    VAR.HOT = OFS$HOT.FIELD
    IF LEN(VAR.HOT) EQ 0 THEN
        RETURN
    END
*
    IF VAR.PORC GT 0 THEN
        VAR.MAXIMO = (Y.NOMINAL.VALUE * VAR.PORC)/100
        VAR.MAXIMO = DROUND(VAR.MAXIMO,2)
        R.NEW(COLL.LOCAL.REF)<1,WPOSMAX> = VAR.MAXIMO
    END
*
RETURN

* =========
INITIALISE:
* =========

    PROCESS.GOAHEAD = 1

    WCAMPO = "L.COL.LN.MX.PER"
    WCAMPO<2> = "L.COL.LN.MX.VAL"

    WCAMPO = CHANGE(WCAMPO,@FM,@VM)
    YPOS=0
    CALL MULTI.GET.LOC.REF("COLLATERAL",WCAMPO,YPOS)
    WPOSPORC   = YPOS<1,1>
    WPOSMAX    = YPOS<1,2>

    VAR.MAXIMO = ''
    Y.NOMINAL.VALUE = R.NEW(COLL.NOMINAL.VALUE)
    VAR.PORC = COMI

RETURN

END
