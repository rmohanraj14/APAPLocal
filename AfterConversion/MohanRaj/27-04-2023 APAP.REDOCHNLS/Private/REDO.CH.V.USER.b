* @ValidationCode : MjotMTU3Mjk2MDIxOTpDcDEyNTI6MTY4MTIxNTE2OTM0ODpJVFNTOi0xOi0xOjI4NDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 284
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.V.USER
**
* Subroutine Type : VERSION
* Attached to     : PASSWORD.RESET,REDO.CH.RESUSRPWD
* Attached as     : USER.RESET field as VALIDATION.RTN
* Primary Purpose : Reset to a new temporal password to be sent by email to
*                   Internet User by email.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version.
*           ODR Reference: ODR-2010-06-0155.
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*           Martin Macias.
*           mmacias@temenos.com
* 07/11/11 - Fix for PACS00146411.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       F.READ to CACHE.READ, <> to NE
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.PASSWORD.RESET
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.CUSTOMER

    IF R.NEW(EB.PWR.USER.RESET) EQ '' THEN
        RETURN
    END

    GOSUB INIT
    GOSUB PROCESS

RETURN

********
PROCESS:
********

    ID.USER = R.NEW(EB.PWR.USER.RESET)

    R.EXT.USER = ''; EXUSER.ERR = ''
    CALL CACHE.READ(FN.EXT.USER, ID.USER, R.EXT.USER, EXUSER.ERR) ;*R22 Auto conversion
    IF R.EXT.USER THEN
        ID.CUS = R.EXT.USER<EB.XU.CUSTOMER>
        USER.STATUS = R.EXT.USER<EB.XU.STATUS>
    END

    IF R.EXT.USER<EB.XU.CHANNEL> NE "INTERNET" THEN ;*R22 Auto conversion
        E = "EB-REDO.CHANN.INTERNET"
        RETURN
    END

    IF USER.STATUS NE 'ACTIVE' THEN
        E = "EB-REDO.CH.USR.NO.ACTIVE"
        RETURN
    END

    R.CUSTOMER = ''; CUS.ERR = ''
    CALL F.READ(FN.CUST,ID.CUS,R.CUSTOMER,FV.CUST,CUS.ERR)
    IF R.CUSTOMER EQ '' THEN
        E = "EB-CUSTOMER.NOT.EXIST"
        RETURN
    END

RETURN

*****
INIT:
*****

    FN.CUST = 'F.CUSTOMER'
    FV.CUST = ''
    CALL OPF(FN.CUST, FV.CUST)

    FN.EXT.USER = 'F.EB.EXTERNAL.USER'
    FV.EXT.USER = ''
    CALL OPF(FN.EXT.USER, FV.EXT.USER)

RETURN

END
