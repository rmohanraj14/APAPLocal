* @ValidationCode : MjotOTc1NDU3NjMxOkNwMTI1MjoxNjgxMjg1NTk4NzM2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:16:38
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
SUBROUTINE REDO.V.AUT.EFF.RATE
*----------------------------------------------------------------------------------------------------
* DESCRIPTION : This routine is auth routine attached to the below versions
*               SEC.TRADE,APAP.BUY.OWN.BOOK , SEC.TRADE,APAP.SEL.OWN.BOOK
*-----------------------------------------------------------------------------------------------------
* Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : NaveenKumar N
* PROGRAM NAME : REDO.V.AUT.EFF.RATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date             Author             Reference          Description
* 14-Oct-2010      NaveenKumar N      ODR-2010-07-0081   Initial creation
* 28-Mar-2010      Pradeep S          PACS00051213       Logic changed for par value
* 06 Jul 2011      Pradeep S          PACS00080124       Initial Creation
* 18-Feb-2013      Arundev KR         RTC-553577         Changes for CR008 Discount Amortisation
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.COMPANY
    $INSERT I_F.SC.STD.SEC.TRADE
    $INSERT I_F.SC.PARAMETER
    $INSERT I_F.SEC.ACC.MASTER
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.REDO.APAP.L.CONTRACT.BALANCES
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.REDO.APAP.L.SC.DISC.AMORT
    $INSERT I_F.SC.TRADING.POSITION
    $INSERT I_F.SC.TRADE.POS.HISTORY
    $INSERT I_F.DATES

    GOSUB INITIALISE
    GOSUB OPENFILES
    GOSUB GETLOCREF
    GOSUB PROCESS

RETURN

*-------------------------------------------------------------------------
INITIALISE:
*-------------------------------------------------------------------------

    APAP.LCCY = LCCY

    SEC.TRADE.ID = ID.NEW

RETURN

*-------------------------------------------------------------------------
OPENFILES:
*-------------------------------------------------------------------------
    FN.SC.STD.SEC.TRADE = 'F.SC.STD.SEC.TRADE'
    F.SC.STD.SEC.TRADE = ''
    CALL OPF(FN.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE)

    FN.SC.PARAMETER = 'F.SC.PARAMETER'
    F.SC.PARAMETER = ''
    CALL OPF(FN.SC.PARAMETER,F.SC.PARAMETER)

    FN.SEC.ACC.MASTER = 'F.SEC.ACC.MASTER'
    F.SEC.ACC.MASTER = ''
    CALL OPF(FN.SEC.ACC.MASTER,F.SEC.ACC.MASTER)

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

    FN.REDO.APAP.L.CONTRACT.BALANCES = 'F.REDO.APAP.L.CONTRACT.BALANCES'
    F.REDO.APAP.L.CONTRACT.BALANCES = ''
    CALL OPF(FN.REDO.APAP.L.CONTRACT.BALANCES,F.REDO.APAP.L.CONTRACT.BALANCES)

    FN.REDO.APAP.L.SC.DISC.AMORT = 'F.REDO.APAP.L.SC.DISC.AMORT'
    F.REDO.APAP.L.SC.DISC.AMORT = ''
    CALL OPF(FN.REDO.APAP.L.SC.DISC.AMORT,F.REDO.APAP.L.SC.DISC.AMORT)

    FN.SC.TRADING.POSITION = 'F.SC.TRADING.POSITION'
    F.SC.TRADING.POSITION = ''
    CALL OPF(FN.SC.TRADING.POSITION,F.SC.TRADING.POSITION)

    FN.SC.TRADING.HIS = 'F.SC.TRADE.POS.HISTORY'
    F.SC.TRADING.HIS = ''
    CALL OPF(FN.SC.TRADING.HIS,F.SC.TRADING.HIS)

RETURN

*-------------------------------------------------------------------------
GETLOCREF:
*-------------------------------------------------------------------------

    APPL.ARR = 'SEC.ACC.MASTER'
    FIELD.ARR = 'L.DISC.ADJ.CAT':@VM:'L.INT.ADJ.CAT'
    POS.ARR = ''
    CALL MULTI.GET.LOC.REF(APPL.ARR,FIELD.ARR,POS.ARR)

    L.DISC.ADJ.CAT.POS = POS.ARR<1,1>
    L.INT.ADJ.CAT.POS = POS.ARR<1,2>

RETURN

*-------------------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------------------

    GOSUB READ.SECURITY.MASTER

    IF BOND.SHARE NE 'B' THEN
        RETURN
    END

    GOSUB READ.SEC.AC.MASTER
    GOSUB READ.SC.STD.SEC.TRADE
    GOSUB READ.SC.PARAMETER

    STP.ID = SAM.ID:'.':SM.ID

    INT.LIN.AMT = R.NEW(SC.SBS.CUST.INTR.AMT)
    SELL.NOMINAL = R.NEW(SC.SBS.CUST.TOT.NOM)

    GOSUB INTEREST.ACRUAL.ADJUSTMENT
    GOSUB DISCOUNT.PREMIUM.ACCRUAL.REVERSAL

RETURN

*-------------------------------------------------------------------------
INTEREST.ACRUAL.ADJUSTMENT:
*-------------------------------------------------------------------------
    APAP.CONTRACT.BALANCES.ID = STP.ID
    R.APAP.CONTRACT.BALANCES = ''
    APAP.CONTRACT.BALANCES.ERR = ''
    CALL F.READ(FN.REDO.APAP.L.CONTRACT.BALANCES,APAP.CONTRACT.BALANCES.ID,R.APAP.CONTRACT.BALANCES,F.REDO.APAP.L.CONTRACT.BALANCES,APAP.CONTRACT.BALANCES.ERR)
****
    Y.ORG.SELL.NOMINAL = R.APAP.CONTRACT.BALANCES<CRT.BAL.NOMINAL>
****
    INT.EFF.ACC.TODATE = R.APAP.CONTRACT.BALANCES<CRT.BAL.ACCRUE.TO.DATE>

    R.APAP.CONTRACT.BALANCES<CRT.BAL.NOMINAL> -= SELL.NOMINAL
    INT.EFF.NOMINALS = R.APAP.CONTRACT.BALANCES<CRT.BAL.NOMINAL>
********
    IF INT.EFF.NOMINALS EQ 0 THEN
        INT.EFF.AMT = INT.EFF.ACC.TODATE
    END ELSE
        INT.EFF.AMT = (INT.EFF.ACC.TODATE / Y.ORG.SELL.NOMINAL) * SELL.NOMINAL
    END
**********
    DIFF.AMT = DROUND((INT.EFF.AMT - INT.LIN.AMT),2)
    DIFF.AMT = -1 * DIFF.AMT
    GOSUB DIFF.AMT.FCY.LCY.CONV

    STMT.ENTRY.ACC = INT.ADJ.ACC
    CATEG.ENTRY.PL = INT.RECD.CAT
    Y.NARRATIVE = 'INTEREST ACCRUAL'
    CR.TXN.CODE = INT.CR.TXN.CODE
    DR.TXN.CODE = INT.DR.TXN.CODE

    GOSUB ACCOUNTING.ENTRIES

    CALL F.WRITE(FN.REDO.APAP.L.CONTRACT.BALANCES,APAP.CONTRACT.BALANCES.ID,R.APAP.CONTRACT.BALANCES)

RETURN

*-------------------------------------------------------------------------
DISCOUNT.PREMIUM.ACCRUAL.REVERSAL:
*-------------------------------------------------------------------------

    DISC.AMORT.ID = STP.ID
    R.DISC.AMORT = ''
    DISC.AMORT.ERR = ''
    CALL F.READ(FN.REDO.APAP.L.SC.DISC.AMORT,DISC.AMORT.ID,R.DISC.AMORT,F.REDO.APAP.L.SC.DISC.AMORT,DISC.AMORT.ERR)

    EFF.DISC.AMT = R.DISC.AMORT<DISC.AMRT.EFF.DISC.TODATE>
****
    Y.DISC.ORG.NOMINAL = R.DISC.AMORT<DISC.AMRT.NOMINAL>
****
    R.DISC.AMORT<DISC.AMRT.NOMINAL> -= SELL.NOMINAL
    DISC.NOMINAL = R.DISC.AMORT<DISC.AMRT.NOMINAL>
    DISC.LIN.AMT = R.DISC.AMORT<DISC.AMRT.LIN.ACCR.AMT>

    GOSUB READ.SC.TRADING.POSITION
********
    IF DISC.NOMINAL EQ 0 THEN
        Y.DA = EFF.DISC.AMT
    END ELSE
        Y.DA = (EFF.DISC.AMT / Y.DISC.ORG.NOMINAL) * SELL.NOMINAL
    END
**********

    Y.LAST.DAY = R.DATES(EB.DAT.LAST.WORKING.DAY)
    Y.TRADE.HIS.ID = SAM.ID:'.':R.NEW(SC.SBS.SECURITY.CODE):'.':Y.LAST.DAY[1,6]
    Y.DAY.HIS = Y.LAST.DAY[7,2]
    CALL F.READ(FN.SC.TRADING.HIS,Y.TRADE.HIS.ID,R.SC.TRADE.HIS,F.SC.TRADING.HIS,TRADE.HIS.ERR)
    Y.HIS.DAYS = R.SC.TRADE.HIS<SC.TPH.DAY>
    LOCATE Y.DAY.HIS IN Y.HIS.DAYS SETTING Y.HIS.POS THEN
        STP.DISC.ACCR = R.SC.TRADE.HIS<SC.TPH.V.D.DISC.ACCR,Y.HIS.POS>
    END
    DIFF.AMT = DROUND((STP.DISC.ACCR - Y.DA),2)

    IF DISC.LIN.AMT LT 0 THEN
        DIFF.AMT = (-1) * DIFF.AMT
    END

    GOSUB DIFF.AMT.FCY.LCY.CONV

    STMT.ENTRY.ACC = DISC.ADJ.ACC
    CATEG.ENTRY.PL = DISCOUNT.CAT
    Y.NARRATIVE = 'DISCOUNT ACCRUAL'
    CR.TXN.CODE = DISC.CR.TXN.CODE
    DR.TXN.CODE = DISC.DR.TXN.CODE

    GOSUB ACCOUNTING.ENTRIES

    CALL F.WRITE(FN.REDO.APAP.L.SC.DISC.AMORT,DISC.AMORT.ID,R.DISC.AMORT)

RETURN

*-------------------------------------------------------------------------
READ.SECURITY.MASTER:
*-------------------------------------------------------------------------

    SM.ID = R.NEW(SC.SBS.SECURITY.CODE)
    R.SM = ''
    SM.ERR = ''
    CALL F.READ(FN.SECURITY.MASTER,SM.ID,R.SM,F.SECURITY.MASTER,SM.ERR)

    SC.CCY = R.SM<SC.SCM.SECURITY.CURRENCY>
    BOND.SHARE = R.SM<SC.SCM.BOND.OR.SHARE>

RETURN

*-------------------------------------------------------------------------
READ.SEC.AC.MASTER:
*-------------------------------------------------------------------------

    SAM.ID = R.NEW(SC.SBS.CUST.SEC.ACC)
    R.SAM = ''
    SAM.ERR = ''
    CALL F.READ(FN.SEC.ACC.MASTER,SAM.ID,R.SAM,F.SEC.ACC.MASTER,SAM.ERR)

    INT.RECD.CAT = R.SAM<SC.SAM.INT.RECD.CAT>

    DISC.ADJ.CAT = R.SAM<SC.SAM.LOCAL.REF,L.DISC.ADJ.CAT.POS>
    DISC.ADJ.ACC = SC.CCY:DISC.ADJ.CAT:'0001'

    INT.ADJ.CAT = R.SAM<SC.SAM.LOCAL.REF,L.INT.ADJ.CAT.POS>
    INT.ADJ.ACC = SC.CCY:INT.ADJ.CAT:'0001'

    CUSTOMER.NO = R.SAM<SC.SAM.CUSTOMER.NUMBER>

    DISCOUNT.CAT = R.SAM<SC.SAM.DISCOUNT.CAT>

RETURN

*-------------------------------------------------------------------------
READ.SC.STD.SEC.TRADE:
*-------------------------------------------------------------------------

    SC.STD.SEC.TRADE.ID = ID.COMPANY
    R.SC.STD.SEC.TRADE = ''
    SC.STD.SEC.TRADE.ERR = ''
*  CALL F.READ(FN.SC.STD.SEC.TRADE,ID.COMPANY,R.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ERR)  ;* Tus Start
    CALL CACHE.READ(FN.SC.STD.SEC.TRADE,ID.COMPANY,R.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ERR)  ;* Tus End
    IF SC.STD.SEC.TRADE.ERR THEN
        SC.STD.SEC.TRADE.ID = R.COMPANY(EB.COM.FINANCIAL.COM)
*    CALL F.READ(FN.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ID,R.SC.STD.SEC.TRADE,F.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ERR)  ;* Tus Start
        CALL CACHE.READ(FN.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ID,R.SC.STD.SEC.TRADE,SC.STD.SEC.TRADE.ERR)  ;* Tus End
    END
    INT.CR.TXN.CODE = R.SC.STD.SEC.TRADE<SC.SST.ACCR.CR.CODE>
    INT.DR.TXN.CODE = R.SC.STD.SEC.TRADE<SC.SST.ACCR.DR.CODE>
    DISC.CR.TXN.CODE = R.SC.STD.SEC.TRADE<SC.SST.CU.DISC.CR.CODE>
    DISC.DR.TXN.CODE = R.SC.STD.SEC.TRADE<SC.SST.CU.DISC.DB.CODE>
RETURN

*-------------------------------------------------------------------------
READ.SC.PARAMETER:
*-------------------------------------------------------------------------

    SC.PARAMETER.ID = ID.COMPANY
    R.SC.PARAMETER = ""
    SC.PARAMETER.ERR= ''
*  CALL F.READ(FN.SC.PARAMETER,ID.COMPANY,R.SC.PARAMETER,F.SC.PARAMETER,SC.PARAMETER.ERR)  ;* Tus Start
    CALL CACHE.READ(FN.SC.PARAMETER,ID.COMPANY,R.SC.PARAMETER,SC.PARAMETER.ERR)   ;* Tus End
    IF SC.PARAMETER.ERR THEN
        SC.PARAMETER.ID = R.COMPANY(EB.COM.FINANCIAL.COM)
*    CALL F.READ(FN.SC.PARAMETER,SC.PARAMETER.ID,R.SC.PARAMETER,F.SC.PARAMETER,SC.PARAMETER.ERR)  ;* Tus Start
        CALL CACHE.READ(FN.SC.PARAMETER,SC.PARAMETER.ID,R.SC.PARAMETER,SC.PARAMETER.ERR)  ;* Tus End
    END
    SC.CCY.MARKET = R.SC.PARAMETER<SC.PARAM.DEFAULT.CCY.MARKET>

RETURN

*-------------------------------------------------------------------------
READ.SC.TRADING.POSITION:
*-------------------------------------------------------------------------

    R.STP = ''
    STP.ERR = ''
    CALL F.READ(FN.SC.TRADING.POSITION,STP.ID,R.STP,F.SC.TRADING.POSITION,STP.ERR)

    STP.DISC.ACCR = ABS(R.STP<SC.TRP.V.DATED.DIS.ACC,1>)

RETURN

*-------------------------------------------------------------------------
DIFF.AMT.FCY.LCY.CONV:
*-------------------------------------------------------------------------

    IF SC.CCY NE LCCY THEN
        DIFF.FCY.AMT = DIFF.AMT
        DIFF.LCY.AMT = ''
        EXCH.RATE = ''
        CALL EXCHRATE(SC.CCY.MARKET,SC.CCY,DIFF.FCY.AMT,APAP.LCCY,DIFF.LCY.AMT,'',EXCH.RATE,'','','')
    END ELSE
        DIFF.LCY.AMT = DIFF.AMT
        DIFF.FCY.AMT = ''
    END

RETURN

*-------------------------------------------------------------------------
ACCOUNTING.ENTRIES:
*-------------------------------------------------------------------------

    ACC.ENTRY.ARRAY = ''
    IF DIFF.AMT THEN
        GOSUB FORM.STMT.ENTRY
        ACC.ENTRY.ARRAY<-1> = LOWER(STMT.ENTRY.ARRAY)
        GOSUB FORM.CATEG.ENTRY
        ACC.ENTRY.ARRAY<-1> = LOWER(CATEG.ENTRY.ARRAY)
    END

    IF ACC.ENTRY.ARRAY THEN
        Y.STMT.NO = R.NEW(SC.SBS.STATEMENT.NOS)

        CALL EB.ACCOUNTING("SC","SAO",ACC.ENTRY.ARRAY,'')

        Y.STMT.NO.NEW = R.NEW(SC.SBS.STATEMENT.NOS)
        R.NEW(SC.SBS.STATEMENT.NOS) = Y.STMT.NO
        R.NEW(SC.SBS.STATEMENT.NOS)<1,-1> = ID.COMPANY
        R.NEW(SC.SBS.STATEMENT.NOS)<1,-1> = Y.STMT.NO.NEW
    END

RETURN

*-------------------------------------------------------------------------
FORM.STMT.ENTRY:
*-------------------------------------------------------------------------

    STMT.ENTRY.ARRAY = ''
    STMT.ENTRY.ARRAY<AC.STE.ACCOUNT.NUMBER>   = STMT.ENTRY.ACC
    STMT.ENTRY.ARRAY<AC.STE.COMPANY.CODE>     = SC.PARAMETER.ID
    STMT.ENTRY.ARRAY<AC.STE.AMOUNT.LCY>       = -1 * DIFF.LCY.AMT

    IF STMT.ENTRY.ARRAY<AC.STE.AMOUNT.LCY> GT 0 THEN
        STMT.ENTRY.ARRAY<AC.STE.TRANSACTION.CODE> = CR.TXN.CODE
    END ELSE
        STMT.ENTRY.ARRAY<AC.STE.TRANSACTION.CODE> = DR.TXN.CODE
    END

    STMT.ENTRY.ARRAY<AC.STE.NARRATIVE,1> = Y.NARRATIVE
    STMT.ENTRY.ARRAY<AC.STE.CUSTOMER.ID>      = CUSTOMER.NO
    STMT.ENTRY.ARRAY<AC.STE.VALUE.DATE>       = TODAY
    STMT.ENTRY.ARRAY<AC.STE.CURRENCY>         = SC.CCY

    IF DIFF.FCY.AMT THEN
        STMT.ENTRY.ARRAY<AC.STE.AMOUNT.FCY>       = DIFF.FCY.AMT
        STMT.ENTRY.ARRAY<AC.STE.EXCHANGE.RATE >   = EXCH.RATE
    END

    STMT.ENTRY.ARRAY<AC.STE.POSITION.TYPE>    = 'TR'
    STMT.ENTRY.ARRAY<AC.STE.OUR.REFERENCE>    = STP.ID
    STMT.ENTRY.ARRAY<AC.STE.EXPOSURE.DATE>    = TODAY
    STMT.ENTRY.ARRAY<AC.STE.CURRENCY.MARKET>  = SC.CCY.MARKET
    STMT.ENTRY.ARRAY<AC.STE.TRANS.REFERENCE>  = STP.ID
    STMT.ENTRY.ARRAY<AC.STE.SYSTEM.ID>        = 'SCAC'
    STMT.ENTRY.ARRAY<AC.STE.BOOKING.DATE>     = TODAY

RETURN

*-------------------------------------------------------------------------
FORM.CATEG.ENTRY:
*-------------------------------------------------------------------------

    CATEG.ENTRY.ARRAY = ''
    CATEG.ENTRY.ARRAY<AC.CAT.COMPANY.CODE>     = SC.PARAMETER.ID
    CATEG.ENTRY.ARRAY<AC.CAT.AMOUNT.LCY>       = DIFF.LCY.AMT

    IF CATEG.ENTRY.ARRAY<AC.CAT.AMOUNT.LCY> GT 0 THEN
        CATEG.ENTRY.ARRAY<AC.CAT.TRANSACTION.CODE> = CR.TXN.CODE
    END ELSE
        CATEG.ENTRY.ARRAY<AC.CAT.TRANSACTION.CODE> = DR.TXN.CODE
    END

    CATEG.ENTRY.ARRAY<AC.CAT.NARRATIVE,1>      = Y.NARRATIVE
    CATEG.ENTRY.ARRAY<AC.CAT.PL.CATEGORY>      = CATEG.ENTRY.PL
    CATEG.ENTRY.ARRAY<AC.CAT.CUSTOMER.ID>      = CUSTOMER.NO
    CATEG.ENTRY.ARRAY<AC.CAT.VALUE.DATE>       = TODAY
    CATEG.ENTRY.ARRAY<AC.CAT.CURRENCY>         = SC.CCY

    IF DIFF.FCY.AMT THEN
        CATEG.ENTRY.ARRAY<AC.CAT.AMOUNT.FCY>       = (-1) * DIFF.FCY.AMT
        CATEG.ENTRY.ARRAY<AC.CAT.EXCHANGE.RATE>    = EXCH.RATE
    END

    CATEG.ENTRY.ARRAY<AC.CAT.OUR.REFERENCE>    = STP.ID
    CATEG.ENTRY.ARRAY<AC.CAT.EXPOSURE.DATE>    = TODAY
    CATEG.ENTRY.ARRAY<AC.CAT.CURRENCY.MARKET>  = SC.CCY.MARKET
    CATEG.ENTRY.ARRAY<AC.CAT.TRANS.REFERENCE>  = STP.ID
    CATEG.ENTRY.ARRAY<AC.CAT.SYSTEM.ID>        = "SCAC"
    CATEG.ENTRY.ARRAY<AC.CAT.BOOKING.DATE>     = TODAY

RETURN
*-------------------------------------------------------------------------
END
