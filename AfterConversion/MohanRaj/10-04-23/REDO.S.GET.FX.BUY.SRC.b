* @ValidationCode : MjoxNzAzMjExNDM5OkNwMTI1MjoxNjgxMTI4MzE0NjM2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 17:35:14
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.FX.BUY.SRC (BUY.SRC)
*
* ====================================================================================
*
*    - Gets the information related to the AA specified in input parameter
*
*    - Generates BULK OFS MESSAGES to apply payments to corresponding AA
*
* ====================================================================================
*
* Subroutine Type :
* Attached to     :
* Attached as     :
* Primary Purpose :
*
*
* Incoming:
* ---------
*
*
*
* Outgoing:

* ---------
*
*
*-----------------------------------------------------------------------------------
* Modification History:
*
* Development for : Asociacion Popular de Ahorros y Prestamos
* Development by  : pgarzongavilanes
* Date            : 2011-06-09
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*=======================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EB.LOOKUP
    $INSERT I_F.TELLER
    $INSERT I_F.USER
*
*************************************************************************
*


    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

*
RETURN
*
* ======
PROCESS:
* ======
    CALL F.READ(FN.EB.LOOKUP, Y.EB.LOOKUP.ID, R.EB.LOOKUP, F.EB.LOOKUP, Y.ERR.EB.LOOKUP)

    Y.LANG = R.USER<EB.USE.LANGUAGE>

    BUY.SRC = R.EB.LOOKUP<EB.LU.DESCRIPTION,Y.LANG>


RETURN
*
* =========
OPEN.FILES:
* =========
*
    CALL OPF(FN.EB.LOOKUP, F.EB.LOOKUP)
RETURN

*
* =========
INITIALISE:
* =========
*
    FN.EB.LOOKUP = 'F.EB.LOOKUP'
    F.EB.LOOKUP = ''
    R.EB.LOOKUP = ''
    Y.EB.LOOKUP.ID = ''
    Y.ERR.EB.LOOKUP = ''

    WCAMPO = "L.TT.FX.BUY.SRC"
    YPOS = ""

    CALL MULTI.GET.LOC.REF("TELLER",WCAMPO,YPOS)
    WPOS.TT.FX.BUY.SRC = YPOS<1,1>

    Y.FX.BUY.SRC = R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TT.FX.BUY.SRC>
    Y.EB.LOOKUP.ID = "L.TT.FX.BUY.SRC" : "*" : Y.FX.BUY.SRC


RETURN


END
