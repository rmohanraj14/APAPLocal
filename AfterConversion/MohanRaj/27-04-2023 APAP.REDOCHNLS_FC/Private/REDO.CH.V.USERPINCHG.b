* @ValidationCode : MjoxMzcxMjA0MjQ4OkNwMTI1MjoxNjgxMjE1MTY5NDQwOklUU1M6LTE6LTE6NjY0OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 664
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.USERPINCHG
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PINADM,RESET.PIN
* Attached as     : VALIDATION.ROUTINE for PIN field
* Primary Purpose : Validate the User & Customer status related to permit the
*                   PIN reset
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 8/01/13 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
* 10-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, F.READ to CACHE.READ
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUSTOMER.STATUS
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.REDO.CH.PINADM

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*----------
OPEN.FILES:
*----------

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    CALL OPF(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CUSTOMER.STATUS = 'F.CUSTOMER.STATUS'
    F.CUSTOMER.STATUS = ''
    CALL OPF(FN.CUSTOMER.STATUS,F.CUSTOMER.STATUS)

    FN.CUST.DOCUMENT = 'F.CUST.DOCUMENT'
    F.CUST.DOCUMENT  = ''
    CALL OPF(FN.CUST.DOCUMENT,F.CUST.DOCUMENT)

RETURN

*-------
PROCESS:
*-------

    Y.USER.ID = ID.NEW

    R.EB.EXTERNAL.USER = ''; EEU.ERR = ''
    CALL CACHE.READ(FN.EB.EXTERNAL.USER, Y.USER.ID, R.EB.EXTERNAL.USER, EEU.ERR) ;*R22 Auto conversion
    IF R.EB.EXTERNAL.USER THEN
        Y.CUST.ID = R.EB.EXTERNAL.USER<EB.XU.CUSTOMER>
        Y.USER.STA = R.EB.EXTERNAL.USER<EB.XU.STATUS>
    END

    GOSUB CHECK.USER.STATUS

RETURN

*-----------------
CHECK.USER.STATUS:
*-----------------

    IF Y.USER.STA NE 'ACTIVE' THEN
        AF = REDO.CH.PINADMIN.PIN
        ETEXT = 'EB-REDO.CH.V.USERPINCHG'
        CALL STORE.END.ERROR
        RETURN
    END

    GOSUB CHECK.CUST.STATUS

RETURN

*-----------------
CHECK.CUST.STATUS:
*-----------------

    R.CUSTOMER = ''; CUST.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUST.ID,R.CUSTOMER,F.CUSTOMER,CUST.ERR)
    IF R.CUSTOMER THEN
        Y.CUST.STAT = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
    END

    IF Y.CUST.STAT NE 1 THEN
        GOSUB GET.DESC.STATUS
        AF = REDO.CH.PINADMIN.PIN
        ETEXT = 'EB-REDO.CH.V.USERPINCHG2':@FM:Y.CUS.STATUS.DESC
        CALL STORE.END.ERROR
        RETURN
    END

    Y.ACTDATAOS  = Y.CUST.ID:'*':'ACTDATOS'
    CALL F.READ(FN.CUST.DOCUMENT,Y.ACTDATAOS,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
    IF R.CUST.DOCUMENT THEN
        Y.ACTDATAOS.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>
    END

    IF Y.ACTDATAOS.STATUS EQ '2' OR Y.ACTDATAOS.STATUS EQ '3' OR Y.ACTDATAOS.STATUS EQ '4' THEN
        AF = REDO.CH.PINADMIN.PIN
        ETEXT = 'EB-REDO.CH.V.USERPINCHG3'
        CALL STORE.END.ERROR
        RETURN
    END

RETURN

****************
GET.DESC.STATUS:
****************

    R.CUSTOMER.STATUS = '' ; CS.ERR = ''
    CALL F.READ(FN.CUSTOMER.STATUS,Y.CUST.STAT,R.CUSTOMER.STATUS,F.CUSTOMER.STATUS,CS.ERR)
    IF R.CUSTOMER.STATUS THEN
        Y.CUS.STATUS.DESC = R.CUSTOMER.STATUS<EB.CST.SHORT.NAME>
    END

RETURN

END
