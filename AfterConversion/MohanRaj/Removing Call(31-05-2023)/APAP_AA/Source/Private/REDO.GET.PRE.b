* @ValidationCode : Mjo3NDkzNzE0MjI6Q3AxMjUyOjE2ODQ4NDA4NjEwNzc6SVRTUzotMTotMToxMTExOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 23 May 2023 16:51:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 1111
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.GET.PRE(Y.ACTIVI.ID,CURR.VALUE,PREVIOUS.COND)
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.GET.PRE
*--------------------------------------------------------------------------------------------------------
*Description       : This is call routine for REDO.E.NOFILE.LOAN.PAYMENTS enquiry routine, routine gives
*                    previous record and record for the arrangement
*Linked With       : Enquiry REDO.LOAN.PAYMENT
*In  Parameter     : Y.ACTIVI.ID
*                    Y.ACTIVI.ID<2>  ---- arrangement>eff.date
*Out Parameter     : CURR.VALUE, PREVIOUS.COND
*Files  Used       : AA.ARRANGEMENT
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date                 Who                        Reference                   Description
*     ------               -----                      -------------                -------------
* 30 Nov 2010            Arulprakasam P               ODR-2010-03-0142- 166              Initial Creation
* 21 Jan 2013            Shekar                       Performance
*                     do not read aa.arrangement to get effective.date.. this is now passed as argument
*                     cache read aa.property
*19-04-2023       CONVERSION TOOLS            AUTO R22 CODE CONVERSION           TAM.BP REMOVED, $INCLUDE to $INSERT
*19-04-2023       AJITHKUMAR                  MANUAL R22 CODE CONVERSION
*----------------------------------------------------------------------------------------
*********************************************************************************************************

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ACTIVITY.MESSAGING
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_F.AA.CHANGE.PRODUCT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.PAYOFF
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.AA.OFFICERS
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.ACTIVITY.CHARGES
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.PROPERTY
    $INSERT I_AA.ID.COMPONENT
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.STANDARD.SELECTION

**********
MAIN.PARA:
**********
* This is the para from where the execution of the code starts

    GOSUB OPEN.PARA
    GOSUB PROCESS.PARA

RETURN

**********
OPEN.PARA:
**********
* In this para of the code, file variables are initialised and opened

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ARR.ACCOUNT = 'F.AA.ARR.ACCOUNT'
    F.AA.ARR.ACCOUNT = ''
    CALL OPF(FN.AA.ARR.ACCOUNT,F.AA.ARR.ACCOUNT)

    FN.AA.ARR.TERM.AMOUNT = 'F.AA.ARR.TERM.AMOUNT'
    F.AA.ARR.TERM.AMOUNT = ''
    CALL OPF(FN.AA.ARR.TERM.AMOUNT,F.AA.ARR.TERM.AMOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

    FN.AA.PROPERTY = 'F.AA.PROPERTY'
    F.AA.PROPERTY = ''
    CALL OPF(FN.AA.PROPERTY,F.AA.PROPERTY)

    Y.VALUE = ''
    Y.PRE.VALUE = ''

*Shek -s
*  arrangement effective date is passed... not reading aa.arrangement
    Y.EFF.DATE = Y.ACTIVI.ID<2>
    DEL Y.ACTIVI.ID<2>

*Shek -e


RETURN



*************
PROCESS.PARA:
*************
    ARR.INFO = ''
    Y.APP = ''
    Y.ID = ''
    Y.PROPERTY.ITEM = ''
    CURR.VALUE = ''
    PREVIOUS.COND = ''

    AA.ARRANGEMENT.ACTIVITY.ID = Y.ACTIVI.ID
    CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,AA.ARRANGEMENT.ACTIVITY.ID,R.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY,AA.ARRANGEMENT.ACTIVITY.ER)
    IF R.AA.ARRANGEMENT.ACTIVITY NE '' THEN
        AA.ARRANGEMENT.ID = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.ARRANGEMENT>
*Shek
* effective date is now passed as argument... do not read aa.arrangement to get effective date
*-        GOSUB READ.AA.ARRANGEMENT
*-        Y.EFF.DATE = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE>
*Shek -e
* Y.PROCESS.DETAIL = R.AA.ARRANGEMENT.ACTIVITY<AA.ARR.ACT.PROCESS.DETAIL> ;* commented for R22 Code conversion
        Y.PROCESS.DETAIL = '';* R22 Code conversion
        Y.PROCESS.DETAIL = RAISE(Y.PROCESS.DETAIL)
        Y.PROPERTY = ''
        INIT1 = 1
        CHANGE @FM TO '*' IN Y.PROCESS.DETAIL
        Y.COUNT.TRANS1 = DCOUNT(Y.PROCESS.DETAIL,'*')
        LOOP
        WHILE INIT1 LE Y.COUNT.TRANS1
            Y.PROPERTY = FIELD(Y.PROCESS.DETAIL,'*',INIT1)
            Y.APP = FIELD(Y.PROPERTY,' ',1,1)
            Y.APP = FIELD(Y.APP,',',1,1)
            Y.ID =  FIELD(Y.PROPERTY,' ',3,1)
            Y.APP.FUN =  FIELD(Y.PROPERTY,' ',2,1)
            Y.PROPERTY.ITEM =  FIELD(Y.ID,'-',2,1)
            IF Y.APP.FUN EQ 'I' THEN
                GOSUB READ.FILES
            END
            INIT1 += 1
        REPEAT
    END

    CURR.VALUE = Y.VALUE
    PREVIOUS.COND = Y.PRE.VALUE
RETURN

***********
READ.FILES:
***********

    FN.FILENAME = ''
    R.RECORD = ''

    FN.FILENAME  = 'F.':Y.APP
    F.FILENAME = ''

    CALL OPF(FN.FILENAME,F.FILENAME)
    CALL F.READ(FN.FILENAME,Y.ID,R.RECORD,F.FILENAME,Y.ERR)

    GOSUB PROCESS.CASE
RETURN

*************
PROCESS.CASE:
*************

    Y.CASE = ''

    BEGIN CASE
        CASE Y.APP EQ 'AA.ARR.CUSTOMER'
            Y.CASE = 1
            CHANGE.TERM.AMOUNT= R.RECORD<AA.CUS.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.OFFICERS'
            Y.CASE = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.OFF.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END
        CASE Y.APP EQ 'AA.ARR.LIMIT'
            Y.CASE = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.LIM.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

    END CASE
    IF NOT(Y.CASE) THEN
        GOSUB PROCESS.CASE1
    END
RETURN

**************
PROCESS.CASE1:
**************
    Y.CASE1 = ''
    BEGIN CASE

        CASE Y.APP EQ 'AA.ARR.ACCOUNT'
            Y.CASE1 = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.AC.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.CHANGE.PRODUCT'
            Y.CASE1 = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.CP.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END
        CASE Y.APP EQ 'AA.ARR.TERM.AMOUNT'
            Y.CASE1= 1

            CHANGE.TERM.AMOUNT  =  R.RECORD<AA.AMT.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END
    END CASE
    IF NOT(Y.CASE1) THEN
        GOSUB PROCESS.CASE2
    END

RETURN
**************
PROCESS.CASE2:
**************
    Y.CASE2 = ''
    BEGIN CASE
        CASE Y.APP EQ 'AA.ARR.CHANGE.PRODUCT'
            Y.CASE2 = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.CP.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.INTEREST'
            Y.CASE2 = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.INT.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.CHARGE'
            Y.CASE2 = 1
            CHANGE.TERM.AMOUNT = R.RECORD<AA.CHG.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END
    END CASE
    IF NOT(Y.CASE2) THEN
        GOSUB PROCESS.CASE3
    END
RETURN
**************
PROCESS.CASE3:
**************

    BEGIN CASE
        CASE Y.APP EQ 'AA.ARR.PAYMENT.SCHEDULE'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.PS.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.PAYOFF'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.POFF.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.OVERDUE'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.OD.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.ACTIVITY.MESSAGING'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.AM.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.BALANCE.MAINTENANCE'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.BM.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.ACTIVITY.RESTRICTION'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.BM.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END

        CASE Y.APP EQ 'AA.ARR.ACTIVITY.CHARGES'
            CHANGE.TERM.AMOUNT = R.RECORD<AA.ACT.CHG.CHANGED.FIELDS>
            IF CHANGE.TERM.AMOUNT NE '' THEN
                GOSUB GET.CHANGE.AMOUNT
            END
    END CASE

RETURN

******************
GET.CHANGE.AMOUNT:
******************
    LOC.REF.NO = ''
    CHANGE @VM TO '*' IN CHANGE.TERM.AMOUNT
    Y.COUNT.TRANS = DCOUNT(CHANGE.TERM.AMOUNT,'*')
    INIT = 1
    CALL GET.STANDARD.SELECTION.DETS(Y.APP,R.STANDARD.SELECTION)
    LOOP
    WHILE INIT LE Y.COUNT.TRANS
        CHANGE.FIELD.TERM.FIRST = FIELD(CHANGE.TERM.AMOUNT,'*',INIT)
        POS.FIELD = ''

        LOCATE CHANGE.FIELD.TERM.FIRST IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME,1> SETTING POS1 THEN
            POS.FIELD = R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,POS1>
        END ELSE
            LOCATE 'LOCAL.REF' IN R.STANDARD.SELECTION<SSL.SYS.FIELD.NAME,1> SETTING LOC.POS1 THEN
                POS.LOC.REF = R.STANDARD.SELECTION<SSL.SYS.FIELD.NO,LOC.POS1>
            END
        END
        IF POS.FIELD THEN
            Y.AA.FIELDS = POS.FIELD
            Y.VALUE<-1> = R.RECORD<Y.AA.FIELDS>
        END ELSE
            LOC.REF.NO = FIELD(CHANGE.FIELD.TERM.FIRST,'-',2,1)
            Y.AA.FIELDS = POS.LOC.REF
            Y.VALUE<-1> = R.RECORD<Y.AA.FIELDS,LOC.REF.NO>
        END
        GOSUB GET.PREVI
        INIT += 1
    REPEAT

RETURN

**********
GET.PREVI:
**********
    idPropertyClass = ''
    CALL CACHE.READ(FN.AA.PROPERTY, Y.PROPERTY.ITEM, R.AA.PROPERTY, AA.PROPERTY.ERR)        ;* Shek.. cache read aa.property
    Y.PROPERTY.CLASS = R.AA.PROPERTY<AA.PROP.PROPERTY.CLASS>
    OPTION = ''
    R.PROPERTY = ''
    RET.ERROR = ''
    ID.COMPONENT = ''
    idPropertyClass = Y.PROPERTY.CLASS
    Y.EFFECTIVE.DATE = TODAY
    ID.COMPONENT<AA.IDC.ARR.NO> = AA.ARRANGEMENT.ID
    ID.COMPONENT<AA.IDC.PROPERTY> = Y.PROPERTY.ITEM
    ID.COMPONENT<AA.IDC.EFF.DATE> = Y.EFF.DATE
    CALL AA.GET.PREVIOUS.PROPERTY.RECORD(OPTION, idPropertyClass , ID.COMPONENT, Y.EFFECTIVE.DATE, R.PROPERTY, RET.ERROR)
    IF LOC.REF.NO EQ '' THEN
        Y.PRE.VALUE<-1> = R.PROPERTY<Y.AA.FIELDS>
    END ELSE
        Y.PRE.VALUE<-1> = R.PROPERTY<Y.AA.FIELDS,LOC.REF.NO>
    END

RETURN

********************
READ.AA.ARRANGEMENT:
********************
* In this para of the code, file AA.ARRANGEMENT is read
    R.AA.ARRANGEMENT  = ''
    AA.ARRANGEMENT.ER = ''
    CALL F.READ(FN.AA.ARRANGEMENT,AA.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARRANGEMENT.ER)

RETURN

END
