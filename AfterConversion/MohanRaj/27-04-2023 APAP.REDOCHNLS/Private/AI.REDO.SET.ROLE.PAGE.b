* @ValidationCode : MjozNDczOTA3MTY6Q3AxMjUyOjE2ODEzODA3ODY5NDk6SVRTUzotMTotMTo3NjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 76
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.SET.ROLE.PAGE(ENQ.DATA)
*-----------------------------------------------------------------------------
*Company   Name    : APAP
*Developed By      : Martin Macias
*Program   Name    : AI.REDO.SET.ROLE.PAGE
*-----------------------------------------------------------------------------
* 11-APR-2023     Conversion tool   R22 Auto conversion    VM to @VM, F.READ to CACHE.READ, IF condition added
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes

    $INSERT I_COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_EQUATE
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_System

    GOSUB INITIALISE
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*---------------
INITIALISE:
*---------------

    Y.USR.VAR = System.getVariable("EXT.EXTERNAL.USER")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion -START
        Y.USR.VAR = ""
    END					;*R22 Auto conversion - END

    LOC.REF.APPLICATION="EB.EXTERNAL.USER"
    LOC.REF.FIELDS='PROD.USED':@VM
    Y.ROLE.PAGE = 'COS AI.REDO.ARC.CUSTOMER.POSITION'

RETURN

*---------------
OPEN.FILES:
*---------------

    FN.EXT.USER = 'F.EB.EXTERNAL.USER'
    F.EXT.USER = ''
    CALL OPF(FN.EXT.USER,F.EXT.USER)

RETURN

*---------------
PROCESS:
*---------------

    CALL CACHE.READ(FN.EXT.USER, Y.USR.VAR, R.EXT.USER, EXT.USER.ERR) ;*R22 Auto conversion

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.L.PROD.USED = LOC.REF.POS<1,1>
    Y.L.PROD.USED = R.EXT.USER<EB.XU.LOCAL.REF><1,POS.L.PROD.USED>

    IF Y.L.PROD.USED EQ 'CORPINPUT' THEN
        Y.ROLE.PAGE = 'COS AI.REDO.CORP.INP.MAIN.PAGE'
    END

    CALL System.setVariable("CURRENT.ROLE.PAGE",Y.ROLE.PAGE)

RETURN
END
