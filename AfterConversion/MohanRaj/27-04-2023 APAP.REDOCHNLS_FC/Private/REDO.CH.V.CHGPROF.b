* @ValidationCode : MjoxMTY4NDMwOTM5OkNwMTI1MjoxNjgxNzMzNjg5NjI1OklUU1M6LTE6LTE6OTY0OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 964
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.CHGPROF
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PROFILE,CHANGE
* Attached as     : VALIDATION.ROUTINE
* Primary Purpose : Validate the change of the profile for Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 02/07/12 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 13/08/12 - Second Version
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 07/12/12 - Third Version
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 20/12/12 - Fourth Version
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM, F.READ to CACHE.READ
* 12-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CUSTOMER.STATUS
    $INSERT I_F.CUST.DOCUMENT
    $INSERT I_F.DOCUMENT.STATUS

    $INSERT I_F.REDO.CH.PROFILE

    GOSUB INIT
    GOSUB PROCESS

RETURN

*****
INIT:
*****

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

    FN.DOCUMENT.STATUS = 'F.DOCUMENT.STATUS'
    F.DOCUMENT.STATUS = ''
    CALL OPF(FN.DOCUMENT.STATUS,F.DOCUMENT.STATUS)

RETURN

********
PROCESS:
********

    Y.PRODUCT = R.NEW(REDO.CH.PROF.PRODUCT)
    Y.PROFILE.OLD = R.OLD(REDO.CH.PROF.PROFILE)
    Y.PROFILE = COMI

    GOSUB VAL.ACTIVE.CUST

    IF Y.PROFILE.OLD EQ 'Apapenlinea.Consultas' OR Y.PROFILE.OLD EQ 'Apapenlinea.Txns' THEN
        IF Y.PROFILE EQ 'Teleapap.Consultas' OR Y.PROFILE EQ 'Teleapap.Txns' THEN
            AF = REDO.CH.PROF.PROFILE
            ETEXT = 'EB-REDO.CH.V.CHGPROF'
            CALL STORE.END.ERROR
            RETURN
        END
    END

    IF Y.PROFILE.OLD EQ 'Teleapap.Consultas' OR Y.PROFILE.OLD EQ 'Teleapap.Txns' THEN
        IF Y.PROFILE EQ 'Apapenlinea.Consultas' OR Y.PROFILE EQ 'Apapenlinea.Txns' THEN
            AF = REDO.CH.PROF.PROFILE
            ETEXT = 'EB-REDO.CH.V.CHGPROF'
            CALL STORE.END.ERROR
            RETURN
        END
    END

RETURN

*---------------
VAL.ACTIVE.CUST:
*---------------

    Y.USER = ID.NEW

    R.EB.EXTERNAL.USER = '' ; EEU.ERR = ''
    CALL CACHE.READ(FN.EB.EXTERNAL.USER, Y.USER, R.EB.EXTERNAL.USER, EEU.ERR) ;*R22 Auto conversion
    IF R.EB.EXTERNAL.USER THEN
        Y.STATUS = R.EB.EXTERNAL.USER<EB.XU.STATUS>
        Y.CUSTOMER = R.EB.EXTERNAL.USER<EB.XU.CUSTOMER>
    END

    IF Y.STATUS NE 'ACTIVE' THEN
        AF = REDO.CH.PROF.PROFILE
        ETEXT = 'EB-REDO.CH.V.STAUSR'
        CALL STORE.END.ERROR
        RETURN
    END

    R.CUSTOMER = '' ; CUST.ERR = ''
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER,R.CUSTOMER,F.CUSTOMER,CUST.ERR)
    IF R.CUSTOMER THEN
        Y.CUS.STATUS = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
    END

    IF Y.CUS.STATUS NE 1 THEN
        AF = REDO.CH.PROF.PROFILE
        GOSUB GET.DESC.STATUS
        ETEXT = 'EB-REDO.CH.V.EMAIL':@FM:Y.CUS.STATUS.DESC
        CALL STORE.END.ERROR
        RETURN
    END

    Y.ACTDATAOS  = Y.CUSTOMER:'*':'ACTDATOS'
    CALL F.READ(FN.CUST.DOCUMENT,Y.ACTDATAOS,R.CUST.DOCUMENT,F.CUST.DOCUMENT,CUST.DOCUMENT.ERR)
    IF R.CUST.DOCUMENT THEN
        Y.ACTDATAOS.STATUS = R.CUST.DOCUMENT<CUS.DOC.STATUS>
    END

    IF Y.PRODUCT EQ 'PERSONAL' THEN
        Y.CHCTTO  = Y.CUSTOMER:'*CANIBP'
    END ELSE
        Y.CHCTTO  = Y.CUSTOMER:'*CANIVR'
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
        AF = REDO.CH.PROF.PROFILE
        ETEXT = 'EB-REDO.CH.V.DOC':@FM:Y.MSG.DESC
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.CHCTTO.STATUS NE '1' THEN
        Y.TYPE.DOC = 2
        Y.DOC.STA.REC = Y.CHCTTO.STATUS
        GOSUB GET.MSG.DESC
        AF = REDO.CH.PROF.PROFILE
        ETEXT = 'EB-REDO.CH.V.DOC2':@FM:Y.MSG.DESC
        CALL STORE.END.ERROR
        RETURN
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
