* @ValidationCode : MjoxNjUyNTMxNTQ2OkNwMTI1MjoxNjg1NTMyNjA0NjIzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:00:04
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
SUBROUTINE REDO.UPDATE.NAB.HISTORY.MIG
*-----------------------------------------------------------------------------
* Description
*
* Attached as a POST routine in ACTIVITY.API for the activity LENDING-AGE-APAP.OVERDUE*NAB for the UPDATE action
*
* This routine will update the file REDO.UPDATE.NAB.HISTORY when the Arrangement moves to NAB status
*
*
* Input/Output:
*----------------
*
* IN  : -NA-
* OUT : -NA-
*---------------
*
*-----------------------------------------------------------------------------------------------------------------------------
*
* Modification History
*
*-------------------------------------------------------------------------------------------------------------------------------------
*   Date               |           Who                    |           Reference                    |          Description
*------------------------------------------------------------------------------------------------------------------------------
*
*  Nov-11                      Ravikiran AV                             CR-41                               NAB Accounting
*
*  20-10-2012                  MARIMUTHU S                             NAB AND WOF                          PACS00202156
** 29-03-2023 R22 Auto Conversion � FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - CALL method format changed
*------------------------------------------------------------------------------------------------------------------------------
*
* All file INSERTS done here
*
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
    $INSERT I_F.REDO.AA.NAB.HISTORY
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.SCHEDULED.ACTIVITY
    $INSERT I_F.AA.PROPERTY
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.DATES
    $INSERT I_F.AA.PAYMENT.SCHEDULE
*-------------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
MAIN.LOGIC:

    GOSUB INITIALISE

* IF (c_aalocActivityStatus EQ 'REVERSE') THEN  ;*Reversal Processing

*     AGEING.ACT= FIELD(ACTIVITY.ID,'-',3)
*     AGEING.STATUS = FIELD(AGEING.ACT,'*',2)
*     AGE.BILLS = FIELD(AGEING.STATUS,'*',2)    ;*Flag indicating if arrangement is already in the current overdue (AGE.ALL.BILL set) status

*     CALL F.DELETE(FN.REDO.AA.NAB.HISTORY,ARR.ID)        ;* Delete the record while reversing NAB

*     IF (AGE.BILLS) THEN   ;*Build the NAB.HISTORY Record again after reversing the NAB*AGE.BILLS activity. Since the Arrangement is still in NAB
*         GOSUB FORM.NAB.HISTORY.REC
*     END

* END

* IF (c_aalocActivityStatus EQ 'UNAUTH') THEN

*    GOSUB PROCESS
* END

    IF (c_aalocActivityStatus EQ 'AUTH') THEN

        Y.OLD.STATUS = R.OLD(AA.AC.LOCAL.REF)<1,POS.L.OD.STATUS>
        Y.NEW.STATUS = R.NEW(AA.AC.LOCAL.REF)<1,POS.L.OD.STATUS>
*IF Y.NEW.STATUS EQ 'NAB' AND Y.OLD.STATUS NE 'NAB' THEN
        GOSUB PROCESS
        GOSUB GET.ACCRUED.INTEREST
        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
        GOSUB WRITE.NAB.HISTORY
*END
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------------
* File OPEN and Variables are initialised here
*
INITIALISE:


    GOSUB OPEN.FILES

    ARR.ID = c_aalocArrId

    ACCOUNT.DETAILS = c_aalocAccountDetails

    ACTIVITY.ID = c_aalocCurrActivity

    EFF.DATE = c_aalocActivityEffDate

    ARR.CURRENCY = c_aalocArrCurrency

    ARR.ACCOUNT.ID = c_aalocLinkedAccount
    RET.ERR = ''

    ARR.EFF.DATE = c_aalocAccountDetails<AA.AD.START.DATE>

    BILL.POS = ''

    APP = 'AA.ARR.ACCOUNT':@FM:'ACCOUNT'
    LOC.FLD = 'L.LOAN.STATUS':@VM:'L.OD.STATUS':@FM:'L.OD.STATUS'
    LOC.FLD.POS = ''
    CALL MULTI.GET.LOC.REF(APP, LOC.FLD, LOC.FLD.POS)
    L.LOAN.STATUS.POS = LOC.FLD.POS<1,1>
    POS.L.OD.STATUS = LOC.FLD.POS<1,2>
    L.OD.ST.AC = LOC.FLD.POS<2,1>


    IF R.NEW(AA.AC.LOCAL.REF)<1,L.LOAN.STATUS.POS> EQ 3 THEN  ;* No need to update REDO.AA.NAB.HISTORY for write off contracts during migration - PACS00344329.
        GOSUB PGM.END
    END


    GOSUB READ.ARR.ACCOUNT

RETURN
*------------------------------------------------------------------------------------------------------------------------------
* List of OPEN files
*
OPEN.FILES:

    FN.REDO.AA.NAB.HISTORY = 'F.REDO.AA.NAB.HISTORY'
    F.REDO.AA.NAB.HISTORY = ''
    CALL OPF (FN.REDO.AA.NAB.HISTORY, F.REDO.AA.NAB.HISTORY)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS, F.AA.BILL.DETAILS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER, F.CUSTOMER)

    FN.AA.INTEREST.ACCRUALS = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INTEREST.ACCRUALS = ''
    CALL OPF(FN.AA.INTEREST.ACCRUALS, F.AA.INTEREST.ACCRUALS)

    FN.AA.PROPERTY = 'F.AA.PROPERTY'
    F.AA.PROPERTY = ''
    CALL OPF(FN.AA.PROPERTY,F.AA.PROPERTY)

    FN.REDO.AA.INT.CLS = 'F.REDO.AA.INT.CLASSIFICATION'
    F.REDO.AA.INT.CLS = ''
    CALL OPF(FN.REDO.AA.INT.CLS,F.REDO.AA.INT.CLS)

    FN.AA.SCH.ACT = 'F.AA.SCHEDULED.ACTIVITY'
    F.AA.SCH.ACT = ''
    CALL OPF(FN.AA.SCH.ACT,F.AA.SCH.ACT)

RETURN
*------------------------------------------------------------------------------------------------------------------------------------
*
*
PROCESS:



    AGEING.ACT= FIELD(ACTIVITY.ID,'-',3)

    AGEING.STATUS = FIELD(AGEING.ACT,'*',2)

    GOSUB FORM.NAB.HISTORY.REC

RETURN
*--------------------------------------------------------------------------------------------------------------------------------
*
*
READ.ARR.ACCOUNT:

    CALL F.READ(FN.ACCOUNT, ARR.ACCOUNT.ID, R.ACCOUNT, F.ACCOUNT, RET.ERR)
    Y.OD.STATUS = R.ACCOUNT<AC.LOCAL.REF,L.OD.ST.AC>


    Y.COR.FIELD.VAL = ''
    Y.CURR.ACT.REC = c_aalocArrActivityRec
    Y.LOCAL.REF = c_aalocArrActivityRec<AA.ARR.ACT.FIELD.NAME>
    Y.LOCAL.REF = CHANGE(Y.LOCAL.REF,@SM,@FM)
    Y.LOCAL.REF = CHANGE(Y.LOCAL.REF,@VM,@FM)
    Y.CNT.LL = DCOUNT(Y.LOCAL.REF,@FM)

    Y.LL.S = c_aalocArrActivityRec<AA.ARR.ACT.FIELD.VALUE>
    Y.LL.S = CHANGE(Y.LL.S,@SM,@FM)
    Y.LL.S = CHANGE(Y.LL.S,@VM,@FM)

    FLG.LL = ''
    LOOP
    WHILE Y.CNT.LL GT 0 DO
        FLG.LL += 1
        Y.FIELD = Y.LOCAL.REF<FLG.LL>
        Y.COR.FIELD.NAME = FIELD(Y.FIELD,':',1)
        IF Y.COR.FIELD.NAME EQ 'L.OD.STATUS' THEN
            Y.COR.FIELD.VAL = Y.LL.S<FLG.LL>
            Y.CNT.LL = 0
        END
        Y.CNT.LL -= 1
    REPEAT


    IF Y.COR.FIELD.VAL EQ 'NAB' THEN

        CALL AA.GET.ARRANGEMENT.CONDITIONS(ARR.ID,'ACCOUNT', '','',RET.IDS, ACC.COND, RET.ERR)

        ACC.COND = RAISE(ACC.COND)
        ARR.LOAN.STATUS = ACC.COND<AA.AC.LOCAL.REF, L.LOAN.STATUS.POS>

        ARR.CATEGORY = R.ACCOUNT<AC.CATEGORY>
        ARR.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>

        CALL F.READ(FN.CUSTOMER, ARR.CUSTOMER, R.CUSTOMER, F.CUSTOMER, RET.ERR)

        ARR.SECTOR = R.CUSTOMER<EB.CUS.SECTOR>
    END ELSE

        Y.ACCT.MAS = c_aalocMasterActivity<1,2>
        Y.PRP = FIELD(Y.ACCT.MAS,'-',3)
        CALL CACHE.READ(FN.AA.PROPERTY, Y.PRP, R.AA.PROPERTY, PRP.ER) ;** R22 Auto Conversion
        Y.PRP.CLS = R.AA.PROPERTY<AA.PROP.PROPERTY.CLASS>
        Y.ACTION = FIELD(Y.ACCT.MAS,'-',2)

        IF Y.PRP.CLS EQ 'PAYMENT.RULES' AND Y.ACTION EQ 'APPLYPAYMENT' THEN
            IF Y.OD.STATUS EQ 'NAB' AND Y.COR.FIELD.VAL NE 'NAB' THEN
                R.NAB.HISTORY.REC = ''
                CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)
                R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'SETTLED'
                CALL F.WRITE(FN.REDO.AA.NAB.HISTORY,ARR.ID,R.NAB.HISTORY.REC)
                GOSUB PGM.END
            END
        END ELSE
            GOSUB PGM.END
        END

    END

RETURN
*------------------------------------------------------------------------------------------------------------------------------------
* Form the NAB History Record
*
FORM.NAB.HISTORY.REC:

    GOSUB CHECK.NAB.HIST.REC

    GOSUB GET.NAB.DATE
    IF Y.NAB.PAY.DATE ELSE
        Y.NAB.PAY.DATE = c_aalocActivityEffDate
    END

    GOSUB GET.BILL.INFO

    GOSUB GET.NAB.SUM

    R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> = INT.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = INT.NAB.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'STARTED'       ;*Status would be STARTED when the ARRANGEMENT enters NAB status
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO> = 'YES'
    IF EFF.DATE LT TODAY THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'YES'
    END ELSE
        IF EFF.DATE EQ TODAY THEN
            IF R.DATES(EB.DAT.CO.BATCH.STATUS) EQ 'O' THEN
                R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'YES'
            END ELSE
                R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'NO'
            END
        END
    END

*  GOSUB WRITE.NAB.HISTORY

RETURN
*-----------------------------------------------------------------------------------------------------------
GET.NAB.DATE:
*-----------------------------------------------------------------------------------------------------------

    Y.BILL.IDS = ACCOUNT.DETAILS<AA.AD.BILL.ID>     ;* Get the Arrangement BILL ids
    Y.BILL.STATUS = ACCOUNT.DETAILS<AA.AD.BILL.STATUS>        ;* Get the Bill Status for the corresponding BILLS
    Y.BILL.TYPE = ACCOUNT.DETAILS<AA.AD.BILL.TYPE>  ;* Get the Bill Type, Coz only the Scheduled BILLS are aged


    CHANGE @VM TO @FM IN Y.BILL.IDS
    CHANGE @SM TO @FM IN Y.BILL.IDS
    CHANGE @VM TO @FM IN Y.BILL.STATUS
    CHANGE @SM TO @FM IN Y.BILL.STATUS
    CHANGE @VM TO @FM IN Y.BILL.TYPE
    CHANGE @SM TO @FM IN Y.BILL.TYPE

    GOSUB GET.INTEREST.PROPERTY

    GOSUB GET.ACCOUNT.PROPERTY

    Y.VAR1 = 1
    Y.NAB.BILL = ''
    Y.NAB.PAY.DATE = ''
    Y.BILL.CNT = DCOUNT(Y.BILL.IDS,@FM)
    IF INT.PROPERTY AND Y.ACC.PROPERTY ELSE
        RETURN
    END
    LOOP
    WHILE Y.VAR1 LE Y.BILL.CNT
        IF Y.BILL.STATUS<Y.VAR1> NE 'SETTLED' AND Y.BILL.TYPE<Y.VAR1> EQ 'PAYMENT' THEN
            Y.BILL.ID = Y.BILL.IDS<Y.VAR1>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.BILL.DET,F.AA.BILL.DETAILS,BILL.DET.ERR)
            LOCATE Y.ACC.PROPERTY IN R.BILL.DET<AA.BD.PROPERTY,1> SETTING POS1 THEN
                LOCATE INT.PROPERTY IN R.BILL.DET<AA.BD.PROPERTY,1> SETTING POS2 THEN
                    IF Y.NAB.BILL THEN
                        Y.PAY.DATE = R.BILL.DET<AA.BD.PAYMENT.DATE>
                        IF Y.PAY.DATE LT Y.NAB.PAY.DATE THEN
                            Y.NAB.PAY.DATE = R.BILL.DET<AA.BD.PAYMENT.DATE>
                        END
                    END ELSE
                        Y.NAB.BILL     = Y.BILL.ID
                        Y.NAB.PAY.DATE = R.BILL.DET<AA.BD.PAYMENT.DATE>
                    END
                END
            END

        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
    IF Y.NAB.PAY.DATE THEN
        GOSUB GET.OVERDUE.PROPERTY
        IF Y.NO.NAB.DAYS THEN
            YREGION = ''
            YDATE = Y.NAB.PAY.DATE
            YDAYS.ORIG = '+':Y.NO.NAB.DAYS:'C'
            CALL CDT(YREGION,YDATE,YDAYS.ORIG)
            Y.NAB.PAY.DATE = YDATE
        END ELSE
            Y.NAB.PAY.DATE = ''
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------------------
GET.OVERDUE.PROPERTY:
*-----------------------------------------------------------------------------------------------------------

    EFFEC.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'OVERDUE'
    PROPERTY    = ''
    ERR.MSG     = ''
    R.OVERDUE.COND   = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFFEC.DATE,PROP.CLASS,PROPERTY,R.OVERDUE.COND,ERR.MSG);* R22 Manual conversion
    LOCATE 'NAB' IN R.OVERDUE.COND<AA.OD.OVERDUE.STATUS,1,1> SETTING POS3 THEN
        Y.NO.NAB.DAYS = R.OVERDUE.COND<AA.OD.AGEING,1,POS3>
    END

RETURN
*-----------------------------------------------------------------------------------------------------------
GET.ACCOUNT.PROPERTY:
*-----------------------------------------------------------------------------------------------------------

    IN.PROPERTY.CLASS = 'ACCOUNT'
    R.OUT.AA.RECORD   = ''
    Y.ACC.PROPERTY      = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.ACC.PROPERTY,OUT.ERR);* R22 Manual conversion

RETURN
*-----------------------------------------------------------------------------------------------------------
GET.ACCRUED.INTEREST:
*-----------------------------------------------------------------------------------------------------------
* Accured interest before NAB is updated in REDO.AA.NAB.HISTORY
    GOSUB GET.INTEREST.PROPERTY
    BAL.TYPES = 'ACC':INT.PROPERTY
    ACCOUNT.ID = c_aalocLinkedAccount
    START.DATE = c_aalocActivityEffDate ; END.DATE = '' ; SYSTEM.DATE = ''
    REQUEST.TYPE    = ''
    REQUEST.TYPE<4>  = 'ECB'
    BAL.DETAILS = ''
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BAL.TYPES, REQUEST.TYPE, START.DATE, END.DATE, SYSTEM.DATE, BAL.DETAILS, ERROR.MESSAGE)

*Y.TOT.ACC.AMT = ABS(BAL.DETAILS<4>)
    Y.TOT.ACC.AMT = 0
    CALL F.READ(FN.AA.SCH.ACT,ARR.ID,R.AA.SCH.ACT,F.AA.SCH.ACT,SCH.ERR)

    FINDSTR 'LENDING-MAKEDUE-REPAYMENT.SCHEDULE' IN R.AA.SCH.ACT<AA.SCH.ACTIVITY.NAME,1> SETTING POS.NEX THEN
        Y.NEX.BL.DATE = R.AA.SCH.ACT<AA.SCH.NEXT.DATE,POS.NEX>
    END ELSE
        Y.NEX.BL.DATE = BAL.DETAILS<1>
    END
* CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)
    R.NAB.HISTORY.REC<REDO.NAB.HIST.NXT.BILL.DATE> = Y.NEX.BL.DATE
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT> = Y.TOT.ACC.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCRUED.AMT.RAISED> = 0   ;* We will initialise to 0, Because if the loan moves out of nab due to payment and then
*                                                               moves to NAB because of non repayment of subsequent bills.


RETURN
*-------------------------------------------------------------------------------------------------------------------------------------
* Read NAB history record. If Present update it else form a new one
*
CHECK.NAB.HIST.REC:

    CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)

    IF (RET.ERR) THEN ;* Record Not present; Create a New one

        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.CURRENCY> = ARR.CURRENCY
        R.NAB.HISTORY.REC<REDO.NAB.HIST.SECTOR> = ARR.SECTOR
        R.NAB.HISTORY.REC<REDO.NAB.HIST.L.LOAN.STATUS> = ARR.LOAN.STATUS
        R.NAB.HISTORY.REC<REDO.NAB.HIST.CATEGORY> = ARR.CATEGORY

    END ELSE

        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.L.LOAN.STATUS> = ARR.LOAN.STATUS  ;* Update the Loan Status

        RETURN

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Write the NAB.HISTORY record to the LIVE template
*
WRITE.NAB.HISTORY:

    IF R.NAB.HISTORY.REC THEN

        CALL F.WRITE(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC)

    END

RETURN
*---------------------------------------------------------------------------------------------------------------------------------
* Get the Total INterest paid and Total NAB Interets
*
GET.NAB.SUM:

    NAB.INT.COUNT = DCOUNT(R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>,@VM)          ;* Loop thru each Outstanding BILL for total of INTEREST amount

    FOR NAB.COUNT = 1 TO NAB.INT.COUNT

        INT.AMT = INT.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,NAB.COUNT>
        INT.NAB.AMT = INT.NAB.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,NAB.COUNT>

    NEXT NAB.COUNT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
* Get the BILLS which are UNPAID
*
GET.BILL.INFO:

    ARR.BILL.IDS = ACCOUNT.DETAILS<AA.AD.BILL.ID>   ;* Get the Arrangement BILL ids
    ARR.BILL.STATUS = ACCOUNT.DETAILS<AA.AD.BILL.STATUS>      ;* Get the Bill Status for the corresponding BILLS
    ARR.BILL.TYPE = ACCOUNT.DETAILS<AA.AD.BILL.TYPE>          ;* Get the Bill Type, Coz only the Scheduled BILLS are aged

    CHANGE @VM TO @FM IN ARR.BILL.IDS
    CHANGE @SM TO @FM IN ARR.BILL.IDS

    CHANGE @VM TO @FM IN ARR.BILL.STATUS
    CHANGE @SM TO @FM IN ARR.BILL.STATUS

    CHANGE @VM TO @FM IN ARR.BILL.TYPE
    CHANGE @SM TO @FM IN ARR.BILL.TYPE

    BILL.COUNT = DCOUNT(ARR.BILL.IDS, @FM)

    FOR BILL = 1 TO BILL.COUNT  ;* Loop thru each BILL

        IF ARR.BILL.STATUS<BILL> NE 'SETTLED' AND ARR.BILL.TYPE<BILL> EQ 'PAYMENT' THEN       ;* Check whether the BILL is in UNPAID status. Starting from This BILL NAB Entries will be posted :)

            GOSUB GET.BILL.DETAILS

        END

    NEXT BILL

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------
* Get the BILL Information to get the NAB details
*
GET.BILL.DETAILS:

    BILL.ID = ARR.BILL.IDS<BILL>

    CALL F.READ(FN.AA.BILL.DETAILS, BILL.ID, R.BILL.DETAILS, F.AA.BILL.DETAILS, RET.ERR)
    Y.AGE.ST = R.BILL.DETAILS<AA.BD.AGING.STATUS,1>

    Y.CK.DTW = R.BILL.DETAILS<AA.BD.PAYMENT.DATE>
*IF Y.CK.DTW LE EFF.DATE THEN
    IF Y.CK.DTW LE Y.NAB.PAY.DATE THEN
        GOSUB GET.INTEREST.PROPERTY

        LOCATE INT.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING  INT.POS THEN

            INT.OS.AMT = R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,INT.POS>
            INT.OR.AMT = R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT, INT.POS>
            REPAY.REF = R.BILL.DETAILS<AA.BD.REPAY.REF, INT.POS>
            PAYMENT.DATE = FIELD(REPAY.REF,2,'-')
            INT.PAID = INT.OR.AMT  -  INT.OS.AMT

            GOSUB UPDATE.BILL.HISTORY         ;* Update the history REC

        END
    END

RETURN
*---------------------------------------------------------------------------------------------------------------------------------------
* Update the BILL information in the History Record
*
UPDATE.BILL.HISTORY:

    NAB.BILLS =  R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>
    CHANGE @VM TO @FM IN NAB.BILLS
    CHANGE @SM TO @FM IN NAB.BILLS

    BILL.COUNT1 = DCOUNT(NAB.BILLS,@FM)

    LOCATE 'NAB' IN R.BILL.DETAILS<AA.BD.AGING.STATUS,1> SETTING NAB.POS THEN

        NAB.DATE = R.BILL.DETAILS< AA.BD.AGING.ST.CHG.DT,NAB.POS>

    END

    IF (NAB.BILLS) THEN

        NAB.BILL.REC = ''

        FOR BILL1 = 1 TO BILL.COUNT1

            NAB.BILL = NAB.BILLS<BILL1>

*           BILL.ID1 = FIELD(NAB.BILL,'-',1)
            HIST.BILL = R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID,BILL1>

            HIST.BILL = FIELD(HIST.BILL,'-',1)
            NAB.BILL.REC<-1> = HIST.BILL

        NEXT BILL1

        LOCATE BILL.ID IN NAB.BILL.REC SETTING BILL.POS THEN

            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,BILL.POS> = INT.OR.AMT
            R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,BILL.POS> = PAYMENT.DATE
            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,BILL.POS> = INT.PAID
            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,BILL.POS> = INT.OS.AMT
            R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.AMT.RAISED,BILL.POS> =INT.PAID
        END ELSE

            HIST.BILL.ID = BILL.ID:'-':NAB.DATE

            R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID,-1> = HIST.BILL.ID
            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,-1> = INT.OR.AMT
            R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,-1> = PAYMENT.DATE
            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,-1> = INT.PAID
            R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,-1> = INT.OS.AMT
            R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.AMT.RAISED,BILL.POS> =INT.PAID

        END

    END ELSE

        HIST.BILL.ID = BILL.ID:'-':NAB.DATE

        R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID,-1> = HIST.BILL.ID
        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,-1> = INT.OR.AMT
        R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,-1> = PAYMENT.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,-1> = INT.PAID
        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,-1> = INT.OS.AMT
        R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.AMT.RAISED,BILL.POS> =INT.PAID

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
GET.INTEREST.PROPERTY:

    ARR.INFO<1> =ARR.ID ; R.ARRANGEMENT = ''
    Y.EFF.DATE = ARR.EFF.DATE

    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''

    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes
    CLASS.LIST = RAISE(CLASS.LIST) ; PROP.LIST = RAISE(PROP.LIST)

    PROPERTY.CLASS = 'PAYMENT.SCHEDULE'
    PROPERTY = ''
    EFF.DATE = c_aalocActivityEffDate
    ERR.MSG = ''
    R.PAY.SCH.COND = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.PAY.SCH.COND,ERR.MSG);* R22 Manual conversion
    Y.PAYMENT.PROPERTY=R.PAY.SCH.COND<AA.PS.PROPERTY>
    CHANGE @SM TO @FM IN Y.PAYMENT.PROPERTY
    CHANGE @VM TO @FM IN Y.PAYMENT.PROPERTY
    CLASS.CTR = ''
    FLAG = 1
    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ "INTEREST" THEN
            INT.PROPERTY = PROP.LIST<CLASS.CTR>

            GOSUB GET.PRINCIPAL.INT.PROP

            IF (FLAG EQ 0) THEN      ;* Break only when PRINCIPAL INTEREST property is found
                BREAK
            END

        END
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------
* Get the principal Interest Property
*
GET.PRINCIPAL.INT.PROP:

    LOCATE INT.PROPERTY IN Y.PAYMENT.PROPERTY SETTING POS.PAY THEN
        FLAG = 0
    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------
*
*
PGM.END:

END
