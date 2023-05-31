* @ValidationCode : MjoxMjMzMTE0ODY1OkNwMTI1MjoxNjg1NTMzOTc0MzAyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:22:54
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
$PACKAGE APAP.AA
SUBROUTINE REDO.VAL.AA.REPAY.AMT
*-----------------------------------------------------------------------------------
* Modification History:
*DATE                 WHO                  REFERENCE                    DESCRIPTION
*29/03/2023         Conversion Tool    AUTO R22 CODE CONVERSION           NOCHANGE
*29/03/2023         SURESH      MANUAL R22 CODE CONVERSION        Package Name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------
*-------------------------------------------------
*Description: This routine is to check the overpayment
*             amount against the loan outstanding amount.
*-------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $USING APAP.TAM

    GOSUB PROCESS

RETURN
*-------------------------------------------------
PROCESS:
*-------------------------------------------------
* Fix for PACS00392651 [Over Payment Cheque TXN not displaying in REDO.TELLER.TODAY]

    CALL MULTI.GET.LOC.REF('TELLER','L.INITIAL.ID',LOC.REF.POS)

    IF PGM.VERSION EQ ',REDO.OVERPYMT.CASH' AND R.NEW(TT.TE.LOCAL.REF)<1,LOC.REF.POS> EQ ID.NEW THEN
        AF = TT.TE.LOCAL.REF
        AV = LOC.REF.POS
        ETEXT = 'TT-REDO.OVERPAY.RSTR.STNDALN'
        CALL STORE.END.ERROR
    END

* End of Fix

    Y.LOAN.ACC  = R.NEW(TT.TE.NARRATIVE.1)<1,1>
    Y.REPAY.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)

    APAP.TAM.redoConvertAccount(Y.LOAN.ACC,"",ARR.ID,ERR.TEXT);* R22 Manual conversion
    GOSUB GET.LOAN.OUTSTANDING.BALANCE
    GOSUB GET.UNC.BALANCES
    Y.PENDING.AMT = Y.PROP.AMT<1> - Y.UNC.BALANCE

    IF Y.REPAY.AMT GT Y.PENDING.AMT THEN
        AF    = TT.TE.AMOUNT.LOCAL.1
        ETEXT = 'EB-REDO.REPAY.AMT.GTFS'
        CALL STORE.END.ERROR
    END


RETURN

*-------------------------------------------------------------
GET.LOAN.OUTSTANDING.BALANCE:
*-------------------------------------------------------------
* Here  we get the amount excluding the UNC balances.
    Y.PROP.AMT  = 0
    Y.TOTAL.AMT = 0
    APAP.TAM.redoGetTotalOutstandingSinUncUnd(ARR.ID,Y.PROP.AMT,Y.TOTAL.AMT);* R22 Manual conversion

RETURN
*-------------------------------------------------------------
GET.UNC.BALANCES:
*-------------------------------------------------------------
* Here we get the UNC balance of the Loan.

    Y.ACCOUNT.PROPERTY = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,'ACCOUNT',R.OUT.AA.RECORD,Y.ACCOUNT.PROPERTY,OUT.ERR);* R22 Manual conversion

    BALANCE.TO.CHECK = 'UNC':Y.ACCOUNT.PROPERTY
    BALANCE.AMOUNT   = ''
    CALL AA.GET.ECB.BALANCE.AMOUNT(Y.LOAN.ACC,BALANCE.TO.CHECK,TODAY,BALANCE.AMOUNT,RET.ERROR)
    Y.UNC.BALANCE = ABS(BALANCE.AMOUNT)
RETURN



END
