* @ValidationCode : MjotMjAzMTQzNTM3MzpDcDEyNTI6MTY4MTczMzY4Nzk0MzpJVFNTOi0xOi0xOjI2NzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 267
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.CHGPROFILE
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PROFILE,CHANGE
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Change the profile for Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 28/09/11 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 22/11/11 - Update
*            ODR Reference: ODR-2010-06-0155
*            IMPORTANT NOTE ABOUT UPDATE: The change to OFS.CALL.BULK.MANAGER
*            is required by the client requirement. The OFS message need to be
*            process immediately to change the profile
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 02/07/12 - Update
*            ODR Reference: ODR-2010-06-0155
*            Functionality to change the difererent profiles of corporative user
*            Paul Pasquel - TAM Latin America
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 06/09/12 - Update
*            ODR Reference: ODR-2010-06-0155
*            Functionality to change the difererent profiles of IVR users
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
* 31/01/17 - Update
*            PACS00575199
*            Used OPM instead of OFS.CALL.BULK.MANAGER for the fatal error in browser.
*            Silambarasan S - 3MS Technologies
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM, ++ to +=
* 12-APR-2023      Harishvikram C   Manual R22 conversion    CALL routine format modified
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    $INSERT I_F.REDO.CH.CONFIG
    $INSERT I_F.REDO.CH.PROFILE

    GOSUB OPEN.FILES
    GOSUB DELETE.CACHE
    GOSUB PROCESS

RETURN

***********
OPEN.FILES:
***********

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''
    CALL OPF(FN.REDO.CH.CONFIG,F.REDO.CH.CONFIG)

    FN.OS.XML.CACHE = 'F.OS.XML.CACHE'
    F.OS.XML.CACHE = ''
    OPEN FN.OS.XML.CACHE TO F.OS.XML.CACHE ELSE
        TEXT = 'Error in opening : ':FN.OS.XML.CACHE
        CALL FATAL.ERROR('REDO.CH.CHGPROFILE')
    END

RETURN

********
PROCESS:
********

    OFS.SRC = 'CHADMONPROC'

    Y.PROFILE.OLD = R.OLD(REDO.CH.PROF.PROFILE)
    Y.PROFILE = R.NEW(REDO.CH.PROF.PROFILE)
    Y.ARR = R.NEW(REDO.CH.PROF.ARRANGEMENT)

    GOSUB SEL.PROFILE

    IF Y.PROFILE EQ 'Apapenlinea.Consultas' OR Y.PROFILE EQ 'Apapenlinea.Txns' THEN
        OFS.HEADER = 'AA.ARRANGEMENT.ACTIVITY,REDO.CH.CHANGEPROF/I/PROCESS//0/,//DO0010001/////,,'
        OFS.BODY = 'ARRANGEMENT:1:1=' : Y.ARR : ','
        OFS.BODY := 'ACTIVITY:1:1=INTERNET.SERVICES-UPDATE-UIBEHAVIOUR,'
        OFS.BODY := 'EFFECTIVE.DATE:1:1=' : TODAY : ','
        OFS.BODY := 'PROPERTY:1:1=UIBEHAVIOUR,'
        OFS.BODY := 'FIELD.NAME:1:1=FLOW.TYPE:1:1,'
        OFS.BODY := 'FIELD.NAME:1:2=FLOW.TYPE:2:1,'
        OFS.BODY := 'FIELD.NAME:1:3=FLOW.TYPE:3:1,'
        OFS.BODY := 'FIELD.NAME:1:4=FLOW.VALUE:1:1,'
        OFS.BODY := 'FIELD.NAME:1:5=FLOW.VALUE:2:1,'
        OFS.BODY := 'FIELD.NAME:1:6=FLOW.VALUE:3:1,'
        OFS.BODY := 'FIELD.VALUE:1:1=FIRST.LOGIN,'
        OFS.BODY := 'FIELD.VALUE:1:2=EVERY.LOGIN,'
        OFS.BODY := 'FIELD.VALUE:1:3=INITIAL.SCREEN,'
        OFS.BODY := 'FIELD.VALUE:1:4=COS ' : Y.PROFILE1 :','
        OFS.BODY := 'FIELD.VALUE:1:5=COS ' : Y.PROFILE1 :','
        OFS.BODY := 'FIELD.VALUE:1:6=COS ' : Y.PROFILE1 :','

        OFS.MSG = OFS.HEADER : OFS.BODY

        CALL APAP.REDOCHNLS.REDO.CH.OFSPROC(OFS.MSG,OFS.SRC) ;*Manual R22 conversion

        Y.ACTIVITY = 'ACTIVITY:1:1=INTERNET.SERVICES-UPDATE-USERRIGHTS,'
        Y.PROP.FOR.UR = 'PROPERTY:1:1=USERRIGHTS,'
    END ELSE
        Y.ACTIVITY = 'ACTIVITY:1:1=INTERNET.SERVICES-UPDATE-USERRIGTEL,'
        Y.PROP.FOR.UR = 'PROPERTY:1:1=USERRIGTEL,'
    END

    OFS.HEADER1 = 'AA.ARRANGEMENT.ACTIVITY,REDO.CH.CHANGEPROF/I/PROCESS//0/,//DO0010001/////,,'
    OFS.BODY1 = 'ARRANGEMENT:1:1=' : Y.ARR : ','
    OFS.BODY1 := Y.ACTIVITY
    OFS.BODY1 := 'EFFECTIVE.DATE:1:1=' : TODAY : ','
    OFS.BODY1 := Y.PROP.FOR.UR
    OFS.BODY1 := 'FIELD.NAME:1:1=SMS.GROUP,'
    OFS.BODY1 := 'FIELD.VALUE:1:1=' : Y.USG1 :','

    OFS.MSG1 = OFS.HEADER1 : OFS.BODY1

    TXN.COMM = ''

*CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG1,RESP.OFS.MSG1,TXN.COMM)
    CALL OFS.POST.MESSAGE(OFS.MSG1,RESP.OFS.MSG1,OFS.SRC,"")

RETURN

************
SEL.PROFILE:
************

    CONFIG.ID = "SYSTEM"
    CALL CACHE.READ(FN.REDO.CH.CONFIG,CONFIG.ID,R.CON,CONFIG.ERR)

    Y.PROFILE1 = '' ; Y.USG1 = ''
    IF R.CON THEN
        Y.PROFILES.CON = R.CON<REDO.CH.CONFIG.PROFILE.TYPE>
        Y.MENUS.CON = R.CON<REDO.CH.CONFIG.MENU.COS>
        Y.USG.CON = R.CON<REDO.CH.CONFIG.USER.SMS.GROUP>
        Y.PROFILES.CNT = DCOUNT(Y.PROFILES.CON,@VM)
        Y.CNT = 1
        LOOP
        WHILE Y.CNT LE Y.PROFILES.CNT
            Y.PROFILE.SEL = FIELD(Y.PROFILES.CON,@VM,Y.CNT)
            IF Y.PROFILE EQ Y.PROFILE.SEL THEN
                Y.PROFILE1 = FIELD(Y.MENUS.CON,@VM,Y.CNT)
                Y.USG1 = FIELD(Y.USG.CON,@VM,Y.CNT)
                Y.CNT = Y.PROFILES.CNT
            END
            Y.CNT += 1
        REPEAT
    END

RETURN

*************
DELETE.CACHE:
*************

    SEL.REC = ''; REC.LIST = ''; CNT.REC = ''; RET.CD = ''
    SEL.REC = 'SELECT F.OS.XML.CACHE WITH @ID LIKE ..._':ID.NEW:'_...'
    CALL EB.READLIST(SEL.REC,REC.LIST,'',CNT.REC,RET.CD)

    LOOP
        REMOVE REC.ID FROM REC.LIST SETTING REC.ID.POS
    WHILE REC.ID:REC.ID.POS
*    DELETE F.OS.XML.CACHE, REC.ID ;*Tus Start
        CALL F.DELETE(FN.OS.XML.CACHE,REC.ID)     ;*Tus End
    REPEAT

RETURN

END
