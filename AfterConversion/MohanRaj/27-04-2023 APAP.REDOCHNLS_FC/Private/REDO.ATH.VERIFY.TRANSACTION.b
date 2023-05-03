* @ValidationCode : MjotMTAyMTM0NzQ1NTpDcDEyNTI6MTY4MDc3MzY4NjgxNzpIYXJpc2h2aWtyYW1DOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:04:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.VERIFY.TRANSACTION
************************************************************************
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : DHAMU S
* Program Name : REDO.ATH.VERIFY.TRANSACTION
*****************************************************************
*Description: This routine is to verify the transaction happened
*******************************************************************************
*In parameter : None
*Out parameter : None
****************************************************************************
*Modification History:
**************************
*     Date            Who                  Reference               Description
*    ------          ------               -----------             --------------
*   3-12-2010       DHAMU S              ODR-2010-08-0469         Initial Creation
* 04-APR-2023     Conversion tool    R22 Auto conversion        No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion       No changes
*--------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.REDO.ATH.SETTLMENT
    $INSERT I_F.REDO.APAP.H.PARAMETER
    $INSERT I_F.ATM.REVERSAL
    $INSERT I_REDO.ATH.STLMT.FILE.PROCESS.COMMON

    GOSUB PROCESS
RETURN

********
PROCESS:
********


    TXN.REF = R.ATM.REVERSAL<AT.REV.TXN.REF>

    IF R.ATM.REVERSAL<AT.REV.VISA.STLMT.REF> NE '' THEN
        ERROR.MESSAGE = 'DUP.PROCESSED.TRANS'
        RETURN
    END

    IF TXN.REF NE '' AND TXN.REF[1,4] EQ 'ACLK' THEN
        CALL F.READ(FN.AC.LOCKED.EVENTS,TXN.REF,R.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS,AC.LOCKED.EVENTS.ERR)
        IF R.AC.LOCKED.EVENTS EQ '' THEN
            ERROR.MESSAGE = 'DELAY.SUBMISSION'
            RETURN
        END

    END ELSE

        IF TXN.REF NE '' AND TXN.REF[1,4] NE 'ACLK' THEN
            ERROR.MESSAGE = 'DELAY.SUBMISSION'
            RETURN
        END

    END



    Y.STLMT.LOCAL.DATE = R.REDO.STLMT.LINE<ATH.SETT.TRANSACTION.DATE>
    Y.TRANSACTION.DATE = R.ATM.REVERSAL<AT.REV.LOCAL.DATE>

*IF Y.STLMT.LOCAL.DATE NE Y.TRANSACTION.DATE THEN
*    ERROR.MESSAGE = 'NO.MATCH.TRANSACTION'
*    RETURN
*END


    ACCOUNT.ID=R.ATM.REVERSAL<AT.REV.ACCOUNT.NUMBER>
    CALL F.READ(FN.ACCOUNT,ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)
    Y.AVAILABLE.BALANCE = R.ACCOUNT<AC.LOCAL.REF,POS.L.AC.AV.BAL>

    Y.STLMT.SOURCE.AMOUNT=R.REDO.STLMT.LINE<ATH.SETT.REQUESTED.AMT.RD>
    Y.TRANSACTION.AMT=R.ATM.REVERSAL<AT.REV.TRANSACTION.AMOUNT>         ;*L.TXN.AMT
    IF Y.STLMT.SOURCE.AMOUNT NE Y.TRANSACTION.AMT THEN
        ERROR.MESSAGE='INVALID.TRAN.AMT.OR.ACCT.NUM'
    END
RETURN
END
