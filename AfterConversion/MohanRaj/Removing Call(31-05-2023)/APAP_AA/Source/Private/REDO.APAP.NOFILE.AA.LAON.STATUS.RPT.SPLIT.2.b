* @ValidationCode : MjotNDUyMTcwNDcyOkNwMTI1MjoxNjg1NTI4NjE3ODUwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 15:53:37
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
SUBROUTINE REDO.APAP.NOFILE.AA.LAON.STATUS.RPT.SPLIT.2(AA.ARRANGEMENT.ID,ACCOUNT.ID,Y.CAP.TOT.BAL,Y.INT.TOT.BAL,Y.INS.TOT.BAL,Y.CHG.TOT.BAL)
*********************************************************************************************************
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : Temenos Application Management
*Program   Name    : REDO.APAP.NOFILE.AA.LAON.STATUS.RPT.SPLIT.2
*--------------------------------------------------------------------------------------------------------
*Description       : This is a spilt of the NO-FILE enquiry routine REDO.APAP.NOFILE.AA.LAON.STATUS.RPT
*Linked With       : Enquiry REDO.APAP.NOF.LAON.STATUS.RPT
*In  Parameter     : AA.ARRANGEMENT.ID - Arrangement ID
*                    ACCOUNT.ID - Contract account Id
*Out Parameter     : Y.CAP.TOT.BAL - Captial Total Balance
*                    Y.INT.TOT.BAL - Interest Total Balance
*                    Y.INS.TOT.BAL - Insurance Total Balance
*                    Y.CHG.TOT.BAL - Charges Total Balance
*Files  Used       : AA.ARRANGEMENT              As              I               Mode
*--------------------------------------------------------------------------------------------------------
*Modification Details:
*=====================
*      Date                 Who                  Reference                 Description
*     ------               -----               -------------              -------------
* 20 August 2010       Shiva Prasad Y       ODR-2010-03-0179 136         Initial Creation
* 29-MAR-2023           Conversion Tool       R22 Auto conversion        FM TO @FM, VM to @VM, SM to @SM, ++ to +=, Variable name changed I to I.VAR
* 29-MAR-2023         Harishvikram C        Manual R22 Conversion        modified CALL routine format
*-----------------------------------------------------------------------------------

*********************************************************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.ACCT.ACTIVITY

    $INSERT I_F.AA.PAYMENT.SCHEDULE  ;* PACS00313556 - S/E

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

RETURN
*--------------------------------------------------------------------------------------------------------
*************
PROCESS.PARA:
*************
* This is the main processing para
    GOSUB GET.CAP.TOT.BALANCE
    GOSUB GET.INT.TOT.BALANCE
    GOSUB GET.INS.CHG.TOT.BALANCE

RETURN
*--------------------------------------------------------------------------------------------------------
********************
GET.CAP.TOT.BALANCE:
********************
*
    Y.BAL.TYPE = 'CURACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.CURACCOUNT = Y.BK.BALANCE

    Y.BAL.TYPE = 'DUEACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.DUEACCOUNT = Y.BK.BALANCE

    Y.BAL.TYPE = 'GRCACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.GRCACCOUNT = Y.BK.BALANCE

    Y.BAL.TYPE = 'DELACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.DELACCOUNT = Y.BK.BALANCE
* PACS00313556 - 2014NOV14 - Cristina's email - S
    Y.DE1ACCOUNT = ''
    Y.DE3ACCOUNT = ''
    Y.BAL.TYPE = 'DE1ACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.DE1ACCOUNT = Y.BK.BALANCE

    Y.BAL.TYPE = 'DE3ACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.DE3ACCOUNT = Y.BK.BALANCE
* PACS00313556 - 2014NOV14 - Cristina's email - E
    Y.BAL.TYPE = 'NABACCOUNT'
    GOSUB GET.BK.BALANCE
    Y.NABACCOUNT = Y.BK.BALANCE

    Y.CAP.TOT.BAL = Y.CURACCOUNT + Y.DUEACCOUNT + Y.GRCACCOUNT + Y.DELACCOUNT + Y.NABACCOUNT + Y.DE1ACCOUNT + Y.DE3ACCOUNT          ;* PACS00313556 - 2014NOV14 - Cristina's email - S/E
RETURN
*--------------------------------------------------------------------------------------------------------
********************
GET.INT.TOT.BALANCE:
********************
*
    Y.BAL.TYPE = 'DUEPRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.DUEPRINCIPALINT = Y.BK.BALANCE

    Y.BAL.TYPE = 'DELPRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.DELPRINCIPALINT = Y.BK.BALANCE
* PACS00313556 - 2014NOV14 - Cristina's email - S
    Y.DE1PRINCIPALINT = ''
    Y.DE3PRINCIPALINT = ''
    Y.BAL.TYPE = 'DE1PRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.DE1PRINCIPALINT = Y.BK.BALANCE

    Y.BAL.TYPE = 'DE3PRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.DE3PRINCIPALINT = Y.BK.BALANCE
* PACS00313556 - 2014NOV14 - Cristina's email - E
    Y.BAL.TYPE = 'GRCPRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.GRCPRINCIPALINT = Y.BK.BALANCE

    Y.BAL.TYPE = 'NABPRINCIPALINT'
    GOSUB GET.BK.BALANCE
    Y.NABPRINCIPALINT = Y.BK.BALANCE
* PACS00313556 - 2015MAR31 - Cristina's email - S
    Y.ACCPENALTINT = ''
    Y.BAL.TYPE = 'ACCPENALTINT'
    GOSUB GET.BK.BALANCE
    Y.ACCPENALTINT = Y.BK.BALANCE
* PACS00313556 - 2015MAR31 - Cristina's email - E
    Y.INT.TOT.BAL = Y.DUEPRINCIPALINT + Y.DELPRINCIPALINT + Y.GRCPRINCIPALINT + Y.NABPRINCIPALINT + Y.ACCPENALTINT + Y.DE1PRINCIPALINT + Y.DE3PRINCIPALINT        ;* PACS00313556 - 2015APR31 - Cristina's email - S/E
RETURN
*--------------------------------------------------------------------------------------------------------
************************
GET.INS.CHG.TOT.BALANCE:
************************
* PACS00313556 - 2014OCT10 - S
    ARR.ID      = AA.ARRANGEMENT.ID
* PACS00313556 - 2014OCT10 - E
    PROP.CLASS  = 'PAYMENT.SCHEDULE'
    EFF.DATE    = TODAY
    PROPERTY    = 'REPAYMENT.SCHEDULE'
    R.CONDITION = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual Conversion - modified CALL routine format

    PAY.SCH.LIST = R.CONDITION<AA.PS.PAYMENT.TYPE>

    Y.INS.TOT.BAL = 0
    Y.CHG.TOT.BAL = 0
    Y.INT.TOT.DUE = 0
    Y.PAY.TYPE    = ''
    Y.AMT.PS      = 0
    Y.PRP.PS      = ''

    I.VAR=1
    LOOP
        REMOVE Y.PAY.TYPE FROM PAY.SCH.LIST SETTING Y.PS.PT.POS
    WHILE Y.PAY.TYPE:Y.PS.PT.POS
        Y.AMT.PS = FIELD(R.CONDITION<AA.PS.ACTUAL.AMT>,@VM,I.VAR)
        Y.PRP.PS = FIELD(R.CONDITION<AA.PS.PROPERTY>,@VM,I.VAR)
        IF Y.PAY.TYPE EQ "INSURANCE" THEN   ;* Insurance type
            GOSUB GET.INSU.BAL      ;* PACS00313556 - 2014NOV14 - Cristina's email - S/E
        END
        IF Y.PAY.TYPE EQ "CARGOS" THEN      ;* Charges type
            GOSUB GET.CHRG.BAL      ;* PACS00313556 - 2014NOV14 - Cristina's email - S/E
        END
        I.VAR += 1
*
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
*************
GET.INSU.BAL:
*************

    Y.PREF = 'DUE':@VM:'DE1':@VM:'DE3':@VM:'DEL':@VM:'NAB' ; Y.CNT = DCOUNT(Y.PREF,@VM)
    Y.BAL = Y.PRP.PS ; Y.BAL.TYPE = ''
    Y.FLG.H = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        Y.FLG.H += 1
        Y.BAL.TYPE = Y.PREF<1,Y.FLG.H>:Y.BAL
        BALANCE.AMOUNT = ''
        CALL AA.GET.ECB.BALANCE.AMOUNT(Y.LINK.APP.ID, Y.BAL.TYPE, REQUEST.DATE, BALANCE.AMOUNT,RET.ERROR)
        Y.INS.TOT.BAL += ABS(BALANCE.AMOUNT)
        Y.CNT -= 1
    REPEAT
RETURN
*--------------------------------------------------------------------------------------------------------
*************
GET.CHRG.BAL:
*************

    Y.PREF = 'DUE':@VM:'DE1':@VM:'DE3':@VM:'DEL':@VM:'NAB' ; Y.CNT = DCOUNT(Y.PREF,@VM)
    Y.BAL = Y.PRP.PS ; Y.BAL.TYPE = ''
    Y.FLG.H = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        Y.FLG.H += 1
        Y.BAL.TYPE = Y.PREF<1,Y.FLG.H>:Y.BAL
        BALANCE.AMOUNT = ''
        CALL AA.GET.ECB.BALANCE.AMOUNT(Y.LINK.APP.ID, Y.BAL.TYPE, REQUEST.DATE, BALANCE.AMOUNT,RET.ERROR)
        Y.CHG.TOT.BAL += ABS(BALANCE.AMOUNT)
        Y.CNT -= 1
    REPEAT
RETURN
*--------------------------------------------------------------------------------------------------------
***************
GET.BK.BALANCE:
***************

    Y.LINK.APP.ID    = ACCOUNT.ID
    BALANCE.TO.CHECK = Y.BAL.TYPE
    DATE.OPTIONS     = ''
    EFFECTIVE.DATE   = TODAY
    DATE.OPTIONS<2>  = 'ALL'
    BALANCE.AMOUNT   = ''

    CALL AA.GET.PERIOD.BALANCES(Y.LINK.APP.ID, BALANCE.TO.CHECK, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")

    Y.BK.BALANCE = BAL.DETAILS<IC.ACT.BALANCE>

RETURN
*--------------------------------------------------------------------------------------------------------
END       ;* End of Prgram
