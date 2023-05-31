* @ValidationCode : MjoxMTI2MDkyNzQyOkNwMTI1MjoxNjg1NTI5MDA0ODU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:00:04
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
SUBROUTINE REDO.AUTH.AA.OVERPAYMENT
*---------------------------------------------------------------------------------
* Description: This routine is to update the contact table REDO.AA.OVERPAYMENT during the
*             AUTH stage of AA overpayment through TELLER CASH & CHEQUE version.
*
* Version Involved:
*              VERSION>TELLER,REDO.OVERPYMT.CASH
*              VERSION>TELLER,REDO.OVERPYMT.CHEQUE
*----------------------------------------------------------------------------------

*-----------------------------------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion     ++ to +=, FM TO @FM, VM to @VM, SM to @SM
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   CALL routine format modified
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.ACCOUNT
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.AA.OVERPAYMENT
    $USING APAP.TAM


    GOSUB INIT        ;* Here variables are intialised and req. files are opened.
    GOSUB PROCESS     ;* Main process begins here.

RETURN
*-----------------------------------------------------------------------------

*** <region name= INIT>
INIT:
*** <desc>Here variables are intialised and req. files are opened.</desc>

    LOC.REF.APPLICATION   = "TELLER":@FM:"ACCOUNT"
    LOC.REF.FIELDS        = 'L.COMMENTS':@VM:'L.TT.MET.OF.PAY':@FM:'L.OD.STATUS':@VM:'L.LOAN.STATUS'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.COMMENTS        = LOC.REF.POS<1,1>
    POS.L.TT.MET.OF.PAY   = LOC.REF.POS<1,2>
    POS.L.OD.STATUS       = LOC.REF.POS<2,1>
    POS.L.LOAN.STATUS     = LOC.REF.POS<2,2>


    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.AA.OVERPAYMENT = 'F.REDO.AA.OVERPAYMENT'
    F.REDO.AA.OVERPAYMENT  = ''
    CALL OPF(FN.REDO.AA.OVERPAYMENT,F.REDO.AA.OVERPAYMENT)

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS>
PROCESS:
*** <desc>Main process begins here.</desc>

    Y.ACC.ID           = R.NEW(TT.TE.NARRATIVE.1)<1,1>
    GOSUB GET.ARRANGEMENT.ID    ;* get the arrangement id.
    Y.OVERPAYMENT.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)
    Y.CUSTOMER.ID     = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.COMMENTS>
    GOSUB GET.INTEREST.RATE     ;* Here we will get the interest rate of the loan.
    GOSUB GET.NEXT.DUE.DATE     ;* Get the next due date of the loan for interest calculation.
    GOSUB CALCULATE.INTEREST    ;* Here we will use the API to calculate the interest rate for period between overpayment date(today) till the next DUE date.
    GOSUB UPDATE.CONCAT.TABLE   ;* Here we will update all the details in concat table.

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.INTEREST.RATE>
GET.INTEREST.RATE:
*** <desc>Here we will get the interest rate of the loan.</desc>

    PROP.NAME            =  'PRINCIPAL'   ;* Interest Property to obtain
    OUT.PROP             =  ''
    APAP.TAM.redoGetInterestProperty(Y.ARRANGEMENT.ID,PROP.NAME,OUT.PROP,ERR);* R22 Manual conversion
    Y.INT.PROPERTY       =  OUT.PROP
    PROPERTY.CLASS       = 'INTEREST'
    EFF.DATE             = ''
    ERR.MSG              = ''
    R.INTEREST.CONDITION = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROPERTY.CLASS,Y.INT.PROPERTY,R.INTEREST.CONDITION,ERR.MSG);* R22 Manual Conversion - CALL routine format modified
    Y.INT.RATE           = R.INTEREST.CONDITION<AA.INT.EFFECTIVE.RATE,1>
    Y.DAY.BASIS          = R.INTEREST.CONDITION<AA.INT.DAY.BASIS>
    IF Y.DAY.BASIS ELSE
        Y.DAY.BASIS = 'A'
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.NEXT.DUE.DATE>
GET.NEXT.DUE.DATE:
*** <desc>Get the next due date of the loan for interest calculation.</desc>

    Y.NEXT.DUE.DATE= ''
    NO.RESET       = ''
    DATE.RANGE     = ''
    SIMULATION.REF = ''
    CALL AA.SCHEDULE.PROJECTOR(Y.AA.ID, SIMULATION.REF, NO.RESET, DATE.RANGE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)

    Y.PAYMENT.DATES.CNT = DCOUNT(DUE.DATES,@FM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.PAYMENT.DATES.CNT
        IF DUE.DATES<Y.VAR1> GT TODAY THEN
            Y.NEXT.DUE.DATE = DUE.DATES<Y.VAR1>
            Y.VAR1 = Y.PAYMENT.DATES.CNT+1    ;* Break.
        END

        Y.VAR1 += 1
    REPEAT
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CALCULATE.INTEREST>
CALCULATE.INTEREST:
*** <desc>Here we will use the API to calculate the interest rate for period between overpayment date(today) till the next DUE date.</desc>

    IF Y.NEXT.DUE.DATE EQ '' OR Y.INT.RATE EQ '' THEN
        TEXT = 'EB-REDO.NEXT.DUE.NULL'
        CALL STORE.OVERRIDE("")
        Y.TOTAL.INTEREST = "0.00"
        Y.THISMONTH.INT  = "0.00"
        Y.NEXTMONTH.INT  = "0.00"
        CCY         = R.NEW(TT.TE.CURRENCY.1)
        RETURN
    END
    START.DATE = TODAY
    END.DATE   = Y.NEXT.DUE.DATE
    RATES      = Y.INT.RATE
    BASE.AMTS  = Y.OVERPAYMENT.AMT

    CCY         = R.NEW(TT.TE.CURRENCY.1)
    ROUND.TYPE  = ""
    CALL EB.INTEREST.CALC(START.DATE, END.DATE, RATES, BASE.AMTS, INT.AMTS, ACCR.DAYS, Y.DAY.BASIS, CCY, ROUND.AMTS, ROUND.TYPE, Y.CUSTOMER.ID)
    Y.THISMONTH.INT = ''
    Y.NEXTMONTH.INT = ''
    Y.TOTAL.INTEREST= ROUND.AMTS

    IF START.DATE[5,2] NE END.DATE[5,2] THEN

        Y.NEW.START.DATE = END.DATE[1,6]:'01'
        YREGION  = ""
        YDAYS    = "C"
        CALL CDD (YREGION,Y.NEW.START.DATE,END.DATE,YDAYS)
        Y.NEXTMONTH.INT = (ROUND.AMTS/ACCR.DAYS)*YDAYS
        Y.THISMONTH.INT = ROUND.AMTS-Y.NEXTMONTH.INT

        CALL EB.ROUND.AMOUNT(CCY,Y.NEXTMONTH.INT, "", "")
        CALL EB.ROUND.AMOUNT(CCY,Y.THISMONTH.INT, "", "")
    END ELSE
        Y.THISMONTH.INT = ROUND.AMTS
        Y.NEXTMONTH.INT = "0.00"

    END



RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= UPDATE.CONCAT.TABLE>
UPDATE.CONCAT.TABLE:
*** <desc>Here we will update all the details in concat table.</desc>

    R.REDO.AA.OVERPAYMENT                               = ""
    R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.NO>            = Y.ACC.ID
    R.REDO.AA.OVERPAYMENT<REDO.OVER.CURRENCY>           = CCY
    R.REDO.AA.OVERPAYMENT<REDO.OVER.AMOUNT>             = Y.OVERPAYMENT.AMT
    R.REDO.AA.OVERPAYMENT<REDO.OVER.PAYMENT.METHOD>     = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.MET.OF.PAY>
    R.REDO.AA.OVERPAYMENT<REDO.OVER.PAYMENT.DATE>       = TODAY
    R.REDO.AA.OVERPAYMENT<REDO.OVER.TELLER.TXN.REF>     = ID.NEW
    R.REDO.AA.OVERPAYMENT<REDO.OVER.CUSTOMER.ID>        = Y.CUSTOMER.ID
    R.REDO.AA.OVERPAYMENT<REDO.OVER.INTEREST.RATE>      = Y.INT.RATE
    R.REDO.AA.OVERPAYMENT<REDO.OVER.NEXT.DUE.DATE>      = Y.NEXT.DUE.DATE
    R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.AGING.STATUS>  = R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS>
    R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.MANUAL.STATUS> = R.ACCOUNT<AC.LOCAL.REF,POS.L.LOAN.STATUS>
    R.REDO.AA.OVERPAYMENT<REDO.OVER.CATEGORY>           = R.ACCOUNT<AC.CATEGORY>
    R.REDO.AA.OVERPAYMENT<REDO.OVER.COMP.CODE>          = R.ACCOUNT<AC.CO.CODE>
    R.REDO.AA.OVERPAYMENT<REDO.OVER.TOT.COMP.INTEREST>  = Y.TOTAL.INTEREST
    R.REDO.AA.OVERPAYMENT<REDO.OVER.COMP.INT.THISMONTH> = Y.THISMONTH.INT
    R.REDO.AA.OVERPAYMENT<REDO.OVER.COMP.INT.NEXTMONTH> = Y.NEXTMONTH.INT
    R.REDO.AA.OVERPAYMENT<REDO.OVER.STATUS>             = "PENDIENTE"
    R.REDO.AA.OVERPAYMENT<REDO.OVER.CURR.NO>            = 1
    R.REDO.AA.OVERPAYMENT<REDO.OVER.INPUTTER>           = R.NEW(TT.TE.INPUTTER)
    R.REDO.AA.OVERPAYMENT<REDO.OVER.DATE.TIME>          = R.NEW(TT.TE.DATE.TIME)
    R.REDO.AA.OVERPAYMENT<REDO.OVER.AUTHORISER>         = OPERATOR
    R.REDO.AA.OVERPAYMENT<REDO.OVER.CO.CODE>            = R.NEW(TT.TE.CO.CODE)
    R.REDO.AA.OVERPAYMENT<REDO.OVER.DEPT.CODE>          = R.NEW(TT.TE.DEPT.CODE)


    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)
    CHANGE '.' TO '' IN UNIQUE.TIME
    LEN.UNIQUE.TIME = LEN(UNIQUE.TIME) -6
    Y.UNIQUE.ID = UNIQUE.TIME[LEN.UNIQUE.TIME,6]

    Y.CNCT.ID = Y.CUSTOMER.ID:".":TODAY:".":Y.UNIQUE.ID

    CALL F.WRITE(FN.REDO.AA.OVERPAYMENT,Y.CNCT.ID,R.REDO.AA.OVERPAYMENT)

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.ARRANGEMENT.ID>
GET.ARRANGEMENT.ID:
*** <desc>get the arrangement id.</desc>

    Y.AA.ID = ""
    CALL F.READ(FN.ACCOUNT,Y.ACC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.AA.ID  = R.ACCOUNT<AC.ARRANGEMENT.ID>


RETURN
*** </region>
END
