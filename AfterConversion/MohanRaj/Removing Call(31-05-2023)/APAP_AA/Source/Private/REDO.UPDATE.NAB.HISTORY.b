* @ValidationCode : MjoyMDM2NzczNTc0OkNwMTI1MjoxNjg1NTMyNTc1MzkxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:59:35
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
SUBROUTINE REDO.UPDATE.NAB.HISTORY
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
*
*  21-07-2017                  PACS00607187 - Changes made to calculate the accrual amount during holidays instead of referring AA.INTEREST.ACCRUALS.
*                              As the AA.INTEREST.ACCRUALS is not getting updated during holidays in R15, whereas it gets once after the process is completed.
** 29-03-2023                 Conversion Tool                       R22 Auto Conversion                     FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023                   Skanda                              R22 Manual Conversion                   CALL method format changed
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
*   $INSERT I_F.AA.INTEREST.ACCRUALS ;** R22 Auto Conversion
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


    IF (c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'AUTH-REV') THEN

        Y.OLD.STATUS = R.OLD(AA.AC.LOCAL.REF)<1,POS.L.OD.STATUS>
        Y.NEW.STATUS = R.NEW(AA.AC.LOCAL.REF)<1,POS.L.OD.STATUS>
        IF Y.NEW.STATUS EQ 'NAB' AND Y.OLD.STATUS NE 'NAB' AND c_aalocActivityStatus EQ 'AUTH' THEN
            IF R.NEW(AA.AC.LOCAL.REF)<1,L.LOAN.STATUS.POS> EQ 3 THEN  ;* No need to update REDO.AA.NAB.HISTORY for write off contracts during migration - PACS00344329.
                GOSUB PGM.END
            END

            GOSUB PROCESS
            GOSUB GET.ACCRUED.INTEREST
            R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
            GOSUB WRITE.NAB.HISTORY
        END

        IF Y.NEW.STATUS EQ 'NAB' AND Y.OLD.STATUS EQ 'NAB' AND  c_aalocActivityStatus EQ 'AUTH-REV' THEN
            CALL F.READ(FN.REDO.AA.NAB.HISTORY,ARR.ID,R.AA.NAB.HIST,F.REDO.AA.NAB.HISTORY,HIST.ERR)
            Y.BK.DTED.LN = R.AA.NAB.HIST<REDO.NAB.HIST.BACK.DATED.LN>
            IF R.AA.NAB.HIST<REDO.NAB.HIST.ACCT.YES.NO> EQ 'YES' THEN
                Y.ACCT.REQ = 'Y'
                Y.ACCT.REQ<-1> = Y.BK.DTED.LN
            END ELSE
                IF R.AA.NAB.HIST<REDO.NAB.HIST.ACCT.YES.NO> EQ 'NO' THEN
                    Y.ACCT.REQ = 'N'
                    Y.ACCT.REQ<-1> = Y.BK.DTED.LN
                END
            END

            IF Y.ACCT.REQ THEN
                CALL F.WRITE(FN.REDO.NAB.BK.REV.REP,ARR.ID,Y.ACCT.REQ)
            END

            CALL F.DELETE(FN.REDO.AA.NAB.HISTORY,ARR.ID)

        END
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

    FN.AA.INT.AC = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INT.AC = ''
    CALL OPF(FN.AA.INT.AC,F.AA.INT.AC)

    FN.AAA.NAU = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AAA.NAU = ''
    CALL OPF(FN.AAA.NAU,F.AAA.NAU)

    FN.REDO.NAB.BK.REV.REP = 'F.REDO.NAB.BK.REV.REP'
    F.REDO.NAB.BK.REV.REP = ''
    CALL OPF(FN.REDO.NAB.BK.REV.REP,F.REDO.NAB.BK.REV.REP)

    FN.AAA = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AAA = ''
    CALL OPF(FN.AAA,F.AAA)


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
                IF c_aalocActivityStatus EQ 'AUTH' OR c_aalocActivityStatus EQ 'UNAUTH' THEN
                    R.NAB.HISTORY.REC = ''
                    CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'SETTLED'
                    CALL F.WRITE(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC)
                    GOSUB PGM.END
                END
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

    GOSUB GET.BILL.INFO

    GOSUB GET.NAB.SUM

    R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> = INT.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = INT.NAB.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'STARTED'     ;*Status would be STARTED when the ARRANGEMENT enters NAB status

    Y.MASTER.ACT = c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA>
    CALL F.READ(FN.AAA.NAU,Y.MASTER.ACT,R.AAA.NAU,F.AAA.NAU,NAU.AAA.ERR)

    IF NOT(R.AAA.NAU) THEN
        CALL F.READ(FN.AAA,Y.MASTER.ACT,R.AAA.NAU,F.AAA,AA.ERR)
    END

    Y.MAST.EFF.DATE = R.AAA.NAU<AA.ARR.ACT.EFFECTIVE.DATE>

    IF Y.MAST.EFF.DATE EQ EFF.DATE THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO> = 'YES'
        IF EFF.DATE LT TODAY THEN
            IF R.DATES(EB.DAT.CO.BATCH.STATUS) EQ 'B' THEN  ;* When we run month end COB say from 29 Jul to 04 Aug, then loan moves to NAB on 30&31 Jul will happen in EOD and 1,2,3 will happen in SOD.
                R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'NO'
            END ELSE
                R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'YES'
            END
        END ELSE
            IF EFF.DATE EQ TODAY THEN
                IF R.DATES(EB.DAT.CO.BATCH.STATUS) EQ 'O' THEN
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'YES'
                END ELSE
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'NO'
                END
            END
        END
    END ELSE
        Y.ACT.IDS = R.AAA.NAU<AA.ARR.ACT.ACTIVITY>
        IF Y.ACT.IDS EQ 'LENDING-DISBURSE-COMMITMENT' THEN
            GOSUB CHECK.DISB.REV
        END ELSE
            GOSUB PROC.REV.REP
        END
    END

*  GOSUB WRITE.NAB.HISTORY

RETURN

CHECK.DISB.REV:

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

RETURN

PROC.REV.REP:

    IF Y.MAST.EFF.DATE LT EFF.DATE THEN
        CALL F.READ(FN.REDO.NAB.BK.REV.REP,ARR.ID,R.REDO.NAB.BK.REV,F.REDO.NAB.BK.REV.REP,REV.ERR)
        GOSUB SUB.LOOP
    END

RETURN

SUB.LOOP:

    IF R.REDO.NAB.BK.REV THEN
        IF R.REDO.NAB.BK.REV<1> EQ 'Y' THEN
            R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO> = 'YES'
            R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = R.REDO.NAB.BK.REV<2>
        END ELSE
            IF R.REDO.NAB.BK.REV<1> EQ 'N' THEN
                R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO> = 'NO'
                R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = R.REDO.NAB.BK.REV<2>
            END
        END
        CALL F.DELETE(FN.REDO.NAB.BK.REV.REP,ARR.ID)
    END ELSE        ;* In case of repayment reversal. Say Cheque repayment was done during when loan is in DE1(85 DAYS), after some 10 days repayment is reversed and loan moves to NAB but we wont have record in R.REDO.NAB.BK.REV. then NAB accounting needs to be raised(Ref # PACS00401841 ).

        R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO>   = 'YES'
        R.NAB.HISTORY.REC<REDO.NAB.HIST.BACK.DATED.LN> = 'YES'

    END

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

* Y.TOT.ACC.AMT = ABS(BAL.DETAILS<4>)

    Y.AA.INT.AC = ARR.ID:'-':INT.PROPERTY
    CALL F.READ(FN.AA.INT.AC,Y.AA.INT.AC,R.AA.INT.AC,F.AA.INT.AC,INT.AC.ER)
    Y.PER.ST.DTE = R.AA.INT.AC<AA.INT.ACC.PERIOD.START>

    LOCATE EFF.DATE IN Y.PER.ST.DTE<1,1> BY 'AR' SETTING POS.AR THEN
        Y.FIN.PS = POS.AR - 1
        Y.PER.ST =  R.AA.INT.AC<AA.INT.ACC.PERIOD.START,Y.FIN.PS>
        Y.PER.END = R.AA.INT.AC<AA.INT.ACC.PERIOD.END,Y.FIN.PS>
*IF EFF.DATE GT Y.PER.ST AND EFF.DATE EQ Y.PER.END THEN
        Y.TOT.INT.ACC = R.AA.INT.AC<AA.INT.ACC.TOT.ACCR.AMT,Y.FIN.PS>
        Y.TOT.SUSP.ACC = R.AA.INT.AC<AA.INT.ACC.TOT.SUSP.AMT,Y.FIN.PS>
        IF Y.TOT.SUSP.ACC EQ '' THEN
            Y.TOT.ACC.AMT = 0
        END ELSE
            Y.TOT.ACC.AMT = Y.TOT.INT.ACC - Y.TOT.SUSP.ACC
        END
*END
    END ELSE
        Y.FIN.PS = POS.AR - 1
        Y.PER.ST =  R.AA.INT.AC<AA.INT.ACC.PERIOD.START,Y.FIN.PS>
        Y.PER.END = R.AA.INT.AC<AA.INT.ACC.PERIOD.END,Y.FIN.PS>
        IF EFF.DATE GT Y.PER.ST AND EFF.DATE LT Y.PER.END THEN
            Y.TOT.INT.ACC = R.AA.INT.AC<AA.INT.ACC.TOT.ACCR.AMT,Y.FIN.PS>
            Y.TOT.SUSP.ACC = R.AA.INT.AC<AA.INT.ACC.TOT.SUSP.AMT,Y.FIN.PS>
            Y.TOT.ACC.AMT = Y.TOT.INT.ACC - Y.TOT.SUSP.ACC
            GOSUB CALS.HOLS
        END
    END
    CALL F.READ(FN.AA.SCH.ACT,ARR.ID,R.AA.SCH.ACT,F.AA.SCH.ACT,SCH.ERR)

    FINDSTR 'LENDING-MAKEDUE-REPAYMENT.SCHEDULE' IN R.AA.SCH.ACT<AA.SCH.ACTIVITY.NAME,1> SETTING POS.NEX THEN
        Y.NEX.BL.DATE = R.AA.SCH.ACT<AA.SCH.NEXT.DATE,POS.NEX>
    END ELSE
        Y.NEX.BL.DATE = BAL.DETAILS<1>
    END
* CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)
    R.NAB.HISTORY.REC<REDO.NAB.HIST.NXT.BILL.DATE> = Y.NEX.BL.DATE
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT> = Y.TOT.ACC.AMT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCRUED.AMT.RAISED> = 0 ;* We will initialise to 0, Because if the loan moves out of nab due to payment and then
*                                                               moves to NAB because of non repayment of subsequent bills.

RETURN

CALS.HOLS:

    CALL AWD('',EFF.DATE,DAYTYPE)

* During the Holidays, Core is not updating the AA.INTEREST.ACCRUALS file from R15 when this activity is triggerred. So the accrual amount for the holiday is calculated manually here.

*    IF DAYTYPE EQ 'H' AND EFF.DATE EQ R.DATES(EB.DAT.PERIOD.END) THEN
* Changes made for calculating interest in holiday
*        Y.PER.SS.SF = DCOUNT(R.AA.INT.AC<AA.INT.ACC.FROM.DATE>,VM) ; LKL = ''
*        LOOP
*        WHILE Y.PER.SS.SF GT 0 DO
*            LKL += 1 ; SS.ST.DATE = R.AA.INT.AC<AA.INT.ACC.FROM.DATE,LKL> ; ED.ST.DATE = R.AA.INT.AC<AA.INT.ACC.TO.DATE,LKL>
*            IF EFF.DATE GE SS.ST.DATE AND EFF.DATE LE ED.ST.DATE THEN
*                Y.ACR.DAYS = R.AA.INT.AC<AA.INT.ACC.DAYS,LKL>
*                Y.ACR.AMT = R.AA.INT.AC<AA.INT.ACC.ACCRUAL.AMT,LKL,1>
*                Y.ONE.LSE.ACR = Y.ACR.AMT / Y.ACR.DAYS
*                Y.ONE.LSE.ACR = DROUND(Y.ONE.LSE.ACR,2)
*                Y.PER.SS.SF = 0
*            END
*            Y.PER.SS.SF -= 1
*        REPEAT
*        IF Y.ONE.LSE.ACR THEN
*            Y.TOT.ACC.AMT = Y.TOT.INT.ACC - Y.ONE.LSE.ACR
*        END

    IF DAYTYPE EQ 'H' THEN
        NAB.MOVE.DATE = ''; NAB.MOVE.DATE = EFF.DATE
        CALL CDT('',NAB.MOVE.DATE,'-1C')
        NO.OF.DAYS.HOLIDAY = 'C'
        LWRK.DAY = R.DATES(EB.DAT.LAST.WORKING.DAY)
        CALL CDD('',LWRK.DAY,NAB.MOVE.DATE,NO.OF.DAYS.HOLIDAY)
        LONG.MNTH = '01':@VM:'03':@VM:'05':@VM:'07':@VM:'08':@VM:'10':@VM:'12'
*------------------------------------------
* Ensure 30 day basis calculation happens
*------------------------------------------
* If Last working day or NAB.MOVE.DATE is a 31st day of the month. then reduce 1 day
        IF LWRK.DAY[7,2] EQ 31 OR NAB.MOVE.DATE[7,2] EQ 31 THEN ;** R22 Auto Conversion
            NO.OF.DAYS.HOLIDAY -= 1
        END ELSE
* If the last working day falls in 31 days month then reduce 1 day
            IF NAB.MOVE.DATE[5,2] NE LWRK.DAY[5,2] THEN
* If the last working day falls in Feb. Then check for 29 or 28 days. add one or two days at accrual days for calculation
                IF LWRK.DAY[5,2] EQ '02' THEN ;** R22 Auto Conversion
                    LAST.WRK.DAY.YEAR = LWRK.DAY[1,4]
                    IF MOD(LAST.WRK.DAY.YEAR,4) EQ 0 THEN ;** R22 Auto Conversion
                        NO.OF.DAYS.HOLIDAY += 1
                    END ELSE
                        NO.OF.DAYS.HOLIDAY += 2
                    END
                END ELSE
* If the date falls on 31 days calendar month
                    LWRK.DAY.MNTH = LWRK.DAY[5,2]
                    LOCATE LWRK.DAY.MNTH IN LONG.MNTH<1,1> SETTING MONTH.LOC.POS THEN
                        NO.OF.DAYS.HOLIDAY -=1
                    END
                END
            END
        END
        IF NO.OF.DAYS.HOLIDAY GT 0 THEN ;** R22 Auto Conversion
            RECENT.ACCR.DAYS = ''; RECENT.ACCR.DAYS = R.AA.INT.AC<AA.INT.ACC.DAYS,1>
            RECENT.ACCR.AMT = ''; RECENT.ACCR.AMT = R.AA.INT.AC<AA.INT.ACC.ACT.ACC.AMT,1,1>
            ONE.DAY.ACCR = RECENT.ACCR.AMT / RECENT.ACCR.DAYS
            ONE.DAY.ACCR = DROUND(ONE.DAY.ACCR,2)
            ACCR.AMT.HOLIDAY = NO.OF.DAYS.HOLIDAY * ONE.DAY.ACCR
            Y.TOT.ACC.AMT += ACCR.AMT.HOLIDAY
        END
    END

RETURN

*-------------------------------------------------------------------------------------------------------------------------------------
* Read NAB history record. If Present update it else form a new one
*
CHECK.NAB.HIST.REC:

    CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, RET.ERR)

    IF (RET.ERR) THEN         ;* Record Not present; Create a New one

        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.CURRENCY> = ARR.CURRENCY
        R.NAB.HISTORY.REC<REDO.NAB.HIST.SECTOR> = ARR.SECTOR
        R.NAB.HISTORY.REC<REDO.NAB.HIST.L.LOAN.STATUS> = ARR.LOAN.STATUS
        R.NAB.HISTORY.REC<REDO.NAB.HIST.CATEGORY> = ARR.CATEGORY

    END ELSE

        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.CHANGE.DATE> = EFF.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.L.LOAN.STATUS> = ARR.LOAN.STATUS        ;* Update the Loan Status

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

    NAB.INT.COUNT = DCOUNT(R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>,@VM)        ;* Loop thru each Outstanding BILL for total of INTEREST amount

    FOR NAB.COUNT = 1 TO NAB.INT.COUNT

        INT.AMT = INT.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,NAB.COUNT>
        INT.NAB.AMT = INT.NAB.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,NAB.COUNT>

    NEXT NAB.COUNT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------------
* Get the BILLS which are UNPAID
*
GET.BILL.INFO:

    ARR.BILL.IDS = ACCOUNT.DETAILS<AA.AD.BILL.ID> ;* Get the Arrangement BILL ids
    ARR.BILL.STATUS = ACCOUNT.DETAILS<AA.AD.BILL.STATUS>    ;* Get the Bill Status for the corresponding BILLS
    ARR.BILL.TYPE = ACCOUNT.DETAILS<AA.AD.BILL.TYPE>        ;* Get the Bill Type, Coz only the Scheduled BILLS are aged

    CHANGE @VM TO @FM IN ARR.BILL.IDS
    CHANGE @SM TO @FM IN ARR.BILL.IDS

    CHANGE @VM TO @FM IN ARR.BILL.STATUS
    CHANGE @SM TO @FM IN ARR.BILL.STATUS

    CHANGE @VM TO @FM IN ARR.BILL.TYPE
    CHANGE @SM TO @FM IN ARR.BILL.TYPE

    BILL.COUNT = DCOUNT(ARR.BILL.IDS, @FM)

    FOR BILL = 1 TO BILL.COUNT          ;* Loop thru each BILL

        IF ARR.BILL.STATUS<BILL> NE 'SETTLED' AND ARR.BILL.TYPE<BILL> EQ 'PAYMENT' THEN   ;* Check whether the BILL is in UNPAID status. Starting from This BILL NAB Entries will be posted :)

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
    IF Y.CK.DTW LE EFF.DATE THEN

        GOSUB GET.INTEREST.PROPERTY

        LOCATE INT.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING  INT.POS THEN

            INT.OS.AMT = R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,INT.POS>
            INT.OR.AMT = R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT, INT.POS>
            REPAY.REF = R.BILL.DETAILS<AA.BD.REPAY.REF, INT.POS>
            PAYMENT.DATE = FIELD(REPAY.REF,2,'-')
            INT.PAID = INT.OR.AMT  -  INT.OS.AMT

            GOSUB UPDATE.BILL.HISTORY   ;* Update the history REC

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

    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)       ;* Find their Property classes
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

            IF (FLAG EQ 0) THEN          ;* Break only when PRINCIPAL INTEREST property is found ;** R22 Auto Conversion
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
