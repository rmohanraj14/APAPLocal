* @ValidationCode : MjoxMjcxMDY2NzExOkNwMTI1MjoxNjg1NTMyMjAyMTY3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:53:22
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
SUBROUTINE REDO.RELATED.NO.RISK.GROUP(AA.ARRAY)
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : This is a no file enquiry routine for the enquiry REDO.ENQ.RELATED.NO.RISK.GROUP
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.RELATED.NO.RISK.GROUP
*-----------------------------------------------------------------------------------------------------
* Modification History :
* DATE             WHO                REFERENCE         DESCRIPTION
* 01.07.2010      SUDHARSANAN S      ODR-2009-10-0578   INITIAL CREATION

* 20.09.2010     SHANKAR RAJU       ODR-2010-09-0020   MODIFICATION FOR CR-010
*
*                                                      CR DESCRIPTION : Include a validation for the
*                                                                       field RELATION the valid values
*                                                                       are in the range 300 to 500
* -----------------------------------------------------------------------------------------------------
*Modification History:
*Date             Who                   Reference                                   Descripition
* 29-03-2023   Conversion Tool         Auto R22 code conversion                   FM TO @FM, VM TO @VM
* 29-03-2023     Samaran T            Manual R22 Code Conversion                Package Name Added APAP.AA, CALL method format changed
*-------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.CREDIT.LIMIT.MAINTENANCE

    GOSUB INIT
    GOSUB PROCESS
RETURN
******
INIT:
******
    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMT= ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)


    FN.CUSTOMER= 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CREDIT.LIMIT.MAINTENANCE = 'F.CREDIT.LIMIT.MAINTENANCE'
    F.CREDIT.LIMIT.MAINTENANCE = ''
    CALL OPF(FN.CREDIT.LIMIT.MAINTENANCE,F.CREDIT.LIMIT.MAINTENANCE)

    FN.ALTERNATE.ACCOUNT = 'F.ALTERNATE.ACCOUNT'
    F.ALTERNATE.ACCOUNT = ''
    CALL OPF(FN.ALTERNATE.ACCOUNT,F.ALTERNATE.ACCOUNT)

    FN.ECB = 'F.EB.CONTRACT.BALANCES'
    F.ECB = ''
    CALL OPF(FN.ECB,F.ECB)

    CUST.ID=''
    CONT.BAL = 0
    RECEIVABLE.YIELD.BALANCE = 0
    DIRECT.BAL = 0


RETURN
*********
PROCESS:
*********

    LOCATE "CUSTOMER.NO" IN D.FIELDS<1> SETTING CUS.POS THEN
        CUST.ID = D.RANGE.AND.VALUE<CUS.POS>
    END

    CALL F.READ(FN.CUSTOMER,CUST.ID,R.CUSTOMER,F.CUSTOMER,CUS.ERR)

    CUST = R.CUSTOMER<EB.CUS.REL.CUSTOMER>
    REL.CODE.CUS = R.CUSTOMER<EB.CUS.RELATION.CODE>

    CHANGE @VM TO @FM IN CUST
    CHANGE @VM TO @FM IN REL.CODE.CUS

    CUST.LIST = DCOUNT(CUST,@FM)

    CNT1 = 1
    LOOP
        CUS.REL.CODE = REL.CODE.CUS<CNT1>
******FOR CHANGE REQUEST CR-010*********field RELATION the valid values are in the range 300 to 500*******20/SEP/2010***

        IF CUS.REL.CODE GE 300 AND CUS.REL.CODE LE 500 THEN

            REL.CUS.ID = CUST<CNT1>
            SEL.CMD='SELECT ':FN.AA.ARRANGEMENT:' WITH CUSTOMER EQ ':REL.CUS.ID
            CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR)
            LOOP
                REMOVE AA.ID FROM SEL.LIST SETTING AA.POS
            WHILE AA.ID :AA.POS
                CALL F.READ(FN.AA.ARRANGEMENT,AA.ID,R.AA,F.AA.ARRANGEMENT,AA.ERR)
                Y.PRD.LINE = R.AA<AA.ARR.PRODUCT.LINE>
                Y.STATUS = R.AA<AA.ARR.ARR.STATUS>
                IF Y.PRD.LINE EQ 'LENDING' AND Y.STATUS NE 'AUTH' AND Y.STATUS NE 'UNAUTH' THEN
                    TYPE.OF.PROD = R.AA<AA.ARR.PRODUCT>
                    GOSUB BAL.AMT
                    AA.ARRAY<-1> = TYPE.OF.PROD :"*":DIRECT.BAL:"*":RECEIVABLE.YIELD.BALANCE:"*":CONT.BAL:"*":TOTAL.AMT
                END

            REPEAT
        END
    WHILE CNT1 LE CUST.LIST
        CNT1 += 1   ;*R22 Auto Conversion
    REPEAT
    CALL CACHE.READ(FN.CREDIT.LIMIT.MAINTENANCE,'SYSTEM',R.CRD.LIM.MAIN,CRD.ERR)
    LOCATE "RELATED.GLOBAL.LIMIT" IN R.CRD.LIM.MAIN<CRD.LIM.TYPE.OF.GROUP,1> SETTING GROUP.POS THEN
        TOTAL.AVAIL.AMT = R.CRD.LIM.MAIN<CRD.LIM.AVAILABLE.AMOUNT,GROUP.POS>
    END
    IF AA.ARRAY NE '' THEN
        AA.ARRAY<1> := '*': TOTAL.AVAIL.AMT
    END
RETURN
********************************
BAL.AMT:
********************************

    PROP.CLASS="TERM.AMOUNT"
    APAP.AA.redoCrrGetConditions(AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG);* R22 Manual conversion
    DIRECT.BAL=R.Condition<AA.AMT.AMOUNT>
    GOSUB YIELD.BAL
    GOSUB CONTENGENCY.BALANCE
    TOTAL.AMT = DIRECT.BAL + RECEIVABLE.YIELD.BALANCE + CONT.BAL
RETURN
**************
YIELD.BAL:
**************
*Calculates the due interest amount for the next 90 days

    ST.DATE = TODAY
    F.DATE = '+90C'
    CALL CDT('',ST.DATE,F.DATE)
    CALL AA.SCHEDULE.PROJECTOR(AA.ID, SIM.REF, "",CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    Y.NO.OF.DATE=DCOUNT(DUE.DATES,@FM)
    VAR1=1
    Y.INT.RATE = 0
    Y.TOTAL.INT.AMT = 0
    LOOP
    WHILE VAR1 LE Y.NO.OF.DATE
        Y.PAYMENT.DATE = DUE.DATES<VAR1>
        IF Y.PAYMENT.DATE GE TODAY THEN
            IF Y.PAYMENT.DATE LE ST.DATE THEN
                Y.INT.AMT            = DUE.PROP.AMTS<VAR1,1,2>
                Y.TOTAL.INT.AMT+= Y.INT.AMT
            END ELSE
                BREAK
            END
        END
        VAR1 += 1  ;*R22 Auto Conversion
    REPEAT
    RECEIVABLE.YIELD.BALANCE = Y.TOTAL.INT.AMT
RETURN
*********************
CONTENGENCY.BALANCE:
*********************
*Calculates Available amount from Commitment amount

    CALL F.READ(FN.ALTERNATE.ACCOUNT, AA.ID , R.ALT.ACC, F.ALTERNATE.ACCOUNT, ACC.ERROR)
    Y.ACCOUNT.NO = R.ALT.ACC<AAC.GLOBUS.ACCT.NUMBER>
    CALL AA.GET.PROPERTY.NAME(AA.ID,PROP.CLASS,OUT.PARAM)
    IF OUT.PARAM EQ '' THEN
        OUT.PARAM = 'COMMITMENT'
    END
    Y.PROPERTY = "CUR":OUT.PARAM
    CALL F.READ(FN.ECB,Y.ACCOUNT.NO, R.ECB, F.ECB, ECB.ERR)
    LOCATE Y.PROPERTY IN R.ECB<ECB.CURR.ASSET.TYPE,1> SETTING PROP.POS THEN
        Y.DISBURSE.AMT = R.ECB<ECB.CREDIT.MVMT,PROP.POS,1>
        Y.COMMITMENT.AMT = R.ECB<ECB.CREDIT.MVMT,PROP.POS,1>
        Y.AVAIL.AMT = Y.DISBURSE.AMT + Y.COMMITMENT.AMT
        CONT.BAL = ABS(Y.AVAIL.AMT)
    END
RETURN
*--------------------------------------------------------------------------------------------------------------*
END
