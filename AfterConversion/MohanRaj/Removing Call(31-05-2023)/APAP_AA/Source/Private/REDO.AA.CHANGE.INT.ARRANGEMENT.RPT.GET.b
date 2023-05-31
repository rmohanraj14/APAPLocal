* @ValidationCode : MjotMTYyNzc3MjUzMjpDcDEyNTI6MTY4NTUyODEzNDAyMzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:45:34
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
$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.CHANGE.INT.ARRANGEMENT.RPT.GET(Y.PROCESSED.IDS, Y.OUT.ARRAY)
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : T.Jeeva, Temenos Application Management
*Program   Name    : REDO.APAP.E.NOF.PAYMENT.DYNAMIC.RPT.GET
*ODR Reference     : ODR-2010-03-0183
*--------------------------------------------------------------------------------------------------------
*Description  :REDO.AA.CHANGE.INT.ARRANGEMENT.RPT.GET is a mainline routine called within the routine
*              REDO.AA.CHANGE.INT.ARRANGEMENT.RPT, the routine fetches the record details required to
*              display in the enquiry
*In Parameter : Y.PROCESSED.IDS
*Out Parameter: Y.OUT.ARRAY
*--------------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

* Modification History: * Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023       Conversion Tool        R22 Auto Code Conversion             FM to @FM, VM to @VM ,SM to @SM
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA, CALL method format changed
*-----------------------------------------------------------------------------------



    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.ID.COMPONENT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $USING APAP.TAM

*--------------------------------------------------------------------------------------------------------
MAIN.PARA:
*--------------------------------------------------------------------------------------------------------

    GOSUB OPEN.PARA
    GOSUB PROCESS.PARA

RETURN
*--------------------------------------------------------------------------------------------------------
OPEN.PARA:
*--------------------------------------------------------------------------------------------------------

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.INTEREST.ACCRUALS = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INTEREST.ACCRUALS = ''
    CALL OPF(FN.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS)

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF (FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS.PARA:
*--------------------------------------------------------------------------------------------------------

    GOSUB GET.LR.FLD.POS
    LOOP
        REMOVE Y.AA.ID FROM Y.PROCESSED.IDS SETTING Y.AA.ARR.POS
    WHILE Y.AA.ID:Y.AA.ARR.POS
        Y.CONT.FLAG = 'YES'
        LOCATE Y.AA.ID IN Y.AA.LIST SETTING Y.AA.POS THEN
            Y.CONT.FLAG = 'NO'
        END ELSE
            Y.AA.LIST<-1> := Y.AA.ID
        END
        IF Y.CONT.FLAG EQ 'YES' THEN
            CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.AA.ACCOUNT.DETAILS.ERR)
            GOSUB NULLIFY.VARAIBLES
            GOSUB GET.ARRANGEMENT.DETAILS
            GOSUB GET.ARR.CUSTOMER.DETAILS
            GOSUB GET.ACCT.ACT.BK.BAL
            GOSUB GET.ARR.ACCOUNT.DETAILS
            GOSUB GET.TERM.AMOUNT.DETAILS
            GOSUB GET.OVERDUE.DETAILS
            GOSUB GET.INTEREST.DETAILS
            GOSUB GET.AA.INTEREST.ACCRUALS.DETAILS
            GOSUB GET.PAYMENT.SCHEDULE.DETIALS

            IF Y.ERROR.FLAG EQ '' THEN

*                               1                         2                     3                    4                 5                        6                   7                       8                        9                    10                           11                    12                13                      14                  15                  16                        17                           18                          19                  20                 21                            22                        23                         24                    25                 26

                Y.OUT.ARRAY<-1> := Y.LOAN.PORTFOLIO.TYPE:"*":Y.PRODUCT.TYPE:"*":Y.LOAN.ORGIN.AGENCY:"*":Y.LOAN.STATUS:"*":Y.CAMPAIGN.TYPE:"*":Y.AFFILIATED.COMPANY:"*":Y.LOAN.NUMBER:"*":Y.PREVIOUS.LOAN.NUMBER:"*":Y.APPROVED.AMOUNT:"*":Y.PENDING.CAPITAL.BALANCE:"*":Y.NEXT.REVIEW.DATE:"*":Y.LOAN.DUE.DATE:"*":Y.RATE.USER:"*":Y.PREVIOUS.INTEREST.RATE:"*":Y.INTEREST:"*":Y.PREVIOUS.BILL.AMOUNT:"*":Y.CURRENT.BILL.AMOUNT:"*":Y.CURRENCY:"*":Y.LOAN.OVERALL.STATUS
            END
        END

    REPEAT
RETURN
*--------------------------------------------------------------------------------------------------------
NULLIFY.VARAIBLES:
*--------------------------------------------------------------------------------------------------------
    Y.LOAN.PORTFOLIO.TYPE = ''
    Y.PRODUCT.TYPE = ''
    Y.LOAN.ORGIN.AGENCY = ''
    Y.LOAN.STATUS = ''
    Y.CAMPAIGN.TYPE = ''
    Y.AFFILIATED.COMPANY = ''
    Y.LOAN.NUMBER = ''
    Y.PREVIOUS.LOAN.NUMBER = ''
    Y.APPROVED.AMOUNT = '0.00'
    Y.PENDING.CAPITAL.BALANCE = '0.00'
    Y.NEXT.REVIEW.DATE = ''
    Y.LOAN.DUE.DATE = ''
    Y.RATE.USER = ''
    Y.INTEREST = '0.00'
    Y.PREVIOUS.BILL.AMOUNT = '0.00'
    Y.CURRENT.BILL.AMOUNT = '0.00'
    Y.CURRENCY = ''
    Y.LOAN.OVERALL.STATUS = ''
    Y.ERROR.FLAG = ''

RETURN
*--------------------------------------------------------------------------------------------------------
GET.ARRANGEMENT.DETAILS:
*--------------------------------------------------------------------------------------------------------
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,Y.AA.ERRR)
    Y.LOAN.PORTFOLIO.TYPE=R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    Y.PRODUCT.TYPE=R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
    Y.LOAN.ORGIN.AGENCY=R.AA.ARRANGEMENT<AA.ARR.CO.CODE>
    Y.CURRENCY=R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    Y.LOAN.OVERALL.STATUS=R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>
    Y.LOAN.NUMBER = Y.AA.ID
*TUS AA Chnages 20161021
*  Y.CHECK = "CURRENT":FM:"MATURED":FM:"EXPIRED":"REVERSED"
    Y.CHECK = "CURRENT":@FM:"PENDING.CLOSURE":@FM:"EXPIRED":@FM:"REVERSED"
*TUS END
    LOCATE Y.LOAN.OVERALL.STATUS IN Y.CHECK SETTING POS.OVERALL ELSE
        Y.ERROR.FLAG = '1'
    END
    Y.ACCT.NO = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
    Y.LOAN.DUE.DATE=R.AA.ACCOUNT.DETAILS<AA.AD.MATURITY.DATE>
RETURN
*--------------------------------------------------------------------------------------------------------
GET.ARR.ACC.ID:
*--------------------------------------------------------------------------------------------------------
    ARR.ID=Y.AA.ID
    EFF.DATE=TODAY
    PROPERTY=''
    R.CONDITION =''
    ERR.MSG=''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

RETURN
*--------------------------------------------------------------------------------------------------------
GET.ARR.CUSTOMER.DETAILS:
*--------------------------------------------------------------------------------------------------------
    PROP.CLASS = 'CUSTOMER'
    GOSUB GET.ARR.ACC.ID
    Y.CAMPAIGN.TYPE = R.CONDITION<AA.CUS.LOCAL.REF,Y.LOC.CAMPAIGN.POS>
    Y.AFFILIATED.COMPANY = R.CONDITION<AA.CUS.LOCAL.REF,Y.AFFI.COMPANY.POS>

RETURN
*-----------------------------------------------------------------------------
GET.OVERDUE.DETAILS:
*-----------------------------------------------------------------------------
    PROP.CLASS = 'OVERDUE'
    GOSUB GET.ARR.ACC.ID
    IF R.CONDITION THEN
        GOSUB LOAN.SELECT
    END

RETURN
*-----------------------------------------------------------------------------
LOAN.SELECT:
*-----------------------------------------------------------------------------

    Y.STATUS = R.CONDITION<AA.OD.LOCAL.REF,L.LOAN.STATUS.POS>
    Y.STAT.COUNT = DCOUNT(Y.STATUS,@SM);*R22 Auto Code  Conversion
    Y.COUNT2 = 1
    IF Y.STATUS EQ '' THEN
        Y.LOAN.AA.STATUS=R.AA.ACCOUNT.DETAILS<AA.AD.ARR.AGE.STATUS>
        GOSUB LOAN.ARR.STATUS
        Y.LOAN.STATUS=Y.LOAN.AA.STATUS
    END ELSE
        CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,Y.AA.ACCOUNT.DETAILS.ERR)
        Y.LOAN.AA.STATUS=R.AA.ACCOUNT.DETAILS<AA.AD.ARR.AGE.STATUS>
        GOSUB LOAN.ARR.STATUS
        Y.LOAN.STATUS=Y.LOAN.AA.STATUS
        LOOP
        WHILE Y.COUNT2 LE Y.STAT.COUNT
            Y.OVERDUE.LOAN.STATUS = FIELD(Y.STATUS,@SM,Y.COUNT2,1) ;*R22 Auto Code  Conversion
            IF  Y.LOAN.STATUS EQ '' THEN
                Y.LOAN.STATUS = Y.OVERDUE.LOAN.STATUS
            END ELSE
                Y.LOAN.STATUS:= @VM:Y.OVERDUE.LOAN.STATUS ;*R22 Auto Code  Conversion
            END
            Y.COUNT2 += 1
        REPEAT
        RETURN
    END

RETURN
*-----------------------------------------------------------------------------
LOAN.ARR.STATUS:
*-----------------------------------------------------------------------------
    Y.AA.STATUS = "GRC":@FM:"NAB":@FM:"DEL":@FM:"CUR" ;*R22 Auto Code  Conversion
    LOCATE Y.LOAN.AA.STATUS IN Y.AA.STATUS SETTING AA.POS THEN
        IF Y.LOAN.AA.STATUS EQ "GRC" THEN
            Y.LOAN.AA.STATUS ="Current 0-30 days"
        END
        IF Y.LOAN.AA.STATUS EQ "DEL" THEN
            Y.LOAN.AA.STATUS ="Overdue from 31 to 90 days"
        END
        IF Y.LOAN.AA.STATUS EQ "NAB" THEN
            Y.LOAN.AA.STATUS ="Overdue more than 90 days"
        END
        IF Y.LOAN.AA.STATUS EQ "CUR" THEN
            Y.LOAN.AA.STATUS ="No Overdue"
        END
    END

RETURN
*----------------------------------------------------------------------
GET.ARR.ACCOUNT.DETAILS:
*----------------------------------------------------------------------
    PROP.CLASS = 'ACCOUNT'
    GOSUB GET.ARR.ACC.ID
    Y.PREVIOUS.LOAN.NUMBER = R.CONDITION<AA.AC.ALT.ID>
RETURN
*-----------------------------------------------------------------------------
GET.TERM.AMOUNT.DETAILS:
*-----------------------------------------------------------------------------
    PROP.CLASS = 'TERM.AMOUNT'
    GOSUB GET.ARR.ACC.ID
    IF R.CONDITION THEN
        Y.APPROVED.AMOUNT = R.CONDITION<AA.AMT.AMOUNT>
    END

RETURN

*-----------------------------------------------------------------------------
GET.INTEREST.DETAILS:
*-----------------------------------------------------------------------------
    PROP.CLASS = 'INTEREST'
    GOSUB GET.ARR.ACC.ID
    IF R.CONDITION THEN
        Y.NEXT.REVIEW.DATE = R.CONDITION<AA.INT.LOCAL.REF><1,L.AA.NXT.REV.DT.POS>
    END

RETURN
*----------------------------------------------------------------------
GET.ACCT.ACT.BK.BAL:
*----------------------------------------------------------------------

    BALANCE.TO.CHECK = 'CURACCOUNT'
    DATE.OPTIONS = ''
    EFFECTIVE.DATE = TODAY
    DATE.OPTIONS<4>  = 'ECB'
    BALANCE.AMOUNT = ""
    CALL AA.GET.PERIOD.BALANCES(Y.ACCT.NO, BALANCE.TO.CHECK, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")
    IF BAL.DETAILS THEN
        IF NOT(Y.PENDING.CAPITAL.BALANCE) THEN
            Y.PENDING.CAPITAL.BALANCE =  BAL.DETAILS<IC.ACT.BALANCE>
        END ELSE
            Y.PENDING.CAPITAL.BALANCE = Y.PENDING.CAPITAL.BALANCE + BAL.DETAILS<IC.ACT.BALANCE>
        END
    END
    Y.PENDING.CAPITAL.BALANCE = ABS(Y.PENDING.CAPITAL.BALANCE)
RETURN

*----------------------------------------------------------------------------------------------------------
GET.AA.INTEREST.ACCRUALS.DETAILS:
*----------------------------------------------------------------------------------------------------------

    Y.EFF.DATE = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE>
    ARR.INFO<1> =Y.AA.ID
    R.ARRANGEMENT=''
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    INT.PROPERTY = ''
    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes
    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    CLASS.CTR = ''

    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ "INTEREST" THEN
            INT.PROPERTY<-1> = PROP.LIST<CLASS.CTR>
        END
        IF Y.CLASS EQ "PAYMENT.SCHEDULE" THEN
            PS.PROPERTY=PROP.LIST<CLASS.CTR>
        END

    REPEAT

    PROP.NAME = 'PRINCIPAL'
    APAP.TAM.redoGetInterestProperty(Y.AA.ID,PROP.NAME,INT.PROPERTY,ERR);* R22 Manual conversion
    CHANGE @FM TO '*' IN INT.PROPERTY ;*R22 Auto Code  Conversion
    Y.COUNT.PROP = DCOUNT(INT.PROPERTY,'*')
    INIT = 1

    LOOP
    WHILE INIT LE Y.COUNT.PROP
        Y.FIRST.PROP = FIELD(INT.PROPERTY,'*',INIT)
        AA.INTEREST.ACCRUALS.ID = Y.AA.ID:'-':Y.FIRST.PROP      ;* form the accrual id using the property
        GOSUB AA.ARRG.ACTIVITY
        CALL F.READ(FN.AA.INTEREST.ACCRUALS,AA.INTEREST.ACCRUALS.ID,R.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS,AA.INTEREST.ACCRUALS.ER)
        Y.ACC.ST.DATE  = R.AA.INTEREST.ACCRUALS<AA.INT.ACC.PERIOD.START>
        Y.ACC.END.DATE = R.AA.INTEREST.ACCRUALS<AA.INT.ACC.PERIOD.END>
        IF Y.ACC.ST.DATE OR Y.ACC.END.DATE THEN
            Y.ACCRUALS.RATE = R.AA.INTEREST.ACCRUALS<AA.INT.ACC.RATE,1,1>
            Y.INTEREST=Y.ACCRUALS.RATE
            GOSUB INT.CLASS
        END
        INIT += 1 ;*R22 Auto Code  Conversion
    REPEAT

RETURN

*-----------------------------------------------------------------------------
GET.PAYMENT.SCHEDULE.DETIALS:
*-----------------------------------------------------------------------------
    idPropertyClass = "PAYMENT.SCHEDULE"
    PROP.CLASS = "PAYMENT.SCHEDULE"
    GOSUB GET.ARR.ACC.ID
    GOSUB ARR.PREV.CONDITIONS
    IF RET.ERROR THEN
        RETURN
    END
    IF R.CONDITION THEN
        Y.CURRENT.BILL.AMOUNT=R.CONDITION<AA.PS.CALC.AMOUNT>
    END
    IF R.PROPERTY THEN
        Y.PREVIOUS.BILL.AMOUNT=R.PROPERTY<AA.PS.CALC.AMOUNT>
    END

RETURN

*-----------------------------------------------------------------------------
ARR.PREV.CONDITIONS:
*-----------------------------------------------------------------------------
    OPTION=''
    R.PROPERTY=''
    RET.ERROR=''
    ID.COMPONENT = ""
    ID.COMPONENT<AA.IDC.ARR.NO> = Y.AA.ID
    IF idPropertyClass EQ "INTEREST" THEN
        ID.COMPONENT<AA.IDC.PROPERTY> = Y.FIRST.PROP
    END ELSE
        ID.COMPONENT<AA.IDC.PROPERTY> = PS.PROPERTY
    END
    ID.COMPONENT<AA.IDC.EFF.DATE> = Y.EFFECTIVE.DATE
    CALL AA.GET.PREVIOUS.PROPERTY.RECORD(OPTION, idPropertyClass , ID.COMPONENT, Y.EFFECTIVE.DATE, R.PROPERTY, RET.ERROR)
    IF RET.ERROR THEN
        RETURN
    END

RETURN

*-----------------------------------------------------------------------------
INT.CLASS:
*-----------------------------------------------------------------------------


    Y.PREVIOUS.INTEREST.RATE = '0.00'
    idPropertyClass = "INTEREST"
    PROP.CLASS = "INTEREST"
    GOSUB GET.ARR.ACC.ID
    GOSUB ARR.PREV.CONDITIONS

    IF R.CONDITION AND Y.INTEREST EQ '' THEN
        Y.INTEREST=R.CONDITION<AA.INT.EFFECTIVE.RATE,1>
    END
    IF RET.ERROR THEN
        RETURN
    END
    IF R.PROPERTY THEN
        Y.PREVIOUS.INTEREST.RATE=R.PROPERTY<AA.INT.EFFECTIVE.RATE,1>
    END

RETURN

*-----------------------------------------------------------------------------
AA.ARRG.ACTIVITY:
*-----------------------------------------------------------------------------
    Y.FLAG = ''
    CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.AA.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,Y.ERR.ACT.HIS)       ;*Process Arrangement activity records with LENDING-CHANGE-PRINCIPALINT
    IF R.AA.ACTIVITY.HISTORY THEN
        Y.EFFECTIVE.DATE.HIS=R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE>  ;* getting the all effective date
        Y.EFFECTIVE.DATE.COUNT=DCOUNT(Y.EFFECTIVE.DATE.HIS,@VM) ;*R22 Auto Code  Conversion
        Y.COUNT=1
        LOOP
        WHILE Y.COUNT LE Y.EFFECTIVE.DATE.COUNT
            Y.ACTIVITY.HIS = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY,Y.COUNT>  ;* getting the activity for the first effective date
            Y.ACT.COUNT=DCOUNT(Y.ACTIVITY.HIS,@SM) ;*R22 Auto Code  Conversion
            Y.COUNT1 = 1
            LOOP
            WHILE Y.COUNT1 LE Y.ACT.COUNT
                Y.ACTIVITY = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY,Y.COUNT,Y.COUNT1>
                Y.EFF.DATE =   R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE,Y.COUNT>

                Y.ACT.CHECK='LENDING-CHANGE':'-':Y.FIRST.PROP
                IF Y.ACTIVITY EQ Y.ACT.CHECK AND Y.FLAG NE '1' THEN
                    Y.EFFECTIVE.DATE=R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE,Y.COUNT>
                    Y.AAA.ID = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY.REF,Y.COUNT,Y.COUNT1> ;* activity reference for the 'LENDING-CHANGE-PRINCIPALINT' activity
                    GOSUB AA.ARRG.PROCESS
                END
                Y.COUNT1 += 1 ;*R22 Auto Code  Conversion
            REPEAT
            Y.COUNT += 1 ;*R22 Auto Code  Conversion
        REPEAT
    END

RETURN
*-----------------------------------------------------------------------------
AA.ARRG.PROCESS:
*-----------------------------------------------------------------------------
    CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,Y.AAA.ID,R.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY,Y.ERR.AAA)
    IF R.AA.ARRANGEMENT.ACTIVITY NE '' THEN
        IF Y.FLAG NE '1' THEN
            Y.RATE.USER = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.INPUTTER>    ;*getting the value of inputter
            Y.RATE.USER = FIELD(Y.RATE.USER,'_',2,1)
            Y.FLAG =1
        END
    END

RETURN
*-----------------------------------------------------------------------------
GET.LR.FLD.POS:
*-----------------------------------------------------------------------------
    Y.LRF.APPL = "AA.PRD.DES.CUSTOMER":@FM:"AA.ARR.OVERDUE":@FM:"AA.PRD.DES.INTEREST" ;*R22 Auto Code  Conversion
    Y.LRF.FIELDS = "L.AA.CAMP.TY":@VM:"L.AA.AFF.COM":@FM:'L.LOAN.STATUS.1':@FM:"L.AA.NXT.REV.DT" ;*R22 Auto Code  Conversion
    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(Y.LRF.APPL,Y.LRF.FIELDS,FIELD.POS)
    Y.LOC.CAMPAIGN.POS = FIELD.POS<1,1>
    Y.AFFI.COMPANY.POS=FIELD.POS<1,2>
    L.LOAN.STATUS.POS=FIELD.POS<2,1>
    L.AA.NXT.REV.DT.POS=FIELD.POS<3,1>

RETURN
*-----------------------------------------------------------------------------
END
