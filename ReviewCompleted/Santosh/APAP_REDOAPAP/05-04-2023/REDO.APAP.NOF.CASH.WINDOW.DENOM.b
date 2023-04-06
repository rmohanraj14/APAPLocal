* @ValidationCode : MjotNDQyMDMyODIzOkNwMTI1MjoxNjgwNjgwNDA5ODIxOklUU1M6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 05 Apr 2023 13:10:09
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOAPAP
SUBROUTINE REDO.APAP.NOF.CASH.WINDOW.DENOM(Y.OUT.ARRAY)
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.APAP.NOF.CASH.WINDOW.DENOM
*--------------------------------------------------------------------------------------------------------
*Description       : REDO.APAP.NOF.CASH.WINDOW.DENOM is an No-file enquiry routine, this routine is used to
*                    extract data from relevant files so as to display in the CASH DENOM TRANSACTION report
*Linked With       : Enquiry - REDO.APAP.ENQ.CASH.WINDOW.DENOM

*In  Parameter     : NA
*Out Parameter     : Y.OUT.ARRAY - Output array for display
*Files  Used       : REDO.H.TELLER.TXN.CODES          As              I               Mode
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*    Date               Who                         Reference                 Description
*   ------             -----                       -------------             -------------
* 11 Mar 2011       Shiva Prasad Y              ODR-2011-03-0150 35         Initial Creation
* Date                   who                   Reference              
* 05-04-2023         CONVERSTION TOOL     R22 AUTO CONVERSTION FM TO @FM VM TO @VM AND ++ TO += 1 AND F.READ TO CACHE.READ AND REMOVING F.DENOM
* 05-04-2023          ANIL KUMAR B        R22 MANUAL CONVERSTION -NO CHANGES
*
*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.DENOMINATION
    $INSERT I_F.TELLER.PARAMETER
    $INSERT I_F.TELLER.ID


    GOSUB INIT
    GOSUB PROCESS
    GOSUB GET.DENOM.DETAILS
    GOSUB GET.TELLER.DETAILS
    GOSUB JOIN.BILL.COIN
    GOSUB FORM.OUT.ARRAY

RETURN

INIT:
    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

    FN.DENOM = 'F.TELLER.DENOMINATION'
    F.DENOM = ''
    CALL OPF(FN.DENOM,F.DENOM)

    FN.TELLER.ID = 'F.TELLER.ID'
    F.TELLER.ID = ''
    CALL OPF(FN.TELLER.ID,F.TELLER.ID)

    FN.TELLER.PARAM = 'F.TELLER.PARAMETER'
    F.TELLER.PARAM = ''
    CALL OPF(FN.TELLER.PARAM,F.TELLER.PARAM)


    LOC.APPLICATION = 'TELLER.ID'
    LOC.FIELDS = 'L.TT.BRAN.LIM':@VM:'L.TT.CURRENCY'
    LOC.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.APPLICATION,LOC.FIELDS,LOC.POS)

    Y.TT.TID.BR.LIM = LOC.POS<1,1>
    Y.TT.TID.CCY    = LOC.POS<1,2>

    Y.FLAG            = ''
    VAR.DR.BILL.DENOM = ''
    VAR.CR.BILL.DENOM = ''
    VAR.CURRENCY      = ''
    VAR.CR.COIN.DENOM = ''
    VAR.CR.COIN.UNIT  = ''
    VAR.DR.BILL.UNIT  = ''
    VAR.CR.BILL.UNIT  = ''

RETURN

PROCESS:

    LOCATE 'AGENCY' IN D.FIELDS<1> SETTING Y.AGY.POS  THEN
        Y.AGENCY = D.RANGE.AND.VALUE<Y.AGY.POS>
    END

    SEL.CMD = "SELECT ":FN.TELLER:" WITH CO.CODE EQ ":Y.AGENCY:" WITH DR.DENOM LIKE ...COIN OR DR.DENOM LIKE ...BILL OR DENOMINATION LIKE ...BILL OR DENOMINATION LIKE ...COIN BY CURRENCY.1"
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,RET.ERR)
    VAR.COUNT = 1
    LOOP
        REMOVE TT.ID FROM SEL.LIST SETTING TT.POS
    WHILE VAR.COUNT LE NO.REC
        GOSUB PROCESS1
        VAR.COUNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN

PROCESS1:
*Get the Denomination Values and Store credit and Debit separately

    CALL F.READ(FN.TELLER,TT.ID,R.TELLER,F.TELLER,TELL.ERR)

    VAR.CR.TEL.DENOM  =  R.TELLER<TT.TE.DENOMINATION>
    VAR.CR.TEL.UNIT   =  R.TELLER<TT.TE.UNIT>
    VAR.DR.TEL.DENOM  =  R.TELLER<TT.TE.DR.DENOM>
    VAR.DR.TEL.UNIT   =  R.TELLER<TT.TE.DR.UNIT>
    IF VAR.CR.TEL.DENOM THEN
        CREDIT.DENOM =  VAR.CR.TEL.DENOM
        CREDIT.UNIT  =  VAR.CR.TEL.UNIT
        GOSUB CREDIT.PROCESS
    END
    IF VAR.DR.TEL.DENOM THEN
        DEBIT.DENOM = VAR.DR.TEL.DENOM
        DEBIT.UNIT  = VAR.DR.TEL.UNIT
        GOSUB DEBIT.PROCESS
    END

RETURN

CREDIT.PROCESS:
*Getting the Credit Value and storing the values in Array

    VAR.CR.COUNT = 1

    VAR.CR.TEL.CNT = DCOUNT(CREDIT.DENOM,@VM)
    LOOP
        REMOVE Y.CR.DENOM FROM CREDIT.DENOM SETTING CR.DENOM.POS
    WHILE VAR.CR.COUNT LE VAR.CR.TEL.CNT
        CALL CACHE.READ(FN.DENOM, Y.CR.DENOM, R.DENOM, DENOM.ERR) ;*R22 AUTO CONVERSTION F.READ TO CACHE.READ AND REMOVING F.DENOM
        Y.DENOM.VALUE = R.DENOM<TT.DEN.VALUE>
        GOSUB CR.SUB.LOOP
        VAR.CR.COUNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN

DEBIT.PROCESS:
*Getting the Debit denom value and storing in Array

    VAR.DR.COUNT = 1

    VAR.DR.TEL.CNT = DCOUNT(DEBIT.DENOM,@VM)
    LOOP
        REMOVE Y.DR.DENOM FROM DEBIT.DENOM SETTING DR.DENOM.POS
    WHILE VAR.DR.COUNT LE VAR.DR.TEL.CNT
        CALL CACHE.READ(FN.DENOM, Y.DR.DENOM, R.DENOM, DENOM.ERR)  ;*R22 AUTO CONVERSTION F.READ TO CACHE.READ AND REMOVING F.DENOM
        Y.DENOM.VALUE = R.DENOM<TT.DEN.VALUE>
        Y.DENOM.VALUE = R.DENOM<TT.DEN.VALUE>
        GOSUB DR.SUB.LOOP
        VAR.DR.COUNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN

CR.SUB.LOOP:
*Storing in Separate Variable

    VAR.CCY  = Y.CR.DENOM[1,3]
    VAR.TYPE = Y.CR.DENOM[4]

    LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
        IF VAR.TYPE EQ 'BILL' THEN
            GOSUB CR.BILL.VALUES
        END
        IF VAR.TYPE EQ 'COIN' THEN
            GOSUB CR.COIN.VALUES
        END
    END
    ELSE
        VAR.CURRENCY<-1> = VAR.CCY
        IF VAR.TYPE EQ 'BILL' THEN
            LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
                VAR.CR.BILL.DENOM<CCY.POS,-1> = Y.CR.DENOM
                VAR.CR.BILL.UNIT<CCY.POS,-1> = CREDIT.UNIT<1,VAR.CR.COUNT>
                LOC.BILL.CR.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
            END
        END
        IF VAR.TYPE EQ 'COIN' THEN
            LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
                VAR.CR.COIN.DENOM<CCY.POS,-1> = Y.CR.DENOM
                VAR.CR.COIN.UNIT<CCY.POS,-1> = CREDIT.UNIT<1,VAR.CR.COUNT>
                LOC.COIN.CR.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
            END
        END
    END
RETURN
DR.SUB.LOOP:
*Storing in Separate Variable
    VAR.CCY  = Y.DR.DENOM[1,3]
    VAR.TYPE = Y.DR.DENOM[4]

    LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
        IF VAR.TYPE EQ 'BILL' THEN
            GOSUB DR.BILL.VALUES
        END
        IF VAR.TYPE EQ 'COIN' THEN
            GOSUB DR.COIN.VALUES
        END
    END
    ELSE
        VAR.CURRENCY<-1> = VAR.CCY
        IF VAR.TYPE EQ 'BILL' THEN
            LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
                VAR.DR.BILL.DENOM<CCY.POS,-1> = Y.DR.DENOM
                VAR.DR.BILL.UNIT<CCY.POS,-1> = DEBIT.UNIT<1,VAR.DR.COUNT>
                LOC.BILL.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
            END
        END
        IF VAR.TYPE EQ 'COIN' THEN
            LOCATE VAR.CCY IN VAR.CURRENCY SETTING CCY.POS THEN
                VAR.DR.COIN.DENOM<CCY.POS,-1> = Y.DR.DENOM
                VAR.DR.COIN.UNIT<CCY.POS,-1> = DEBIT.UNIT<1,VAR.DR.COUNT>
                LOC.COIN.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
            END
        END
    END
RETURN

CR.BILL.VALUES:
*Separating Credit Bill Values

    LOCATE Y.CR.DENOM IN VAR.CR.BILL.DENOM<CCY.POS,1> SETTING Y.CR.DENOM.POS THEN
        VAR.CR.BILL.UNIT<CCY.POS,Y.CR.DENOM.POS> += CREDIT.UNIT<1,VAR.CR.COUNT>
        LOC.BILL.CR.DENOM<CCY.POS,Y.CR.DENOM.POS> += (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
    END
    ELSE
        VAR.CR.BILL.DENOM<CCY.POS,-1> = Y.CR.DENOM
        LOCATE Y.CR.DENOM IN VAR.CR.BILL.DENOM SETTING Y.CR.DENOM.POS THEN
            VAR.CR.BILL.UNIT<CCY.POS,-1> = CREDIT.UNIT<1,VAR.CR.COUNT>
            LOC.BILL.CR.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
        END
    END
RETURN
DR.BILL.VALUES:
*Separating Debit bill values

    LOCATE Y.DR.DENOM IN VAR.DR.BILL.DENOM<CCY.POS,1> SETTING Y.DR.DENOM.POS THEN
        VAR.DR.BILL.UNIT<CCY.POS,Y.DR.DENOM.POS> += DEBIT.UNIT<1,VAR.DR.COUNT>
        LOC.BILL.DENOM<CCY.POS,Y.DR.DENOM.POS> += (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
    END
    ELSE
        VAR.DR.BILL.DENOM<CCY.POS,-1> = Y.DR.DENOM
        LOCATE Y.DR.DENOM IN VAR.DR.BILL.DENOM<CCY.POS,1> SETTING Y.DR.DENOM.POS THEN
            VAR.DR.BILL.UNIT<CCY.POS,-1> = DEBIT.UNIT<1,VAR.DR.COUNT>
            LOC.BILL.DENOM<CCY.POS,-1> += (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
        END
    END
RETURN

CR.COIN.VALUES:
* Separating Credit Coin Values

    LOCATE Y.CR.DENOM IN VAR.CR.COIN.DENOM<CCY.POS,1> SETTING Y.CR.DENOM.POS THEN
        VAR.CR.COIN.UNIT<CCY.POS,Y.CR.DENOM.POS> += CREDIT.UNIT<1,VAR.CR.COUNT>
        LOC.COIN.CR.DENOM<CCY.POS,Y.CR.DENOM.POS> += (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
    END
    ELSE
        VAR.CR.COIN.DENOM<CCY.POS,-1> = Y.CR.DENOM
        LOCATE Y.CR.DENOM IN VAR.CR.COIN.DENOM SETTING Y.CR.DENOM.POS THEN
            VAR.CR.COIN.UNIT<CCY.POS,-1> = CREDIT.UNIT<1,VAR.CR.COUNT>
            LOC.COIN.CR.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*CREDIT.UNIT<1,VAR.CR.COUNT>)
        END
    END
RETURN

DR.COIN.VALUES:
*Seperating Debit Coin Values

    LOCATE Y.DR.DENOM IN VAR.DR.COIN.DENOM<CCY.POS,1> SETTING Y.DR.DENOM.POS THEN
        VAR.DR.COIN.UNIT<CCY.POS,Y.DR.DENOM.POS> += DEBIT.UNIT<1,VAR.DR.COUNT>
        LOC.COIN.DENOM<CCY.POS,Y.DR.DENOM.POS> += (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
    END
    ELSE
        VAR.DR.COIN.DENOM<CCY.POS,-1> = Y.DR.DENOM
        LOCATE Y.DR.DENOM IN VAR.DR.COIN.DENOM<CCY.POS,1> SETTING Y.DR.DENOM.POS THEN
            VAR.DR.COIN.UNIT<CCY.POS,-1> = DEBIT.UNIT<1,VAR.DR.COUNT>
            LOC.COIN.DENOM<CCY.POS,-1> = (Y.DENOM.VALUE*DEBIT.UNIT<1,VAR.DR.COUNT>)
        END
    END
RETURN

GET.DENOM.DETAILS:
*Sorting the Denomination Details
    VAR.INT.CCY = 1

    VAR.CCY.CNT = DCOUNT(VAR.CURRENCY,@FM)
    LOOP
        REMOVE VAR.CCY.ID FROM VAR.CURRENCY SETTING VAR.CCY.POS
    WHILE VAR.INT.CCY LE VAR.CCY.CNT
        GOSUB FILTER.BILL
        GOSUB FILTER.COIN
        GOSUB GET.TOTAL
        VAR.INT.CCY += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN

FILTER.BILL:
*Sorting Bill details
    VAR.INT.DR.CNT = 1
    VAR.DR.DENOM.CNT = DCOUNT(VAR.DR.BILL.DENOM<VAR.INT.CCY>,@VM)
    VAR.DR.BILL.DENOM.LIST = VAR.DR.BILL.DENOM<VAR.INT.CCY>
    LOOP
        REMOVE DENOM.VAR FROM VAR.DR.BILL.DENOM.LIST SETTING DR.FIL.POS
    WHILE VAR.INT.DR.CNT LE VAR.DR.DENOM.CNT
        LOCATE DENOM.VAR IN VAR.CR.BILL.DENOM<VAR.INT.CCY,1> SETTING LOC.DENOM.VAL.POS THEN
            VAR.DR.BILL.UNIT<VAR.INT.CCY,VAR.INT.DR.CNT> = VAR.DR.BILL.UNIT<VAR.INT.CCY,VAR.INT.DR.CNT> - VAR.CR.BILL.UNIT<VAR.INT.CCY,LOC.DENOM.VAL.POS>
            LOC.BILL.DENOM<VAR.INT.CCY,VAR.INT.DR.CNT> = LOC.BILL.DENOM<VAR.INT.CCY,VAR.INT.DR.CNT> - LOC.BILL.CR.DENOM<VAR.INT.CCY,LOC.DENOM.VAL.POS>
            VAR.CR.BILL.UNIT<VAR.INT.CCY,LOC.DENOM.VAL.POS> = ''
            LOC.BILL.CR.DENOM<VAR.INT.CCY,LOC.DENOM.VAL.POS> = ''
            VAR.CR.BILL.DENOM<VAR.INT.CCY,LOC.DENOM.VAL.POS> = ''
        END
        VAR.INT.DR.CNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT

    VAR.INT.CR.CNT = 1
    VAR.CR.DENOM.CNT = DCOUNT(VAR.CR.BILL.DENOM<VAR.INT.CCY>,@VM)
    VAR.CR.BILL.DENOM.LIST = VAR.CR.BILL.DENOM<VAR.INT.CCY>
    LOOP
        REMOVE DENOM.CR.VAR FROM VAR.CR.BILL.DENOM.LIST SETTING CR.FIL.POS
    WHILE VAR.INT.CR.CNT LE VAR.CR.DENOM.CNT
        IF DENOM.CR.VAR THEN
            LOCATE DENOM.CR.VAR IN VAR.CR.BILL.DENOM<VAR.INT.CCY,1> SETTING FIL.POS.CR THEN
                VAR.DR.BILL.DENOM<VAR.INT.CCY,-1> = DENOM.CR.VAR
                VAR.DR.BILL.UNIT<VAR.INT.CCY,-1> = VAR.CR.BILL.UNIT<VAR.INT.CCY,FIL.POS.CR>
                LOC.BILL.DENOM<VAR.INT.CCY,-1> = LOC.BILL.CR.DENOM<VAR.INT.CCY,FIL.POS.CR>
            END
        END
        VAR.INT.CR.CNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
    VAR.DR.BILL.DENOM<VAR.INT.CCY,-1> = "TOTAL BILLETES"

*Billets Count

    BILLETS.CNT = DCOUNT(LOC.BILL.DENOM<VAR.INT.CCY>,@VM)
    TOT.BILLETS = 0
    Y.BILLETS.LIST = LOC.BILL.DENOM<VAR.INT.CCY>
    INT.BILL.CNT = 1
    LOOP
        REMOVE Y.BILLET FROM Y.BILLETS.LIST SETTING Y.BILLET.POS
    WHILE INT.BILL.CNT LE BILLETS.CNT
        TOT.BILLETS<VAR.INT.CCY> = TOT.BILLETS<VAR.INT.CCY> + Y.BILLET
        INT.BILL.CNT += 1   ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
    VAR.DR.BILL.UNIT<VAR.INT.CCY,-1> = " "
    LOC.BILL.DENOM<VAR.INT.CCY,-1> = TOT.BILLETS<VAR.INT.CCY>

*Forming the header for Coins

    VAR.DR.BILL.DENOM<VAR.INT.CCY,-1> = "DENOMINAC.MONEDAS"
    VAR.DR.BILL.UNIT<VAR.INT.CCY,-1> = "CANT.MONEDAS"
    LOC.BILL.DENOM<VAR.INT.CCY,-1> = "MONTO"

RETURN

FILTER.COIN:
*Sorting the Coin Details
    VAR.DR.COIN.CNT  = DCOUNT(VAR.DR.COIN.DENOM<VAR.INT.CCY>,@VM)
    VAR.INT.COIN.CNT = 1
    LOOP
        REMOVE COIN.VAR FROM VAR.DR.COIN.DENOM SETTING DR.FIL.COIN.POS
    WHILE VAR.INT.COIN.CNT LE VAR.DR.COIN.CNT
        LOCATE COIN.VAR IN VAR.CR.COIN.DENOM<VAR.CCY.POS,1> SETTING DR.FIL.COIN.POS THEN
            VAR.DR.COIN.UNIT<VAR.INT.CCY,VAR.INT.COIN.CNT> = VAR.DR.COIN.UNIT<VAR.INT.CCY,VAR.INT.COIN.CNT> - VAR.CR.COIN.UNIT<VAR.INT.CCY,DR.FIL.COIN.POS>
            LOC.COIN.DENOM<VAR.INT.CCY,VAR.INT.COIN.CNT> = LOC.COIN.DENOM<VAR.INT.CCY,VAR.INT.COIN.CNT> - LOC.COIN.CR.DENOM<VAR.INT.CCY,DR.FIL.COIN.POS>
            VAR.CR.COIN.UNIT<VAR.INT.CCY,DR.FIL.COIN.POS> = ''
            LOC.COIN.CR.DENOM<VAR.INT.CCY,DR.FIL.COIN.POS> = ''
            VAR.CR.COIN.DENOM<VAR.INT.CCY,DR.FIL.COIN.POS> = ''
        END
        VAR.INT.COIN.CNT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT

    VAR.CR.COIN.CNT  = DCOUNT(VAR.CR.COIN.DENOM<VAR.INT.CCY>,@VM)
    VAR.FIN.COIN.CNT = 1
    LOOP
        REMOVE COIN.CR.VAR FROM VAR.CR.COIN.DENOM SETTING CR.FIL.COIN.POS
    WHILE VAR.FIN.COIN.CNT LE VAR.CR.COIN.CNT
        IF COIN.CR.VAR THEN
            LOCATE COIN.CR.VAR IN VAR.CR.COIN.DENOM<VAR.CCY.POS,1> SETTING CR.FIL.COIN.POS THEN
                VAR.DR.COIN.DENOM<VAR.INT.CCY,-1> = COIN.CR.VAR
                VAR.DR.COIN.UNIT<VAR.INT.CCY,-1> = VAR.CR.COIN.UNIT<VAR.INT.CCY,CR.FIL.COIN.POS,1>
                LOC.COIN.DENOM<VAR.INT.CCY,-1> = LOC.COIN.CR.DENOM<VAR.INT.CCY,CR.FIL.COIN.POS,1>
            END
        END
        VAR.FIN.COIN.CNT += 1   ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN

GET.TOTAL:
*Monedas Count

    INT.MON.CNT = 1
    MONEDAS.CNT = DCOUNT(LOC.COIN.DENOM<VAR.INT.CCY>,@VM)
    TOTAL.MONEDAS = 0
    Y.MONEDAS.LIST = LOC.COIN.DENOM<VAR.INT.CCY>
    LOOP
        REMOVE Y.MONEDAS FROM Y.MONEDAS.LIST SETTING Y.MONEDA.POS
    WHILE INT.MON.CNT LE MONEDAS.CNT
        TOTAL.MONEDAS<VAR.INT.CCY> = TOTAL.MONEDAS<VAR.INT.CCY> + Y.MONEDAS
        INT.MON.CNT += 1
    REPEAT
    Y.GEN.TOTAL<VAR.INT.CCY> = TOT.BILLETS<VAR.INT.CCY> + TOTAL.MONEDAS<VAR.INT.CCY>
RETURN

GET.TELLER.DETAILS:

    CALL REDO.RTE.EXCESS(Y.AGENCY,Y.AMT.EXCEEDED,REC.CNT)

RETURN

JOIN.BILL.COIN:

    Y.JOIN.CCY.CNT = DCOUNT(VAR.CURRENCY,@FM)
    Y.JOIN.CCY.INT = 1
    CALL CACHE.READ(FN.TELLER.PARAM,ID.COMPANY,R.TELLER.PARAM,PARAM.ERR)
    TELLER.ID = R.TELLER.PARAM<TT.PAR.VAULT.ID>
    CALL F.READ(FN.TELLER.ID,TELLER.ID,R.TELLER.ID,F.TELLER.ID,TELLER.ID.ERR)
    VAR.TID.CCY  = R.TELLER.ID<TT.TID.LOCAL.REF><1,Y.TT.TID.CCY>
    TT.CCY       = R.TELLER.ID<TT.TID.CURRENCY>
    TT.TID.CATEG = R.TELLER.ID<TT.TID.CATEGORY>
    LOOP
    WHILE Y.JOIN.CCY.INT LE Y.JOIN.CCY.CNT
        TT.CATEG.CNT = DCOUNT(TT.TID.CATEG,@VM)
        VAR.CAT.CNT = 1
        Y.CASH.HELD    = 0
        Y.CASH.LIMIT   = 0
        TT.TID.CCY = VAR.CURRENCY<Y.JOIN.CCY.INT>
        LOOP
            REMOVE CATEG.ID FROM TT.TID.CATEG SETTING TT.CATEG.POS
        WHILE VAR.CAT.CNT LE TT.CATEG.CNT
            CATEG.CCY = TT.CCY<1,VAR.CAT.CNT>
            IF TT.TID.CCY EQ CATEG.CCY THEN
                Y.CASH.HELD+= R.TELLER.ID<TT.TID.TILL.CLOS.BAL,VAR.CAT.CNT>
            END
            VAR.CAT.CNT += 1   ;*R22 AUTO CONVERSTION ++ TO += 1
        REPEAT
        LOCATE TT.TID.CCY IN VAR.TID.CCY<1,1,1> SETTING TT.TID.POS THEN
            Y.CASH.LIMIT = R.TELLER.ID<TT.TID.LOCAL.REF><1,Y.TT.TID.BR.LIM,TT.TID.POS>
        END
        Y.CASH.EXCESS = Y.CASH.LIMIT - Y.CASH.HELD
        Y.DENOM<Y.JOIN.CCY.INT,-1>      = VAR.DR.BILL.DENOM<Y.JOIN.CCY.INT>
        Y.DENOM<Y.JOIN.CCY.INT,-1>      = VAR.DR.COIN.DENOM<Y.JOIN.CCY.INT>
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1> = VAR.DR.BILL.UNIT<Y.JOIN.CCY.INT>
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1> = VAR.DR.COIN.UNIT<Y.JOIN.CCY.INT>
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>  = LOC.BILL.DENOM<Y.JOIN.CCY.INT>
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>  = LOC.COIN.DENOM<Y.JOIN.CCY.INT>
        GOSUB FORM.FINAL.ARRAY
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = "TOTAL MONEDAS"
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = " "
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = Y.DENOM.AMOUNT
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = "TOTAL GENERAL"
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = " "
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = Y.GEN.TOTAL<Y.JOIN.CCY.INT>
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = "LIMITE EFECT.AGENCIA"
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = " "
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = Y.CASH.LIMIT
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = "EXCESO/DEFECTO LIMIT"
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = " "
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = Y.CASH.EXCESS
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = "RTE: EFECT=>US10M"
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = "CANT. FORMULARIOS"
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = "MONTO TOTAL"
        Y.DENOM<Y.JOIN.CCY.INT,-1>          = " "
        Y.DENOM.UNIT<Y.JOIN.CCY.INT,-1>     = REC.CNT
        Y.DENOM.AMT<Y.JOIN.CCY.INT,-1>      = Y.AMT.EXCEEDED
        Y.JOIN.CCY.INT += 1
    REPEAT
RETURN

FORM.FINAL.ARRAY:

    Y.DENOM.AMOUNT = 0
    Y.DENOM.AMT.LIST = LOC.COIN.DENOM<Y.JOIN.CCY.INT>
    LOOP
        REMOVE Y.DENOM.AMT.ID FROM Y.DENOM.AMT.LIST SETTING Y.DENOM.AMT.POS
    WHILE Y.DENOM.AMT.ID:Y.DENOM.AMT.POS
        IF Y.DENOM.AMT.ID NE 'MONTO' THEN
            Y.DENOM.AMOUNT += Y.DENOM.AMT.ID
        END
    REPEAT
RETURN

FORM.OUT.ARRAY:

    OUT.CCY.CNT = DCOUNT(VAR.CURRENCY,@FM)
    OUT.INT.CCY = 1
    LOOP
    WHILE OUT.INT.CCY LE OUT.CCY.CNT
        OUT.CCY.ID = VAR.CURRENCY<OUT.INT.CCY>
        OUT.DENOM.INT = 1
        OUT.DENOM.CNT = DCOUNT(Y.DENOM<OUT.INT.CCY>,@VM)
        LOOP
        WHILE OUT.DENOM.INT LE OUT.DENOM.CNT
            FIRST.HEADER    = ''
            SECOND.HEADER   = ''
            THIRD.HEADER    = ''
            FIRST.HEADER    = Y.DENOM<OUT.INT.CCY,OUT.DENOM.INT>
            SECOND.HEADER   = Y.DENOM.UNIT<OUT.INT.CCY,OUT.DENOM.INT>
            THIRD.HEADER    = Y.DENOM.AMT<OUT.INT.CCY,OUT.DENOM.INT>
            THIRD.HEADER    = TRIM(FMT(THIRD.HEADER,"L2,#19")," ",'B')
            Y.OUT.ARRAY<-1> = OUT.CCY.ID:'*':FIRST.HEADER:'*':SECOND.HEADER:'*':THIRD.HEADER
            OUT.DENOM.INT += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
        REPEAT
        OUT.INT.CCY += 1  ;*R22 AUTO CONVERSTION ++ TO += 1
    REPEAT
RETURN
END
