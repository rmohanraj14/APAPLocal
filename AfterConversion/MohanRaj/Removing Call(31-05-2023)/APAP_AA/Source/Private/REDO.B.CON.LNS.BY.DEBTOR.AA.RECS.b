$PACKAGE APAP.AA
SUBROUTINE REDO.B.CON.LNS.BY.DEBTOR.AA.RECS(AA.ID,OUT.RECORD)
*-----------------------------------------------------------------------------
*
* Developed By            : Emmanuel James Natraj Livingston
*
* Developed On            : 10-Sep-2013
*
* Development Reference   : 786790(FS-205-DE13)
*
* Development Description : CALL routine to fetch the Arrangement field records
*
*-----------------------------------------------------------------------------------------------------------------
* Input Parameter:
* ---------------*
* Argument#1 : AA.ID
*-----------------------------------------------------------------------------------------------------------------
*-----------------*
* Output Parameter:
* ----------------*
* Argument#2 : OUT.RECORD
*-----------------------------------------------------------------------------------------------------------------
*  M O D I F I C A T I O N S
*-----------------------------------------------------------------------------------------------------------------
* Defect Reference       Modified By                    Date of Change        Change Details
* NA                     NA                             NA                    NA
*-----------------------------------------------------------------------------------------------------------------
* PACS00460183           Ashokkumar.V.P                  27/05/2015            new mapping changes.
*-----------------------------------------------------------------------------------------------------------------
* Include files
*-----------------------------------------------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
* 29-MAR-2023      Conversion Tool       R22 Auto Conversion - No changes
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_REDO.B.COM.LNS.BY.DEBTOR.COMMON
* </region>
*-----------------------------------------------------------------------------
*

    GOSUB MAIN.PROCESS
*
RETURN
*
*------------
MAIN.PROCESS:
*------------
*
    OUT.RECORD = ''
    Y.AA.ARR.ID = AA.ID
*
    FN.AA.ACCOUNT.DETAILS = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACCOUNT.DETAILS  = ""
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
*
    FN.AA.INTEREST.ACCRUALS = "F.AA.INTEREST.ACCRUALS"
    F.AA.INTEREST.ACCRUALS  = ""
    CALL OPF(FN.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS)
*

    GOSUB AA.LIMIT.READ
    GOSUB AA.OVERDUE.READ
    GOSUB AA.INTEREST.READ
    GOSUB AA.TERM.AMOUNT.READ
    GOSUB AA.ACCOUNT.DETAILS.READ
    GOSUB AA.PAYMENT.SCHEDULE.READ
    GOSUB AA.INTEREST.ACCRUALS.READ
    GOSUB AA.ACCOUNT.READ
    GOSUB AA.CUSTOMER
    GOSUB FORM.ARRAY
RETURN
*-------------------
AA.TERM.AMOUNT.READ:
**------------------
    ARRANGEMENT.ID   = Y.AA.ARR.ID
    R.AA.TERM.AMOUNT = ''
    PROP.CLASS       = 'TERM.AMOUNT'
    PROP.NAME        = ''
    RET.ERR          = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.TERM.AMOUNT = RAISE(returnConditions)
    TERM.AMOUNT      = R.AA.TERM.AMOUNT
RETURN
*
*-----------------------
AA.ACCOUNT.DETAILS.READ:
**----------------------
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ACCOUNT.DETAILS.ERR)
    ACCT.DETAILS = R.AA.ACCOUNT.DETAILS
RETURN
*------------------------
AA.PAYMENT.SCHEDULE.READ:
**-----------------------
    ARRANGEMENT.ID   = Y.AA.ARR.ID
    R.AA.PAYMENT.SCHEDULE = ''
    PROP.CLASS       = 'PAYMENT.SCHEDULE'
    PROP.NAME        = ''
    RET.ERR          = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.PAYMENT.SCHEDULE = RAISE(returnConditions)
    PAY.SCH = R.AA.PAYMENT.SCHEDULE
RETURN
*-------------------------
AA.INTEREST.ACCRUALS.READ:
**------------------------
    Y.INT.ACCR.ID = Y.AA.ARR.ID:"-PRINCIPALINT"
    CALL F.READ(FN.AA.INTEREST.ACCRUALS,Y.INT.ACCR.ID,R.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS,INT.ERROR)
    INT.ACCRUALS = R.INTEREST.ACCRUALS
RETURN
*---------------
AA.OVERDUE.READ:
**--------------
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.OVERDUE   = ''
    PROP.CLASS     = ''
    PROP.NAME      = 'APAP.OVERDUE'
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.OVERDUE = RAISE(returnConditions)
    OVERDUE      = R.AA.OVERDUE
RETURN
*-------------
AA.LIMIT.READ:
**------------

    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.LIMIT     = ''
    PROP.CLASS     = 'LIMIT'
    PROP.NAME      = ''
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.LIMIT = RAISE(returnConditions)
    LIMIT      = R.AA.LIMIT
RETURN
*----------------
AA.INTEREST.READ:
**---------------
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.INTEREST  = ''
    PROP.CLASS     = ''
    PROP.NAME      = 'PRINCIPALINT'
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.INTEREST = RAISE(returnConditions)
    INTEREST = R.AA.INTEREST
RETURN

AA.ACCOUNT.READ:
*---------------
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.INTEREST  = ''
    PROP.CLASS     = 'ACCOUNT'
*    PROP.CLASS     = ''
*    PROP.NAME      = 'ACCOUNT'
    PROP.NAME      = ''
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.ACCOUNT.APP = RAISE(returnConditions)
    ACCOUNT.APP = R.AA.ACCOUNT.APP
RETURN

AA.CUSTOMER:
************
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.INTEREST  = ''
    PROP.CLASS     = ''
    PROP.NAME      = 'CUSTOMER'
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.CUSTOMER = RAISE(returnConditions)
    CUSTOMER.APP = R.AA.CUSTOMER
RETURN

FORM.ARRAY:
*---------
    OUT.RECORD = TERM.AMOUNT:"*":ACCT.DETAILS:"*":PAY.SCH:"*":INT.ACCRUALS:"*":OVERDUE:"*":LIMIT:"*":INTEREST:'*':ACCOUNT.APP:'*':CUSTOMER.APP
RETURN
END
