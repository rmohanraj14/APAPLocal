* @ValidationCode : MjotMTI2NDA1MzU0NzpDcDEyNTI6MTY4MTIxNTE2NDkwMzpJVFNTOi0xOi0xOi0yOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -2
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GENARR
**
* Subroutine Type : VERSION
* Attached to : EB.EXTERNAL.USER,REDO.PERS.NEWINT,
* EB.EXTERNAL.USER,REDO.PERS.NEWTEL,
* EB.EXTERNAL.USER,REDO.CORP.NEWINTADM,
* EB.EXTERNAL.USER,REDO.CORP.NEWINTAUTH,
* EB.EXTERNAL.USER,REDO.CORP.NEWINTINP
* Attached as : INPUT.ROUTINE
* Primary Purpose : Generate AA Arrangement for Channel User defined
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_F.EB.EXTERNAL.USER

    YPOS.PROD.USED = ""
    OFS.HEADER = ""
    OFS.BODY = ""
    OFS.MSG = ""
    RESP.OFS.MSG = ""

    CALL GET.LOC.REF("EB.EXTERNAL.USER","PROD.USED",YPOS.PROD.USED)

    OFS.SRC = "CHADMONPROC3"

    CUSTOMER = R.NEW(EB.XU.CUSTOMER)
    PRODUCT = R.NEW(EB.XU.LOCAL.REF)<1,YPOS.PROD.USED>

*Arrangement Creation as an OFS message
    OFS.HEADER = "AA.ARRANGEMENT.ACTIVITY,REDO.NEWUSR/I/PROCESS/1/0,/,,"
    OFS.BODY = "ARRANGEMENT:1:1=NEW,"
    OFS.BODY := "ACTIVITY:1:1=INTERNET.SERVICES-NEW-ARRANGEMENT,"
    OFS.BODY := "CUSTOMER:1:1=": CUSTOMER :","
    OFS.BODY := "PRODUCT:1:1=": PRODUCT :","
    OFS.BODY := "EFFECTIVE.DATE:1:1=": TODAY :","
    OFS.BODY := "ARC.USR.ID:1:1=": ID.NEW :","

    OFS.MSG = OFS.HEADER : OFS.BODY

*Input Arrangement created

    CALL OFS.POST.MESSAGE(OFS.MSG,RESP.OFS.MSG,OFS.SRC,"0")

RETURN

END
