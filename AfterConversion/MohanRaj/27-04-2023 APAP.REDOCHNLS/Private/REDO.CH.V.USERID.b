* @ValidationCode : Mjo5OTU2ODc4MzpDcDEyNTI6MTY4MTIxNTE2OTM4MzpJVFNTOi0xOi0xOjU4NjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 586
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.USERID
**
* Subroutine Type : VERSION
* Attached to     : AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWINT,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.PERS.NEWTEL,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXINP,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXAUTH,
*                   AA.ARRANGEMENT.ACTIVITY,REDO.CORP.NEWPROXADM
* Attached as     : Field ARC.USR.ID as VALIDATION.RTN
* Primary Purpose : Validate the channel user id
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 5/07/12 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    GOSUB INITIALIZE
    GOSUB PROCESS

RETURN
***********
INITIALIZE:
***********

    APP.LOC.REF = 'AA.ARRANGEMENT.ACTIVITY'
    APP.LOC.REF.FLD = 'L.EB.PROXY.ARR'

    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(APP.LOC.REF,APP.LOC.REF.FLD,LOC.REF.POS)
    LOC.PROXY.ARR.POS = LOC.REF.POS<1,1>

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    FN.CORPORATE.USER.LIST = 'F.CORPORATE.USER.LIST'
    F.CORPORATE.USER.LIST  = ''
    CALL OPF(FN.CORPORATE.USER.LIST,F.CORPORATE.USER.LIST)

    FN.CORPORATE.CUSTOMER.LIST = 'F.CORPORATE.CUSTOMER.LIST'
    F.CORPORATE.CUSTOMER.LIST  = ''
    CALL OPF(FN.CORPORATE.CUSTOMER.LIST,F.CORPORATE.CUSTOMER.LIST)

RETURN

********
PROCESS:
********

    Y.USER.ID = COMI

    Y.SEL.CMD = 'SSELECT ':FN.EB.EXTERNAL.USER:' WITH @ID LIKE ':Y.USER.ID
    SEL.CMD.ERR = ''
    CALL EB.READLIST(Y.SEL.CMD,Y.SEL.CMD.LIST,'',Y.SEL.CMD.LIST.NO,SEL.CMD.ERR)

    IF Y.SEL.CMD.LIST.NO GE 1 THEN
        ETEXT = 'EB-REDO.CH.V.USERID'
        CALL STORE.END.ERROR
        RETURN
    END
    Y.PROXY.CUS  = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,LOC.PROXY.ARR.POS>
    Y.COMPANY.CUS = R.NEW(AA.ARR.ACT.CUSTOMER)
    CALL F.READ(FN.CORPORATE.USER.LIST,Y.COMPANY.CUS,R.CORPORATE.USER.LIST,F.CORPORATE.USER.LIST,CORPORATE.USER.LIST.ERR)
    LOCATE Y.USER.ID IN R.CORPORATE.USER.LIST SETTING Y.USER.POS THEN
    END ELSE
        R.CORPORATE.USER.LIST<-1> = Y.USER.ID
        CALL F.WRITE(FN.CORPORATE.USER.LIST,Y.COMPANY.CUS,R.CORPORATE.USER.LIST)
    END

    CALL F.READ(FN.CORPORATE.CUSTOMER.LIST,Y.PROXY.CUS,R.CORPORATE.CUSTOMER.LIST,F.CORPORATE.CUSTOMER.LIST,CORPORATE.CUSTOMER.LIST.ERR)
    LOCATE Y.USER.ID IN R.CORPORATE.CUSTOMER.LIST SETTING Y.CUSTOMER.POS THEN
    END ELSE
        R.CORPORATE.CUSTOMER.LIST<-1> = Y.USER.ID
        CALL F.WRITE(FN.CORPORATE.CUSTOMER.LIST,Y.PROXY.CUS,R.CORPORATE.CUSTOMER.LIST)
    END

RETURN

END
