* @ValidationCode : MjotNjk4NTI3NTA6Q3AxMjUyOjE2ODE4MTI5MjE1Mjk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:45:21
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
***********************************************************
*----------------------------------------------------------
*
* COMPANY NAME    : APAP
* DEVELOPED BY    : GOPALA KRISHNAN R
*
*----------------------------------------------------------
*
* DESCRIPTION     : BEFORE AUTHORISATION routine to be used in FT versions.
*                   Check to see whether account gets overdrawn.
*------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     < TO LE,SM TO @SM,FM TO @FM,VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------
*
SUBROUTINE REDO.V.OVERRIDE.FT.WV.COMTAX

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_System
*
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
*

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
*
RETURN
*
* ===
INIT:
* ===
*

    PROCESS.GOHEAD = 1

    LREF.APPLICATION = "FUNDS.TRANSFER" : @FM : "FT.COMMISSION.TYPE" : @FM : "BENEFICIARY"
    LOC.REF.FIELDS   = "L.TT.TAX.CODE" : @VM : "L.TT.WV.TAX" : @VM : "L.TT.TAX.AMT" : @VM
    LREF.POS         = ''

    CALL MULTI.GET.LOC.REF(LREF.APPLICATION,LOC.REF.FIELDS,LREF.POS)
    POS.L.TT.TAX.CODE = LREF.POS<1,1>
    POS.L.TT.TAX.AMT  = LREF.POS<1,3>
    Y.L.TT.TRANS.AMT  = LREF.POS<1,7>

    Y.DR.ACCT.NO      = ''
    Y.TXN.CCY         = ''
*
RETURN          ;* Return INIT
*
* =========
OPEN.FILES:
* =========

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN          ;* Return OPEN.FILES

* ======
PROCESS:
* ======
*
    GOSUB GET.TRANSACTION.INFO
    Y.TAX.CODE.CNT = DCOUNT(Y.WV.TAX.CODE,@FM)
    Y.TAX.AMT.TEMP = ''
    Y.TAX.CTR = 1

    LOOP
    WHILE Y.TAX.CTR LE Y.TAX.CODE.CNT

        Y.TAX.AMT         = Y.WV.TAX.AMT<Y.TAX.CTR>
        GOSUB CALC.TAX.AMT
        Y.TAX.AMT.LCY.CALC = Y.TAX.AMT.LCY
        Y.TAX.AMT.TEMP    += Y.TAX.AMT.LCY.CALC
        Y.TAX.CTR += 1

    REPEAT

    GOSUB GET.OVERRIDE.MSG

RETURN          ;* Return PROCESS
*

* ===================
GET.TRANSACTION.INFO:
* ===================
*

    Y.DR.ACCT.NO    = R.NEW(FT.DEBIT.ACCT.NO)
    Y.EXCHANGE.RATE = R.NEW(FT.IN.EXCH.RATE)

    Y.TXN.CCY       = R.NEW(FT.DEBIT.CURRENCY)
    Y.WV.TAX.AMT    = R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.AMT>
    Y.WV.TAX.CODE   = R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.CODE>

    CHANGE @SM TO @FM IN Y.WV.TAX.CODE
    CHANGE @SM TO @FM IN Y.WV.TAX.AMT

RETURN
*
* ===========
CALC.TAX.AMT:
* ===========

    Y.TAX.AMT         = Y.WV.TAX.AMT
    Y.TAX.AMT.FCY = ''
    Y.TAX.AMT.LCY = ''

    IF Y.TXN.CCY EQ LCCY THEN
        Y.TAX.AMT.LCY = Y.TAX.AMT
        Y.TAX.AMT.FCY = ''
    END

    IF Y.TXN.CCY NE LCCY THEN
        Y.TAX.AMT.FCY = Y.TAX.AMT
        Y.TAX.AMT.LCY = Y.TAX.AMT * Y.EXCHANGE.RATE
    END
*
RETURN          ;* Return CALC.TAX.AMT
*

* ===============
GET.OVERRIDE.MSG:
* ===============

    Y.TAX.AMT.TEMP = Y.TAX.AMT.TEMP<1>
    CALL F.READ(FN.ACCOUNT,Y.DR.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ERR.ACC)
    YACCNO = Y.DR.ACCT.NO
    WORKING.BAL.AMT  = R.ACCOUNT<AC.WORKING.BALANCE>
    TOT.LOCK.AMOUNT = '0'
    IF R.ACCOUNT<AC.LOCKED.AMOUNT> THEN
        LOC.AMT.CNT = DCOUNT(R.ACCOUNT<AC.LOCKED.AMOUNT>, @VM)
        FOR TOT.LOCK.AMT = 1 TO LOC.AMT.CNT
            IF R.ACCOUNT<AC.FROM.DATE, TOT.LOCK.AMT> LE TODAY THEN ;*R22 Auto code conversion
                TOT.LOCK.AMOUNT = R.ACCOUNT<AC.LOCKED.AMOUNT , TOT.LOCK.AMT>
            END
        NEXT TOT.LOCK.AMT
    END
    IF WORKING.BAL.AMT LT 0 THEN
        WORKING.BAL.AMT   = ABS(WORKING.BAL.AMT)
        WORKING.BAL.AMT += TOT.LOCK.AMOUNT ;*R22 Auto code conversion
        DIFF.AMT      = -1 * WORKING.BAL.AMT
    END ELSE
        DIFF.AMT    = WORKING.BAL.AMT - TOT.LOCK.AMOUNT
    END
    TAX.AMT        = Y.TAX.AMT.TEMP
    IF DIFF.AMT LT TAX.AMT THEN
        TEXT = "ACCT.UNAUTH.OVRDRFT":@FM:YACCNO
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN

END
