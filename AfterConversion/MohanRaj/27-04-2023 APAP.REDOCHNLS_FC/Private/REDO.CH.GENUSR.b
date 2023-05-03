* @ValidationCode : MjotNjMzODQ4OTY2OkNwMTI1MjoxNjgxNzMzNjg4MzM4OklUU1M6LTE6LTE6MTY2OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 166
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GENUSR
**
* Subroutine Type : VERSION
* Attached to     : REDO.SOLICITUD.CANAL,INPAC
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Generate Channel User from Autoaffiliation Applications.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version.
*           ODR Reference: ODR-2010-06-0155.
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
* 4/07/11 - Update to find the customer using cedule or passport no. instead
*           of customer name.
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
* 29/09/11 - Update to create an external user in a single step and email
*            validation for customer.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
* 05/10/11 - Update as code re-structuting.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 12-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 12-APR-2023     Conversion tool    R22 Auto conversion       No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.CUSTOMER

    $INSERT I_F.REDO.SOLICITUD.CANAL

    GOSUB INITIALIZE
    GOSUB PROCESS

RETURN

***********
INITIALIZE:
***********

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    CHANNEL = ""
    USER = ""
    ID.TYPE = ""
    ID.NO = ""
    CUSTOMER = ""
    VERSION = ""
    FULLNAME = ""
    OFS.HEADER = ""
    OFS.BODY = ""
    OFS.MSG = ""
    RESP.OFS.MSG = ""
    TXN.COMM = ""

    OFS.SRC = "CHADMONPROC"

RETURN

********
PROCESS:
********

*Get Customer Data
    CHANNEL = R.NEW(RD.SC.TIPO.CANAL)
    USER = R.NEW(RD.SC.ID.USUARIO)
    ID.TYPE = R.NEW(RD.SC.TIPO.IDENT)
    ID.NO = R.NEW(RD.SC.NUMERO.IDENT)
    EMAIL = R.NEW(RD.SC.EMAIL)

*Find Customer for cedule or passport no.
    IF ID.TYPE EQ "CEDULA" THEN
        ID.TYPE.NO = 1
    END ELSE
        ID.TYPE.NO = 2
    END

    GOSUB VAL.IDENT.NO

    IF NOT.FOUND EQ "Y" THEN
        AF = RD.SC.NUMERO.IDENT
        E = "EB-REDO.CH.CUSNOTID"
        RETURN
    END

*Validate the e-mail for customer.
    IF EMAIL EQ '' THEN
        GOSUB GET.EMAIL.CUS
    END

    IF REG.EMAIL EQ '' THEN
        AF = RD.SC.EMAIL
        E = "EB-REDO.NOT.MAIL"
        RETURN
    END

*Define version to create the user according with the channel
    IF CHANNEL EQ "INTERNET" THEN
        VERSION = "AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINT"
    END ELSE
        VERSION = "AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWTEL"
    END

*Arrangement Creation as an OFS message.
    OFS.HEADER = VERSION : "/I/PROCESS/1/0,/,,"
    OFS.BODY := "CUSTOMER:1:1=": CUSTOMER :","
    OFS.BODY := "ARC.USR.ID:1:1=": USER  :","

    OFS.MSG = OFS.HEADER : OFS.BODY

*Input User created.

    CALL OFS.POST.MESSAGE(OFS.MSG,RESP.OFS.MSG,OFS.SRC,"0")

RETURN

*************
VAL.IDENT.NO:
*************

    NOT.FOUND = "Y"

    IF ID.TYPE.NO EQ 1 THEN
        SEL.CMD = "SELECT ":FN.CUSTOMER:" WITH L.CU.CIDENT EQ ":ID.NO
    END ELSE
        SEL.CMD = "SELECT ":FN.CUSTOMER:" WITH LEGAL.ID EQ ":ID.NO
    END

    CALL EB.READLIST(SEL.CMD,NO.OF.REC,'',CNT.REC,RET.CD)

    IF CNT.REC EQ "1" THEN
        NOT.FOUND = "N"
        CUSTOMER = NO.OF.REC<CNT.REC>
    END

RETURN

**************
GET.EMAIL.CUS:
**************

    R.CUS = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER,R.CUS,F.CUSTOMER,CUS.ERR)
    IF R.CUS THEN
        REG.EMAIL = R.CUS<EB.CUS.EMAIL.1>
    END

RETURN

END
