* @ValidationCode : MjotNzg4MzQzNDI2OkNwMTI1MjoxNjgxODIxNjYwNTUyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 18:11:00
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.TEMP.PYMNT.VP
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
*                TAM Latin America
* Client       : Asociacion Popular de Ahorro & Prestamo (APAP)
* Date         : 05.25.2013
* Description  : Routine for validating a new credit card payment
* Type         : Input Routine
* Attached to  : Vision Plus Transactionsal VERSIONs (TT y FT)
* Dependencies :
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date           Who                     Reference         Description
* 1.0       29.06.2017     Edwin Charles D          R15 Upgrade      Initial Version
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     IF Condition Added,VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
*-----------------------------------------------------------------------------

* <region name="INSERTS">

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_System
    $INSERT I_F.REDO.VISION.PLUS.TXN
*   $INSERT I_GTS.COMMON

* </region>
    IF OFS$OPERATION EQ 'PROCESS' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN

* <region name="GOSUBS" description="Gosub blocks">

***********************
* Initialize
INIT:
***********************
    IF APPLICATION EQ 'REDO.FT.TT.TRANSACTION' THEN
        Y.LET = 'F'
        Y.OVERRIDE.LOCAL.REF = FT.TN.OVERRIDE
    END

    ALLOW.OFFLINE = ''
    TXN.RESULT = ''
    R.REDO.VISION.PLUS.TXN = ''
    FN.REDO.VISION.PLUS.TXN = 'F.REDO.VISION.PLUS.TXN'
    F.REDO.VISION.PLUS.TXN = ''
    R.REDO.VISION.PLUS.TXN = ''
    REDO.VISION.PLUS.TXN.ID = ''
    CALL OPF(FN.REDO.VISION.PLUS.TXN,F.REDO.VISION.PLUS.TXN)
    TXN.VERSION = APPLICATION : PGM.VERSION

RETURN

***********************
* Main Process
PROCESS:
***********************

    IF APPLICATION EQ 'REDO.FT.TT.TRANSACTION' THEN
        ALLOW.OFFLINE = 1
        CALL APAP.TAM.REDO.VP.TEMP.CC.PAYMENT(ALLOW.OFFLINE, TXN.RESULT) ;* R22 Manual Conversion - CALL method format modified
    END

    IF TXN.RESULT<1> EQ 'OFFLINE' OR TXN.RESULT<1> EQ 'ERROR' THEN

        CALL APAP.SRTN.REDO.S.NOTIFY.INTERFACE.ACT('VPL003', 'ONLINE', '04', 'Email PAGO SE APLICARA OFFLINE - ID: ':ID.NEW , ' ' : TIMEDATE() : ' - LOG EN Jboss : server.log', '', '', '', '', '', OPERATOR, '') ;* R22 Manual Conversion - CALL method format modified

        EXT.USER.ID = System.getVariable("EXT.EXTERNAL.USER")
        IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
            EXT.USER.ID = ""
        END ;*R22 Auto code conversion-END
        IF EXT.USER.ID EQ 'EXT.EXTERNAL.USER' THEN

            TEXT    = 'ST-VP-NO.ONLINE.PYMNT'
            CURR.NO = DCOUNT(R.NEW(Y.OVERRIDE.LOCAL.REF),@VM)+ 1
            CALL STORE.OVERRIDE(CURR.NO)
        END

        FINDSTR 'EB-UNKNOWN.VARIABLE' IN E<1,1> SETTING POS.FM.OVER THEN
            DEL E<POS.FM.OVER>
        END

        GOSUB SET.OFFLINE.TXN
    END

RETURN

*************************************
* Set Transaction Offline Processing
SET.OFFLINE.TXN:
*************************************


    R.NEW(FT.TN.L.FT.MSG.CODE) = '000000'

RETURN

* </region>

END
