* @ValidationCode : MjotMTk1NDM4NDEwODpDcDEyNTI6MTY4MTIxNjQ3NzkzODpJVFNTOi0xOi0xOjM0NToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:04:37
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 345
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GENNEWUSR
**
* Subroutine Type : VERSION
* Attached to     : AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINT,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWTEL,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINTINP,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINTAUTH,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINTADM
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Generate Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 21/09/11 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 28/09/11 - Update for fix for PACS00106562
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 14/02/12 - Update for fix for PACS00181894
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 03/07/12 - Update for profile change
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 13/08/12 - Update for corporate users and IVR users
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 10-APR-2023     Conversion tool   R22 Auto conversion    VM to @VM, REM to DISPLAY.MESSAGE(TEXT, '')
* 10-APR-2023      Harishvikram C   Manual R22 conversion      CALL routine format modified
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.CUSTOMER

    $INSERT I_F.REDO.CH.CONFIG
    $INSERT I_REDO.CH.GENNEWUSR.COMMON
    $INSERT I_REDO.CH.V.EMAIL.COMMON

    IF OFS.VAL.ONLY EQ '' THEN
        GOSUB OPEN.FILES
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN

***********
OPEN.FILES:
***********

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''
    CALL OPF(FN.REDO.CH.CONFIG,F.REDO.CH.CONFIG)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

RETURN

*****
INIT:
*****

    LREF.APP = 'AA.ARRANGEMENT.ACTIVITY'
    LREF.FIELDS = 'ARC.USR.ID':@VM:'L.EB.PROXY.ARR':@VM:'L.CORP.EMAIL'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    ARC.USR.ID.POS = LREF.POS<1,1>
    L.EB.PROXY.ARR.POS = LREF.POS<1,2>
    L.CORP.EMAIL.POS = LREF.POS<1,3>

    OFS.SRC = 'CHADMONPROC3'

RETURN

********
PROCESS:
********

    USER = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,ARC.USR.ID.POS>
    CUSTOMER = R.NEW(AA.ARR.ACT.CUSTOMER)
    Y.EMAIL.REG = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,L.CORP.EMAIL.POS>
    R.NEW(AA.ARR.ACT.LOCAL.REF)<1,L.CORP.EMAIL.POS> = ''
    ARRANGEMENT = R.NEW(AA.ARR.ACT.ARRANGEMENT)
    PRODUCT = R.NEW(AA.ARR.ACT.PRODUCT)
    PRD.CORP = 'N'
    CORP.FLG = 'N'

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        FULLNAME = R.CUSTOMER<EB.CUS.SHORT.NAME>
    END

*Create the profile record and define version to create the user according with the channel
    BEGIN CASE
        CASE PRODUCT EQ 'PERSONAL.TEL'
            GET.WARNING.INFO = OFS$WARNINGS<2>

            IF GET.WARNING.INFO EQ '' OR GET.WARNING.INFO NE 'NOANSWER' THEN
*PACS00459944 ASLAM
* IF SHOWPIN EQ 'Y' THEN
                Y.PROFILE = 'Teleapap.Consultas'
                GOSUB GEN.PIN
                TEXT = "PIN temporal asignado: ": PINMAIL
                CALL DISPLAY.MESSAGE(TEXT, '') ;* R22 Auto conversion
                VERSION = 'EB.EXTERNAL.USER,REDO.PERS.NEWTEL'
                SHOWPIN = 0
                GOSUB GEN.PROFILE.REC
*    END ELSE
*        SHOWPIN = 'Y'
*    END
            END
*PACS00459944 ASLAM
        CASE PRODUCT EQ 'PERSONAL'
            Y.PROFILE = 'Apapenlinea.Consultas'
            VERSION = 'EB.EXTERNAL.USER,REDO.PERS.NEWINT'
            GOSUB GEN.PROFILE.REC
        CASE PRODUCT EQ 'CORPINPUT'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTINP'
            PRD.CORP = 'Y'
        CASE PRODUCT EQ 'CORPAUTH'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTAUTH'
            PRD.CORP = 'Y'
        CASE PRODUCT EQ 'CORPADMIN'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTADM'
            PRD.CORP = 'Y'
    END CASE

*User Creation as an OFS message
    GOSUB GET.VALID.TIME

    OFS.HEADER.2 = VERSION : '/I/PROCESS/1/0,/,' : USER : ','
    OFS.BODY.2 = 'NAME:1:1=' : FULLNAME : ','
    OFS.BODY.2 := 'CUSTOMER:1:1=' : CUSTOMER : ','
    OFS.BODY.2 := 'ARRANGEMENT:1:1=' : ARRANGEMENT : ','
    OFS.BODY.2 := 'END.DATE:1:1=' : EXP.DATE.LIMIT : ','

    IF PRD.CORP EQ 'Y' THEN
        OFS.BODY.2 := 'L.CORP.EMAIL:1:1=' : Y.EMAIL.REG : ','
    END

    OFS.MSG.2 = OFS.HEADER.2 : OFS.BODY.2

*Input User created
    TXN.COMM = ''

* Fix for PACS00462053 [DUPLICATION MAIL GENERATION]

    GET.WARNING.INFO = OFS$WARNINGS<2>

    IF GET.WARNING.INFO EQ '' OR GET.WARNING.INFO NE 'NOANSWER' THEN
        CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG.2,RESP.OFS.MSG.2,TXN.COMM)
    END

* End of Fix

RETURN

****************
GEN.PROFILE.REC:
****************

    OFS.HEADER.1 = 'REDO.CH.PROFILE,NEW/I/PROCESS/1/0,/,' : USER : ','
    OFS.BODY.1 = 'PROFILE:1:1=' : Y.PROFILE : ','
    OFS.BODY.1 := 'PRODUCT:1:1=' : PRODUCT : ','
    OFS.BODY.1 := 'ARRANGEMENT:1:1=' : ARRANGEMENT : ','

    OFS.MSG.1 = OFS.HEADER.1 : OFS.BODY.1

    CALL APAP.REDOCHNLS.REDO.CH.OFSPROC(OFS.MSG.1,OFS.SRC) ;*Manual R22 conversion

RETURN

***************
GET.VALID.TIME:
***************

    CONFIG.ID = 'SYSTEM'
    R.CON = ''; CONFIG.ERR = ''
    CALL CACHE.READ(FN.REDO.CH.CONFIG,CONFIG.ID,R.CON,CONFIG.ERR)
    IF R.CON THEN
        DAYS.EXP = R.CON<REDO.CH.CONFIG.VALTIMEPWD>
    END

    EXP.DATE.LIMIT = TODAY
    TEMP.DAYS.EXP = '+':DAYS.EXP:'C'
    CALL CDT('',EXP.DATE.LIMIT,TEMP.DAYS.EXP)

RETURN

********
GEN.PIN:
********

    PINMAIL = RND(9) : RND(9) : RND(9) : RND(9)
    PIN = PINMAIL

RETURN

END
