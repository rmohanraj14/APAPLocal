* @ValidationCode : MjoxNjkzODEwMjI3OkNwMTI1MjoxNjgxMzgwODQxNzQ5OklUU1M6LTE6LTE6MjY5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 269
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.CHGPROFILE.MIG
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PROFILE,MIG
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Input the profile for Channel User during migration.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 22/03/12 - First Version.
*            ODR Reference: ODR-2010-06-0155.
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM, ++ to +=
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
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

        CALL OFS.POST.MESSAGE(OFS.MSG,RESP.OFS.MSG,OFS.SRC,"0")

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

    CALL OFS.POST.MESSAGE(OFS.MSG1,RESP.OFS.MSG1,OFS.SRC,"0")

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
        CALL F.DELETE(FN.OS.XML.CACHE,REC.ID) ;*Tus End
    REPEAT

RETURN

END
