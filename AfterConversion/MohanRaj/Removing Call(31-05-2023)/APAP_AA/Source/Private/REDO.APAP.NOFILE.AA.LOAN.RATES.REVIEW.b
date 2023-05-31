* @ValidationCode : MjotMTg4MzY0ODQwNDpDcDEyNTI6MTY4NTUyODc0NDU1NTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:55:44
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
SUBROUTINE REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW(OUT.ARRAY)
*-------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : T.Jeeva, Temenos Application Management
*Program   Name    : REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW
*ODR Reference     : ODR-2010-03-0186
*--------------------------------------------------------------------------------------------------------
*Description  :REDO.APAP.NOFILE.AA.LOAN.RATES.REVIEW is a no-file enquiry routine for the enquiry
*              REDO.APAP.ENQ.LOAN.RATES.REVIEW, the routine based on the selection criteria selects the
*              records from respective files and displays the processed records
*In Parameter : N/A
*Out Parameter: Y.OUT.ARRAY
*LINKED WITH  : STANDARD.SELECTION>NOFILE.LOAN.RATES.REVIEW
*   DATE            WHO               GAP                             DESCRIPTION
* 28-APR-2011      H GANESH           CR009                    Change the Vetting value of local field.
* 29-MAR-2023      Conversion Tool   R22 Auto conversion       ++ to +=, FM TO @FM, VM to @VM, SM to @SM
* 29-MAR-2023    Harishvikram C      manual R22 Conversion     Modified call routine format
*--------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AA.OVERDUE
    $USING APAP.TAM
    $USING APAP.REDOENQ

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*--------------------------------------------------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------------------------------------------------

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL  = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.NOTIFY.RATE.CHANGE = 'F.REDO.NOTIFY.RATE.CHANGE'
    F.REDO.NOTIFY.RATE.CHANGE  = ''
    CALL OPF(FN.REDO.NOTIFY.RATE.CHANGE,F.REDO.NOTIFY.RATE.CHANGE)


    LOC.REF.APPLICATION   = "AA.PRD.DES.INTEREST":@FM:"AA.PRD.DES.CUSTOMER":@FM:"AA.PRD.DES.TERM.AMOUNT":@FM:"ACCOUNT":@FM:"AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS        = 'L.AA.FIR.REV.DT':@VM:'L.AA.LST.REV.DT':@VM:'L.AA.NXT.REV.DT':@FM:'L.AA.AFF.COM':@VM:'L.AA.CAMP.TY':@FM:'L.AA.COL':@FM:'L.OD.STATUS':@FM:'L.LOAN.STATUS.1'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.FIR.REV.DT   = LOC.REF.POS<1,1>
    POS.L.AA.LST.REV.DT   = LOC.REF.POS<1,2>
    POS.L.AA.NXT.REV.DT   = LOC.REF.POS<1,3>
    POS.L.AA.AFF.COM      = LOC.REF.POS<2,1>
    POS.L.AA.CAMP.TY      = LOC.REF.POS<2,2>
    POS.L.AA.COL          = LOC.REF.POS<3,1>
    POS.L.OD.STATUS       = LOC.REF.POS<4,1>
    POS.L.LOAN.STATUS.1   = LOC.REF.POS<5,1>

    SEL.PRIM.LIST              = ''
    Y.FINAL.AA.IDS             = ''
    FIRST.REVIEW.DATE.OPERAND  = ''
    FIRST.REVIEW.DATE.VALUE    = ''
    FIRST.REVIEW.DATE.FIELD    = ''
    NEXT.REVIEW.DATE.OPERAND   = ''
    NEXT.REVIEW.DATE.VALUE     = ''
    NEXT.REVIEW.DATE.FIELD     = ''
    LAST.REVIEW.DATE.OPERAND   = ''
    LAST.REVIEW.DATE.VALUE     = ''
    LAST.REVIEW.DATE.FIELD     = ''
    Y.AFF.COMP.FIELD           = ''
    Y.CAMP.TYPE.FIELD          = ''
    Y.GUARANTEE.FIELD          = ''
    Y.MATURITY.DATE.FIELD      = ''
    Y.LOAN.STATUS.FIELD        = ''
    Y.AGING.FIELD              = ''

RETURN
*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------

    VALUE.BK   = D.RANGE.AND.VALUE        ;* Temp storing the common variable.
    OPERAND.BK = D.LOGICAL.OPERANDS
    FIELDS.BK  = D.FIELDS

    D.RANGE.AND.VALUE  = ''
    D.LOGICAL.OPERANDS = ''
    D.FIELDS           = ''

    GOSUB PRIMARY.SELECTION
    IF SEL.PRIM.LIST THEN
        GOSUB INTEREST.SELECTION
    END ELSE
        ENQ.ERROR = 'No records selected in primary list'
        GOSUB END1
    END
    IF Y.INT.FINAL.ARR.IDS THEN
        GOSUB CUSTOMER.SELECTION
    END ELSE
        ENQ.ERROR = 'No records selected after interest selection'
        GOSUB END1
    END
    IF Y.CUS.FINAL.ARR.IDS THEN
        GOSUB TERM.SELECTION
    END ELSE
        ENQ.ERROR = 'No records selected after customer selection'
        GOSUB END1
    END
    IF Y.TERM.FINAL.ARR.IDS THEN
        GOSUB AGING.AND.LOAN.STATUS.SELECTION
    END ELSE
        ENQ.ERROR = 'No records selected after term selection'
        GOSUB END1
    END

    IF Y.FINAL.AA.IDS THEN
        GOSUB FETCH.REPORT.DATE
    END ELSE
        ENQ.ERROR = 'No records selected user selection'
    END

RETURN
*--------------------------------------------------------------------------------------------------------
PRIMARY.SELECTION:
*--------------------------------------------------------------------------------------------------------
* Primary selection of loans are done here.

    D.RANGE.AND.VALUE   = 'CURRENT'       ;* We need select only current loans.
    D.LOGICAL.OPERANDS  = '1'
    D.FIELDS            = 'ARR.STATUS'

    Y.SEL.FIELDS = 'PRODUCT.GROUP':@FM:'CO.CODE':@FM:'START.DATE'
    Y.SEL1.CNT = DCOUNT(Y.SEL.FIELDS,@FM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.SEL1.CNT
        LOCATE Y.SEL.FIELDS<Y.VAR1> IN FIELDS.BK<1> SETTING POS1 THEN
            D.RANGE.AND.VALUE<-1> = VALUE.BK<POS1>
            D.LOGICAL.OPERANDS<-1>= OPERAND.BK<POS1>
            D.FIELDS<-1>          = FIELDS.BK<POS1>
        END
        Y.VAR1 += 1
    REPEAT


    FILE.NAME = FN.AA.ARRANGEMENT
    APAP.REDOENQ.redoEFormSelStmt(FILE.NAME, '', '', SEL.AA.PRIM.CMD);* R22 Manual conversion
    CALL EB.READLIST(SEL.AA.PRIM.CMD,SEL.PRIM.LIST,'',NO.OF.REC.PRIM,SEL.ERR)

    IF SEL.PRIM.LIST ELSE
        ENQ.ERROR = 'No loans selected in primary select'
        GOSUB END1
    END

RETURN
*--------------------------------------------
INTEREST.SELECTION:
*--------------------------------------------
    Y.INT.FINAL.ARR.IDS = ''
    GOSUB CHECK.INT.SELECTION
    IF Y.INT.SEL.FLAG NE 'YES' THEN       ;* No selection values for the interest prop related fields
        Y.INT.FINAL.ARR.IDS = SEL.PRIM.LIST
        RETURN
    END


    Y.INT.CNT = DCOUNT(SEL.PRIM.LIST,@FM)
    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.INT.CNT
        Y.ARR.ID = SEL.PRIM.LIST<Y.VAR2>
        R.PRINCPALINT.COND = ''
        GOSUB GET.INTEREST.COND
        IF Y.INT.SUCCESS.FLAG EQ 'SUCCESS' THEN
            Y.INT.FINAL.ARR.IDS<-1> = Y.ARR.ID
        END

        Y.VAR2 += 1
    REPEAT

RETURN
*--------------------------------------------
CHECK.INT.SELECTION:
*--------------------------------------------
    Y.INT.SEL.FLAG = ''
    Y.INT.SEL.FIELDS = 'FIRST.REVIEW.DATE':@FM:'NEXT.REVIEW.DATE':@FM:'LAST.REVIEW.DATE'
    Y.VAR3 = 1
    Y.INT.SEL.CNT = DCOUNT(Y.INT.SEL.FIELDS,@FM)
    LOOP
    WHILE Y.VAR3 LE Y.INT.SEL.CNT
        LOCATE Y.INT.SEL.FIELDS<Y.VAR3> IN FIELDS.BK<1> SETTING POS2 THEN
            Y.OPERAND = OPERAND.BK<POS2>
            Y.VALUE   = VALUE.BK<POS2>
            Y.FIELD   = FIELDS.BK<POS2>
            GOSUB CHECK.OPERAND.COND
            Y.INT.SEL.FLAG = 'YES'
            GOSUB GET.INTEREST.SEL.VALUES
        END
        Y.VAR3 += 1
    REPEAT
    LOCATE 'MATURITY.DATE' IN FIELDS.BK<1> SETTING POS4 THEN

        Y.OPERAND = OPERAND.BK<POS4>
        Y.VALUE   = VALUE.BK<POS4>
        Y.FIELD   = FIELDS.BK<POS4>
        GOSUB CHECK.OPERAND.COND

        Y.MATURITY.DATE.FIELD   = FIELDS.BK<POS4>
        Y.MATURITY.DATE.VALUE   = VALUE.BK<POS4>
        Y.MATURITY.DATE.OPERAND = OPERAND.BK<POS4>
    END

RETURN
*--------------------------------------------
CHECK.OPERAND.COND:
*--------------------------------------------
    IF Y.OPERAND EQ 1 THEN
        Y.VALUE.CNT = DCOUNT(Y.VALUE,@SM)
        IF Y.VALUE.CNT GT 1 THEN
            ENQ.ERROR = "Only one value allowed for this operand - ":Y.FIELD
            GOSUB END1
        END
    END
    IF Y.OPERAND EQ 2 THEN
        Y.VALUE.CNT = DCOUNT(Y.VALUE,@SM)
        IF Y.VALUE.CNT NE 2 THEN
            ENQ.ERROR = "Two values needs to be entered for this operand - ":Y.FIELD
            GOSUB END1
        END
    END

RETURN
*--------------------------------------------
GET.INTEREST.SEL.VALUES:
*--------------------------------------------

    BEGIN CASE
        CASE Y.VAR3 EQ 1
            FIRST.REVIEW.DATE.OPERAND = Y.OPERAND
            FIRST.REVIEW.DATE.VALUE   = Y.VALUE
            FIRST.REVIEW.DATE.FIELD   = Y.FIELD
        CASE Y.VAR3 EQ 2
            NEXT.REVIEW.DATE.OPERAND = Y.OPERAND
            NEXT.REVIEW.DATE.VALUE   = Y.VALUE
            NEXT.REVIEW.DATE.FIELD   = Y.FIELD
        CASE Y.VAR3 EQ 3
            LAST.REVIEW.DATE.OPERAND = Y.OPERAND
            LAST.REVIEW.DATE.VALUE   = Y.VALUE
            LAST.REVIEW.DATE.FIELD   = Y.FIELD
    END CASE

RETURN
*--------------------------------------------
GET.INTEREST.COND:
*--------------------------------------------
    Y.INT.SUCCESS.FLAG = 'SUCCESS'
    PROP.NAME = 'PRINCIPAL'
    APAP.TAM.redoGetInterestProperty(Y.ARR.ID,PROP.NAME,PRIN.PROP,ERR);* R22 Manual conversion

    EFF.DATE        = ''
    PROP.CLASS      = 'INTEREST'
    PROPERTY        = PRIN.PROP
    R.CONDITION.INT = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.INT,ERR.MSG);* R22 Manual conversion - CALL routine format changed

    Y.INT.FIRST.REV.DATE = R.CONDITION.INT<AA.INT.LOCAL.REF,POS.L.AA.FIR.REV.DT>
    Y.INT.NEXT.REV.DATE  = R.CONDITION.INT<AA.INT.LOCAL.REF,POS.L.AA.NXT.REV.DT>
    Y.INT.LAST.REV.DATE  = R.CONDITION.INT<AA.INT.LOCAL.REF,POS.L.AA.LST.REV.DT>

    IF FIRST.REVIEW.DATE.FIELD THEN
        IF FIRST.REVIEW.DATE.OPERAND EQ 1 THEN
            IF Y.INT.FIRST.REV.DATE NE FIRST.REVIEW.DATE.VALUE THEN
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END
        IF FIRST.REVIEW.DATE.OPERAND EQ 2 THEN
            IF Y.INT.FIRST.REV.DATE GE FIRST.REVIEW.DATE.VALUE<1,1,1> AND Y.INT.FIRST.REV.DATE LE FIRST.REVIEW.DATE.VALUE<1,1,2> ELSE
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END
    END
    IF NEXT.REVIEW.DATE.FIELD THEN
        IF NEXT.REVIEW.DATE.OPERAND EQ 1 THEN
            IF Y.INT.NEXT.REV.DATE NE NEXT.REVIEW.DATE.VALUE THEN
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END

        IF NEXT.REVIEW.DATE.OPERAND EQ 2 THEN
            IF Y.INT.NEXT.REV.DATE GE NEXT.REVIEW.DATE.VALUE<1,1,1> AND Y.INT.NEXT.REV.DATE LE NEXT.REVIEW.DATE.VALUE<1,1,2> ELSE
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END

    END
    IF LAST.REVIEW.DATE.FIELD THEN
        IF LAST.REVIEW.DATE.OPERAND EQ 1 THEN
            IF Y.INT.LAST.REV.DATE NE LAST.REVIEW.DATE.VALUE THEN
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END

        IF LAST.REVIEW.DATE.OPERAND EQ 2 THEN
            IF Y.INT.LAST.REV.DATE GE LAST.REVIEW.DATE.VALUE<1,1,1> AND Y.INT.LAST.REV.DATE LE LAST.REVIEW.DATE.VALUE<1,1,2> ELSE
                Y.INT.SUCCESS.FLAG = 'FAIL'
            END
        END

    END


RETURN
*--------------------------------------------
CUSTOMER.SELECTION:
*--------------------------------------------

    Y.CUS.FINAL.ARR.IDS        = ''

    LOCATE 'AFFILIATED.COMPANY' IN FIELDS.BK<1> SETTING POS3 THEN
        Y.AFF.COMP.FIELD   = FIELDS.BK<POS3>
        Y.AFF.COMP.VALUE   = VALUE.BK<POS3>
    END
    LOCATE 'CAMPAIGN.TYPE' IN FIELDS.BK<1> SETTING POS4 THEN
        Y.CAMP.TYPE.FIELD   = FIELDS.BK<POS4>
        Y.CAMP.TYPE.VALUE   = VALUE.BK<POS4>
    END
    IF Y.AFF.COMP.FIELD EQ '' AND Y.CAMP.TYPE.FIELD EQ '' THEN
        Y.CUS.FINAL.ARR.IDS  =  Y.INT.FINAL.ARR.IDS
        RETURN
    END
    Y.INT.ARR.CNT = DCOUNT(Y.INT.FINAL.ARR.IDS,@FM)
    Y.VAR4 = 1
    LOOP
    WHILE Y.VAR4 LE Y.INT.ARR.CNT
        Y.ARR.ID = Y.INT.FINAL.ARR.IDS<Y.VAR4>
        GOSUB GET.CUSTOMER.PROD.COND
        IF Y.AFF.COMP.FIELD THEN
            IF Y.CUS.AFF.COMP NE Y.AFF.COMP.VALUE THEN
                Y.CUS.SUCCESS.FLAG = 'FAIL'
            END
        END
        IF Y.CAMP.TYPE.FIELD THEN
            IF Y.CUS.CAMP.TYPE NE Y.CAMP.TYPE.VALUE THEN
                Y.CUS.SUCCESS.FLAG = 'FAIL'
            END
        END
        IF Y.CUS.SUCCESS.FLAG EQ 'SUCCESS' THEN
            Y.CUS.FINAL.ARR.IDS<-1> = Y.ARR.ID
        END
        Y.VAR4 += 1
    REPEAT

RETURN
*--------------------------------------------
GET.CUSTOMER.PROD.COND:
*--------------------------------------------

    Y.CUS.SUCCESS.FLAG = 'SUCCESS'
    EFF.DATE        = ''
    PROP.CLASS      = 'CUSTOMER'
    PROPERTY        = ''
    R.CONDITION.CUS = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.CUS,ERR.MSG);* R22 Manual conversion - CALL routine format changed
    Y.CUS.AFF.COMP  = R.CONDITION.CUS<AA.CUS.LOCAL.REF,POS.L.AA.AFF.COM>
    Y.CUS.CAMP.TYPE = R.CONDITION.CUS<AA.CUS.LOCAL.REF,POS.L.AA.CAMP.TY>

RETURN
*--------------------------------------------
TERM.SELECTION:
*--------------------------------------------

    Y.TERM.FINAL.ARR.IDS = ''
    LOCATE 'TYPE.OF.GUARANTEE' IN FIELDS.BK<1> SETTING POS4 THEN
        Y.GUARANTEE.FIELD = FIELDS.BK<POS4>
        Y.GUARANTEE.VALUE = VALUE.BK<POS4>
    END
    IF Y.GUARANTEE.FIELD EQ '' AND Y.MATURITY.DATE.FIELD EQ '' THEN
        Y.TERM.FINAL.ARR.IDS = Y.CUS.FINAL.ARR.IDS
        RETURN
    END
    Y.CUS.ARR.CNT = DCOUNT (Y.CUS.FINAL.ARR.IDS,@FM)
    Y.VAR5 = 1
    LOOP
    WHILE Y.VAR5 LE Y.CUS.ARR.CNT
        Y.ARR.ID = Y.CUS.FINAL.ARR.IDS<Y.VAR5>
        GOSUB GET.TERM.PRODUCT.COND
        GOSUB CHECK.TERM.COND
        IF Y.TERM.SUCCESS.FLAG EQ 'SUCCESS' THEN
            Y.TERM.FINAL.ARR.IDS<-1> = Y.ARR.ID
        END
        Y.VAR5 += 1
    REPEAT


RETURN
*-------------------------------------------------
GET.TERM.PRODUCT.COND:
*-------------------------------------------------

    Y.TERM.SUCCESS.FLAG = 'SUCCESS'
    EFF.DATE        = ''
    PROP.CLASS      = 'TERM.AMOUNT'
    PROPERTY        = ''
    R.CONDITION.TERM = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.TERM,ERR.MSG);* R22 Manual conversion - CALL routine format changed
    Y.TERM.MATURITY.DATE = R.CONDITION.TERM<AA.AMT.MATURITY.DATE>
    Y.COLL.IDS           = R.CONDITION.TERM<AA.AMT.LOCAL.REF,POS.L.AA.COL>
    Y.TERM.COLL.CODES = ''
    Y.COL.VAR = 1
    Y.COLL.CNT = DCOUNT(Y.COLL.IDS,@SM)
    LOOP
    WHILE Y.COL.VAR LE Y.COLL.CNT
        Y.COLL.ID = Y.COLL.IDS<1,1,Y.COL.VAR>
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,COL.ERR)
        Y.TERM.COLL.CODES<-1> = R.COLLATERAL<COLL.COLLATERAL.CODE>
        Y.COL.VAR += 1
    REPEAT
RETURN
*--------------------------------------------
CHECK.TERM.COND:
*--------------------------------------------
    IF Y.GUARANTEE.FIELD THEN
        LOCATE Y.GUARANTEE.VALUE IN Y.TERM.COLL.CODES<1> SETTING COL.POS ELSE
            Y.TERM.SUCCESS.FLAG = 'FAIL'
        END
    END
    IF Y.MATURITY.DATE.FIELD THEN
        IF Y.MATURITY.DATE.OPERAND EQ 1 THEN
            IF Y.TERM.MATURITY.DATE NE Y.MATURITY.DATE.VALUE THEN
                Y.TERM.SUCCESS.FLAG = 'FAIL'
            END
        END
        IF Y.MATURITY.DATE.OPERAND EQ 2 THEN
            IF Y.TERM.MATURITY.DATE GE Y.MATURITY.DATE.VALUE<1,1,1> AND Y.TERM.MATURITY.DATE LE Y.MATURITY.DATE.VALUE<1,1,2> ELSE
                Y.TERM.SUCCESS.FLAG = 'FAIL'
            END
        END
    END
RETURN
*--------------------------------------------
AGING.AND.LOAN.STATUS.SELECTION:
*--------------------------------------------
    Y.AGING.FINAL.ARR.IDS = ''
    LOCATE 'LOAN.AGING' IN FIELDS.BK<1> SETTING POS5 THEN
        Y.AGING.FIELD = FIELDS.BK<POS5>
        Y.AGING.VALUE = VALUE.BK<POS5>
    END
    IF Y.AGING.FIELD EQ '' THEN
        Y.AGING.FINAL.ARR.IDS = Y.TERM.FINAL.ARR.IDS
    END ELSE
        GOSUB CHECK.AGING.STATUS
    END
    IF Y.AGING.FINAL.ARR.IDS THEN
        GOSUB CHECK.LOAN.STATUS
    END ELSE
        ENQ.ERROR = 'No records selected after aging selection'
        GOSUB END1
    END
    IF Y.USER.AA.IDS THEN
        GOSUB CHECK.RATE.CHANGE.USER.SELECTION
    END ELSE

    END

RETURN
*--------------------------------------------
CHECK.AGING.STATUS:
*--------------------------------------------
    IN.ACC.ID = ''
    Y.TERM.ARR.CNT = DCOUNT(Y.TERM.FINAL.ARR.IDS,@FM)
    Y.VAR6 = 1
    LOOP
    WHILE Y.VAR6 LE Y.TERM.ARR.CNT
        Y.ARR.ID   = Y.TERM.FINAL.ARR.IDS<Y.VAR6>
        Y.LOAN.ACC = ''
        APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.ARR.ID,Y.LOAN.ACC,ERR.TEXT);* R22 Manual conversion
        CALL F.READ(FN.ACCOUNT,Y.LOAN.ACC,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        Y.LOAN.AGING.STATUS = R.ACCOUNT<AC.LOCAL.REF,POS.L.OD.STATUS>
        IF Y.LOAN.AGING.STATUS EQ Y.AGING.VALUE THEN
            Y.AGING.FINAL.ARR.IDS<-1> = Y.ARR.ID
        END
        Y.VAR6 += 1
    REPEAT

RETURN
*--------------------------------------------
CHECK.LOAN.STATUS:
*--------------------------------------------

    Y.USER.AA.IDS = ''
    LOCATE 'LOAN.STATUS' IN FIELDS.BK<1> SETTING POS6 THEN
        Y.LOAN.STATUS.FIELD = FIELDS.BK<POS6>
        Y.LOAN.STATUS.VAUE  = VALUE.BK<POS6>
    END
    IF Y.LOAN.STATUS.FIELD EQ '' THEN
        Y.USER.AA.IDS = Y.AGING.FINAL.ARR.IDS
        RETURN
    END

    Y.AGING.ARR.CNT = DCOUNT(Y.AGING.FINAL.ARR.IDS,@FM)
    Y.VAR7 = 1
    LOOP
    WHILE Y.VAR7 LE Y.AGING.ARR.CNT
        Y.ARR.ID   = Y.AGING.FINAL.ARR.IDS<Y.VAR7>
        GOSUB GET.OVERDUE.COND
        IF Y.AA.LOAN.STATUS EQ Y.LOAN.STATUS.VAUE THEN
            Y.USER.AA.IDS<-1> = Y.ARR.ID
        END

        Y.VAR7 += 1
    REPEAT
RETURN
*------------------------------------------------
GET.OVERDUE.COND:
*------------------------------------------------

    EFF.DATE        = ''
    PROP.CLASS      = 'OVERDUE'
    PROPERTY        = ''
    R.CONDITION.OVERDUE = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(Y.ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.OVERDUE,ERR.MSG);* R22 Manual conversion - CALL routine format changed
    Y.AA.LOAN.STATUS = R.CONDITION.OVERDUE<AA.OD.LOCAL.REF,POS.L.LOAN.STATUS.1,1>
RETURN
*------------------------------------------------
CHECK.RATE.CHANGE.USER.SELECTION:
*------------------------------------------------
    LOCATE 'RATE.REVIEW.USER' IN FIELDS.BK<1> SETTING POS7 THEN
        Y.RATE.USER.VAUE  = VALUE.BK<POS7>
    END ELSE
        Y.FINAL.AA.IDS = Y.USER.AA.IDS
        RETURN
    END
    Y.VAR8 = 1
    Y.USER.AA.CNT = DCOUNT(Y.USER.AA.IDS,@FM)
    LOOP
    WHILE Y.VAR8 LE Y.USER.AA.CNT
        Y.ARR.ID = Y.USER.AA.IDS<Y.VAR8>
        CALL F.READ(FN.REDO.NOTIFY.RATE.CHANGE,Y.ARR.ID,R.REDO.NOTIFY.RATE.CHANGE,F.REDO.NOTIFY.RATE.CHANGE,NOT.ERR)
        IF R.REDO.NOTIFY.RATE.CHANGE<6> EQ Y.RATE.USER.VAUE THEN
            Y.FINAL.AA.IDS<-1> = Y.ARR.ID
        END
        Y.VAR8 += 1
    REPEAT

RETURN
*------------------------------------------------
FETCH.REPORT.DATE:
*------------------------------------------------
    OUT.ARRAY = ''
    APAP.AA.redoApapNofileAaLoanRatesReview(Y.FINAL.AA.IDS,OUT.ARRAY);* R22 Manual conversion - CALL routine format changed

RETURN
*--------------------------------------------
END1:
*--------------------------------------------
END
