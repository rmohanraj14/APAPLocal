* @ValidationCode : MjotMTk1NzA0Njc2NzpDcDEyNTI6MTY4MTczMzY4NzI1MjpJVFNTOi0xOi0xOi0xMToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -11
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATM.ACCT.VERIFY
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.ATM.ACCT.VERIFY
*--------------------------------------------------------------------------------------------------------
*Description  : This is the version routine used to identify the account is a valid open account or not
*In Parameter : N/A
*Out Parameter: N/A
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
* 27 Oct 2010     SWAMINATHAN           ODR-2009-12-0291         Initial Creation
* 12-APR-2023     Conversion tool    R22 Auto conversion         No changes
*--------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.REDO.ACCT.STATUS.CODE
    $INSERT I_F.REDO.ACCT.IST.RESP.MAP
    $INSERT I_AT.ISO.COMMON
*--------------------------------------------------------------------------------------------------------
    IF V$FUNCTION EQ 'R' THEN

        RETURN

    END

    GOSUB PROCESS
RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS:
************
*Check the field position of amount ATM$RECON.REQ.MAP.ID (4) in  and check if its equal to '0'
*Check the position  of ATM$RECON.REQ.MAP.ID(25) and check if its equal to '51'
*if above two satisfies then throw the error message "VALID ACCOUNT"
*

    Y.MAP.FOUR.POS = AT$INCOMING.ISO.REQ(4)*1
    Y.MAP.TWENTY.FIVE.POS = AT$INCOMING.ISO.REQ(25)
    IF Y.MAP.FOUR.POS EQ '0' AND Y.MAP.TWENTY.FIVE.POS EQ '51' THEN
        ETEXT = 'AC-VALID.ACCOUNT'
        CALL STORE.END.ERROR
    END
RETURN
END
