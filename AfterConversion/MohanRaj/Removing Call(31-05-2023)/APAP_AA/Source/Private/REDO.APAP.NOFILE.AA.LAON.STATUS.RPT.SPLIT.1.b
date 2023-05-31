* @ValidationCode : Mjo5NDcxMDA2MTE6Q3AxMjUyOjE2ODU1Mjg1NzEzMjg6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 15:52:51
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
SUBROUTINE REDO.APAP.NOFILE.AA.LAON.STATUS.RPT.SPLIT.1(Y.PROCESSED.IDS,Y.LOAN.STATUS.SEL,Y.LOAN.COND.SEL,Y.OUT.ARRAY)
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.APAP.NOFILE.AA.LAON.STATUS.RPT.SPLIT.1
*--------------------------------------------------------------------------------------------------------
*Description       : This is a spilt of the NO-FILE enquiry routine REDO.APAP.NOFILE.AA.LAON.STATUS.RPT
*Linked With       : Enquiry REDO.APAP.NOF.LAON.STATUS.RPT
*In  Parameter     : Y.PROCESSED.IDS - Contains the processed AA.ARRANGEMENT IDs
*Out Parameter     : Y.OUT.ARRAY - The output array for the enquiry display
*Files  Used       : AA.ARRANGEMENT             As              I               Mode
*                    ACCT.ACTIVITY              As              I               Mode
*                    AA.BILL.DETAILS            As              I               Mode
*                    CUSTOMER                   As              I               Mode
*                    COLLATERAL                 As              I               Mode
*                    AA.INTEREST.ACCRUALS       As              I               Mode
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date                 Who                  Reference                 Description
*     ------               -----               -------------              -------------
* 20 August 2010       Shiva Prasad Y       ODR-2010-03-0179 136         Initial Creation
* 29-MAR-2023          Conversion Tool      R22 Auto conversion         FM TO @FM, VM to @VM, SM to @SM, ++ to +=
* 29-Mar-2023          Harishvikram C       Manual R22 Conversion      Modified call routine format
*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.CUSTOMER
    $INSERT I_F.COLLATERAL
    $USING APAP.REDOAPAP
    $USING APAP.TAM
*-------------------------------------------------------------------------------------------------------
**********
MAIN.PARA:
**********
* This is the para from where the execution of the code starts
    GOSUB OPEN.PARA
    GOSUB PROCESS.PARA
RETURN
*--------------------------------------------------------------------------------------------------------
**********
OPEN.PARA:
**********
* In this para of the code, file variables are initialised and opened

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCT.ACTIVITY = 'F.ACCT.ACTIVITY'
    F.ACCT.ACTIVITY = ''
    CALL OPF(FN.ACCT.ACTIVITY,F.ACCT.ACTIVITY)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.AA.INTEREST.ACCRUALS = 'F.AA.INTEREST.ACCRUALS'
    F.AA.INTEREST.ACCRUALS = ''
    CALL OPF(FN.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS)

RETURN
*--------------------------------------------------------------------------------------------------------
*************
PROCESS.PARA:
*************
* This is the main processing para
    GOSUB FIND.MULTI.LOCAL.REF

    W.VAR=1
    Y.AA.FM.CNT = DCOUNT(Y.PROCESSED.IDS,@FM)

    LOOP
        REMOVE AA.ARRANGEMENT.ID FROM Y.PROCESSED.IDS SETTING Y.AA.ARR.POS
    WHILE AA.ARRANGEMENT.ID: Y.AA.ARR.POS

        LOCATE AA.ARRANGEMENT.ID IN Y.AA.LIST SETTING Y.AA.POS THEN
            CONTINUE
        END ELSE
            Y.AA.LIST<-1> = AA.ARRANGEMENT.ID
        END
        Y.OUT.ARR = ''
        GOSUB ASSIGN.NULL.VAR
        GOSUB GET.HEADER.DETAILS
        GOSUB GET.ARRANGEMENT.DETAILS
        GOSUB GET.ARR.ACCOUNT.DETAILS
        Y.LOAN.NO = Y.AC.CONTRACT ;* PACS00313556 -  2014NOV10 Cristina - S/E

        GOSUB GET.ARR.CUSTOMER.DETAILS
        GOSUB GET.ARR.OVERDUE.DETAILS
        GOSUB GET.AA.INTEREST.ACCRUALS.DETAILS
        GOSUB GET.ARR.TERM.AMOUNT.DETAILS
* PACS00313556 - 2014OCT10 - S
        APAP.AA.redoApapNofileAaLaonStatusRptSplit2(AA.ARRANGEMENT.ID,Y.AC.CONTRACT,Y.CAP.TOT.BAL,Y.INT.TOT.BAL,Y.INS.TOT.BAL,Y.CHG.TOT.BAL);* R22 Manual conversion
* PACS00313556 - 2014OCT10 - E
        GOSUB GET.TOT.BALANCE.DUE ;* PACS00313556 - 2014OCT10 - S/E
        GOSUB GET.LKUP.COND.DSC   ;* PACS00313556 - S
        GOSUB GET.LKUP.STAT.DSC   ;* PACS00313556 - E

        Y.OUT.ARR  = Y.LOAN.BOOK.TYPE :'*': Y.LOAN.PROD.TYPE :'*': Y.LOAN.ORG.AGENCY :'*': Y.LOAN.NO     :'*': Y.PREV.LOAN.NO :'*': Y.CLIENT.NAME :'*'
        Y.OUT.ARR := Y.LOAN.STATUS    :'*': Y.LOAN.COND      :'*': Y.CAMP.TYPE       :'*': Y.AFF.COMP    :'*': Y.CCY          :'*': Y.INT.RATE    :'*'
        Y.OUT.ARR := Y.OPEN.DATE      :'*': Y.APP.LOAN.AMT   :'*': Y.LOAN.EXP.DATE   :'*': Y.GUARANT.NO  :'*': Y.TYPE.OF.GUAR :'*': Y.CAP.TOT.BAL :'*'
        Y.OUT.ARR := Y.INT.TOT.BAL    :'*': Y.INS.TOT.BAL    :'*': Y.CHG.TOT.BAL     :'*': Y.TOT.BAL.DUE
        Y.OUT.ARRA<-1> = Y.OUT.ARR

        W.VAR += 1

    REPEAT

    GOSUB GET.LD.COND.HDR       ;* PACS00313556 - S
    GOSUB GET.LD.STAT.HDR       ;* PACS00313556 - E

    CHANGE @FM TO ', ' IN Y.LOAN.COND.HDR
    CHANGE @FM TO ', ' IN Y.LOAN.STATUS.HDR

    Y.ARR.COUNT = DCOUNT(Y.OUT.ARRA,@FM)
    Y.COUNT = 1
    LOOP
    WHILE Y.COUNT LE Y.ARR.COUNT
        Y.ARRAY = Y.OUT.ARRA<Y.COUNT>
        Y.OUT.ARRAY<-1>= Y.ARRAY:'*':Y.LOAN.COND.HDR:'*':Y.LOAN.STATUS.HDR
        Y.COUNT += 1
    REPEAT

RETURN

*--------------------------------------------------------------------------------------------------------
****************
GET.LD.COND.HDR:
****************
*
    Y.LC.HDR.TMP = Y.LOAN.COND.HDR
    CHANGE ',' TO @FM IN Y.LC.HDR.TMP
    CHANGE " " TO "" IN Y.LC.HDR.TMP
    W.LC.CNT = DCOUNT(Y.LC.HDR.TMP,@FM)
*
    W.LC.DESCR = '' ; W.EL.DSC = 1
    LOOP
    WHILE W.EL.DSC LE W.LC.CNT
*
        W.EL.POS = ''
        LOCATE Y.LC.HDR.TMP<W.EL.DSC> IN Y.LOOKUP.LIST SETTING W.EL.POS THEN
            W.LC.DESCR = Y.DESC.LIST<W.EL.POS,LNGG>
            IF Y.LC.HDR.TMP EQ '' THEN
                Y.LC.HDR.TMP = Y.DESC.LIST<W.EL.POS,1>
            END ELSE
                Y.LC.HDR.TMP<W.EL.DSC> = W.LC.DESCR
            END
        END
*
        W.EL.DSC += 1
    REPEAT
*
    Y.LOAN.COND.HDR = Y.LC.HDR.TMP
*
RETURN
*--------------------------------------------------------------------------------------------------------
****************
GET.LD.STAT.HDR:
****************
*
    Y.LS.HDR.TMP = Y.LOAN.STATUS.HDR
    CHANGE ',' TO @FM IN Y.LS.HDR.TMP
    CHANGE " " TO "" IN Y.LS.HDR.TMP
    W.LS.CNT = DCOUNT(Y.LS.HDR.TMP,@FM)
*
    W.LS.DESCR = '' ; W.EL.DSC = 1
    LOOP
    WHILE W.EL.DSC LE W.LS.CNT

        W.EL.POS = ''
        LOCATE Y.LS.HDR.TMP<W.EL.DSC> IN X.LOOKUP.LIST SETTING W.EL.POS THEN
            W.LS.DESCR = X.DESC.LIST<W.EL.POS,LNGG>
            IF Y.LS.HDR.TMP EQ '' THEN
                Y.LS.HDR.TMP = X.DESC.LIST<W.EL.POS,1>
            END ELSE
                Y.LS.HDR.TMP<W.EL.DSC> = W.LS.DESCR
            END
        END
        W.EL.DSC += 1
    REPEAT
*
    Y.LOAN.STATUS.HDR = Y.LS.HDR.TMP
*
RETURN
*--------------------------------------------------------------------------------------------------------
**************
GET.EBL.STATUS:
**************
    VIRTUAL.TAB.ID = 'L.LOAN.STATUS.1'
    CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
    X.LOOKUP.LIST = VIRTUAL.TAB.ID<2> ; X.LOOKUP.LIST = CHANGE(X.LOOKUP.LIST,'_',@FM )
    X.DESC.LIST = VIRTUAL.TAB.ID<11> ;  X.DESC.LIST = CHANGE(X.DESC.LIST,'_',@FM)
RETURN
**************
GET.EBL.CONDIT:
**************
    VIRTUAL.TAB.ID = 'L.LOAN.COND'
    CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
    Y.LOOKUP.LIST = VIRTUAL.TAB.ID<2> ; Y.LOOKUP.LIST = CHANGE(Y.LOOKUP.LIST,'_',@FM )
    Y.DESC.LIST = VIRTUAL.TAB.ID<11> ;  Y.DESC.LIST = CHANGE(Y.DESC.LIST,'_',@FM)
RETURN
*--------------------------------------------------------------------------------------------------------
****************
ASSIGN.NULL.VAR:
****************
    Y.LOAN.STATUS    = '' ;Y.LOAN.COND      = '' ;Y.CAMP.TYPE       = '' ;Y.AFF.COMP    = '' ;Y.CCY          = '' ;Y.INT.RATE    = ''
    Y.OPEN.DATE      = '' ;Y.APP.LOAN.AMT   = '' ;Y.LOAN.EXP.DATE   = '' ;Y.GUARANT.NO  = '' ;Y.TYPE.OF.GUAR = '' ;Y.CAP.TOT.BAL = ''
    Y.INT.TOT.BAL    = '' ;Y.INS.TOT.BAL    = '' ;Y.CHG.TOT.BAL     = '' ;Y.TOT.BAL.DUE = '' ;Y.AC.CONTRACT  = ''         ;* PACS00313556 - 2014OCT10 - S/E
RETURN
*--------------------------------------------------------------------------------------------------------
******************
GET.LKUP.COND.DSC:
******************
    GOSUB GET.EBL.CONDIT
    Y.LC.CNT = DCOUNT(Y.LOAN.COND,@VM)
*
    Y.LN.CND.TMP = Y.LOAN.COND
    CHANGE @VM TO @FM IN Y.LN.CND.TMP
*
    Y.LC.DESCR = '' ; Y.EL.DSC = 1
    LOOP
    WHILE Y.EL.DSC LE Y.LC.CNT
*
        Y.EL.POS = ''
        LOCATE Y.LN.CND.TMP<Y.EL.DSC> IN Y.LOOKUP.LIST SETTING Y.EL.POS THEN
            Y.LC.DESCR = Y.DESC.LIST<Y.EL.POS,LNGG>
            IF Y.LN.CND.TMP EQ '' THEN
                Y.LN.CND.TMP = Y.DESC.LIST<Y.EL.POS,1>
            END ELSE
                Y.LN.CND.TMP<Y.EL.DSC> = Y.LC.DESCR
            END
        END
*
        Y.EL.DSC += 1
    REPEAT
*
    CHANGE @FM TO @VM IN Y.LN.CND.TMP
    Y.LOAN.COND = Y.LN.CND.TMP
*
RETURN
******************
GET.LKUP.STAT.DSC:
******************
    GOSUB GET.EBL.STATUS
*
    Y.LN.STA.TMP = Y.LOAN.STATUS
    CHANGE @VM TO @FM IN Y.LN.STA.TMP
    Y.LS.CNT = DCOUNT(Y.LN.STA.TMP,@FM)
*
    Y.LS.DESCR = '' ; Y.EL.DSC = 1
    LOOP
    WHILE Y.EL.DSC LE Y.LS.CNT

        Y.EL.POS = ''
        LOCATE Y.LN.STA.TMP<Y.EL.DSC> IN X.LOOKUP.LIST SETTING Y.EL.POS THEN
            Y.LS.DESCR = X.DESC.LIST<Y.EL.POS,LNGG>
            IF Y.LN.STA.TMP EQ '' THEN
                Y.LN.STA.TMP = X.DESC.LIST<Y.EL.POS,1>
            END ELSE
                Y.LN.STA.TMP<Y.EL.DSC> = Y.LS.DESCR
            END
        END

        Y.EL.DSC += 1
    REPEAT
*
    CHANGE @FM TO @VM IN Y.LN.STA.TMP
    Y.LOAN.STATUS = Y.LN.STA.TMP
*
RETURN
*******************
GET.HEADER.DETAILS:
*******************
    ARR.ID      = AA.ARRANGEMENT.ID
    EFF.DATE    = TODAY
    PROP.CLASS  = 'OVERDUE'
    PROPERTY    = ''
    R.CONDITION = ''
    ERR.MSG      = ''

    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.LOAN.COND.COUNT   = DCOUNT(R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.COND.POS>,@SM)
    Y.COUNT = 1
    IF NOT(Y.LOAN.COND.SEL) THEN
        GOSUB GET.LOAN.COND.HDR
    END ELSE
        Y.LOAN.COND.HDR = Y.LOAN.COND.SEL
    END

    Y.LOAN.STATUS.COUNT = DCOUNT(R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.STATUS.1.POS>,@SM)
    Y.COUNT = 1
    IF NOT(Y.LOAN.STATUS.SEL) THEN
        GOSUB GET.LOAN.STATUS.HDR
    END ELSE
        Y.LOAN.STATUS.HDR = Y.LOAN.STATUS.SEL
    END
* PACS00313556 - 2014OCT10 - S
    Y.OVR.STATUS = R.CONDITION<AA.OD.OVERDUE.STATUS>
* PACS00313556 - 2014OCT10 - E
RETURN
*--------------------------------------------------------------------------------------------------------
******************
GET.LOAN.COND.HDR:
******************
    LOOP
    WHILE Y.COUNT LE Y.LOAN.COND.COUNT
        Y.LOAN.COND = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.COND.POS,Y.COUNT>
        LOCATE Y.LOAN.COND IN Y.LOAN.COND.HDR SETTING Y.COND.POS THEN
        END ELSE
            IF Y.LOAN.COND THEN

                IF Y.LOAN.COND.HDR THEN
                    Y.LOAN.COND.HDR<-1> = Y.LOAN.COND
                END ELSE
                    Y.LOAN.COND.HDR = Y.LOAN.COND
                END
            END
        END
        Y.COUNT += 1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
********************
GET.LOAN.STATUS.HDR:
********************
    LOOP
    WHILE Y.COUNT LE Y.LOAN.STATUS.COUNT
        Y.LOAN.STATUS = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.STATUS.1.POS,Y.COUNT>
        LOCATE Y.LOAN.STATUS IN Y.LOAN.STATUS.HDR SETTING Y.STATUS.POS THEN
        END ELSE
            IF Y.LOAN.STATUS THEN
                IF Y.LOAN.STATUS.HDR THEN
                    Y.LOAN.STATUS.HDR<-1> = Y.LOAN.STATUS
                END ELSE
                    Y.LOAN.STATUS.HDR = Y.LOAN.STATUS
                END
            END
        END
        Y.COUNT += 1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
************************
GET.ARRANGEMENT.DETAILS:
************************
    GOSUB READ.AA.ARRANGEMENT

    Y.LOAN.BOOK.TYPE = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    Y.LOAN.PROD.TYPE = R.AA.ARRANGEMENT<AA.ARR.PRODUCT,1>
    Y.CCY            = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    Y.OPEN.DATE      = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE,1>
* PACS00313556 - 2014OCT10 - S
    Y.AC.CONTRACT    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
* PACS00313556 - 2014OCT10 - E
RETURN
*--------------------------------------------------------------------------------------------------------
************************
GET.ARR.ACCOUNT.DETAILS:
************************
    ARR.ID      = AA.ARRANGEMENT.ID
    EFF.DATE    = TODAY
    PROP.CLASS  = 'ACCOUNT'
    PROPERTY    = ''
    R.CONDITION = ''
    ERR.MSG     = ''

    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.LOAN.ORG.AGENCY = R.CONDITION<AA.AC.LOCAL.REF,LOC.L.AA.AGNCY.CODE.POS>
    Y.PREV.LOAN.NO    = R.CONDITION<AA.AC.ALT.ID,1>

RETURN
*--------------------------------------------------------------------------------------------------------
*************************
GET.ARR.CUSTOMER.DETAILS:
*************************
    ARR.ID      = AA.ARRANGEMENT.ID
    EFF.DATE    = TODAY
    PROP.CLASS  = 'CUSTOMER'
    PROPERTY    = ''
    R.CONDITION = ''
    ERR.MSG     = ''

    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

*CUSTOMER.ID = R.CONDITION<AA.CUS.PRIMARY.OWNER> R22 Manual conversion
    CUSTOMER.ID = R.CONDITION<AA.CUS.CUSTOMER>;* R22 Manual conversion
    IF NOT(CUSTOMER.ID) THEN
        Y.CLIENT.NAME = ''
        RETURN
    END

    GOSUB READ.CUSTOMER

    Y.CLIENT.NAME = R.CUSTOMER<EB.CUS.SHORT.NAME>
    Y.CAMP.TYPE   = R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.CAMP.TY.POS>
    Y.AFF.COMP    = R.CONDITION<AA.CUS.LOCAL.REF,LOC.L.AA.AFF.COM.POS>

RETURN
*--------------------------------------------------------------------------------------------------------
************************
GET.ARR.OVERDUE.DETAILS:
************************
    ARR.ID      = AA.ARRANGEMENT.ID
    EFF.DATE    = TODAY
    PROP.CLASS  = 'OVERDUE'
    PROPERTY    = ''
    R.CONDITION = ''
    ERR.MSG     = ''

    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.LOAN.STATUS = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.STATUS.1.POS>
    CHANGE @SM TO @VM IN Y.LOAN.STATUS

    Y.LOAN.COND = R.CONDITION<AA.OD.LOCAL.REF,LOC.L.LOAN.COND.POS>
    CHANGE @SM TO @VM IN Y.LOAN.COND
* PACS00313556 - S
    IF Y.LOAN.COND EQ "" THEN
        Y.LOAN.COND = "SIN CONDICION"
    END
* PACS00313556 - E
RETURN
*--------------------------------------------------------------------------------------------------------
*********************************
GET.AA.INTEREST.ACCRUALS.DETAILS:
*********************************

    AA.INTEREST.ACCRUALS.ID = AA.ARRANGEMENT.ID:'-PRINCIPALINT'
    GOSUB READ.AA.INTEREST.ACCRUALS
    IF NOT(R.AA.INTEREST.ACCRUALS) THEN
        Y.INT.RATE = ''
        RETURN
    END
    Y.INT.RATE = R.AA.INTEREST.ACCRUALS<AA.INT.ACC.RATE,1,1>
    IF Y.INT.RATE AND COUNT(Y.INT.RATE,'.') NE 1 THEN
        Y.INT.RATE = Y.INT.RATE:'.00'
    END
* PACS00313556 - S
    IF Y.INT.RATE EQ "" THEN
        GOSUB GET.RATEINT.ARRCOND
    END
* PACS00313556 - E
RETURN
*--------------------------------------------------------------------------------------------------------
********************
GET.RATEINT.ARRCOND:
********************

    Y.ARRG.ID = AA.ARRANGEMENT.ID
    PROP.NAME = 'PRINCIPAL'     ;* Interest Property to obtain
    APAP.TAM.redoGetInterestProperty(Y.ARRG.ID,PROP.NAME,OUT.PROP,ERR);* R22 Manual conversion
    Y.PRIN.PROP = OUT.PROP      ;* This variable hold the value of principal interest property

    PROPERTY.CLASS = 'INTEREST'
    PROPERTY = Y.PRIN.PROP
    EFF.DATE = ''
    ERR.MSG = ''
    R.INT.ARR.COND = ''
    Y.FIXED.RATE.ARR = ''
    APAP.AA.redoCrrGetConditions(Y.ARRG.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.INT.ARR.COND,ERR.MSG);* R22 Manual conversion
    IF R.INT.ARR.COND NE '' THEN
        Y.FIXED.RATE.ARR     = R.INT.ARR.COND<AA.INT.FIXED.RATE>
    END

    IF Y.FIXED.RATE.ARR AND COUNT(Y.FIXED.RATE.ARR,'.') NE 1 THEN
        Y.INT.RATE = Y.FIXED.RATE.ARR:'.00'
    END

    IF Y.FIXED.RATE.ARR AND FIELD(Y.FIXED.RATE.ARR,'.',2) GT 0 THEN
        Y.INT.RATE = Y.FIXED.RATE.ARR
    END

RETURN
*--------------------------------------------------------------------------------------------------------
****************************
GET.ARR.TERM.AMOUNT.DETAILS:
****************************
    ARR.ID      = AA.ARRANGEMENT.ID
    EFF.DATE    = TODAY
    PROP.CLASS  = 'TERM.AMOUNT'
    PROPERTY    = ''
    R.CONDITION = ''
    ERR.MSG     = ''

    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.APP.LOAN.AMT  = R.CONDITION<AA.AMT.AMOUNT>
    Y.LOAN.EXP.DATE = R.CONDITION<AA.AMT.MATURITY.DATE>
    Y.GUARANT.NO    = R.CONDITION<AA.AMT.LOCAL.REF,LOC.L.AA.COL.POS>

    CHANGE @SM TO @FM IN Y.GUARANT.NO

    CHANGE ' ' TO '' IN Y.GUARANT.NO
* PACS00313556 - S
    Y.CNT.COLS = DCOUNT(Y.GUARANT.NO,@FM)
    I.VAR=1
    LOOP
    WHILE I.VAR LE Y.CNT.COLS
        IF Y.GUARANT.NO<I.VAR> EQ "" THEN       ;* Dropping FM collateral id null values
            DEL Y.GUARANT.NO<I.VAR>
        END
        I.VAR += 1
    REPEAT
* PACS00313556 - E
    Y.TYPE.OF.GUAR = ''
    LOOP
        REMOVE COLLATERAL.ID FROM Y.GUARANT.NO SETTING Y.COLL.POS
    WHILE COLLATERAL.ID: Y.COLL.POS
        GOSUB READ.COLLATERAL
        Y.TYPE.OF.GUAR<-1> = R.COLLATERAL<COLL.COLLATERAL.CODE>
    REPEAT

    CHANGE @SM TO @VM IN Y.GUARANT.NO
    CHANGE @FM TO @VM IN Y.GUARANT.NO
    CHANGE @FM TO @VM IN Y.TYPE.OF.GUAR
* PACS00313556 - S
    IF Y.GUARANT.NO EQ "" THEN
        Y.GUARANT.NO = "SIN GARANTIA"
    END
    IF Y.TYPE.OF.GUAR EQ "" THEN
        Y.TYPE.OF.GUAR = "SIN GARANTIA"
    END
* PACS00313556 - E
RETURN
*--------------------------------------------------------------------------------------------------------
********************
GET.TOT.BALANCE.DUE:
********************
*    Y.TOT.BAL.DUE = 0    ; Y.ARR.OS.PR.AMT.VALUE = 0
*    Y.PAY.PROP.LIST = '' ; Y.CHG.ARR.VAL.POS = ''
*    SEL.CMD.TDUE = 'SELECT ':FN.AA.BILL.DETAILS:' WITH ARRANGEMENT.ID EQ ':AA.ARRANGEMENT.ID
*    CALL EB.READLIST(SEL.CMD.TDUE,SEL.LIST.TDUE,'',NO.OF.REC.TDUE,SEL.ERR.TDUE)
*    LOOP
*        REMOVE AA.BILL.DETAILS.ID FROM SEL.LIST.TDUE SETTING Y.TDUE.POS
*    WHILE AA.BILL.DETAILS.ID:Y.TDUE.POS
*        GOSUB READ.AA.BILL.DETAILS
*        Y.PAY.PROP.LIST = R.AA.BILL.DETAILS<AA.BD.PAY.PROPERTY,1>
*        CHANGE SM TO FM IN Y.PAY.PROP.LIST
*        LOCATE 'PRMORA' IN Y.PAY.PROP.LIST SETTING Y.CHG.ARR.VAL.POS THEN
*            Y.ARR.OS.PR.AMT.VALUE = R.AA.BILL.DETAILS<AA.BD.OS.PR.AMT,1,Y.CHG.ARR.VAL.POS>
*            IF NOT(Y.TOT.BAL.DUE) THEN
*                Y.TOT.BAL.DUE = Y.ARR.OS.PR.AMT.VALUE
*            END
*            ELSE
*                Y.TOT.BAL.DUE = Y.TOT.BAL.DUE + Y.ARR.OS.PR.AMT.VALUE
*            END
*        END
*    REPEAT
*
    REQUEST.TYPE<2> = 'ALL';REQUEST.TYPE<4> = 'ECB'
*  Y.OVR.MORA = 'DUE':VM:Y.OVR.STATUS
    Y.OVR.MORA = 'DUE':@SM:Y.OVR.STATUS
*  Y.CNT.W = DCOUNT(Y.OVR.MORA,VM) ;
    Y.CNT.W = DCOUNT(Y.OVR.MORA,@SM) ;  Y.CNT.I = '' ; Y.TOT.BAL.DUE = 0 ; Y.REQ.DATE = TODAY ; Y.BAL.AMT = '' ; Y.RET.ERROR = ''

    LOOP
    WHILE Y.CNT.W GT 0 DO
        Y.CNT.I += 1

*    Y.PR.MORA = Y.OVR.MORA<1,Y.CNT.I>:'PRMORA'
        Y.PR.MORA = Y.OVR.MORA<1,1,Y.CNT.I>:'PRMORA'
        CALL AA.GET.ECB.BALANCE.AMOUNT(Y.AC.CONTRACT, Y.PR.MORA, Y.REQ.DATE, Y.BAL.AMT,Y.RET.ERROR)
        Y.TOT.BAL.DUE += Y.BAL.AMT

        Y.CNT.W -= 1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
********************
READ.AA.ARRANGEMENT:
********************
* In this para of the code, file AA.ARRANGEMENT is read
    R.AA.ARRANGEMENT  = ''
    AA.ARRANGEMENT.ER = ''
    CALL F.READ(FN.AA.ARRANGEMENT,AA.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARRANGEMENT.ER)

RETURN
*--------------------------------------------------------------------------------------------------------
**************
READ.CUSTOMER:
**************
* In this para of the code, file CUSTOMER is read
    R.CUSTOMER  = ''
    CUSTOMER.ER = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER.ID,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ER)

RETURN
*--------------------------------------------------------------------------------------------------------
****************
READ.COLLATERAL:
****************
* In this para of the code, file COLLATERAL is read
    R.COLLATERAL  = ''
    COLLATERAL.ER = ''
    CALL F.READ(FN.COLLATERAL,COLLATERAL.ID,R.COLLATERAL,F.COLLATERAL,COLLATERAL.ER)

RETURN
*--------------------------------------------------------------------------------------------------------
**************************
READ.AA.INTEREST.ACCRUALS:
**************************
* In this para of the code, file AA.INTEREST.ACCRUALS is read
    R.AA.INTEREST.ACCRUALS  = ''
    AA.INTEREST.ACCRUALS.ER = ''
    CALL F.READ(FN.AA.INTEREST.ACCRUALS,AA.INTEREST.ACCRUALS.ID,R.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS,AA.INTEREST.ACCRUALS.ER)

RETURN
*--------------------------------------------------------------------------------------------------------
*********************
READ.AA.BILL.DETAILS:
*********************
* In this para of the code, file AA.BILL.DETAILS is read
    R.AA.BILL.DETAILS  = ''
    AA.BILL.DETAILS.ER = ''
    CALL F.READ(FN.AA.BILL.DETAILS,AA.BILL.DETAILS.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,AA.BILL.DETAILS.ER)

RETURN
*--------------------------------------------------------------------------------------------------------
*********************
FIND.MULTI.LOCAL.REF:
*********************
    APPL.ARRAY = 'AA.ARR.OVERDUE':@FM:'AA.ARR.ACCOUNT':@FM:'AA.ARR.CUSTOMER':@FM:'AA.ARR.TERM.AMOUNT':@FM:'AA.PRD.DES.INTEREST'
    FLD.ARRAY  = 'L.LOAN.COND':@VM:'L.LOAN.STATUS.1':@FM:'L.AA.AGNCY.CODE':@FM:'L.AA.CAMP.TY':@VM:'L.AA.AFF.COM':@FM:'L.AA.COL':@FM:'L.AA.REV.FORM'
    FLD.POS    = ''

    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FLD.ARRAY,FLD.POS)

    LOC.L.LOAN.COND.POS     =  FLD.POS<1,1>
    LOC.L.LOAN.STATUS.1.POS = FLD.POS<1,2>
    LOC.L.AA.AGNCY.CODE.POS = FLD.POS<2,1>
    LOC.L.AA.CAMP.TY.POS    = FLD.POS<3,1>
    LOC.L.AA.AFF.COM.POS    = FLD.POS<3,2>
    LOC.L.AA.COL.POS        = FLD.POS<4,1>
    LOC.L.AAINT.REVFORM.POS = FLD.POS<5,1>

    Y.OVR.STATUS = ''
    Y.PR.MORA    = ''
RETURN
*--------------------------------------------------------------------------------------------------------
END       ;* End of Prgram
