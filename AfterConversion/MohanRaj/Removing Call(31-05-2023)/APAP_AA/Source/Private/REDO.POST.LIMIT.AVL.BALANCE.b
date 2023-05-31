* @ValidationCode : MjotMTgyMDM3NjY4MzpDcDEyNTI6MTY4NTUzMTQzNzgyMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:40:37
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
$PACKAGE APAP.AA;*Manual R22 code conversion
SUBROUTINE REDO.POST.LIMIT.AVL.BALANCE
*------------------------------------------------------
*Description: This routine is to update the available balance(LIMIT>L.AVL.BALANCE),
*             during following activities..
*Activity:
*        1) LENDING-NEW-ARRANGEMENT          * L.AVL.BALANCE = INTERNAL.AMOUNT(LIMIT) - TERM.AMOUNT(AA).
*        2) LENDING-APPLYPAYMENT-ARRANGEMENT * L.AVL.BALANCE = L.AVL.BALANCE + Amount hit the ACCOUNT property by this repayment.
*        3) LENDING-SETTLE-ARRANGEMENT       * L.AVL.BALANCE = L.AVL.BALANCE + Amount hit the ACCOUNT property by this repayment.
*        4) LENDING-APPLYPAYMENT-ARRANGEMENT(Payoff)
*                                           *  For REVOLVING loan
*                                                       L.AVL.BALANCE = L.AVL.BALANCE+Amount hit the ACCOUNT property by this repayment.
*                                           *  For NON-REVOLVING loan
*                                                       L.AVL.BALANCE =  L.AVL.BALANCE + TERM.AMOUNT(AA).
*----------------------------------------------------------------------------------------------------------
*Modification History
*Date           Who                     Reference                                  Descripition
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA, CALL method format changed
* 29-03-2023  Conversion Tool     Auto R22 code conversion                 VM TO @VM ,FM.FMT TO @FM.FMT,SM TO @SM
*------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.LIMIT
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM
    IF c_aalocActivityStatus EQ 'UNAUTH' AND c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-NEW-ARRANGEMENT' THEN
*GOSUB UNAUTH.PROCESS
    END
    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB AUTH.PROCESS
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        IF c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> MATCHES 'LENDING-APPLYPAYMENT-PAYMENT.RULES':@VM:'LENDING-SETTLE-PAYMENT.RULES' THEN
            GOSUB REVERSE.PROCESS
        END
    END
    IF Y.LIMIT.ID THEN        ;* Release the limit file at the end.
        CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)
    END

RETURN
*------------------------------------------------------
UNAUTH.PROCESS:
*------------------------------------------------------
*At UNAUTH processing level to throw error message if the available balance of the limit falls below zero.

*IF c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-NEW-ARRANGEMENT' ELSE ;* only for new arrangement activity.
*RETURN
*END
    GOSUB OPEN.FILES
    GOSUB GET.LIMIT.PROD.COND
    CALL F.READ(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR)

    IF Y.LIMIT.ID AND R.LIMIT ELSE      ;* Skip the following processing since the loan dont have the limit reference or record.
        RETURN
    END
    Y.INTERNAL.AMOUNT = R.LIMIT<LI.INTERNAL.AMOUNT>
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.TERM.AMOUNT     = R.NEW(AA.AMT.AMOUNT)
    IF Y.AVL.BALANCE EQ '' THEN         ;*   if it is NULL then
        IF (Y.INTERNAL.AMOUNT - Y.TERM.AMOUNT) LT 0 THEN
            AF = AA.AMT.AMOUNT
            ETEXT = 'EB-REDO.LIMIT.INSUFF.AVLBAL':@FM:FMT(Y.AVL.BALANCE,'L2,#15')
            CALL STORE.END.ERROR
        END
        RETURN
    END

    IF Y.AVL.BALANCE EQ 0 THEN          ;* If it is ZERO then
        AF    = AA.AMT.AMOUNT
        ETEXT = 'EB-REDO.LIMIT.INSUFF.AVLBAL':@FM:FMT(Y.AVL.BALANCE,'L2,#15')
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.AVL.BALANCE GT 0 THEN          ;* If it has balance then
        IF (Y.AVL.BALANCE - Y.TERM.AMOUNT) LT 0 THEN
            AF    = AA.AMT.AMOUNT
            ETEXT = 'EB-REDO.LIMIT.INSUFF.AVLBAL':@FM:FMT(Y.AVL.BALANCE,'L2,#15')
            CALL STORE.END.ERROR
        END
    END

RETURN
*------------------------------------------------------
AUTH.PROCESS:
*------------------------------------------------------
* At AUTH Processing level, we will update the available balance of the limit during new arrangement
* repayment activity level.

    GOSUB OPEN.FILES

    BEGIN CASE
        CASE c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-NEW-ARRANGEMENT'
*GOSUB PROCESS.NEW.ARRANGEMENT
        CASE c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-TAKEOVER-ARRANGEMENT'
*       For future purpose.
        CASE c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> MATCHES 'LENDING-APPLYPAYMENT-PAYMENT.RULES':@VM:'LENDING-SETTLE-PAYMENT.RULES'
            GOSUB PROCESS.REPAYMENT
    END CASE

RETURN
*------------------------------------------------------
REVERSE.PROCESS:
*------------------------------------------------------
* During reversal of the payment, we will update the available balance of the limit.

    GOSUB OPEN.FILES
    GOSUB GET.LIMIT.PROD.COND
    IF Y.LIMIT.ID ELSE        ;* Skip the following processing since the loan dont have the limit reference or record.
        RETURN
    END
    CALL F.READU(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR,"")
    IF R.LIMIT EQ '' THEN
        RETURN
    END
    Y.FT.REPAY.REF = c_aalocArrActivityId
    CALL F.READU(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE,F.REDO.CONCAT.LIMIT.BALANCE,CNCT.ERR,"")
    LOCATE Y.FT.REPAY.REF IN R.REDO.CONCAT.LIMIT.BALANCE<1,1> SETTING FT.POS THEN
        Y.TXN.AMT = R.REDO.CONCAT.LIMIT.BALANCE<2,FT.POS>
    END ELSE
        CALL F.RELEASE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,F.REDO.CONCAT.LIMIT.BALANCE)
        RETURN      ;* In case of non revolving loan, then for the normal repayments, FT REF will not be updated.
*                 So it wont be located during reversal and we need not to update available balance.
    END
    IF R.REDO.CONCAT.LIMIT.BALANCE<3,FT.POS> NE 'YES' THEN
        R.REDO.CONCAT.LIMIT.BALANCE<3,FT.POS> = 'YES'
    END ELSE
        R.REDO.CONCAT.LIMIT.BALANCE<3,FT.POS> = 'SECOND.TIME.REV'
        CALL F.WRITE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE)
        CALL F.RELEASE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,F.REDO.CONCAT.LIMIT.BALANCE)
        RETURN      ;* If it is YES then it has been already reversed. Second time getting triggered due to some other reason like 2nd activity.
    END
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.NEW.AVL.BALANCE = (Y.AVL.BALANCE - Y.TXN.AMT)
    R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE> = Y.NEW.AVL.BALANCE
    TEMP.V = V
    V      = LI.AUDIT.DATE.TIME
    CALL F.LIVE.WRITE(FN.LIMIT,Y.LIMIT.ID,R.LIMIT)
    V      = TEMP.V
    CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)
    Y.CHILD.BALANCE = -1 * Y.TXN.AMT
    GOSUB UPDATE.PARENT.LIMIT
    CALL F.WRITE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE)
    CALL F.RELEASE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,F.REDO.CONCAT.LIMIT.BALANCE)

RETURN
*------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------

    FN.LIMIT = 'F.LIMIT'
    F.LIMIT  = ''
    CALL OPF(FN.LIMIT,F.LIMIT)

    FN.AA.ACTIVITY.BALANCES = 'F.AA.ACTIVITY.BALANCES'
    F.AA.ACTIVITY.BALANCES  = ''
    CALL OPF(FN.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES)

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT  = ''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM  = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.REDO.CONCAT.LIMIT.BALANCE = 'F.REDO.CONCAT.LIMIT.BALANCE'
    F.REDO.CONCAT.LIMIT.BALANCE  = ''
    CALL OPF(FN.REDO.CONCAT.LIMIT.BALANCE,F.REDO.CONCAT.LIMIT.BALANCE)

    LOC.REF.APPLICATION   = "LIMIT"
    LOC.REF.FIELDS        = 'L.AVL.BALANCE'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AVL.BALANCE     = LOC.REF.POS<1,1>

RETURN
*------------------------------------------------------
PROCESS.NEW.ARRANGEMENT:
*------------------------------------------------------
* Here we will check whether it is loan has limit then we will update the available balance.

    GOSUB GET.LIMIT.PROD.COND
    IF Y.LIMIT.ID ELSE        ;* Skip the following processing since the loan dont have the limit reference or record.
        RETURN
    END
    CALL F.READU(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR,"")
    IF R.LIMIT EQ '' THEN
        RETURN
    END
    Y.INTERNAL.AMOUNT = R.LIMIT<LI.INTERNAL.AMOUNT>
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.TERM.AMOUNT     = R.NEW(AA.AMT.AMOUNT)

    BEGIN CASE
        CASE Y.AVL.BALANCE EQ ''  ;*   if it is NULL then
            Y.NEW.AVL.BALANCE = Y.INTERNAL.AMOUNT - Y.TERM.AMOUNT
        CASE OTHERWISE
            Y.NEW.AVL.BALANCE = (Y.AVL.BALANCE - Y.TERM.AMOUNT)
    END CASE

    R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE> = Y.NEW.AVL.BALANCE
    TEMP.V = V
    V      = LI.AUDIT.DATE.TIME
    CALL F.LIVE.WRITE(FN.LIMIT,Y.LIMIT.ID,R.LIMIT)
    V      = TEMP.V
    CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)

RETURN
*------------------------------------------------------
PROCESS.REPAYMENT:
*------------------------------------------------------
* Here during repayment we will update the available balance of limit if it is revolving limit.
* during payoff of the loan, we will make the total loan amount available.

    Y.PRODUCT.GROUP.ID = c_aalocArrangementRec<AA.ARR.PRODUCT.GROUP>
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    Y.PAYOFF.ACTIVITY =  R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PAYOFF.ACTIVITY>:@VM:R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PAYOFF.ACT.UNC>

* LOCATE AA$CURR.ACTIVITY IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN       ;* If it is payoff activity then
****Manual R22 Code Conversion**********
    LOCATE c_aalocCurrActivity IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN       ;* If it is payoff activity then
        IF R.NEW(AA.AMT.REVOLVING) MATCHES 'PAYMENT':@VM:'PREPAYMENT' THEN
            GOSUB PROCESS.PAYOFF.REVOLVING.OR.REPAYMENT
        END ELSE
            GOSUB PROCESS.PAYOFF.NON.REVOLVING
        END
    END ELSE        ;* If it is not a payoff activity then check is it a revolving loan.
        IF R.NEW(AA.AMT.REVOLVING) MATCHES 'PAYMENT':@VM:'PREPAYMENT' THEN
            GOSUB PROCESS.PAYOFF.REVOLVING.OR.REPAYMENT
        END ELSE
            RETURN  ;* This process is only for revolving loans.
        END
    END

RETURN
*------------------------------------------------------
PROCESS.PAYOFF.REVOLVING.OR.REPAYMENT:
*------------------------------------------------------
* Update the available limit based on the balance of ACCOUNT property been paid.

    GOSUB GET.LIMIT.PROD.COND
    IF Y.LIMIT.ID ELSE        ;* Skip the following processing since the loan dont have the limit reference or record.
        RETURN
    END
    GOSUB GET.ACCOUNT.REPAID.BALANCE    ;* Here we will get the balance of the ACCOUNT property been paid.
    CALL F.READU(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR,"")
    IF R.LIMIT EQ '' THEN
        RETURN
    END
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.NEW.AVL.BALANCE = (Y.AVL.BALANCE + Y.ACCOUNT.PROP.AMOUNT)
    R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE> = Y.NEW.AVL.BALANCE
    TEMP.V = V
    V      = LI.AUDIT.DATE.TIME
    CALL F.LIVE.WRITE(FN.LIMIT,Y.LIMIT.ID,R.LIMIT)
    V      = TEMP.V
    CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)
    Y.CHILD.BALANCE = Y.ACCOUNT.PROP.AMOUNT
    GOSUB UPDATE.PARENT.LIMIT

    Y.TRANSACTION.REF = c_aalocArrActivityId
    CALL F.READU(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE,F.REDO.CONCAT.LIMIT.BALANCE,CNCT.ERR,"")
    LOCATE c_aalocArrActivityId IN R.REDO.CONCAT.LIMIT.BALANCE<1,1> SETTING CNCT.POS THEN
        R.REDO.CONCAT.LIMIT.BALANCE<1,CNCT.POS> = Y.TRANSACTION.REF
        R.REDO.CONCAT.LIMIT.BALANCE<2,CNCT.POS> = Y.ACCOUNT.PROP.AMOUNT
        R.REDO.CONCAT.LIMIT.BALANCE<3,CNCT.POS> = ''
    END ELSE
        R.REDO.CONCAT.LIMIT.BALANCE<1,-1> = Y.TRANSACTION.REF
        R.REDO.CONCAT.LIMIT.BALANCE<2,-1> = Y.ACCOUNT.PROP.AMOUNT
        R.REDO.CONCAT.LIMIT.BALANCE<3,-1> = ''
    END
    CALL F.WRITE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE)
    CALL F.RELEASE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,F.REDO.CONCAT.LIMIT.BALANCE)

RETURN
*------------------------------------------------------
PROCESS.PAYOFF.NON.REVOLVING:
*------------------------------------------------------
* Check whether all the outstading of the loan has been settled then Update the available limit
* based on the loan's TERM amount.

    IF c_aalocArrActivityRec<AA.ARR.ACT.TXN.SYSTEM.ID> EQ 'FT' OR c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-SETTLE-PAYMENT.RULES' ELSE       ;* We need to update only during the main activity for normal repayment/ any settle activity.
        RETURN
    END

    GOSUB GET.LIMIT.PROD.COND
    IF Y.LIMIT.ID ELSE        ;* Skip the following processing since the loan dont have the limit reference or record.
        RETURN
    END
    GOSUB CHECK.WHETHER.ALL.SETTLED
    IF Y.TOTAL.AMT THEN       ;* There is some outstanding available, so dont update the balance.
        RETURN
    END
    IF R.NEW(AA.AMT.AMOUNT) THEN
        Y.TERM.AMOUNT = R.NEW(AA.AMT.AMOUNT)
    END  ELSE       ;* Expired migrated loans will not have amount here.
        GOSUB GET.TERM.AMOUNT.MIGRATED
    END

    CALL F.READU(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR,"")
    IF R.LIMIT EQ '' THEN
        RETURN
    END
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.NEW.AVL.BALANCE = (Y.AVL.BALANCE + Y.TERM.AMOUNT)

    R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE> = Y.NEW.AVL.BALANCE
    TEMP.V = V
    V      = LI.AUDIT.DATE.TIME
    CALL F.LIVE.WRITE(FN.LIMIT,Y.LIMIT.ID,R.LIMIT)
    V      = TEMP.V
    CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)
    Y.CHILD.BALANCE = Y.TERM.AMOUNT
    GOSUB UPDATE.PARENT.LIMIT
    Y.TRANSACTION.REF = c_aalocArrActivityId
    CALL F.READU(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE,F.REDO.CONCAT.LIMIT.BALANCE,CNCT.ERR,"")
    LOCATE c_aalocArrActivityId IN R.REDO.CONCAT.LIMIT.BALANCE<1,1> SETTING CNCT.POS THEN
        R.REDO.CONCAT.LIMIT.BALANCE<1,CNCT.POS> = Y.TRANSACTION.REF
        R.REDO.CONCAT.LIMIT.BALANCE<2,CNCT.POS> = Y.TERM.AMOUNT
        R.REDO.CONCAT.LIMIT.BALANCE<3,CNCT.POS> = ''
    END ELSE
        R.REDO.CONCAT.LIMIT.BALANCE<1,-1> = Y.TRANSACTION.REF
        R.REDO.CONCAT.LIMIT.BALANCE<2,-1> = Y.TERM.AMOUNT
        R.REDO.CONCAT.LIMIT.BALANCE<3,-1> = ''
    END
    CALL F.WRITE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,R.REDO.CONCAT.LIMIT.BALANCE)
    CALL F.RELEASE(FN.REDO.CONCAT.LIMIT.BALANCE,c_aalocArrId,F.REDO.CONCAT.LIMIT.BALANCE)

RETURN
*------------------------------------------------------
CHECK.WHETHER.ALL.SETTLED:
*------------------------------------------------------
* Here we will check whether all the outstanding balances of the loan has been settled or not.
* Because in case of payoff cheque reversal, we will re-post the payoff FT for the partial amount(when multiple cheque/payment)
* So we shouldnot blindly make the fund available in limit.

    Y.ID.DETAILS = c_aalocArrId:"*":c_aalocActivityEffDate
    APAP.TAM.redoGetTotalOutstandingSinUncUnd(Y.ID.DETAILS,Y.PROP.AMT,Y.TOTAL.AMT);* R22 Manual conversion

RETURN
*------------------------------------------------------
GET.TERM.AMOUNT.MIGRATED:
*------------------------------------------------------

    Y.LOAN.ORIGINAL.START.DATE = c_aalocArrangementRec<AA.ARR.ORIG.CONTRACT.DATE>
    Y.AA.ARR.TM.ID = c_aalocArrId:'-':FIELD(ID.NEW,'-',2):'-':Y.LOAN.ORIGINAL.START.DATE:'.':1      ;* AA.ARR record from the Commitment amend history record.
    CALL F.READ(FN.AA.ARR.TERM.AMOUNT,Y.AA.ARR.TM.ID,R.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT,ARR.TERM.ERR)
    Y.TERM.AMOUNT = R.AA.ARR.TERM.AMOUNT<AA.AMT.AMOUNT>

RETURN
*------------------------------------------------------
GET.ACCOUNT.REPAID.BALANCE:
*------------------------------------------------------
* Here we will get the balance of the ACCOUNT property been paid.

    Y.ACCOUNT.PROP.AMOUNT = 0
    IN.PROPERTY.CLASS = 'ACCOUNT'
    OUT.PROPERTY      = ''
    APAP.TAM.redoGetPropertyName(c_aalocArrId,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR);* R22 Manual conversion
    Y.ACCOUNT.PROP = OUT.PROPERTY

*Y.AAA.IDS =  c_aalocArrActivityId:VM:c_aalocArrActivityRec<AA.ARR.ACT.CHILD.ACTIVITY>
    Y.AAA.IDS =  c_aalocArrActivityId

    CALL F.READ(FN.AA.ACTIVITY.BALANCES,c_aalocArrId,R.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES,BAL.ERR)
    LOOP
        REMOVE Y.AAA.ID FROM Y.AAA.IDS SETTING AAA.POS
    WHILE Y.AAA.ID:AAA.POS
        LOCATE Y.AAA.ID IN R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.REF,1> SETTING POS2 THEN
            Y.PROPERTY     = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2>
            Y.PROPERTY.BAL.TYPE = FIELDS(Y.PROPERTY,'.',1)
            Y.PROPERTY.AMT = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY.AMT,POS2>
            GOSUB CALC.AMT
        END
    REPEAT

RETURN
*------------------------------------------------------
CALC.AMT:
*------------------------------------------------------
* Amount settled the account property.

    Y.PROP.CNT = DCOUNT(Y.PROPERTY,@SM)
    Y.CNT1 = 1
    LOOP
    WHILE Y.CNT1 LE Y.PROP.CNT
        Y.PROP = Y.PROPERTY.BAL.TYPE<1,1,Y.CNT1>
        IF Y.PROP EQ Y.ACCOUNT.PROP THEN
            Y.ACCOUNT.PROP.AMOUNT += Y.PROPERTY.AMT<1,1,Y.CNT1>
        END
        Y.CNT1 += 1   ;* R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------
GET.LIMIT.PROD.COND:
*------------------------------------------------------
    Y.LIMIT.REF = ''
    Y.LIMIT.ID  = ''
    EFF.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'LIMIT'
    PROPERTY    = ''
    R.LIMIT.CONDITION = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,PROP.CLASS,PROPERTY,R.LIMIT.CONDITION,ERR.MSG);* R22 Manual conversion
*AA Changes 20161013
    Y.LIMIT.REF = R.LIMIT.CONDITION<AA.LIM.LIMIT.REFERENCE>
    Y.LIMIT.SERIAL = R.LIMIT.CONDITION<AA.LIM.LIMIT.SERIAL>
    IF Y.LIMIT.REF THEN
*    REF.NO = FMT(FIELD(Y.LIMIT.REF,'.',1,1),"7'0'R")
*    SEQ.NO = FMT(FIELD(Y.LIMIT.REF,'.',2,1),"2'0'R")
        REF.NO = FMT(Y.LIMIT.REF,"7'0'R")
        SEQ.NO = FMT(Y.LIMIT.SERIAL,"2'0'R")
*AA Changes 20161013
        Y.LIMIT.ID  = c_aalocArrangementRec<AA.ARR.CUSTOMER>:".":REF.NO:".":SEQ.NO
    END
RETURN
*------------------------------------------------------
UPDATE.PARENT.LIMIT:
*------------------------------------------------------

    Y.LIMIT.REF.ID = Y.LIMIT.REF
    Y.LIMIT.SEQ    = Y.LIMIT.REF.ID[".",2,1]
    Y.LIMIT.ID     = Y.LIMIT.REF.ID[".",1,1]
    Y.LIMIT.ID     = Y.LIMIT.ID[1,LEN(Y.LIMIT.ID)-2]
    Y.LIMIT.ID     = FMT(Y.LIMIT.ID : "00.","8'0'R")
    Y.LIMIT.ID     = c_aalocArrangementRec<AA.ARR.CUSTOMER>: "." : Y.LIMIT.ID : Y.LIMIT.SEQ

    CALL F.READU(FN.LIMIT,Y.LIMIT.ID,R.LIMIT,F.LIMIT,LIMIT.ERR,"")
    IF R.LIMIT EQ '' THEN
        RETURN
    END
    Y.INTERNAL.AMOUNT = R.LIMIT<LI.INTERNAL.AMOUNT>
    Y.AVL.BALANCE     = R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE>
    Y.NEW.AVL.BALANCE = Y.AVL.BALANCE + Y.CHILD.BALANCE
    R.LIMIT<LI.LOCAL.REF,POS.L.AVL.BALANCE> = Y.NEW.AVL.BALANCE
    TEMP.V = V
    V      = LI.AUDIT.DATE.TIME
    CALL F.LIVE.WRITE(FN.LIMIT,Y.LIMIT.ID,R.LIMIT)
    V      = TEMP.V
    CALL F.RELEASE(FN.LIMIT,Y.LIMIT.ID,F.LIMIT)

RETURN
END
