* @ValidationCode : MjoxODI1MzE5MzI1OkNwMTI1MjoxNjgxMzgwODQzOTEzOklUU1M6LTE6LTE6NzY5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:03
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 769
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.EMAIL.CORP
*******************************
* Subroutine Type : VERSION
* Attached to     : AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXINP,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXAUTH,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXADM,
* Attached as     : Field CUSTOMER as VALIDATION.RTN
* Primary Purpose : Validate if Customer has an email registered in CUSTOMER for
*                   their Internet Channel User and populate in the field
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 12/04/13 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.CUSTOMER.STATUS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.DOCUMENT.STATUS
*   $INCLUDE TAM.BP I_REDO.CH.V.EMAIL.COMMON

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
    F.CUST.DOCUMENT  = ''
    CALL OPF(FN.CUST.DOCUMENT,F.CUST.DOCUMENT)

    FN.DOCUMENT.STATUS = 'F.DOCUMENT.STATUS'
    F.DOCUMENT.STATUS  = ''
    CALL OPF(FN.DOCUMENT.STATUS,F.DOCUMENT.STATUS)

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'

    LREF.APP = 'CUSTOMER':@FM:'AA.ARRANGEMENT.ACTIVITY'
    LREF.FIELDS = 'L.CU.TIPO.CL':@FM:'L.CORP.EMAIL'
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    L.CU.TIPO.CL.POS = LREF.POS<1,1>
    L.CORP.EMAIL.POS = LREF.POS<2,1>

    Y.EMAIL.REG = ''

RETURN

********
PROCESS:
********

    Y.CUSTOMER = COMI

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
    IF R.CUSTOMER THEN
        Y.CUS.STATUS = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
        Y.CUS.TYPE = R.CUSTOMER<EB.CUS.LOCAL.REF><1,L.CU.TIPO.CL.POS>
        Y.EMAIL.REG = R.CUSTOMER<EB.CUS.EMAIL.1>

        Y.ACTDATAOS  = Y.CUSTOMER:'*':'ACTDATOS'
        Y.TELEFONOS  = Y.CUSTOMER:'*':'TELEFONOS'
        CALL F.READ(FN.CUST.DOCUMENT,Y.ACTDATAOS,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
        Y.ACTDATAOS.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>

        IF Y.ACTDATAOS.STATUS NE '1' AND Y.ACTDATAOS.STATUS NE '' THEN
            GOSUB GET.ACTDATOS.DESC
            ETEXT = 'EB-REDO.CH.V.DOC':@FM:Y.ACTDATOS.DESC
            CALL STORE.END.ERROR
        END


    END

    IF Y.CUS.STATUS NE 1 THEN
        GOSUB GET.DESC.STATUS
        ETEXT = 'EB-REDO.CH.V.EMAIL':@FM:Y.CUS.STATUS.DESC
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.CUS.TYPE EQ 'PERSONA JURIDICA' OR Y.CUS.TYPE EQ 'CLIENTE MENOR' THEN
        ETEXT = 'EB-REDO.CH.V.EMAIL2':@FM:Y.CUS.TYPE
        CALL STORE.END.ERROR
        RETURN
    END

*    IF SENDMAIL EQ 0 THEN
*        SENDMAIL = 'Y'
*    END

    R.NEW(AA.ARR.ACT.LOCAL.REF)<1,L.CORP.EMAIL.POS> = Y.EMAIL.REG

RETURN

******************
GET.ACTDATOS.DESC:
******************

    R.DOCUMENT.STATUS = '' ; DS.ERR = ''
    CALL F.READ(FN.DOCUMENT.STATUS,Y.ACTDATAOS.STATUS,R.DOCUMENT.STATUS,F.DOCUMENT.STATUS,DS.ERR)
    IF R.DOCUMENT.STATUS THEN
        IF Y.ACTDATAOS.STATUS NE 2 THEN
            Y.ACTDATOS.DESC2 = ''
        END ELSE
            Y.ACTDATOS.DESC2 = ' (ILOCALIZABLE)'
        END
        Y.ACTDATOS.DESC = R.DOCUMENT.STATUS<DOC.STAT.DESCRIPTION>
        IF LNGG EQ 1 THEN
            Y.ACTDATOS.DESC = FIELD(Y.ACTDATOS.DESC,@VM,1)
        END ELSE
            Y.ACTDATOS.DESC = FIELD(Y.ACTDATOS.DESC,@VM,2)
        END
        Y.ACTDATOS.DESC = Y.ACTDATOS.DESC:Y.ACTDATOS.DESC2
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

END
