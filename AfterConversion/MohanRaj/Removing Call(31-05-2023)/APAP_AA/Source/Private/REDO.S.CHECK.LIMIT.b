* @ValidationCode : MjotMTk2NjA0MTUxMzpDcDEyNTI6MTY4NTUzMjIzMDUzMTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:53:50
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
$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.S.CHECK.LIMIT
*----------------------------------------------------------------------------------------
* DESCRIPTION : This routine is an ACTIVITY.API Pre routine attached to TERM.AMOUNT
*               property class. This will be executed when inputting arrangements for
*               AA Loan Contracts to validate if overpayment rule is setup either in
*               TERM.AMOUNT Property Class
*----------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*----------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : NAVEENKUMAR N
* PROGRAM NAME : REDO.S.CHECK.LIMIT
*----------------------------------------------------------------------------------------
* Modification History :
* Date             Author             Reference           Description
* 02-June-2010     Naveenkumar N     ODR-2009-11-0199    Initial creation
*------------------------------------------------------------------------------------------------------
* Modification History:
* Date           Who                 Reference                                       Descripition
* 29-03-2023    Conversion Tool           Auto R22 code conversion                   FM TO @FM, VM TO @VM
* 29-03-2023     Samaran T            Manual R22 Code Conversion                Package Name Added APAP.AA, CALL method format changed
*-------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.COLLATERAL

    GOSUB INIT
    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------------
*****
INIT:
*****
    FN.LIMIT = "F.LIMIT"
    F.LIMIT = ""
    R.LIMIT = ""
    E.LIMIT = ""
    CALL OPF(FN.LIMIT,F.LIMIT)
*
    FN.LI.COLLATERAL.RIGHT = "F.LI.COLLATERAL.RIGHT"
    F.LI.COLLATERAL.RIGHT = ""
    R.LI.COLLATERAL.RIGHT = ""
    E.LI.COLLATERAL.RIGHT = ""
    CALL OPF(FN.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT)
*
    FN.RIGHT.COLLATERAL = "F.RIGHT.COLLATERAL"
    F.RIGHT.COLLATERAL = ""
    R.RIGHT.COLLATERAL = ""
    E.RIGHT.COLLATERAL = ""
    CALL OPF(FN.RIGHT.COLLATERAL,F.RIGHT.COLLATERAL)
*
    FN.COLLATERAL = "F.COLLATERAL"
    F.COLLATERAL = ""
    R.COLLATERAL = ""
    E.COLLATERAL = ""
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)
*
    CURR.NO = ""
RETURN
*----------------------------------------------------------------------------
********
PROCESS:
********

    GOSUB REDO.CRR.GET.CONDITIONS.TERM
    GOSUB MULTI.GET.LOC.REF
    L.AA.MIN.AMOUNT = R.Condition<AA.AMT.LOCAL.REF><1,L.AA.MIN.AMOUNT.POS>
    L.AA.MAX.AMOUNT = R.Condition<AA.AMT.LOCAL.REF><1,L.AA.MAX.AMOUNT.POS>
    L.AA.COLL.TYPE = R.Condition<AA.AMT.LOCAL.REF><1,L.AA.COLL.TYPE.POS>
    L.AA.RISK.PER = R.Condition<AA.AMT.LOCAL.REF><1,L.AA.RISK.PER.POS>
    GOSUB REDO.CRR.GET.CONDITIONS.LIMIT
    GOSUB LIMIT.CHECKS
    GOSUB AMOUNT.CHECKS
    GOSUB COLLATERAL
    GOSUB CURRENCY.CHECK
    GOSUB ACCOUNT.BLOCKING
RETURN
************
LIMIT.CHECKS:
************
    LIMIT.REFERENCE = R.Condition.limit<AA.LIM.LIMIT.REFERENCE>
*AA Chnages 20161013
    Y.LIMIT.SERIAL = R.Condition.limit<AA.LIM.LIMIT.SERIAL>
    LIMIT.CONCAT = LIMIT.REFERENCE:".":Y.LIMIT.SERIAL
    Y.CUSTOMER = c_aalocArrangementRec
    CUSTOMER  = Y.CUSTOMER<1>
*  CUSTOMER.LIMIT.REFERENCE = CUSTOMER:".":LIMIT.REFERENCE
    CUSTOMER.LIMIT.REFERENCE = CUSTOMER:".":LIMIT.CONCAT
*AA Changes 20161013
    CALL F.READ(FN.LIMIT,CUSTOMER.LIMIT.REFERENCE,R.LIMIT,F.LIMIT,E.LIMIT)
    COLLATERAL.CODE = R.LIMIT<LI.COLLATERAL.CODE>
    IF CUSTOMER NE COLLATERAL.CODE THEN
        CURR.NO=DCOUNT(R.NEW(LI.OVERRIDE),@VM) + 1
        TEXT = "DIFFERENT.COLL.CODE"
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
*************
AMOUNT.CHECKS:
*************
    CALL F.READ(FN.LI.COLLATERAL.RIGHT,CUSTOMER.LIMIT.REFERENCE,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,E.LI.COLLATERAL.RIGHT)
    COLLATERAL.RIGHT.LIST = R.LI.COLLATERAL.RIGHT
    LOOP
        REMOVE COLL.RIGHT FROM COLLATERAL.RIGHT.LIST SETTING POS
    WHILE COLL.RIGHT:POS
        CALL F.READ(FN.RIGHT.COLLATERAL,COLL.RIGHT,R.RIGHT.COLLATERAL,F.RIGHT.COLLATERAL,E.RIGHT.COLLATERAL)
        COLLATERAL.ID.LIST := R.RIGHT.COLLATERAL:@FM
    REPEAT
RETURN
***********
COLLATERAL:
***********
    LOOP
        REMOVE COLL.ID FROM COLLATERAL.ID.LIST SETTING POS1
    WHILE COLL.ID:POS1
        CALL F.READ(FN.COLLATERAL,COLL.ID,R.COLLATERAL,F.COLLATERAL,E.COLLATERAL)
        NOMINAL.VALUE += R.COLLATERAL<COLL.NOMINAL.VALUE>
    REPEAT
*
    Y.NOMINAL.VALUE = (L.AA.MIN.AMOUNT*NOMINAL.VALUE)/100
    Y.TERM.AMOUNT = R.Condition<AA.AMT.AMOUNT>
    IF Y.NOMINAL.VALUE LT Y.TERM.AMOUNT THEN
        CURR.NO = DCOUNT(R.NEW(AA.AMT.OVERRIDE),@VM) + 1
        TEXT = "LESS.THAN.MIN.AMT"
        CALL STORE.OVERRIDE(CURR.NO)
    END
*
    Y.NOMINAL.VALUE = (L.AA.MAX.AMOUNT*NOMINAL.VALUE)/100
    IF Y.NOMINAL.VALUE GT Y.TERM.AMOUNT THEN
        CURR.NO = DCOUNT(R.NEW(AA.AMT.OVERRIDE),@VM) + 1
        TEXT = "GREATER.THAN.MAX.AMT"
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
**************
CURRENCY.CHECK:
**************
    COLLATERAL.ID.LIST := R.RIGHT.COLLATERAL:@FM
    LOOP
        REMOVE COLL.ID FROM COLLATERAL.ID.LIST SETTING POS1
    WHILE COLL.ID:POS1
        CALL F.READ(FN.COLLATERAL,COLL.ID,R.COLLATERAL,F.COLLATERAL,E.COLLATERAL)
        Y.CURRENCY = ""
        Y.CURRENCY = R.COLLATERAL<COLL.CURRENCY>
        IF Y.CURRENCY NE "" THEN
            EXIT
        END
    REPEAT
*
    Y.CURR = c_aalocArrCurrency
    IF Y.CURRENCY NE Y.CURR THEN
        CURR.NO = DCOUNT(R.NEW(AA.AMT.OVERRIDE),@VM) + 1
        TEXT = "CURRENCY.DOES.NOT.MATCH"
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
****************
ACCOUNT.BLOCKING:
****************
    COLLATERAL.ID.LIST := R.RIGHT.COLLATERAL:@FM
    AMOUNT =  R.Condition<AA.AMT.AMOUNT>
    L.AA.RISK.PER = R.Condition<AA.AMT.LOCAL.REF><1,L.AA.RISK.PER.POS>
    Y.CAL.AMT = (L.AA.RISK.PER*AMOUNT)/100
*
    LOOP
        REMOVE COLL.ID FROM COLLATERAL.ID.LIST SETTING POS1
    WHILE COLL.ID:POS1
        CALL F.READ(FN.COLLATERAL,COLL.ID,R.COLLATERAL,F.COLLATERAL,E.COLLATERAL)
        Y.ACCOUNT.NO = ""
        Y.ACCOUNT.NO = R.COLLATERAL<COLL.APPLICATION.ID>
        IF Y.ACCOUNT.NO  NE "" THEN
            EXIT
        END
    REPEAT
*
    Y.LOCKED.AMOUNT = Y.CAL.AMT
    OFS.STR = 'AC.LOCKED.EVENTS,APAP/I/PROCESS,/,,TRANSACTION.REF:1:1:=':',ACCOUNT.NUMBER:1:1:=':Y.ACCOUNT.NO:',LOCKED.AMOUNT:1:1:=':Y.LOCKED.AMOUNT
    OFS.SRC= 'APAP.B.180.OFS'
    OFS.MSG.ID = ''
    OPTIONS = ''
    CALL OFS.POST.MESSAGE(OFS.STR,OFS.MSG.ID,OFS.SRC,OPTIONS)
RETURN
*****************************
REDO.CRR.GET.CONDITIONS.TERM:
*****************************
    ARR.ID = c_aalocArrId
    EFF.DATE = TODAY
    PROP.CLASS = 'TERM.AMOUNT'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG);* R22 Manual conversion
RETURN
******************
MULTI.GET.LOC.REF:
******************
    APPLICATION = "AA.PRD.DES.TERM.AMOUNT"
    FIELD.NAME = "L.AA.MIN.AMOUNT":@VM:"L.AA.MAX.AMOUNT":@VM:"L.AA.COLL.TYPE":@VM:"L.AA.RISK.PER"
    FIELD.POS = ""
    CALL MULTI.GET.LOC.REF(APPLICATION,FIELD.NAME,FIELD.POS)
    L.AA.MIN.AMOUNT.POS = FIELD.POS<1,1>
    L.AA.MAX.AMOUNT.POS = FIELD.POS<1,2>
    L.AA.COLL.TYPE.POS = FIELD.POS<1,3>
    L.AA.RISK.PER.POS = FIELD.POS<1,4>
RETURN
*****************************
REDO.CRR.GET.CONDITIONS.LIMIT:
*****************************
    ARR.ID.LIMIT = c_aalocArrId
    EFF.DATE = TODAY
    PROP.CLASS = 'LIMIT'
    PROPERTY = ''
    R.Condition.limit = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID.LIMIT,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition.limit,ERR.MSG);* R22 Manual conversion
RETURN
END
