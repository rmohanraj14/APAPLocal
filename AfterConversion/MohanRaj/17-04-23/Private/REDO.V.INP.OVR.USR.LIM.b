* @ValidationCode : MjoxODY2MDQ5MTI6Q3AxMjUyOjE2ODE3Mjk3NDI3OTg6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:39:02
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
SUBROUTINE REDO.V.INP.OVR.USR.LIM
*-----------------------------------------------------------------------------
*COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*-------------
*DEVELOPED BY: Temenos Application Management
*-------------
*SUBROUTINE TYPE: INPUT routine
*------------
*DESCRIPTION:
*------------
* This is Input routine attached to the versions of FX, MM and SC. The routine
* fetches various field values from application and compares with the local
* template REDO.APAP.USER.LIMITS throws overrides on certain conditions
*---------------------------------------------------------------------------
* Input / Output
*----------------
*
* Input / Output
* IN     : -na-
* OUT    : -na-
*
*------------------------------------------------------------------------------------------
* Revision History
* Date           Who                Reference              Description
* 08-NOV-2010   A.SabariKumar     ODR-2010-07-0075       Initial Creation
* 08-APR-2011   Pradeep S         PACS00036002           Fix for limit override
* 06-MAY-2011   Pradeep S         PACS00037714           Limit amounts are considered in USD
*                                                        also
* 20-Jul-2011   Pradeep S         PACS00082438           BPS Limit validations corrected
* 22-Mar-2012   Pradeep S         PACS00188141           CDD fatal error corrected for MM
* 08-Apr-2013   Balagurunathan    PACS00265294           R.NEW.LAST changed
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,F.READ TO CACHE.READ
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FOREX
    $INSERT I_F.MM.MONEY.MARKET
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.CURRENCY
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_F.REDO.APAP.USER.LIMITS
    $INSERT I_REDO.FX.OVR.COMMON

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*---------------------------------------------------------------------------
INITIALISE:
*------------
*Initialise/Open necessary varibles/files

    Y.APPLICATION = ''
    Y.OPERATOR = ''
    Y.TODAY = TODAY
    Y.DIFF = 'C'

    FN.REDO.APAP.USER.LIMITS = 'F.REDO.APAP.USER.LIMITS'
    F.REDO.APAP.USER.LIMITS = ''
    CALL OPF(FN.REDO.APAP.USER.LIMITS,F.REDO.APAP.USER.LIMITS)

    FN.FOREX = 'F.FOREX'
    F.FOREX = ''
    CALL OPF(FN.FOREX,F.FOREX)

    FN.MM = 'F.MM.MONEY.MARKET'
    F.MM = ''
    CALL OPF(FN.MM,F.MM)

    FN.SEC.TRADE = 'F.SEC.TRADE'
    F.SEC.TRADE = ''
    CALL OPF(FN.SEC.TRADE,F.SEC.TRADE)

    FN.CURRENCY = 'F.CURRENCY'
    F.CURRENCY = ''
    CALL OPF(FN.CURRENCY,F.CURRENCY)

    FN.SECURITY.MASTER = 'F.SECURITY.MASTER'
    F.SECURITY.MASTER = ''
    CALL OPF(FN.SECURITY.MASTER,F.SECURITY.MASTER)

RETURN

*---------------------------------------------------------------------------
PROCESS:
*------------
* The section goes to the actual processing GOSUB section based on the applicaton

    Y.APPLICATION = APPLICATION
    Y.OPERATOR = OPERATOR
    Y.USD.AMOUNT = ''
    Y.BUY.AMT = ''
    Y.SELL.AMT = ''
    CALL F.READ(FN.REDO.APAP.USER.LIMITS,Y.OPERATOR,R.USR.LIM,F.REDO.APAP.USER.LIMITS,USR.POS)
    IF R.USR.LIM THEN
        Y.CURR.APP = R.USR.LIM<REDO.USR.LIM.APPLICATION>
        CHANGE @VM TO @FM IN Y.CURR.APP
        BEGIN CASE
            CASE Y.APPLICATION EQ 'FOREX'
                GOSUB FX.PROCESS
            CASE Y.APPLICATION EQ 'MM.MONEY.MARKET'
                GOSUB MM.PROCESS
            CASE Y.APPLICATION EQ 'SEC.TRADE'
                GOSUB SC.PROCESS
        END CASE
    END
    CALL F.WRITE(FN.REDO.APAP.USER.LIMITS,Y.OPERATOR,R.USR.LIM)
RETURN

*---------------------------------------------------------------------------
FX.PROCESS:
*-----------
* The section gets executed when the APPLICATION is 'FOREX'. The section raises
* OVERRIDES by checking certain conditions against the template REDO.APAP.USER.LIMITS

    Y.VALUE.BUY = R.NEW(FX.VALUE.DATE.BUY)
    Y.VALUE.SELL = R.NEW(FX.VALUE.DATE.SELL)
    Y.DEAL.DATE = R.NEW(FX.DEAL.DATE)
    Y.CCY.BOUGHT = R.NEW(FX.CURRENCY.BOUGHT)
    Y.CCY.SELL = R.NEW(FX.CURRENCY.SOLD)
    Y.SPOT.RATE = R.NEW(FX.SPOT.RATE)

    Y.AMT.SOLD.DOP = ''
    Y.AMT.SOLD.BOUGHT = ''

    Y.EXCH.CURR.MKT = R.USR.LIM<REDO.USR.LIM.CURR.MKT>        ;*PACS00037714 - S/E

    IF Y.VALUE.BUY GT Y.VALUE.SELL THEN
        Y.VALUE.DATE = Y.VALUE.BUY
    END ELSE
        Y.VALUE.DATE = Y.VALUE.SELL
    END

*PACS00037714 - S

    BEGIN CASE

        CASE Y.CCY.BOUGHT NE 'USD' AND Y.CCY.SELL NE 'USD'
            GOSUB FX.CCY.CHECK
            Y.USD.AMOUNT = Y.BUY.AMT
            Y.OLD.USD.AMOUNT = Y.BUY.AMT
        CASE Y.CCY.BOUGHT EQ 'USD'
            Y.USD.AMOUNT = R.NEW(FX.AMOUNT.BOUGHT)
            Y.OLD.USD.AMOUNT = R.NEW.LAST(FX.AMOUNT.BOUGHT)
        CASE Y.CCY.SELL EQ 'USD'
            Y.USD.AMOUNT = R.NEW(FX.AMOUNT.SOLD)
            Y.OLD.USD.AMOUNT     = R.NEW.LAST(FX.AMOUNT.SOLD)       ;* PACS00265294
    END CASE

    IF Y.OLD.USD.AMOUNT THEN
        Y.USD.AMOUNT -= Y.OLD.USD.AMOUNT
    END


*PACS00037714 - E

    IF Y.USD.AMOUNT EQ '' THEN
        GOSUB FX.CCY.CHECK
        Y.USD.AMOUNT = Y.BUY.AMT
    END
    LOCATE 'FX' IN Y.CURR.APP SETTING Y.FX.POS THEN

        Y.LIMIT = R.USR.LIM<REDO.USR.LIM.TRADER.LIM,Y.FX.POS>
        Y.SIN.TXN.AMT = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.USD,Y.FX.POS>
        Y.SIN.TXN.DATE = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.DATE,Y.FX.POS>
        Y.TOTAL.TXN.LIM = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.USD,Y.FX.POS>
        Y.TOTAL.TXN.DATE = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.DATE,Y.FX.POS>
        Y.DAILY.TXN.AMT = R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.USD,Y.FX.POS>
        IF V$FUNCTION EQ 'D' OR V$FUNCTION EQ 'R' THEN
            R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.USD,Y.FX.POS> = Y.DAILY.TXN.AMT - Y.USD.AMOUNT
        END
        Y.BPS.LIM = R.USR.LIM<REDO.USR.LIM.BPS.LIMIT>
        Y.BPS.LIM = Y.BPS.LIM/100
        Y.BPS.LIM.DATE = R.USR.LIM<REDO.USR.LIM.BPS.LIM.VALID.DATE>
        IF V$FUNCTION EQ 'I' THEN
            R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.USD,Y.FX.POS> = Y.DAILY.TXN.AMT + Y.USD.AMOUNT
            GOSUB FX.OVERRIDE1
            GOSUB FX.OVERRIDE2
            GOSUB FX.OVERRIDE3
            GOSUB FX.OVERRIDE4
        END
    END
RETURN

*---------------------------------------------------------------------------
MM.PROCESS:
*-----------
* The section gets executed when the APPLICATION is 'MM.MONEY.MARKET'. The section raises
* OVERRIDES by checking certain conditions against the template REDO.APAP.USER.LIMITS

    Y.VALUE.DATE = R.NEW(MM.VALUE.DATE)
    Y.MATURITY.DATE = R.NEW(MM.MATURITY.DATE)
    Y.DEAL.DATE = R.NEW(MM.DEAL.DATE)
    Y.MM.CURRENCY = R.NEW(MM.CURRENCY)
    Y.PRINCIPAL = R.NEW(MM.PRINCIPAL)

    Y.EXCH.CURR.MKT = R.USR.LIM<REDO.USR.LIM.CURR.MKT>        ;*PACS00037714 - S/E

    IF Y.MM.CURRENCY NE 'DOP' AND Y.MM.CURRENCY NE 'USD' THEN
        Y.CCY = Y.MM.CURRENCY
        GOSUB GET.RATE
*Y.EXCHANGE.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.EXCHANGE.RATE = R.CURR<EB.CUR.MID.REVAL.RATE,CCY.POS> ;* PACS00037714 - S/E
        Y.SELL.AMT = Y.PRINCIPAL
        Y.CCY.SELL = Y.MM.CURRENCY
        Y.CCY.BUY = 'USD'         ;* PACS00037714 S/E
        GOSUB CCY.CONV
        Y.PRINCIPAL = Y.BUY.AMT
    END
    Y.DIFF = 'C'
    IF Y.VALUE.DATE NE '' AND Y.DEAL.DATE NE '' THEN
        CALL CDD('',Y.DEAL.DATE,Y.VALUE.DATE,Y.DIFF)
        Y.DIFF = ABS(Y.DIFF)
    END
    LOCATE 'MM' IN Y.CURR.APP SETTING Y.MM.POS THEN

        IF Y.MM.CURRENCY EQ LCCY THEN
            Y.SIN.TXN.AMT = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.AMT,Y.MM.POS>
            Y.DAILY.LIMIT = R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.AMT,Y.MM.POS>
            Y.TOTAL.TXN.LIM = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.AMT,Y.MM.POS>
            Y.MM.TOT.AMT.POS = REDO.USR.LIM.DLY.TOT.TXN.AMT
        END ELSE
            Y.SIN.TXN.AMT = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.USD,Y.MM.POS>
            Y.DAILY.LIMIT = R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.USD,Y.MM.POS>
            Y.TOTAL.TXN.LIM = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.USD,Y.MM.POS>
            Y.MM.TOT.AMT.POS = REDO.USR.LIM.DLY.TOT.TXN.USD
        END

        Y.LIMIT = R.USR.LIM<REDO.USR.LIM.TRADER.LIM,Y.MM.POS>
        Y.MAT.DATE = R.USR.LIM<REDO.USR.LIM.MM.LIMIT.DATE>
        Y.SIN.TXN.DATE =R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.DATE,Y.MM.POS>

        IF V$FUNCTION EQ 'D' OR V$FUNCTION EQ 'R'  THEN
            R.USR.LIM<Y.MM.TOT.AMT.POS,Y.MM.POS> = Y.DAILY.LIMIT - Y.PRINCIPAL
        END

        Y.TOTAL.TXN.DATE = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.DATE,Y.MM.POS>
        Y.CURR.DAILY.TXN.LIM = Y.PRINCIPAL + Y.DAILY.LIMIT

        IF V$FUNCTION EQ 'I' THEN
            R.USR.LIM<Y.MM.TOT.AMT.POS,Y.MM.POS> = Y.DAILY.LIMIT + Y.PRINCIPAL
            GOSUB MM.OVERRIDE1
            GOSUB MM.OVERRIDE2
            GOSUB MM.OVERRIDE3
            GOSUB MM.OVERRIDE4
        END
    END
RETURN

*---------------------------------------------------------------------------
SC.PROCESS:
*-----------
* The section gets executed when the APPLICATION is 'SEC.TRADE'. The section raises
* OVERRIDES by checking certain conditions against the template REDO.APAP.USER.LIMITS

    Y.SAM = R.NEW(SC.SBS.CUST.SEC.ACC)
    Y.TRANS.CODE =R.NEW(SC.SBS.CUST.TRANS.CODE)
    Y.SECURITY = R.NEW(SC.SBS.SECURITY.CODE)
    Y.SEC.CURR = R.NEW(SC.SBS.SECURITY.CURRENCY)
    Y.MATURITY = R.NEW(SC.SBS.MATURITY.DATE)
    Y.VALUE.DATE = R.NEW(SC.SBS.VALUE.DATE)
    Y.TRADE.DATE = R.NEW(SC.SBS.TRADE.DATE)
    Y.NET.AMT = R.NEW(SC.SBS.CU.NET.AM.TRD)

    Y.EXCH.CURR.MKT = R.USR.LIM<REDO.USR.LIM.CURR.MKT>        ;*PACS00037714 - S/E

*PACS00037714 -S
*IF Y.SEC.CURR EQ 'DOP' THEN
* GOSUB SC.USD.EQUIVALENT
*END
*PACS00037714 - E

    IF Y.SEC.CURR NE 'DOP' AND Y.SEC.CURR NE 'USD' THEN
        Y.CCY = Y.SEC.CURR
        GOSUB GET.RATE

*IF Y.TRANS.CODE EQ 'BUY' THEN
* Y.EXCHANGE.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
*END
*IF Y.TRANS.CODE EQ 'SEL' THEN
*Y.EXCHANGE.RATE = R.CURR<EB.CUR.SELL.RATE,CCY.POS>
*END

        Y.EXCHANGE.RATE = R.CURR<EB.CUR.MID.REVAL.RATE,CCY.POS> ;*PACS00037714 - S/E

        Y.SELL.AMT = Y.NET.AMT
        Y.CCY.SELL = Y.SEC.CURR
        Y.CCY.BUY = 'DOP'
        Y.BASE.CCY = Y.SEC.CURR
        GOSUB CCY.CONV
        Y.NET.AMT = Y.BUY.AMT
        Y.SEC.CURR = 'DOP'
        Y.BASE.CCY = 'USD'
        GOSUB SC.USD.EQUIVALENT
    END

    Y.SEC.CURR = R.NEW(SC.SBS.SECURITY.CURRENCY)

    LOCATE 'SC' IN Y.CURR.APP SETTING Y.SC.POS THEN
        CALL F.READ(FN.SECURITY.MASTER,Y.SECURITY,R.SM,F.SECURITY.MASTER,SM.ERR)
        Y.BS = R.SM<SC.SCM.BOND.OR.SHARE>
        IF Y.BS EQ 'B' ELSE
            RETURN
        END
        Y.LIMIT.DATE = R.USR.LIM<REDO.USR.LIM.SC.LIMIT.DATE>
        Y.SC.FWD.LIMIT = R.USR.LIM<REDO.USR.LIM.TRADER.LIM,Y.SC.POS>

*PACS00037714 - S
        IF Y.SEC.CURR EQ LCCY THEN
            Y.SIN.TXN.AMT = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.AMT,Y.SC.POS>
            Y.TOTAL.TXN.LIM = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.AMT,Y.SC.POS>
            Y.DAILY.LIMIT = R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.AMT,Y.SC.POS>
            Y.DOP.USD.DAILY.LIMIT = REDO.USR.LIM.DLY.TOT.TXN.AMT
        END ELSE
            Y.SIN.TXN.AMT = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.USD,Y.SC.POS>
            Y.TOTAL.TXN.LIM = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.USD,Y.SC.POS>
            Y.DAILY.LIMIT = R.USR.LIM<REDO.USR.LIM.DLY.TOT.TXN.USD,Y.SC.POS>
            Y.DOP.USD.DAILY.LIMIT = REDO.USR.LIM.DLY.TOT.TXN.USD
        END
*PACS00037714 - E

        Y.SIN.TXN.DATE = R.USR.LIM<REDO.USR.LIM.SIN.TXN.LIM.DATE,Y.SC.POS>
        Y.TOTAL.TXN.DATE = R.USR.LIM<REDO.USR.LIM.TOT.TXN.LIM.DATE,Y.SC.POS>

        IF V$FUNCTION EQ 'D' OR V$FUNCTION EQ 'R' THEN
            R.USR.LIM<Y.DOP.USD.DAILY.LIMIT,Y.SC.POS> = Y.DAILY.LIMIT - Y.NET.AMT
        END

        IF V$FUNCTION EQ 'I' THEN
            R.USR.LIM<Y.DOP.USD.DAILY.LIMIT,Y.SC.POS> = Y.DAILY.LIMIT + Y.NET.AMT
            GOSUB SC.OVERRIDE1
            GOSUB SC.OVERRIDE2
            GOSUB SC.OVERRIDE3
            GOSUB SC.OVERRIDE4
        END
    END
RETURN

*---------------------------------------------------------------------------
FX.OVERRIDE1:
*-------------
    IF Y.DEAL.DATE NE '' AND Y.VALUE.DATE NE '' THEN
        CALL CDD('',Y.DEAL.DATE,Y.VALUE.DATE,Y.DIFF)
        Y.DATE.DIFF = ABS(Y.DIFF)
    END
    IF Y.DATE.DIFF GT Y.LIMIT AND Y.LIMIT NE '' THEN
        CURR.NO = DCOUNT(R.NEW(FX.OVERRIDE),@VM) + 1
        TEXT = 'REDO.FWD.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.FWD.LIM.EXC'
    END

RETURN
*---------------------------------------------------------------------------
FX.OVERRIDE2:
*-------------

    IF Y.SIN.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.SIN.TXN.DATE'
        CALL STORE.END.ERROR
    END
    IF Y.USD.AMOUNT GT Y.SIN.TXN.AMT AND Y.SIN.TXN.DATE NE '' THEN
        CURR.NO = DCOUNT(R.NEW(FX.OVERRIDE),@VM) + 1
        TEXT = 'REDO.SIN.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.SIN.LIM.EXC'
    END

RETURN
*---------------------------------------------------------------------------
FX.OVERRIDE3:
*--------------
    Y.CURR.DAILY.TXN.LIM = Y.USD.AMOUNT + Y.DAILY.TXN.AMT
    IF Y.TOTAL.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.TOT.TXN.DATE'
        CALL STORE.END.ERROR
    END

    IF Y.CURR.DAILY.TXN.LIM GT Y.TOTAL.TXN.LIM AND Y.TOTAL.TXN.DATE NE '' THEN
        CURR.NO = DCOUNT(R.NEW(FX.OVERRIDE),@VM) + 1
        TEXT = 'REDO.TOT.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.TOT.LIM.EXC'
    END

RETURN
*---------------------------------------------------------------------------
FX.OVERRIDE4:
*-------------

    IF Y.BPS.LIM.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.BPS.VAL.DATE'
        CALL STORE.END.ERROR
    END
    GOSUB BPS.FORM.RATE
*PACS00082438 - S
*Y.RATE1 = Y.BPS.LIM - Y.RATE
*Y.RATE2 = Y.BPS.LIM + Y.RATE
    Y.RATE1 = Y.RATE - Y.BPS.LIM
    Y.RATE2 = Y.RATE + Y.BPS.LIM
    IF Y.SPOT.RATE GE Y.RATE1 AND Y.SPOT.RATE LE Y.RATE2 AND Y.SPOT.RATE NE '' ELSE
        CURR.NO = DCOUNT(R.NEW(FX.OVERRIDE),@VM) + 1
        TEXT = 'REDO.PRC.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.PRC.LIM.EXC'
    END
*PACS00082438 - E

RETURN
*---------------------------------------------------------------------------
MM.OVERRIDE1:
*-------------
    IF Y.DIFF GT Y.LIMIT AND Y.LIMIT NE '' THEN
        CURR.NO = DCOUNT(R.NEW(MM.OVERRIDE),@VM) + 1
        TEXT = 'REPO.MM.FWD.TRD.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REPO.MM.FWD.TRD.EXC'
    END
RETURN

*---------------------------------------------------------------------------
MM.OVERRIDE2:
*------------

    IF Y.MAT.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.MM.LIM.DATE'
        CALL STORE.END.ERROR
    END

*PACS00036002 - S
    Y.MM.DIFF = 'C'
    IF Y.VALUE.DATE NE '' AND Y.MATURITY.DATE NE '' AND LEN(Y.MATURITY.DATE) EQ 8 THEN      ;* PACS00188141  - S/E
        CALL CDD('',Y.VALUE.DATE,Y.MATURITY.DATE,Y.MM.DIFF)
        Y.MM.DIFF = ABS(Y.MM.DIFF)
    END ELSE
        Y.MM.DIFF = Y.MATURITY.DATE
    END
*PACS00036002 - E

    IF Y.MM.DIFF GT Y.MAT.DATE AND NUM(Y.MM.DIFF) THEN
        CURR.NO = DCOUNT(R.NEW(MM.OVERRIDE),@VM) + 1
        TEXT = 'REPO.MM.MAT.TRD.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REPO.MM.MAT.TRD.EXC'
    END
RETURN

*---------------------------------------------------------------------------
MM.OVERRIDE3:
*------------
    IF Y.SIN.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.SIN.TXN.DATE'
        CALL STORE.END.ERROR
    END
    IF Y.PRINCIPAL GT Y.SIN.TXN.AMT THEN
        CURR.NO = DCOUNT(R.NEW(MM.OVERRIDE),@VM) + 1
        TEXT = 'REDO.TRD.SIN.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.TRD.SIN.LIM.EXC'
    END
RETURN

*---------------------------------------------------------------------------
MM.OVERRIDE4:
*------------
    IF Y.TOTAL.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.TOT.TXN.DATE'
        CALL STORE.END.ERROR
    END
    IF Y.CURR.DAILY.TXN.LIM GT Y.TOTAL.TXN.LIM THEN
        CURR.NO = DCOUNT(R.NEW(MM.OVERRIDE),@VM) + 1
        TEXT = 'REDO.TRD.TOT.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.TRD.TOT.LIM.EXC'
    END

RETURN
*---------------------------------------------------------------------------
SC.OVERRIDE1:
*-------------

    IF Y.LIMIT.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.SC.LIM.DATE'
        CALL STORE.END.ERROR
    END

*PACS00036002 - S
    Y.SC.DIFF = 'C'
    IF Y.VALUE.DATE NE '' AND Y.MATURITY NE '' THEN
        CALL CDD('',Y.VALUE.DATE,Y.MATURITY,Y.SC.DIFF)
        Y.SC.DIFF = ABS(Y.SC.DIFF)
    END
*PACS00036002 - E

    IF Y.SC.DIFF GT Y.LIMIT.DATE THEN
        CURR.NO = DCOUNT(R.NEW(SC.SBS.OVERRIDE),@VM) + 1
        TEXT = 'REDO.SCT.MAT.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.SCT.MAT.EXC'
    END
RETURN
*---------------------------------------------------------------------------
SC.OVERRIDE2:
*-------------
    IF Y.VALUE.DATE NE '' AND Y.TRADE.DATE NE '' THEN
        CALL CDD('',Y.VALUE.DATE,Y.TRADE.DATE,Y.DIFF)
        Y.VAL.TRD = ABS(Y.DIFF)
    END
    IF Y.SC.FWD.LIMIT EQ '' AND (Y.VALUE.DATE NE Y.TODAY) THEN
        CURR.NO = DCOUNT(R.NEW(SC.SBS.OVERRIDE),@VM) + 1
        TEXT = 'REDO.SCT.FWD.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.SCT.FWD.LIM.EXC'
    END
    IF Y.SC.FWD.LIMIT LT Y.VAL.TRD THEN
        CURR.NO = DCOUNT(R.NEW(SC.SBS.OVERRIDE),@VM) + 1
        TEXT = 'REDO.SCT.FWD.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.SCT.FWD.LIM.EXC'
    END
RETURN
*---------------------------------------------------------------------------
SC.OVERRIDE3:
*-------------
    IF Y.SIN.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.SIN.TXN.DATE'
        CALL STORE.END.ERROR
    END
    IF Y.NET.AMT GT Y.SIN.TXN.AMT THEN
        CURR.NO = DCOUNT(R.NEW(SC.SBS.OVERRIDE),@VM) + 1
        TEXT = 'REDO.TRD.SIN.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.TRD.SIN.LIM.EXC'
    END
RETURN
*---------------------------------------------------------------------------
SC.OVERRIDE4:
*-------------
    Y.CURR.DAILY.TXN.LIM = Y.NET.AMT + Y.DAILY.LIMIT
    IF Y.TOTAL.TXN.DATE EQ '' THEN
        AF = ''
        ETEXT = 'EB-ENTER.TOT.TXN.DATE'
        CALL STORE.END.ERROR
    END
    IF Y.CURR.DAILY.TXN.LIM GT Y.TOTAL.TXN.LIM THEN
        CURR.NO = DCOUNT(R.NEW(FX.OVERRIDE),@VM) + 1
        TEXT = 'REDO.TRD.TOT.LIM.EXC'
        CALL STORE.OVERRIDE(CURR.NO)
        Y.FX.OVERRIDE.DET<-1> = 'REDO.TRD.TOT.LIM.EXC'
    END

RETURN
*---------------------------------------------------------------------------
FX.CCY.CHECK:
*-------------
* The section is used to fetch the DOP amount, if USD is not involved in FX transaction

    IF Y.CCY.BOUGHT EQ 'DOP' THEN
        Y.AMT.BOUGHT.DOP = R.NEW(FX.AMOUNT.BOUGHT)
    END
    IF Y.CCY.SELL EQ 'DOP' THEN
        Y.AMT.SOLD.DOP = R.NEW(FX.AMOUNT.SOLD)
    END
    GOSUB READ.USD.CCY
RETURN

*---------------------------------------------------------------------------
READ.USD.CCY:
*--------------
* Read the currency table USD and get the value of the fields BUY.RATE and SELL.RATE
    Y.CCY = 'USD'
    GOSUB GET.RATE
    IF Y.AMT.SOLD.DOP THEN
        Y.BUY.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.EXCHANGE.RATE = Y.BUY.RATE
        Y.SELL.AMT = Y.AMT.SOLD.DOP
    END
    IF Y.AMT.BOUGHT.DOP THEN
        Y.SELL.RATE = R.CURR<EB.CUR.SELL.RATE,CCY.POS>
        Y.EXCHANGE.RATE = Y.SELL.RATE
        Y.SELL.AMT = Y.AMT.BOUGHT.DOP
    END

    Y.CCY.BUY = 'USD'
    Y.CCY.SELL = 'DOP'
    GOSUB CCY.CONV

RETURN
*---------------------------------------------------------------------------
CCY.CONV:
*-----------
    Y.BUY.AMT = ''
    CALL EXCHRATE(Y.EXCH.CURR.MKT,Y.CCY.BUY,Y.BUY.AMT,Y.CCY.SELL,Y.SELL.AMT,Y.BASE.CCY,Y.EXCHANGE.RATE,Y.DIFFERENCE,Y.LCY.AMT,Y.RETURN.CODE)
RETURN

*---------------------------------------------------------------------------
BPS.FORM.RATE:
*-------------
* The section forms teh rate value based on the currecny to be compared against the
* user limits

    IF Y.CCY.BOUGHT EQ 'DOP' THEN
        R.CURR = ''
        Y.CCY = Y.CCY.SELL
        GOSUB GET.RATE
        Y.RATE =R.CURR<EB.CUR.SELL.RATE,CCY.POS>
    END

    IF Y.CCY.SELL EQ 'DOP' THEN
        R.CURR = ''
        Y.CCY = Y.CCY.BOUGHT
        GOSUB GET.RATE
        Y.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
    END
    IF Y.RATE EQ '' THEN
        GOSUB FX.BPS.USD
    END
RETURN

*---------------------------------------------------------------------------
FX.BPS.USD:
*------------

    IF Y.CCY.BOUGHT EQ 'USD' THEN
        Y.CCY = Y.CCY.BOUGHT
        GOSUB GET.RATE
        Y.USD.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.CCY = Y.CCY.SELL
        GOSUB GET.RATE
        Y.FCY.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.RATE = Y.USD.RATE/Y.FCY.RATE
    END
    IF Y.CCY.SELL EQ 'USD' THEN
        Y.CCY = Y.CCY.SELL
        GOSUB GET.RATE
        Y.USD.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.CCY = Y.CCY.BOUGHT
        GOSUB GET.RATE
        Y.FCY.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
        Y.RATE = Y.FCY.RATE/Y.USD.RATE
    END
RETURN

*---------------------------------------------------------------------------
GET.RATE:
*---------
* Reads the currency and locates the currency market
    R.CURR = ''
    CALL CACHE.READ(FN.CURRENCY, Y.CCY, R.CURR, CCY.ERR) ;*R22 Auto Code conversion
    Y.CCY.MKT = R.CURR<EB.CUR.CURRENCY.MARKET>
    CHANGE @VM TO @FM IN Y.CCY.MKT
    LOCATE Y.EXCH.CURR.MKT IN Y.CCY.MKT SETTING CCY.POS ELSE  ;*PACS00037714 - S/E
        CCY.POS = 1
    END
RETURN
*---------------------------------------------------------------------------
SC.USD.EQUIVALENT:
*------------------
*Get the USD equivalent for the DOP amount

    Y.CCY = 'USD'
    GOSUB GET.RATE
*IF Y.TRANS.CODE = 'BUY' THEN
*Y.RATE = R.CURR<EB.CUR.SELL.RATE,CCY.POS>
*END
*IF Y.TRANS.CODE EQ 'SEL' THEN
*Y.RATE = R.CURR<EB.CUR.BUY.RATE,CCY.POS>
*END

    Y.RATE = R.CURR<EB.CUR.MID.REVAL.RATE,CCY.POS>  ;*PACS00037714 - S/E

    Y.EXCHANGE.RATE = Y.RATE
    Y.SELL.AMT = Y.NET.AMT
    Y.CCY.SELL = Y.SEC.CURR
    Y.CCY.BUY = 'USD'
    GOSUB CCY.CONV
    Y.NET.AMT = Y.BUY.AMT
RETURN
*---------------------------------------------------------------------------
END
