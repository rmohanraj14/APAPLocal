* @ValidationCode : MjotNjY1NDI3ODpDcDEyNTI6MTY4MDc3MzU0NTQzOTpIYXJpc2h2aWtyYW1DOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:02:25
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GENNEWUSR.MIG
**
* Subroutine Type : VERSION
* Attached to : AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINT.MIG,
* AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWTEL.MIG,
* AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWINTADM.MIG,
* AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINTAUTH.MIG,
* AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINTINP.MIG
* Attached as : AUTH.ROUTINE
* Primary Purpose : Generate Channel User.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 9/01/12 - First Version (for channel users migration only).
* ODR Reference: ODR-2010-06-0155.
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
* Roberto Mondragon - TAM Latin America.
* rmondragon@temenos.com
*
* 29/02/12 - Fix for PACS00180440
* ODR Reference: ODR-2010-06-0155.
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
* Roberto Mondragon - TAM Latin America.
* rmondragon@temenos.com
*
* 22/03/12 - Fix for PACS00180442
* ODR Reference: ODR-2010-06-0155.
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
* Roberto Mondragon - TAM Latin America.
* rmondragon@temenos.com
*
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.CUSTOMER

    $INSERT I_F.REDO.CH.CONFIG
    $INSERT I_REDO.CH.GENNEWUSR.MIG.COMMON

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

***********
OPEN.FILES:
***********

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.CH.CONFIG = 'F.REDO.CH.CONFIG'
    F.REDO.CH.CONFIG = ''
    CALL OPF(FN.REDO.CH.CONFIG,F.REDO.CH.CONFIG)

    OFS.SRC = 'CHADMONPROC3'

RETURN

********
PROCESS:
********

    CALL GET.LOC.REF('AA.ARRANGEMENT.ACTIVITY','ARC.USR.ID',YPOS.ARC.USR.ID)

    USER = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,YPOS.ARC.USR.ID>
    CUSTOMER = R.NEW(AA.ARR.ACT.CUSTOMER)
    ARRANGEMENT = R.NEW(AA.ARR.ACT.ARRANGEMENT)
    PRODUCT = R.NEW(AA.ARR.ACT.PRODUCT)

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        FULLNAME = R.CUSTOMER<EB.CUS.SHORT.NAME>
    END

*Define version to create the user according with the channel
    GOSUB GET.VALID.TIME

    BEGIN CASE
        CASE PRODUCT EQ 'PERSONAL'
            VERSION = 'EB.EXTERNAL.USER,REDO.PERS.NEWINT.MIG'
        CASE PRODUCT EQ 'PERSONAL.TEL'
            VERSION = 'EB.EXTERNAL.USER,REDO.PERS.NEWTEL.MIG'
        CASE PRODUCT EQ 'CORPINPUT'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTINP.MIG'
        CASE PRODUCT EQ 'CORPADMIN'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTADM.MIG'
        CASE PRODUCT EQ 'CORPAUTH'
            VERSION = 'EB.EXTERNAL.USER,REDO.CORP.NEWINTAUTH.MIG'
    END CASE

*User Creation as an OFS message.
    OFS.HEADER.2 = VERSION : '/I/PROCESS/1/0,/,' : USER : ','
    OFS.BODY.2 = 'NAME:1:1=' : FULLNAME : ','
    OFS.BODY.2 := 'CUSTOMER:1:1=' : CUSTOMER : ','
    OFS.BODY.2 := 'ARRANGEMENT:1:1=' : ARRANGEMENT : ','
    OFS.BODY.2 := 'END.DATE:1:1=' : EXP.DATE.LIMIT : ','

    OFS.MSG.2 = OFS.HEADER.2 : OFS.BODY.2

*Input User created.

    CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG.2,RESP.OFS.MSG.2,TXN.COMM)

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

END
