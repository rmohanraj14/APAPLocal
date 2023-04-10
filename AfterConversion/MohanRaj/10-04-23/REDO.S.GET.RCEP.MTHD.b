* @ValidationCode : MjotMTIxNzMxNzE5ODpDcDEyNTI6MTY4MTEzMDY0ODU3ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 18:14:08
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
SUBROUTINE REDO.S.GET.RCEP.MTHD(RCEP.MTHD)
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

    RCEP.MTHD = R.EB.LOOKUP<EB.LU.DESCRIPTION,Y.LANG>


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

    WCAMPO = "L.TT.RCEP.MTHD"
    YPOS = ""

    CALL MULTI.GET.LOC.REF("TELLER",WCAMPO,YPOS)
    WPOS.TT.RCEP.MTHD = YPOS<1,1>

    Y.RCEP.MTHD = R.NEW(TT.TE.LOCAL.REF)<1,WPOS.TT.RCEP.MTHD>
    Y.EB.LOOKUP.ID = "L.TT.RCEP.MTHD" : "*" : Y.RCEP.MTHD


RETURN


END
