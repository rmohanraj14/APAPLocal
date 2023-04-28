* @ValidationCode : MjotNDcxODkxNTYyOkNwMTI1MjoxNjgyNjY0NDM5MDY5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 28 Apr 2023 12:17:19
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
*-----------------------------------------------------------------------------
* <Rating>-160</Rating>
*-----------------------------------------------------------------------------
$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.NV.AA.AML.CHECK
    

    
*-----------------------------------------------------------
* Description: This routine is an input routine for the FT payment version in NV,
* to generate the AML override and Deal Slip
*-----------------------------------------------------------
* Input  Arg: N/A
* Output Arg: N/A
* Deals With: FT AA NV Payment
*-----------------------------------------------------------
* Who           Date           Dev Ref           Modification
* H Ganesh     29 Nov 2012   AA NV Payment       Initial Draft
* Vignesh R    15 Dec 2014   PACS00392651        AA OVERPAYMENT THROUGH CASH/CHEQUE
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSTION        Package name added APAP.AA, CALL method format modified,VM TO @VM,FM TO @FM
*29-03-2023    CONVERSION TOOL     AUTO R22 CODE CONVERSION          -----------
*-----------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CURRENCY
    $INSERT I_F.TELLER
    $INSERT I_F.TRANSACTION
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_DEAL.SLIP.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_DEAL.SLIP.COMMON
    $INSERT I_RC.COMMON
    $INSERT I_F.FT.TXN.TYPE.CONDITION
    $INSERT I_F.VERSION
    $INSERT I_F.REDO.CREDIT.TRANS.TELLER
    $INSERT I_F.REDO.AML.PARAM
    $INSERT I_F.T24.FUND.SERVICES
    $INSERT I_F.REDO.AA.OVERPAYMENT ;* Fix for PACS00392651

*  IF OFS$SOURCE.ID EQ 'FASTPATH' AND R.VERSION(EB.VER.VERSION.TYPE) EQ 'NV' THEN
*      RETURN
*  END

    IF OFS$OPERATION EQ 'PROCESS' THEN
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END

RETURN
*-----------------------------------------------------------
OPEN.FILES:
*-----------------------------------------------------------
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.CUR = 'F.CURRENCY'
    F.CUR  = ''
    CALL OPF(FN.CUR,F.CUR)

    FN.FTTC='F.FT.TXN.TYPE.CONDITION'
    F.FTTC=''
    CALL OPF(FN.FTTC,F.FTTC)

    FN.REDO.AML.PARAM='F.REDO.AML.PARAM'
    F.REDO.AML.PARAM=''
    CALL OPF(FN.REDO.AML.PARAM,F.REDO.AML.PARAM)

    FN.TRANSACTION='F.TRANSACTION'
    F.TRANSACTION=''
    CALL OPF(FN.TRANSACTION,F.TRANSACTION)

    FN.REDO.CREDIT.TRANS.TELLER = 'F.REDO.CREDIT.TRANS.TELLER'
    F.REDO.CREDIT.TRANS.TELLER  = ''
    CALL OPF(FN.REDO.CREDIT.TRANS.TELLER,F.REDO.CREDIT.TRANS.TELLER)

    FN.TELLER = 'F.TELLER'
    F.TELLER  = ''
    CALL OPF(FN.TELLER,F.TELLER)

    FN.STMT.ENTRY = 'F.STMT.ENTRY'
    F.STMT.ENTRY  = ''
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)

    FN.STMT.ENTRY.DETAIL = 'F.STMT.ENTRY.DETAIL'
    F.STMT.ENTRY.DETAIL  = ''
    CALL OPF(FN.STMT.ENTRY.DETAIL,F.STMT.ENTRY.DETAIL)

    FN.CUSTOMER.ACCOUNT = 'F.CUSTOMER.ACCOUNT'
    F.CUSTOMER.ACCOUNT = ''
    CALL OPF(FN.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT)

    FN.ACCT.ENT.TODAY='F.ACCT.ENT.TODAY'
 
    F.ACCT.ENT.TODAY=''
    CALL OPF(FN.ACCT.ENT.TODAY,F.ACCT.ENT.TODAY)

    FN.T24.FUND.SERVICES = 'F.T24.FUND.SERVICES'
    F.T24.FUND.SERVICES = ''
    CALL OPF(FN.T24.FUND.SERVICES,F.T24.FUND.SERVICES)

* Fix for PACS00392651 [AA OVERPAYMENT THROUGH CASH/CHEQUE]

    FN.REDO.AA.OVERPAYMENT = 'F.REDO.AA.OVERPAYMENT'
    F.REDO.AA.OVERPAYMENT = ''
    CALL OPF(FN.REDO.AA.OVERPAYMENT,F.REDO.AA.OVERPAYMENT)

* End of Fix

    LRF.APP='TRANSACTION':@FM:'CURRENCY':@FM:'FUNDS.TRANSFER' ;*MANUAL R22 CODE CONVERSTION
    LRF.FIELD='L.TR.AML.CHECK':@FM:'L.CU.AMLBUY.RT':@FM:'L.RTE.FORM':@VM:'L.NEXT.VERSION' ;*MANUAL R22 CODE CONVERSTION
    LRF.POS=''
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)

    POS.L.TR.AML.CHECK = LRF.POS<1,1>
    POS.L.CU.AMLBUY.RT = LRF.POS<2,1>
    POS.L.RTE.FORM     = LRF.POS<3,1>
    POS.NXT.VER = LRF.POS<3,2>

RETURN
*-----------------------------------------------------------
PROCESS:
*-----------------------------------------------------------
    TOT.TODAY.TXN.AMT = ''
    Y.PARAM.ID = 'SYSTEM'
    CALL CACHE.READ(FN.REDO.AML.PARAM,Y.PARAM.ID,R.AML.PARAM,AML.ERR)
    Y.AMT.LIMIT.LCY = R.AML.PARAM<AML.PARAM.AMT.LIMIT.LCY>
    VAR.OVERRIDE.ID  = 'AML.TXN.AMT.EXCEED'
    Y.FTTC.ID = R.NEW(FT.TRANSACTION.TYPE)

    R.TRANSACTION=''
    TRANS.ERR=''
    CALL F.READ(FN.FTTC,Y.FTTC.ID,R.FTTC,F.FTTC,ERR.FTTC)
    FT.TXN.CODE.ID=R.FTTC<FT6.TXN.CODE.CR>

    CALL F.READ(FN.TRANSACTION,FT.TXN.CODE.ID,R.TRANSACTION,F.TRANSACTION,TRANS.ERR)
    FT.TR.AML.CHECK=R.TRANSACTION<AC.TRA.LOCAL.REF><1,POS.L.TR.AML.CHECK>

    IF FT.TR.AML.CHECK EQ 'Y' ELSE
        RETURN
    END

    GOSUB GET.CUSTOMER.ID
    IF Y.CUSTOMER.ID ELSE
        RETURN
    END
    GOSUB GET.TRANSACTION.AMOUNT
    GOSUB GET.TODAY.CREDIT.TXN.AMOUNT
    GOSUB GET.TODAY.TXN.AMOUNT
    GOSUB GET.OVERPYMT.AMOUNT

    TOT.TODAY.TXN.AMT = TOT.CREDIT.CARD.TXN.AMT + TOT.TODAY.TXN.AMT + Y.GET.OVER.PAY.AMT
    IF TOT.TODAY.TXN.AMT GE Y.AMT.LIMIT.LCY THEN
        IF R.NEW(FT.LOCAL.REF)<1,POS.L.RTE.FORM> EQ 'YES' THEN
            CURR.NO = ''
            TEXT    = VAR.OVERRIDE.ID
            CALL STORE.OVERRIDE(CURR.NO)

*GOSUB ANALISE.OVERRIDE.MESSAGE
*
*IF VAR.RTE.CHK EQ 'YES' THEN
            Y.OVER.LIST = OFS$OVERRIDES
*            GOSUB PRCO.OVR ;* Commented not to produce RTE during Input
        END
*END
    END

RETURN

PRCO.OVR:

    IF Y.OVER.LIST THEN
        IF Y.OVER.LIST<2,1> EQ 'YES' AND R.NEW(FT.LOCAL.REF)<1,POS.NXT.VER> EQ '' THEN
            IF R.VERSION(EB.VER.VERSION.TYPE) NE 'NV' THEN
*                OFS$DEAL.SLIP.PRINTING = 1 ;* Commented not to produce RTE during Input
                OFS$DEAL.SLIP.PRINTING = '' ;
                CALL PRODUCE.DEAL.SLIP('AML.FT.RTE.FORM')
                Y.HID = C$LAST.HOLD.ID
                CALL APAP.AA.REDO.V.AUT.RTE.REPRINT(Y.HID) ;* R22 Manual Conversion - CALL method format modified
                PRT.ADVICED.PRODUCED = ""
            END
        END
    END ELSE
        IF R.NEW(FT.LOCAL.REF)<1,POS.NXT.VER> EQ '' THEN
            IF R.VERSION(EB.VER.VERSION.TYPE) NE 'NV' THEN
*                OFS$DEAL.SLIP.PRINTING = 1 ;* Commented not to produce RTE during Input
                OFS$DEAL.SLIP.PRINTING = ''
                CALL PRODUCE.DEAL.SLIP('AML.FT.RTE.FORM')
                Y.HID = C$LAST.HOLD.ID
                CALL APAP.AA.REDO.V.AUT.RTE.REPRINT(Y.HID) ;* R22 Manual Conversion - CALL method format modified
                PRT.ADVICED.PRODUCED = ""
            END
        END
    END

RETURN

*------------------*
GET.OVERPYMT.AMOUNT:
*------------------*

* Fix for PACS00392651 [AA OVERPAYMENT THROUGH CASH/CHEQUE]

    Y.GET.OVER.PAY.AMT = 0
    SEL.CMD.OVER = ''
    SEL.LIST.OVER = ''

    SEL.CMD.OVER = 'SELECT ':FN.REDO.AA.OVERPAYMENT:' WITH @ID LIKE ':Y.CUSTOMER.ID:'.':TODAY:'... AND PAYMENT.METHOD EQ CASH AND STATUS NE REVERSADO'
    CALL EB.READLIST(SEL.CMD.OVER,SEL.LIST.OVER,'','',SEL.ERR)
    LOOP
        REMOVE OVER.ID FROM SEL.LIST.OVER SETTING OVER.POS
    WHILE OVER.ID:OVER.POS
        CALL F.READ(FN.REDO.AA.OVERPAYMENT,OVER.ID,R.REDO.AA.OVERPAYMENT,F.REDO.AA.OVERPAYMENT,REDO.AA.OVERPAYMENT.ERR)
        Y.GET.OVER.PAY.AMT += R.REDO.AA.OVERPAYMENT<REDO.OVER.AMOUNT>

    REPEAT
RETURN

*-----------------------------------------------------------
GET.CUSTOMER.ID:
*-----------------------------------------------------------

    Y.CREDIT.ACC.NO = R.NEW(FT.CREDIT.ACCT.NO)
    CALL F.READ(FN.ACCOUNT,Y.CREDIT.ACC.NO,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.CUSTOMER.ID = R.ACCOUNT<AC.CUSTOMER>

RETURN
*-----------------------------------------------------------
GET.TRANSACTION.AMOUNT:
*-----------------------------------------------------------


    FT.TXN.CCY  = R.NEW(FT.CREDIT.CURRENCY)
    FT.TXN.AMT  = R.NEW(FT.CREDIT.AMOUNT)
    TOT.TXN.AMT = R.NEW(FT.CREDIT.AMOUNT)
    IF FT.TXN.CCY NE LCCY THEN
        CALL CACHE.READ(FN.CUR,FT.TXN.CCY,R.CUR,CURR.ERR)
        CUR.AMLBUY.RATE = R.CUR<EB.CUR.LOCAL.REF,POS.L.CU.AMLBUY.RT>
        TOT.TXN.AMT     = FT.TXN.AMT * CUR.AMLBUY.RATE
    END

RETURN

* ==========================
GET.TODAY.CREDIT.TXN.AMOUNT:
* ==========================
*
    TOT.CREDIT.CARD.TXN.AMT = 0
*
    IF Y.CUSTOMER.ID THEN
        Y.CUSTOMER.CODE         = Y.CUSTOMER.ID : '.' :TODAY
*
        CALL F.READ(FN.REDO.CREDIT.TRANS.TELLER,Y.CUSTOMER.CODE,R.REDO.CREDIT.TRANS.TELLER,F.REDO.CREDIT.TRANS.TELLER,TILL.ERR)
        IF R.REDO.CREDIT.TRANS.TELLER THEN
            GOSUB GET.TOTAL.CREDIT.TXN.AMOUNT
        END
    END
*
RETURN

* ==========================
GET.TOTAL.CREDIT.TXN.AMOUNT:
* ==========================
*
    Y.TELLER.ID.LIST = R.REDO.CREDIT.TRANS.TELLER<CT.TRANSACTION.ID>
    CHANGE @VM TO @FM IN Y.TELLER.ID.LIST ;*;*MANUAL R22 CODE CONVERSTION
    Y.ID.CNT      = DCOUNT(Y.TELLER.ID.LIST,@FM) ;*;*MANUAL R22 CODE CONVERSTION
    Y.ID.LOOP.CNT = 1
    Y.LCCY.AMT    = 0
*
    LOOP
    WHILE Y.ID.LOOP.CNT LE Y.ID.CNT
        CALL F.READ(FN.TELLER,Y.TELLER.ID.LIST<Y.ID.LOOP.CNT>,R.TELLER,F.TELLER,ERR)
        TOT.CREDIT.CARD.TXN.AMT += R.TELLER<TT.TE.AMOUNT.LOCAL.1>
        Y.ID.LOOP.CNT++
    REPEAT
*
RETURN
*
*--------------------------------------------------------------------
GET.TODAY.TXN.AMOUNT:
*--------------------------------------------------------------------

    CALL F.READ(FN.CUSTOMER.ACCOUNT,Y.CUSTOMER.ID,R.CUSTOMER.ACCOUNT,F.CUSTOMER.ACCOUNT,CUS.ACC.ERR)
*
    LOOP
        REMOVE Y.ACC.ID FROM R.CUSTOMER.ACCOUNT SETTING Y.POS
    WHILE Y.ACC.ID:Y.POS
        CALL F.READ(FN.ACCT.ENT.TODAY,Y.ACC.ID,R.ACCT.ENT.TODAY,F.ACCT.ENT.TODAY,ACCT.ENT.ERR)
        CALL F.READ(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        GOSUB GET.AMLBUY.RATE     ;* 2012MAY24 - Code Review
        LOOP
            REMOVE Y.STMT.ENTRY FROM R.ACCT.ENT.TODAY SETTING Y.STMT.POS
        WHILE Y.STMT.ENTRY:Y.STMT.POS
            CALL F.READ(FN.STMT.ENTRY,Y.STMT.ENTRY,R.STMT.ENTRY,F.STMT.ENTRY,STMT.ERR)
            IF R.STMT.ENTRY EQ '' THEN
                CALL F.READ(FN.STMT.ENTRY.DETAIL,Y.STMT.ENTRY,R.STMT.ENTRY,F.STMT.ENTRY.DETAIL,STMT.ERR)
            END
            STMT.TXN.CODE = R.STMT.ENTRY<AC.STE.TRANSACTION.CODE>
            STMT.VAL.DATE = R.STMT.ENTRY<AC.STE.VALUE.DATE>
            IF STMT.VAL.DATE EQ TODAY THEN
                R.TRANSACTION = ''; TRANS.ERR = '' ; WTR.AML.CHECK = ''
                GOSUB VALIDATE.AML.CHECK        ;* 2012MAY24 - Code Review
            END
        REPEAT
    REPEAT
*

    TOT.TODAY.TXN.AMT = ABS(TOT.TODAY.TXN.AMT)
    TOT.TODAY.TXN.AMT = TOT.TXN.AMT + TOT.TODAY.TXN.AMT
RETURN
*--------------------------------------------------------------------
GET.AMLBUY.RATE:
*--------------------------------------------------------------------
*
    WACCT.CCY = R.ACCOUNT<AC.CURRENCY>
    CALL CACHE.READ(FN.CUR,WACCT.CCY,R.CUR,CURR.ERR)
    CUR.AMLBUY.RATE = R.CUR<EB.CUR.LOCAL.REF,POS.L.CU.AMLBUY.RT>
RETURN

*--------------------------------------------------------------------
VALIDATE.AML.CHECK:
*--------------------------------------------------------------------
*
    CALL CACHE.READ(FN.TRANSACTION,STMT.TXN.CODE,R.TRANSACTION,TRANS.ERR)
    WTR.AML.CHECK = R.TRANSACTION<AC.TRA.LOCAL.REF><1,POS.L.TR.AML.CHECK>
*
    IF WTR.AML.CHECK EQ 'Y' THEN
*
        IF WACCT.CCY EQ LCCY THEN
            TOT.TODAY.TXN.AMT += R.STMT.ENTRY<AC.STE.AMOUNT.LCY>
        END ELSE
            TOT.TODAY.TXN.AMT += R.STMT.ENTRY<AC.STE.AMOUNT.FCY> * CUR.AMLBUY.RATE
        END
    END ELSE

        GET.TFS.ID = R.STMT.ENTRY<AC.STE.THEIR.REFERENCE>
        GOSUB GET.TFS.TOTAL
    END
RETURN

*-----------------------------------------------------------------------------------------------------------------------
GET.TFS.TOTAL:
*-----------------------------------------------------------------------------------------------------------------------

    IF GET.TFS.ID[1,5] EQ 'T24FS' THEN
        CALL F.READ(FN.T24.FUND.SERVICES,GET.TFS.ID,R.T24.FUND.SERVICES,F.T24.FUND.SERVICES,TFS.ERR)

        LOCATE GET.TFS.ID IN Y.TFS.LIST SETTING POS THEN
            RETURN
        END
        Y.TFS.LIST <-1> = GET.TFS.ID
        Y.TFS.TXN.CODES = R.T24.FUND.SERVICES<TFS.TRANSACTION>
        Y.TFS.TXN.COUNT = DCOUNT(Y.TFS.TXN.CODES,@VM) ;*MANUAL R22 CODE CONVERSTION
        Y.TFS.COUNT = 1

        LOOP
        WHILE Y.TFS.COUNT LE Y.TFS.TXN.COUNT
            TFS.TRANSACTION.ID = Y.TFS.TXN.CODES<1,Y.TFS.COUNT>

            IF TFS.TRANSACTION.ID EQ 'CASHDEPD' THEN

                TOT.TODAY.TXN.AMT += R.T24.FUND.SERVICES<TFS.AMOUNT,Y.TFS.COUNT>

            END
            Y.TFS.COUNT++
        REPEAT
    END
RETURN

* =======================
ANALISE.OVERRIDE.MESSAGE:
* =======================
*
*  Checking for Overrides
*
*CALL F.READ(FN.OVERRIDE,VAR.OVERRIDE.ID,R.OVERRIDE,F.OVERRIDE,ERR.MSG)
*
* Getting the Override Message
*
*VAR.MESSAGE1 = R.OVERRIDE<EB.OR.MESSAGE,1,2>
*VAR.MESSAGE2 = 'YES'
*
*  Getting the Override Message Values
*
*VAR.OFS.OVERRIDE1 = OFS$OVERRIDES<1>
*VAR.OFS.OVERRIDE2 = OFS$OVERRIDES<2>
*
*  Converting to FM for locate Purpose
*
*CHANGE VM TO FM IN VAR.OFS.OVERRIDE1
*CHANGE VM TO FM IN VAR.OFS.OVERRIDE2
*
*  Checking FOR the override MESSAGE
*
*VAR.RTE.CHK = ""
*
*LOCATE VAR.MESSAGE1 IN VAR.OFS.OVERRIDE1 SETTING POS1 THEN
*R.NEW(TT.TE.LOCAL.REF)<1,POS.L.RTE.FORM> = 'YES'
*END ELSE
*POS1 = ''
*END
**
*LOCATE VAR.MESSAGE2 IN VAR.OFS.OVERRIDE2 SETTING POS2 THEN
*VAR.RTE.CHK = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.RTE.FORM>
*END
*
RETURN
*


END
