* @ValidationCode : MjoyMDE5NzMwNDYxOkNwMTI1MjoxNjg1NTI5Nzg1Njg4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:13:05
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
SUBROUTINE REDO.CORRECTION.NAB.ACT.20150512(Y.AA.ID)
*---------------------------------------------------------------------------
*Description: This routine is to correct the local NAB accounting for the contracts which has first oldest bill
*             without the interest component. So bill is not considered for NAB accounting in Mig routine.
*Date : 12 May 2015
*---------------------------------------------------------------------------
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE
* 29-MAR-2023    Conversion Tool            R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM
* 29-MAR-2023      Harsha                   R22 Manual Conversion -   CALL method format changed
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.REDO.AA.NAB.HISTORY
    $INSERT I_F.REDO.AA.INT.CLASSIFICATION
    $INSERT I_REDO.CORRECTION.NAB.ACT.20150512.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.SCHEDULED.ACTIVITY
    $INSERT I_F.AA.PROPERTY
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.DATES
    $INSERT I_F.AA.PAYMENT.SCHEDULE
* Tus Start
    $INSERT I_F.EB.CONTRACT.BALANCES
    $USING APAP.TAM
* Tus End

    GOSUB PROCESS
RETURN

*---------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------

    CALL OCOMO("Processing the arrangement - ":Y.AA.ID)
    IN.ACC.ID = ""
    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.AA.ID,Y.AC.ID,ERR.TEXT);* R22 Manual conversion
    CALL F.READ(FN.ACCOUNT,Y.AC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    IF R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS> EQ "NAB" ELSE
        CALL OCOMO("Loan Not in NAB")
        RETURN
    END
    IF Y.AC.ID ELSE
        CALL OCOMO("Arrangement Account missing - ":Y.AA.ID)
        RETURN
    END
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AAD.ERR)
    Y.BILL.IDS    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>       ;* Get the Arrangement BILL ids
    Y.BILL.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.STATUS>   ;* Get the Bill Status for the corresponding BILLS
    Y.BILL.TYPE   = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>     ;* Get the Bill Type, Coz only the Scheduled BILLS are aged


    CHANGE @VM TO @FM IN Y.BILL.IDS
    CHANGE @SM TO @FM IN Y.BILL.IDS
    CHANGE @VM TO @FM IN Y.BILL.STATUS
    CHANGE @SM TO @FM IN Y.BILL.STATUS
    CHANGE @VM TO @FM IN Y.BILL.TYPE
    CHANGE @SM TO @FM IN Y.BILL.TYPE

    GOSUB GET.PROPERTIES
    IF Y.PRIN.PROP AND Y.ACCOUNT.PROPERTY ELSE
        CALL OCOMO("Property missing - ":Y.AA.ID)
        RETURN
    END
    Y.NAB.BILL.DATE = ""
    Y.BILL.CNT = DCOUNT(Y.BILL.IDS,@FM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.BILL.CNT
        IF Y.BILL.STATUS<Y.VAR1> NE 'SETTLED' AND Y.BILL.TYPE<Y.VAR1> EQ 'PAYMENT' THEN

            Y.BILL.ID = Y.BILL.IDS<Y.VAR1>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DET,F.AA.BILL.DETAILS,BILL.DET.ERR)
            LOCATE Y.ACCOUNT.PROPERTY IN R.BILL.DET<AA.BD.PROPERTY,1> SETTING POS1 THEN
                Y.NAB.BILL.ID   = Y.BILL.ID
                Y.NAB.BILL.DATE = R.BILL.DET<AA.BD.PAYMENT.DATE>
                Y.VAR1 = Y.BILL.CNT+1 ;* Break
            END

        END
        Y.VAR1 += 1    ;*R22 Auto Conversion
    REPEAT


    IF Y.NAB.BILL.DATE THEN
        IF Y.NO.NAB.DAYS THEN
            YREGION = ''
            YDATE = Y.NAB.BILL.DATE
            YDAYS.ORIG = '+':Y.NO.NAB.DAYS:'C'
            CALL CDT(YREGION,YDATE,YDAYS.ORIG)
            Y.NAB.BILL.DATE = YDATE
        END ELSE
            CALL OCOMO("Overdue date missing -":Y.AA.ID)
            RETURN
        END
    END ELSE
        CALL OCOMO("NAB Bill date missing -":Y.AA.ID)
        RETURN
    END

    GOSUB GET.NAB.BILLS
    GOSUB RAISE.ACCOUNTING

RETURN
*---------------------------------------------------------------
GET.NAB.BILLS:
*---------------------------------------------------------------

    R.NAB.HISTORY.REC = ""
    CALL F.READ(FN.REDO.AA.NAB.HISTORY,Y.AA.ID,R.NAB.HISTORY.REC,F.REDO.AA.NAB.HISTORY,HIST.ERR)
    R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID> = ""   ;* We are going to update again.
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT> = ""
    R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE> = ""
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID> = ""
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE> = ""
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.AMT.RAISED> = ""
    R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = Y.NAB.BILL.DATE

    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.BILL.CNT
        Y.BILL.ID = Y.BILL.IDS<Y.VAR1>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DET,F.AA.BILL.DETAILS,BILL.DET.ERR)
        IF Y.BILL.STATUS<Y.VAR1> NE 'SETTLED' AND Y.BILL.TYPE<Y.VAR1> EQ 'PAYMENT' AND R.BILL.DET<AA.BD.PAYMENT.DATE> LE Y.NAB.BILL.DATE THEN
            LOCATE Y.PRIN.PROP IN R.BILL.DET<AA.BD.PROPERTY,1> SETTING  INT.POS THEN
                INT.OS.AMT = R.BILL.DET<AA.BD.OS.PROP.AMOUNT,INT.POS>
                INT.OR.AMT = R.BILL.DET<AA.BD.OR.PROP.AMOUNT,INT.POS>
                REPAY.REF = R.BILL.DET<AA.BD.REPAY.REF,INT.POS>
                PAYMENT.DATE = FIELD(REPAY.REF,2,'-')
                INT.PAID = INT.OR.AMT  -  INT.OS.AMT
                GOSUB FORM.NAB.HISTORY
            END
        END
        Y.VAR1 += 1    ;*R22 Auto Conversion
    REPEAT

    R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = SUM(R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE>)
    R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> = SUM(R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID>)

    CALL F.WRITE(FN.REDO.AA.NAB.HISTORY,Y.AA.ID,R.NAB.HISTORY.REC)

RETURN
*---------------------------------------------------------------
FORM.NAB.HISTORY:
*---------------------------------------------------------------

    LOCATE 'NAB' IN R.BILL.DET<AA.BD.AGING.STATUS,1> SETTING NAB.POS THEN
        NAB.DATE = R.BILL.DET<AA.BD.AGING.ST.CHG.DT,NAB.POS>

    END

    HIST.BILL.ID = Y.BILL.ID:'-':NAB.DATE

    R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID,-1> = HIST.BILL.ID
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,-1> = INT.OR.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,-1> = PAYMENT.DATE
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,-1> = INT.PAID
    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,-1> = INT.OS.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.AMT.RAISED,-1> =INT.PAID

RETURN
*---------------------------------------------------------------
GET.PROPERTIES:
*---------------------------------------------------------------

    PROP.NAME    = "PRINCIPAL"
    Y.PRIN.PROP  = ""
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,Y.PRIN.PROP,ERR);* R22 Manual conversion

    IN.PROPERTY.CLASS  = "ACCOUNT"
    Y.ACCOUNT.PROPERTY = ""
    APAP.TAM.redoGetPropertyName(Y.AA.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.ACCOUNT.PROPERTY,OUT.ERR);* R22 Manual conversion

    EFFEC.DATE    = ""
    PROP.CLASS  = 'OVERDUE'
    PROPERTY    = ''
    ERR.MSG     = ''
    R.OVERDUE.COND   = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFFEC.DATE,PROP.CLASS,PROPERTY,R.OVERDUE.COND,ERR.MSG);* R22 Manual conversion
    LOCATE 'NAB' IN R.OVERDUE.COND<AA.OD.OVERDUE.STATUS,1,1> SETTING POS3 THEN
        Y.NO.NAB.DAYS = R.OVERDUE.COND<AA.OD.AGEING,1,POS3>
    END

RETURN
*-----------------------------------------------
RAISE.ACCOUNTING:
*-----------------------------------------------
    Y.LOAN.CATEG = R.ACCOUNT<AC.CATEGORY>
    GOSUB BEFORE.RAISE.ENTRIES
    CALL F.READ(FN.REDO.CONCAT.ACC.NAB,Y.AC.ID,R.REDO.CONCAT.ACC.NAB,F.REDO.CONCAT.ACC.NAB,CNCT.ERR)
    IF R.REDO.CONCAT.ACC.NAB THEN
        Y.NEW.AC = R.REDO.CONCAT.ACC.NAB<1>
        CALL F.READ(FN.ACCOUNT,Y.NEW.AC,R.CONT.ACC,F.ACCOUNT,ACC.ERR)
*   Tus Start
        R.ECB = ''
        ECB.ERR =''
        CALL EB.READ.HVT('EB.CONTRACT.BALANCES',Y.NEW.AC,R.ECB,ECB.ERR)
*   Tus End
        GOSUB RAISE.ENTRIES

    END ELSE
        CALL OCOMO("NAB concat record missing -":Y.AA.ID)
        RETURN
    END

RETURN
*-----------------------------------------------
RAISE.ENTRIES:
*-----------------------------------------------
*  Y.CONT.BAL     = R.CONT.ACC<AC.WORKING.BALANCE>
*  Tus start
    Y.CONT.BAL     = R.ECB<ECB.WORKING.BALANCE>
*  Tus End
    Y.NAB.INTEREST = R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST>
    Y.NAB.AMT      = Y.CONT.BAL+Y.NAB.INTEREST
    IF Y.NAB.AMT THEN
        GOSUB CALL.ACCOUNTING
    END ELSE
        CALL OCOMO("Arrangement Skipped - zero balance cont vs int acc -":Y.AA.ID)
    END

RETURN
*-----------------------------------------------
CALL.ACCOUNTING:
*-----------------------------------------------

    R.DR.STMT.ENTRY = ''
    R.STMT.ENTRY    = ''
    R.CR.STMT.ENTRY = ''

    R.DR.STMT.ENTRY<AC.STE.ACCOUNT.NUMBER>    = Y.INTERNAL.ACC
    R.DR.STMT.ENTRY<AC.STE.COMPANY.CODE>      = R.INT.ACC<AC.CO.CODE>
    R.DR.STMT.ENTRY<AC.STE.AMOUNT.LCY>        = Y.NAB.AMT
    R.DR.STMT.ENTRY<AC.STE.TRANSACTION.CODE>  = '1'
    R.DR.STMT.ENTRY<AC.STE.PRODUCT.CATEGORY>  = R.INT.ACC<AC.CATEGORY>
    R.DR.STMT.ENTRY<AC.STE.VALUE.DATE>        = "20150430"
    R.DR.STMT.ENTRY<AC.STE.CURRENCY>          = R.INT.ACC<AC.CURRENCY>
    R.DR.STMT.ENTRY<AC.STE.OUR.REFERENCE>     = R.INT.ACC<AC.CO.CODE>
    R.DR.STMT.ENTRY<AC.STE.EXPOSURE.DATE>     = TODAY
    R.DR.STMT.ENTRY<AC.STE.CURRENCY.MARKET>   = '1'
    R.DR.STMT.ENTRY<AC.STE.TRANS.REFERENCE>   = Y.NEW.AC:"NAB FIX MIG"
    R.DR.STMT.ENTRY<AC.STE.SYSTEM.ID>         = 'AC'
    R.DR.STMT.ENTRY<AC.STE.BOOKING.DATE>      = TODAY

    CHANGE @FM TO @SM IN R.DR.STMT.ENTRY
    CHANGE @SM TO @VM IN R.DR.STMT.ENTRY

    R.STMT.ENTRY<-1> = R.DR.STMT.ENTRY

    R.CR.STMT.ENTRY<AC.STE.ACCOUNT.NUMBER>   = Y.NEW.AC
    R.CR.STMT.ENTRY<AC.STE.COMPANY.CODE>     = R.CONT.ACC<AC.CO.CODE>
    R.CR.STMT.ENTRY<AC.STE.AMOUNT.LCY>       = -1*Y.NAB.AMT
    R.CR.STMT.ENTRY<AC.STE.TRANSACTION.CODE> = '51'
    R.CR.STMT.ENTRY<AC.STE.PRODUCT.CATEGORY> = R.CONT.ACC<AC.CATEGORY>
    R.CR.STMT.ENTRY<AC.STE.VALUE.DATE>       = "20150430"
    R.CR.STMT.ENTRY<AC.STE.CURRENCY>         = R.CONT.ACC<AC.CURRENCY>
    R.CR.STMT.ENTRY<AC.STE.OUR.REFERENCE>    = R.CONT.ACC<AC.CO.CODE>
    R.CR.STMT.ENTRY<AC.STE.EXPOSURE.DATE>    = TODAY
    R.CR.STMT.ENTRY<AC.STE.CURRENCY.MARKET>  = '1'
    R.CR.STMT.ENTRY<AC.STE.TRANS.REFERENCE>  = Y.NEW.AC:"NAB FIX MIG"
    R.CR.STMT.ENTRY<AC.STE.SYSTEM.ID>        = 'AC'
    R.CR.STMT.ENTRY<AC.STE.BOOKING.DATE>     = TODAY

    CHANGE @FM TO @SM IN R.CR.STMT.ENTRY
    CHANGE @SM TO @VM IN R.CR.STMT.ENTRY

    R.STMT.ENTRY<-1> = R.CR.STMT.ENTRY

    IF Y.LOAN.COMP THEN
        CALL LOAD.COMPANY(Y.LOAN.COMP)
    END

    ACC.PRODUCT = 'AC'
    ACC.TYPE    = 'SAO'         ;*Automatically overridden when an override conditions

    CALL EB.ACCOUNTING(ACC.PRODUCT,ACC.TYPE,R.STMT.ENTRY,'')  ;* Raise accounting for Consolidated
    CALL OCOMO('Processed the Arrangement & Accounting done: ':Y.AA.ID:"-":Y.NAB.AMT)

RETURN
*--------------------------------------------------------
BEFORE.RAISE.ENTRIES:
*--------------------------------------------------------

    Y.LOAN.CUR = R.ACCOUNT<AC.CURRENCY>
    Y.INTERNAL.ACC = ''
    LOCATE Y.LOAN.CATEG IN R.REDO.AA.INT.CLASSIFICATION<REDO.INT.CLASS.PROD.CATEGORY,1> SETTING POS.CMP THEN
        LOCATE Y.LOAN.CUR IN R.REDO.AA.INT.CLASSIFICATION<REDO.INT.CLASS.CURRENCY,POS.CMP,1> SETTING POS.CUR THEN
            Y.INTERNAL.ACC = R.REDO.AA.INT.CLASSIFICATION<REDO.INT.CLASS.DEBIT.INT.ACCOUNT,POS.CMP,POS.CUR>
        END
    END ELSE
        CALL OCOMO('Product category not parameterized ':Y.AA.ID)
        GOSUB END1
    END
    Y.LOAN.COMP = R.ACCOUNT<AC.CO.CODE>
    IF Y.INTERNAL.ACC THEN
        Y.LOAN.CO.CODE = Y.LOAN.COMP
        APAP.TAM.redoNabCreateIntAcc(Y.LOAN.CO.CODE,Y.INTERNAL.ACC,Y.RET.INT.ACC);* R22 Manual conversion
        Y.INTERNAL.ACC = Y.RET.INT.ACC
        CALL F.READ(FN.ACCOUNT,Y.INTERNAL.ACC,R.INT.ACC,F.ACCOUNT,ACC.ERR)
        IF R.INT.ACC ELSE
            CALL OCOMO('Internal Account not created - ':Y.AA.ID)
            GOSUB END1
        END
    END ELSE
        CALL OCOMO('Internal Account not parameterized ':Y.AA.ID)
        GOSUB END1

    END

RETURN
END1:
END
