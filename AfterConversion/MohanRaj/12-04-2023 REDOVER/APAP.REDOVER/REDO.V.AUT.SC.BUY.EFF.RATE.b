* @ValidationCode : MjoxMDgyODg3MzE3OkNwMTI1MjoxNjgxMzAwODM2MzcxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:30:36
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
SUBROUTINE REDO.V.AUT.SC.BUY.EFF.RATE
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : This routine is auth routine attached to the below versions
*               SEC.TRADE,REDO.AUTH.BUY.OWN.BOOK
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : Balagurunathan B
* PROGRAM NAME : REDO.V.AUT.SC.BUY.EFF.RATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date             Author             Reference          Description
* 15 Mar 2013      Balagurunathan B   553577 - CR008     Initial Creation
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     IF CONDITION ADDED, VM TO @VM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SEC.ACC.MASTER
    $INSERT I_F.SC.PARAMETER
    $INSERT I_F.SC.STD.SEC.TRADE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.REDO.APAP.L.CONTRACT.BALANCES
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    IF R.NEW(SC.SBS.CURR.NO) LE 1 THEN
        GOSUB INIT
        GOSUB PROCESS
    END
*
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
*****
INIT:
*****
*
    FN.SECURITY.MASTER           = "F.SECURITY.MASTER"
    F.SECURITY.MASTER            = ""
    R.SECURITY.MASTER            = ""
    E.SECURITY.MASTER            = ""
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    FN.SC.PARAMETER = "F.SC.PARAMETER"
    F.SC.PARAMETER  = ""
    R.SC.PARAM      = ""
    ERR.SC.PARAM    = ""
    CALL OPF(FN.SC.PARAMETER,F.SC.PARAMETER)

    FN.SC.STD.SEC.TRADE = 'F.SC.STD.SEC.TRADE'
    F.SC.STD.SEC.TRADE = ''
    CALL OPF(FN.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE)

    APPL.ARR = 'SEC.ACC.MASTER'
    FIELD.ARR = 'L.DISC.ADJ.CAT':@VM:'L.INT.ADJ.CAT'
    POS.ARR = ''
    CALL MULTI.GET.LOC.REF(APPL.ARR,FIELD.ARR,POS.ARR)

    L.DISC.ADJ.CAT.POS = POS.ARR<1,1>
    L.INT.ADJ.CAT.POS = POS.ARR<1,2>

    R.SC.STD.TRADE = ""
*  CALL F.READ(FN.SC.STD.SEC.TRADE,ID.COMPANY,R.SC.STD.TRADE,F.SC.STD.SEC.TRADE,SC.STD.ERR)  ;* Tus Start
    CALL CACHE.READ(FN.SC.STD.SEC.TRADE,ID.COMPANY,R.SC.STD.TRADE,SC.STD.ERR)  ;* Tus End
    IF R.SC.STD.TRADE THEN
        Y.SC.CR.TXN.CODE = R.SC.STD.TRADE<SC.SST.ACCR.CR.CODE>
        Y.SC.DR.TXN.CODE = R.SC.STD.TRADE<SC.SST.ACCR.DR.CODE>
    END ELSE
*    CALL F.READ(FN.SC.STD.SEC.TRADE,R.COMPANY(EB.COM.FINANCIAL.COM),R.SC.STD.TRADE,F.SC.STD.SEC.TRADE,SC.STD.ERR)  ;* Tus Start
        CALL CACHE.READ(FN.SC.STD.SEC.TRADE,R.COMPANY(EB.COM.FINANCIAL.COM),R.SC.STD.TRADE,SC.STD.ERR)   ;* Tus End
        Y.SC.CR.TXN.CODE = R.SC.STD.TRADE<SC.SST.ACCR.CR.CODE>
        Y.SC.DR.TXN.CODE = R.SC.STD.TRADE<SC.SST.ACCR.DR.CODE>
    END

    R.SC.PARAM = ""
*  CALL F.READ(FN.SC.PARAMETER,ID.COMPANY,R.SC.PARAM,F.SC.PARAMETER,ERR.SC.PARAM)  ;* Tus Start
    CALL CACHE.READ(FN.SC.PARAMETER,ID.COMPANY,R.SC.PARAM,ERR.SC.PARAM)   ;* Tus End
    IF R.SC.PARAM THEN
        Y.CCY.MARKET   = R.SC.PARAM<SC.PARAM.DEFAULT.CCY.MARKET>
    END ELSE
*    CALL F.READ(FN.SC.PARAMETER,R.COMPANY(EB.COM.FINANCIAL.COM),R.SC.PARAM,F.SC.PARAMETER,ERR.SC.PARAM)   ;* Tus Start
        CALL CACHE.READ(FN.SC.PARAMETER,R.COMPANY(EB.COM.FINANCIAL.COM),R.SC.PARAM,ERR.SC.PARAM)   ;* Tus End
        Y.CCY.MARKET = R.SC.PARAM<SC.PARAM.DEFAULT.CCY.MARKET>
    END

    FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
    F.SEC.ACC.MASTER = ''
    CALL OPF(FN.SEC.ACC.MASTER,F.SEC.ACC.MASTER)

    FN.APAP.CB = 'F.REDO.APAP.L.CONTRACT.BALANCES'
    F.APAP.CB  = ''
    CALL OPF(FN.APAP.CB,F.APAP.CB)


*
    Y.CNT                  = "1" ; CUST.TOT.NOM.ALL = "" ; CUST.INTR.AMT    = "" ; FACE.VALUE = "" ; COUPON.TENOR              = "" ; ACTUAL.START.DATE         = "" ; INT.PAYMENT.DATE          = "" ; Y.SUB.ASSET.TYPE = "" ;
    Y.SECURITY.CODE        = ""  ; INTEREST.RATE    = "" ; BASE             = "" ; DAYS       = "" ; CALC.BASE.EFFECTIVE.RATE1 = "" ; CALC.BASE.EFFECTIVE.RATE2 = "" ; CALC.BASE.EFFECTIVE.RATE3 = "" ; CALC.EXPONENT    = "" ;
    CALC.EXPONENT.WITH.POW = ""  ; EFFECTIVE.RATE   = "" ; CUST.TOT.NOM.ALL = "" ; Y.COUNT    = "" ; CUST.TOT.NOM              = "" ; CUST.INTR.AMT             = "" ; REGION.CODE               = "" ;
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
********
PROCESS:
********
*
    Y.SECURITY.CODE   = R.NEW(SC.SBS.SECURITY.CODE)
    Y.CCY             = R.NEW(SC.SBS.SECURITY.CURRENCY)
    CALL F.READ(FN.SECURITY.MASTER,Y.SECURITY.CODE,R.SECURITY.MASTER,F.SECURITY.MASTER,E.SECURITY.MASTER)
*
    IF R.SECURITY.MASTER<SC.SCM.BOND.OR.SHARE> EQ 'S' THEN
        RETURN
    END
    Y.SUB.ASSET.TYPE  = R.SECURITY.MASTER<SC.SCM.SUB.ASSET.TYPE>
    Y.SM.PAR.VALUE    = R.SECURITY.MASTER<SC.SCM.PAR.VALUE>
    Y.SEC.CCY         = R.SECURITY.MASTER<SC.SCM.SECURITY.CURRENCY>
    IF NOT(Y.SM.PAR.VALUE) THEN ;*R22 Auto code conversion-START
        Y.SM.PAR.VALUE = 1  ;*PACS00051213 - S/E
    END ;*R22 Auto code conversion-END

    GOSUB READ.SEC.AC.MASTER

    PROCESS.GOHEAD = @TRUE
    GOSUB PROCESS.FOR.CUST.INTR.AMT
    GOSUB LCCY.FCCY.CONV
    GOSUB UPD.APAP.CONTRACT.BAL
    IF PROCESS.GOHEAD THEN
        GOSUB RAISE.ENTRIES
    END
*END

*
RETURN

********************
READ.SEC.AC.MASTER:
*********************

    SAM.ID = R.NEW(SC.SBS.CUST.SEC.ACC)
    R.SAM = ''
    SAM.ERR = ''
    CALL F.READ(FN.SEC.ACC.MASTER,SAM.ID,R.SAM,F.SEC.ACC.MASTER,SAM.ERR)

    INT.RECD.CAT = R.SAM<SC.SAM.INT.RECD.CAT>

    INT.ADJ.CAT = R.SAM<SC.SAM.LOCAL.REF,L.INT.ADJ.CAT.POS>
    INT.ADJ.ACC = Y.CCY:INT.ADJ.CAT:'0001'

    CUSTOMER.NO = R.SAM<SC.SAM.CUSTOMER.NUMBER>

RETURN

**************************
PROCESS.FOR.CUST.INTR.AMT:
**************************
*
    FACE.VALUE         = R.NEW(SC.SBS.CUST.NO.NOM)<1,1>
    CUSTOMER.ID        = R.NEW(SC.SBS.CUSTOMER.NO)<1,1>
    INTEREST.RATE      = R.NEW(SC.SBS.INTEREST.RATE)
    CUST.INTR.AMT      = R.NEW(SC.SBS.CUST.INTR.AMT)
    ACCRUAL.START.DATE = R.SECURITY.MASTER<SC.SCM.ACCRUAL.START.DATE>
    INT.PAYMENT.DATE   = R.SECURITY.MASTER<SC.SCM.INT.PAYMENT.DATE>
    BASE.1             = R.SECURITY.MASTER<SC.SCM.INTEREST.DAY.BASIS>
    BASE               = FIELD(BASE.1,'/',2)

    VALUE.DATE         = R.NEW(SC.SBS.VALUE.DATE)
    CALL CDD(REGION.CODE,VALUE.DATE,TODAY,DAYS)

    IF ACCRUAL.START.DATE AND INT.PAYMENT.DATE THEN
        COUPON.TENOR = "C"
        CALL CDD(REGION.CODE,ACCRUAL.START.DATE,INT.PAYMENT.DATE,COUPON.TENOR)
    END

*
    GOSUB GET.EFF.RATE
*
    CUST.TOT.NOM = R.NEW(SC.SBS.CUST.TOT.NOM)
    EFF.INTR.AMT = (CUST.TOT.NOM * EFFECTIVE.RATE)

    INT.ACCRUAL.VAL = CUST.INTR.AMT - EFF.INTR.AMT
    IF INT.ACCRUAL.VAL EQ 0 THEN
        PROCESS.GOHEAD = @FALSE
    END
*
RETURN

**************
GET.EFF.RATE:
**************
    CALC1          = (INTEREST.RATE/100) / BASE
    CALC2          = (CALC1 * COUPON.TENOR)
    CALC3          = (1 + CALC2)

    CALC.EXP1      = (DAYS/COUPON.TENOR)

    CALC4          = PWR(CALC3,CALC.EXP1)
    EFF.RATE       = (CALC4 - 1)
    EFFECTIVE.RATE = EFF.RATE

RETURN

***************
RAISE.ENTRIES:
***************

    GOSUB STMT.ENTRY
    Y.COMMON.ARRAY = LOWER(R.SPEC.ENT)
    GOSUB CATEG.ENTRY
    Y.COMMON.ARRAY<-1> = LOWER(R.SPEC.ENT)
    GOSUB CALL.EB.ACCOUNTING

RETURN

*****************
LCCY.FCCY.CONV:
*****************

    INT.ACCRUAL.VAL.FCY = ''
    INT.ACCRUAL.VAL.LCY = ''

    IF Y.SEC.CCY EQ LCCY THEN
        INT.ACCRUAL.VAL.LCY = INT.ACCRUAL.VAL
        INT.ACCRUAL.VAL.FCY = ''
    END

    IF Y.SEC.CCY NE LCCY THEN
        INT.ACCRUAL.VAL.FCY = INT.ACCRUAL.VAL
        CCY.MARKET = Y.CCY.MARKET
        FCY.TXN.CCY = Y.SEC.CCY
        FCY.TXN.AMOUNT = INT.ACCRUAL.VAL
        AML.CCY = LCCY
        SELL.AMT = ""
        DIFF.AMT = ''
        LCCY.AMT = ''
        RET.ERR = ''
        EX.RATE = ''
        CALL EXCHRATE(CCY.MARKET,FCY.TXN.CCY,FCY.TXN.AMOUNT,AML.CCY,SELL.AMT,'',EX.RATE,DIFF.AMT,LCCY.AMT,RET.ERR)
        INT.ACCRUAL.VAL.LCY = LCCY.AMT
    END

RETURN


STMT.ENTRY:
***************

    INT.ACCRUAL.VAL.LCY = DROUND(INT.ACCRUAL.VAL.LCY,2)
    INT.ACCRUAL.VAL.FCY = DROUND(INT.ACCRUAL.VAL.FCY,2)
    R.SPEC.ENT = ''
    R.SPEC.ENT<AC.STE.ACCOUNT.NUMBER>   = INT.ADJ.ACC
    R.SPEC.ENT<AC.STE.COMPANY.CODE>     = ID.COMPANY
    R.SPEC.ENT<AC.STE.AMOUNT.LCY>       = INT.ACCRUAL.VAL.LCY
    IF R.SPEC.ENT<AC.STE.AMOUNT.LCY> GT 0 THEN
        R.SPEC.ENT<AC.STE.TRANSACTION.CODE> = Y.SC.CR.TXN.CODE
    END ELSE
        R.SPEC.ENT<AC.STE.TRANSACTION.CODE> = Y.SC.DR.TXN.CODE
    END
    R.SPEC.ENT<AC.STE.PL.CATEGORY>      = ''
    R.SPEC.ENT<AC.STE.CUSTOMER.ID>      = CUSTOMER.ID
    R.SPEC.ENT<AC.STE.PRODUCT.CATEGORY> = INT.ADJ.CAT
    R.SPEC.ENT<AC.STE.VALUE.DATE>       = TODAY
    R.SPEC.ENT<AC.STE.CURRENCY>         = Y.SEC.CCY
    IF INT.ACCRUAL.VAL.FCY THEN
        R.SPEC.ENT<AC.STE.AMOUNT.FCY>       = INT.ACCRUAL.VAL.FCY
        R.SPEC.ENT<AC.STE.EXCHANGE.RATE >   = EX.RATE
    END
    R.SPEC.ENT<AC.STE.POSITION.TYPE>    = 'TR'
    R.SPEC.ENT<AC.STE.OUR.REFERENCE>    = ID.NEW
    R.SPEC.ENT<AC.STE.EXPOSURE.DATE>    = TODAY
    R.SPEC.ENT<AC.STE.CURRENCY.MARKET>  = Y.CCY.MARKET
    R.SPEC.ENT<AC.STE.TRANS.REFERENCE>  = ID.NEW
    R.SPEC.ENT<AC.STE.SYSTEM.ID>        = 'SCAC'
    R.SPEC.ENT<AC.STE.BOOKING.DATE>     = TODAY


RETURN

CATEG.ENTRY:
***********

    INT.ACCRUAL.VAL.LCY = DROUND(INT.ACCRUAL.VAL.LCY,2)
    INT.ACCRUAL.VAL.FCY = DROUND(INT.ACCRUAL.VAL.FCY,2)
    R.SPEC.ENT = ''
    R.SPEC.ENT<AC.CAT.COMPANY.CODE>     = ID.COMPANY
    R.SPEC.ENT<AC.CAT.AMOUNT.LCY>       = INT.ACCRUAL.VAL.LCY * -1
    IF R.SPEC.ENT<AC.CAT.AMOUNT.LCY>  GT 0 THEN
        R.SPEC.ENT<AC.CAT.TRANSACTION.CODE> = Y.SC.CR.TXN.CODE
    END ELSE
        R.SPEC.ENT<AC.CAT.TRANSACTION.CODE> = Y.SC.DR.TXN.CODE
    END
    R.SPEC.ENT<AC.CAT.NARRATIVE,1>      = "DAILY.ACCR"
    R.SPEC.ENT<AC.CAT.PL.CATEGORY>      = INT.RECD.CAT
    R.SPEC.ENT<AC.CAT.CUSTOMER.ID>      = CUSTOMER.ID
    R.SPEC.ENT<AC.CAT.PRODUCT.CATEGORY> = "51001"
    R.SPEC.ENT<AC.CAT.VALUE.DATE>       = TODAY
    R.SPEC.ENT<AC.CAT.CURRENCY>         = Y.SEC.CCY
    IF INT.ACCRUAL.VAL.FCY THEN
        R.SPEC.ENT<AC.CAT.AMOUNT.FCY>       = INT.ACCRUAL.VAL.FCY
        R.SPEC.ENT<AC.CAT.EXCHANGE.RATE>    = EX.RATE
    END
    R.SPEC.ENT<AC.CAT.OUR.REFERENCE>    = ID.NEW
    R.SPEC.ENT<AC.CAT.EXPOSURE.DATE>    = TODAY
    R.SPEC.ENT<AC.CAT.CURRENCY.MARKET>  = Y.CCY.MARKET
    R.SPEC.ENT<AC.CAT.TRANS.REFERENCE>  = ID.NEW
    R.SPEC.ENT<AC.CAT.SYSTEM.ID>        = "SCAC"
    R.SPEC.ENT<AC.CAT.BOOKING.DATE>     = TODAY

RETURN

*********************
CALL.EB.ACCOUNTING:
*********************

    Y.STMT.NO = R.NEW(SC.SBS.STATEMENT.NOS)

    CALL EB.ACCOUNTING("SC","SAO",Y.COMMON.ARRAY,'')

    Y.STMT.NO.NEW = R.NEW(SC.SBS.STATEMENT.NOS)
    R.NEW(SC.SBS.STATEMENT.NOS) = Y.STMT.NO
    R.NEW(SC.SBS.STATEMENT.NOS)<1,-1> = ID.COMPANY
    R.NEW(SC.SBS.STATEMENT.NOS)<1,-1> = Y.STMT.NO.NEW


RETURN

***********************
UPD.APAP.CONTRACT.BAL:
***********************

    R.APAP.L.CB = ''
    Y.ACB = SAM.ID:".":Y.SECURITY.CODE
    IF VALUE.DATE LT TODAY AND EFF.INTR.AMT THEN
        R.APAP.L.CB<CRT.BAL.ACCRUE.TO.DATE>  = EFF.INTR.AMT
        CALL F.WRITE(FN.APAP.CB,Y.ACB,R.APAP.L.CB)
    END

RETURN
END
