* @ValidationCode : MjoxMTM5ODAxNTgyOkNwMTI1MjoxNjgxMjE1MTY2Nzc4OklUU1M6LTE6LTE6ODY1OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 865
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.INAUSR
*******************************
* Subroutine Type : VERSION
* Attached to : EB.EXTERNAL.USER,REDO.CH.USER.M
* Attached as : Field STATUS as VALIDATION.RTN
* Primary Purpose : Validate if Customer has an email registered in CUSTOMER for
* their Internet Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 03/01/13 - First Version
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
*
* 15/02/13 - Update
* ODR Reference: ODR-2010-06-0155
* Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
* Roberto Mondragon - TAM Latin America
* rmondragon@temenos.com
*
* 10-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUSTOMER.STATUS
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.DOCUMENT.STATUS

    GOSUB INITIALIZE
    GOSUB PROCESS

RETURN

***********
INITIALIZE:
***********

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CUSTOMER.STATUS = 'F.CUSTOMER.STATUS'
    F.CUSTOMER.STATUS = ''
    CALL OPF(FN.CUSTOMER.STATUS,F.CUSTOMER.STATUS)

    FN.CUST.DOCUMENT = 'F.CUST.DOCUMENT'
    F.CUST.DOCUMENT = ''
    CALL OPF(FN.CUST.DOCUMENT,F.CUST.DOCUMENT)

    FN.DOCUMENT.STATUS = 'F.DOCUMENT.STATUS'
    F.DOCUMENT.STATUS = ''
    CALL OPF(FN.DOCUMENT.STATUS,F.DOCUMENT.STATUS)

    LREF.APP = 'CUSTOMER'
    LREF.FIELDS = 'L.CU.TIPO.CL'
    LREF.POS = ''
    CALL GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)

    L.CU.TIPO.CL.POS = LREF.POS<1,1>

RETURN

********
PROCESS:
********

    Y.CUSTOMER = R.NEW(EB.XU.CUSTOMER)
    Y.CHANNEL = R.NEW(EB.XU.CHANNEL)
    Y.STATUS.OLD = R.NEW(EB.XU.STATUS)
    Y.STATUS = COMI

    IF Y.STATUS.OLD NE Y.STATUS THEN
        GOSUB VAL.DOCS
    END

RETURN

*********
VAL.DOCS:
*********

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        Y.DIS.MSG = 'N'
        Y.CUS.STATUS = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
        Y.CUS.TYPE = R.CUSTOMER<EB.CUS.LOCAL.REF><1,L.CU.TIPO.CL.POS>
        Y.EMAIL.REG = R.CUSTOMER<EB.CUS.EMAIL.1>

        IF Y.CUS.STATUS NE 1 AND Y.STATUS.OLD EQ 'INACTIVE' AND Y.STATUS EQ 'ACTIVE' THEN
            GOSUB GET.DESC.STATUS
            ETEXT = 'EB-REDO.CH.V.EMAIL':@FM:Y.CUS.STATUS.DESC
            CALL STORE.END.ERROR
            RETURN
        END

        Y.ACTDATAOS = Y.CUSTOMER:'*':'ACTDATOS'
        CALL F.READ(FN.CUST.DOCUMENT,Y.ACTDATAOS,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
        IF R.CUST.DOCUMENT THEN
            Y.ACTDATAOS.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>
        END

        IF Y.CHANNEL EQ 'INTERNET' THEN
            Y.CHCTTO = Y.CUSTOMER:'*CANIBP'
        END ELSE
            Y.CHCTTO = Y.CUSTOMER:'*CANIVR'
        END

        R.CUST.DOCUMENT = ''
        CALL F.READ(FN.CUST.DOCUMENT,Y.CHCTTO,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
        IF R.CUST.DOCUMENT THEN
            Y.CHCTTO.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>
        END

        IF Y.ACTDATAOS.STATUS NE '1' AND Y.ACTDATAOS.STATUS NE '' THEN
            Y.TYPE.DOC = 1
            Y.DOC.STA.REC = Y.ACTDATAOS.STATUS
            GOSUB GET.MSG.DESC
            ETEXT = 'EB-REDO.CH.V.DOC':@FM:Y.MSG.DESC
            CALL STORE.END.ERROR
        END

        IF Y.CHCTTO.STATUS NE '1' THEN
            Y.TYPE.DOC = 2
            Y.DOC.STA.REC = Y.CHCTTO.STATUS
            GOSUB GET.MSG.DESC
            ETEXT = 'EB-REDO.CH.V.DOC2':@FM:Y.MSG.DESC
            CALL STORE.END.ERROR
        END
    END

RETURN

****************
GET.DESC.STATUS:
****************

    R.CUSTOMER.STATUS = '' ; CS.ERR = ''
    CALL F.READ(FN.CUSTOMER.STATUS,Y.CUS.STATUS,R.CUSTOMER.STATUS,F.CUSTOMER.STATUS,CS.ERR)
    IF R.CUSTOMER.STATUS THEN
        Y.CUS.STATUS.DESC = R.CUSTOMER.STATUS<EB.CST.SHORT.NAME>
    END

RETURN

*************
GET.MSG.DESC:
*************

    R.DOCUMENT.STATUS = '' ; DS.ERR = ''
    Y.MSG.DESC2 = ''
    CALL F.READ(FN.DOCUMENT.STATUS,Y.DOC.STA.REC,R.DOCUMENT.STATUS,F.DOCUMENT.STATUS,DS.ERR)
    IF R.DOCUMENT.STATUS THEN
        IF Y.DOC.STA.REC EQ 2 AND Y.TYPE.DOC EQ 1 THEN
            Y.MSG.DESC2 = ' (ILOCALIZABLE)'
        END
        Y.MSG.DESC = R.DOCUMENT.STATUS<DOC.STAT.DESCRIPTION>
        IF LNGG EQ 1 THEN
            Y.MSG.DESC = FIELD(Y.MSG.DESC,@VM,1)
        END ELSE
            Y.MSG.DESC = FIELD(Y.MSG.DESC,@VM,2)
        END
        Y.MSG.DESC = Y.MSG.DESC:Y.MSG.DESC2
    END

    IF Y.TYPE.DOC EQ 2 AND Y.MSG.DESC EQ '' THEN
        IF LNGG EQ 1 THEN
            Y.MSG.DESC = 'NOT EXIST'
        END ELSE
            Y.MSG.DESC = 'NO EXISTE'
        END
    END

RETURN

END
