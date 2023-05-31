* @ValidationCode : MjotMTQ0NTg1MDk4ODpDcDEyNTI6MTY4NTUyOTU0NTY1Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:09:05
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
SUBROUTINE REDO.CHANGE.NAB.STATUS

* Description
*
* Attached as a POST routine in ACTIVITY.API for the activity LENDING-APPLYPAYMENT-PAYMENT.RULES for the CHANGE.STATUS action
*
* This routine will update the file REDO.UPDATE.NAB.HISTORY when the Arrangement moves from NAB to any other status, when an
* repayment is made
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
*-----------------------------------------------------------------------------------------------------------------------------
*   Date               |           Who                    |           Reference                    |          Description
*-----------------------------------------------------------------------------------------------------------------------------
*
*  Nov-11                      Ravikiran AV                             CR-41                               NAB Accounting
*
*  29-10-2012                  MARIMUTHU S                              NAB & WOF                          PACS00202156

* 29-MAR-2023      Conversion Tool                R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - CALL method format changed
*-----------------------------------------------------------------------------------------------------------------------------
*
* All file INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.CUSTOMER
    $INSERT I_F.REDO.AA.NAB.HISTORY
    $USING APAP.TAM
*-----------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
MAIN.LOGIC:


    IF (c_aalocActivityStatus EQ 'UNAUTH') THEN

        GOSUB INITIALISE

        GOSUB PROCESS

    END

    IF (c_aalocActivityStatus EQ 'AUTH-REV') THEN

        GOSUB INITIALISE
        GOSUB PROCESS.REV

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
INITIALISE:

    ARR.ID = c_aalocArrId

    ACCOUNT.DETAILS = c_aalocAccountDetails

    ACTIVITY.ID = c_aalocActivityId

    EFF.DATE = c_aalocActivityEffDate

    ARR.CURRENCY = c_aalocArrCurrency

    ARR.ACCOUNT.ID = c_aalocLinkedAccount
    RET.ERR = ''

    ARR.EFF.DATE = c_aalocAccountDetails<AA.AD.START.DATE>

    APP = 'ACCOUNT'
    LOC.FLD = 'L.LOAN.STATUS':@VM:'L.OD.STATUS'
    LOC.FLD.POS = ''
    CALL MULTI.GET.LOC.REF(APP, LOC.FLD, LOC.FLD.POS)
    L.LOAN.STATUS.POS = LOC.FLD.POS<1,1>
    Y.OD.ST.POS = LOC.FLD.POS<1,2>

    GOSUB OPEN.FILES

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
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

    FN.AA.ACCT.DET = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCT.DET = ''
    CALL OPF(FN.AA.ACCT.DET,F.AA.ACCT.DET)

    FN.REDO.AA.INT.CLS = 'F.REDO.AA.INT.CLASSIFICATION'
    F.REDO.AA.INT.CLS = ''
    CALL OPF(FN.REDO.AA.INT.CLS,F.REDO.AA.INT.CLS)

    BILL.IDS = c_aalocAccountDetails<AA.AD.BILL.ID>
    CHANGE @SM TO @FM IN BILL.IDS
    CHANGE @VM TO @FM IN BILL.IDS

    BILL.STATUS = c_aalocAccountDetails<AA.AD.BILL.STATUS>
    CHANGE @SM TO @FM IN BILL.STATUS
    CHANGE @VM TO @FM IN BILL.STATUS

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
PROCESS:


    GOSUB READ.NAB.HISTORY.REC

    IF NOT(NAB.RET.ERR) THEN

        GOSUB FORM.NAB.HISTORY.REC
        GOSUB PROCESS.ACCRUALS

    END

RETURN

PROCESS.REV:

    GOSUB READ.NAB.HISTORY.REC

    IF NOT(NAB.RET.ERR) THEN
        GOSUB REV.NAB.HIS.REC
    END

RETURN

REV.NAB.HIS.REC:

    Y.BILL.IDS = R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>
    Y.VMCNT = DCOUNT(Y.BILL.IDS,@VM) ; Y.DUP.JJ = Y.VMCNT
    FLA = '' ; Y.NAB.INT = '' ; Y.TOT.INT.PAID = ''
    LOOP
    WHILE Y.VMCNT GT 0 DO
        FLA += 1
        Y.BL.ID = R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID,FLA>
        Y.BL.ID = FIELD(Y.BL.ID,'-',1)
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BL.ID,R.AA.BILL.DET,F.AA.BILL.DETAILS,BILL.ERR)

        IF c_aalocActivityEffDate EQ R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,FLA> THEN
            LOCATE 'PRINCIPALINT' IN R.AA.BILL.DET<AA.BD.PROPERTY,1> SETTING  INT.POS THEN
                INT.OS.AMT = R.AA.BILL.DET<AA.BD.OS.PROP.AMOUNT,INT.POS>
                INT.PAID.AMT = R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,FLA> - INT.OS.AMT
                Y.OPUTS.AMT = R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,FLA>
                Y.HJ.AMT = R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,FLA> - INT.PAID.AMT
                IF INT.OS.AMT EQ Y.HJ.AMT THEN
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,FLA> = ''
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,FLA> =  INT.PAID.AMT
                    R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,FLA> = INT.OS.AMT
                    Y.NAB.INT += R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,FLA>
                END
            END
        END
        Y.VMCNT -= 1   ;*R22 Auto Conversion
    REPEAT

    Y.LAST.PAY.DATE.CNT = DCOUNT(R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE>,@VM)

    FLGH = ''
    LOOP
    WHILE Y.LAST.PAY.DATE.CNT GT 0 DO
        FLGH += 1
        Y.LAST.PAY.DATE = R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,FLGH>
        IF Y.LAST.PAY.DATE EQ '' THEN
            FLGH -= 1
            IF FLGH LE 0 THEN
                Y.LAST.INT.PAY = ''
            END ELSE
                Y.LAST.INT.PAY = R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,FLGH>
            END
            Y.LAST.PAY.DATE.CNT = 0
        END
        Y.LAST.PAY.DATE.CNT -= 1   ;*R22 Auto Conversion
    REPEAT

    R.NAB.HISTORY.REC<REDO.NAB.HIST.LAST.PAY.DATE> = Y.LAST.INT.PAY

    IF Y.LAST.INT.PAY EQ '' THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.LAST.INT.PAID> = ''
    END ELSE
        GOSUB UPDATE.LAST.PAID.INT
    END
*Following lines are commented, beacause reversal accounting is handled in REDO.B.REGEN.NAB.ACCOUNTING.
*IF c_aalocActivityEffDate NE TODAY THEN
*R.NAB.HISTORY.REC<REDO.NAB.HIST.ACCT.YES.NO> = 'YES'
*END

    IF R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> EQ 'SETTLED' THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.NAB.AMT>
    END ELSE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = Y.NAB.INT
    END
    IF R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT.SETLED> THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT> =  R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT.SETLED>
        R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT.SETLED> = ''
    END
    R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> = R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> - Y.NAB.INT
    R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.NAB.AMT> = R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.PAY.AMT>
    R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.PAY.AMT> = ''
    R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'STARTED'
    R.NAB.HISTORY.REC<REDO.NAB.HIST.REPAY.REV.DATE> = TODAY   ;* This date will be passed as value date NAB accounting.
    CALL F.WRITE(FN.REDO.AA.NAB.HISTORY,ARR.ID,R.NAB.HISTORY.REC)


RETURN


UPDATE.LAST.PAID.INT:

    Y.HHJ = Y.DUP.JJ
    FLHJ = ''
    Y.LAST.PAID.INT = ''
    LOOP
    WHILE Y.HHJ GT 0 DO
        FLHJ += 1   ;*R22 Auto Conversion
        Y.LST.PAY.DAT = R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,FLHJ>
        IF Y.LST.PAY.DAT EQ Y.LAST.INT.PAY THEN
            Y.LAST.PAID.INT += R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,FLHJ>
        END
        Y.HHJ -= 1   ;*R22 Auto Conversion
    REPEAT

    R.NAB.HISTORY.REC<REDO.NAB.HIST.LAST.INT.PAID> = Y.LAST.PAID.INT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
READ.NAB.HISTORY.REC:

    CALL F.READ(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC, F.REDO.AA.NAB.HISTORY, NAB.RET.ERR)

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
PROCESS.ACCRUALS:

    ACCR.BIL.DATE = R.NAB.HISTORY.REC<REDO.NAB.HIST.NXT.BILL.DATE>
    ACCR.AMT = R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT>

    IF ACCR.BIL.DATE NE '' AND ACCR.AMT NE '' THEN
        IF EFF.DATE GE ACCR.BIL.DATE THEN
            CALL F.READ(FN.AA.ACCT.DET,ARR.ID,R.AA.ACCT.DET,F.AA.ACCT.DET,ACCC.ERR)
            AA.BILS = R.AA.ACCT.DET<AA.AD.BILL.ID>
            AA.BILS = CHANGE(AA.BILS,@VM,@FM)
            AA.BILS = CHANGE(AA.BILS,@SM,@FM)
            GOSUB CHECK.BILLS
            IF Y.SSET EQ 'Y' THEN
                R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT.SETLED> = ACCR.AMT
                R.NAB.HISTORY.REC<REDO.NAB.HIST.NXT.BILL.DATE> = ''
*  R.NAB.HISTORY.REC<REDO.NAB.HIST.ACC.AMT> = '' ;* TO SHOW THE ACCRUAL AMOUNT IN THE ENQUIRY
                CALL F.WRITE(FN.REDO.AA.NAB.HISTORY,ARR.ID,R.NAB.HISTORY.REC)
            END

        END
    END


RETURN
*-----------------------------------------------------------------------------------------------------------------------------
CHECK.BILLS:

    Y.AR.CNT = DCOUNT(AA.BILS,@FM); Y.AR = ''
    LOOP
    WHILE Y.AR.CNT GT 0 DO
        Y.AR += 1  ;*R22 Auto Conversion
        Y.AR.BIL = AA.BILS<Y.AR>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.AR.BIL,R.AA.BILL.AR,F.AA.BILL.DETAILS,BL.ER)
        Y.PAY.AR.DATE = R.AA.BILL.AR<AA.BD.PAYMENT.DATE>
        IF Y.PAY.AR.DATE EQ ACCR.BIL.DATE THEN
            LOCATE 'PRINCIPALINT' IN R.AA.BILL.AR<AA.BD.PROPERTY,1> SETTING POS.ARS THEN
                Y.OS.AR.AMT = R.AA.BILL.AR<AA.BD.OS.PROP.AMOUNT,POS.ARS>
                IF Y.OS.AR.AMT LE 0 THEN
                    Y.SSET = 'Y'
                    Y.AR.CNT = 0
                END
            END
        END
        Y.AR.CNT -= 1   ;*R22 Auto Conversion
    REPEAT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
FORM.NAB.HISTORY.REC:

    NAB.BILL.IDS = R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>

    CHANGE @VM TO @FM IN NAB.BILL.IDS
    CHANGE @SM TO @FM IN NAB.BILL.IDS


    NAB.BILL.ID.COUNT = DCOUNT(NAB.BILL.IDS,@FM)

    GOSUB UPDATE.BILL.INFO

    GOSUB GET.NAB.SUM

    IF R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> NE 'SETTLED' THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.NAB.AMT> = R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST>
    END

    R.NAB.HISTORY.REC<REDO.NAB.HIST.PREV.PAY.AMT> = R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID>

    R.NAB.HISTORY.REC<REDO.NAB.HIST.TOT.INT.PAID> = INT.AMT
* R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = INT.NAB.AMT

*   IF c_aalocAccountDetails<AA.AD.ARR.AGE.STATUS> NE 'NAB' THEN

    CALL F.READ(FN.ACCOUNT,ARR.ACCOUNT.ID,R.ACC,F.ACCOUNT,ACC.ERR)

    IF R.ACC<AC.LOCAL.REF,Y.OD.ST.POS> NE 'NAB' THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> = 'SETTLED'     ;*Status would be SETTLED when the ARRANGEMENT moves out of NAB status
        R.NAB.HISTORY.REC<REDO.NAB.HIST.MARK.HOLIDAY> = ''
        R.NAB.HISTORY.REC<REDO.NAB.HIST.NAB.INTEREST> = INT.NAB.AMT
    END


    GOSUB GET.PAYMENT.INFO

    GOSUB WRITE.NAB.HISTORY


RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
UPDATE.BILL.INFO:

    FOR BILL = 1 TO NAB.BILL.ID.COUNT

        GOSUB READ.BILL

        GOSUB FORM.NAB.HIST.REC

    NEXT BILL

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
READ.BILL:

    BILL.ID = NAB.BILL.IDS<BILL>

    BILL.ID = FIELD(BILL.ID,'-',1)

    CALL F.READ(FN.AA.BILL.DETAILS, BILL.ID, R.BILL.DETAILS, F.AA.BILL.DETAILS, RET.ERR)

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
* Write the NAB.HISTORY record to the LIVE template
*
WRITE.NAB.HISTORY:

    IF R.NAB.HISTORY.REC THEN

        CALL F.WRITE(FN.REDO.AA.NAB.HISTORY, ARR.ID, R.NAB.HISTORY.REC)

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
FORM.NAB.HIST.REC:


    GOSUB GET.INTEREST.PROPERTY

    LOCATE INT.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING  INT.POS THEN

        INT.OS.AMT = R.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,INT.POS>
        INT.OR.AMT = R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT, INT.POS>
        REPAY.REF = R.BILL.DETAILS<AA.BD.REPAY.REF, INT.POS,1>
        PAYMENT.DATE = FIELD(REPAY.REF,'-',2)

        IF PAYMENT.DATE EQ 'SUSPEND' THEN   ;* SUSPEND is updated in REPAY REF. Get the date :)
            PAYMENT.DATE = FIELD(REPAY.REF,'-',3)
        END

        INT.PAID = INT.OR.AMT  -  INT.OS.AMT

        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.AMT,BILL> = INT.OR.AMT
        R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE,BILL> = PAYMENT.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,BILL> = INT.PAID
        R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,BILL> = INT.OS.AMT

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
GET.PAYMENT.INFO:

    PAY.DATE = R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE>
    PAID.INT = ''

    CHANGE @VM TO @FM IN PAY.DATE
    CHANGE @SM TO @FM IN PAY.DATE

    PAY.DATE.COUNT = DCOUNT(PAY.DATE,@FM)

    ACT.EFF.DATE = c_aalocActivityEffDate

    FOR PAID.DATE = 1 TO PAY.DATE.COUNT

        IF R.NAB.HISTORY.REC<REDO.NAB.HIST.PAYMENT.DATE, PAID.DATE> EQ ACT.EFF.DATE THEN

            PAID.INT = PAID.INT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,PAID.DATE>

        END

    NEXT PAID.DATE

    IF R.NAB.HISTORY.REC<REDO.NAB.HIST.STATUS> NE 'SETTLED' THEN
        R.NAB.HISTORY.REC<REDO.NAB.HIST.LAST.PAY.DATE> = ACT.EFF.DATE
        R.NAB.HISTORY.REC<REDO.NAB.HIST.LAST.INT.PAID> = PAID.INT
    END


RETURN
*-----------------------------------------------------------------------------------------------------------------------------
* Get the Total INterest paid and Total NAB Interets
*
GET.NAB.SUM:

    NAB.INT.COUNT = DCOUNT(R.NAB.HISTORY.REC<REDO.NAB.HIST.BILL.ID>,@VM)          ;* Loop thru each Outstanding BILL for total of INTEREST amount


    FOR NAB.COUNT = 1 TO NAB.INT.COUNT

        INT.AMT = INT.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.PAID,NAB.COUNT>
        INT.NAB.AMT = INT.NAB.AMT + R.NAB.HISTORY.REC<REDO.NAB.HIST.INT.BALANCE,NAB.COUNT>

    NEXT NAB.COUNT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
*
*
GET.INTEREST.PROPERTY:


    ARR.INFO    = '' ;   ARR.INFO<1> = ARR.ID ; ARR.INFO<2> = c_aalocActivityEffDate
    PROP.NAME   = 'PRINCIPAL'
    OUT.PROP    = ''
    APAP.TAM.redoGetInterestProperty(ARR.INFO,PROP.NAME,OUT.PROP,ERR);* R22 Manual conversion
    INT.PROPERTY = OUT.PROP

* Following lines are commented because AA.INTEREST.ACCRUALS doesn't have the END date for migrated expired contracts.
* So because of that PENALTINT has been returned as PRINCIPAL interest property.

*CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)
*CLASS.LIST = ''
*CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)       ;* Find their Property classes
*CLASS.LIST = RAISE(CLASS.LIST) ; PROP.LIST = RAISE(PROP.LIST)
*CLASS.CTR = ''
*FLAG = 1
*LOOP
*REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
*CLASS.CTR +=1
*WHILE Y.CLASS:CLASS.POS
*IF Y.CLASS EQ "INTEREST" THEN
*INT.PROPERTY = PROP.LIST<CLASS.CTR>
*AA.INT.ACCR.ID = ARR.ID:'-':INT.PROPERTY
*CALL F.READ(FN.AA.INTEREST.ACCRUALS, AA.INT.ACCR.ID, R.AA.INT.ACCR.REC, F.AA.INTEREST.ACCRUALS, RET.ERR)
*GOSUB GET.PRINCIPAL.INT.PROP
*IF (FLAG = 0) THEN          ;* Break only when PRINCIPAL INTEREST property is found
*BREAK
*END
*END
*REPEAT

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
* Get the principal Interest Property
*
*GET.PRINCIPAL.INT.PROP:

*ACC.PERIOD.ST.DT = R.AA.INT.ACCR.REC<AA.INT.ACC.PERIOD.START>
*ACC.PERIOD.END.DT = R.AA.INT.ACCR.REC<AA.INT.ACC.PERIOD.END>
*IF ((ACC.PERIOD.ST.DT) AND (ACC.PERIOD.END.DT)) THEN    ;* If PERIOD.START.DATE and PERIOD.END.DATE is present then it is present in the schedule
*FLAG = 0
*END

*  RETURN  ; **TUS  (S/E)
*-----------------------------------------------------------------------------------------------------------------------------
*
*
END
