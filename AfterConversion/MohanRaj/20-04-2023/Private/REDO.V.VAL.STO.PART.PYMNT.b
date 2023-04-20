* @ValidationCode : MjoyNjM4NTU3ODM6Q3AxMjUyOjE2ODE5Nzc2NTQ1MjM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 20 Apr 2023 13:30:54
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
SUBROUTINE REDO.V.VAL.STO.PART.PYMNT
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : Martin
* Program Name : REDO.V.VAL.ARCIB.PART.PYMNT
*-----------------------------------------------------------------------------
* Description : This subroutine is attached to ARC loan payment version
* In Parameter : ENQ.DATA
* Out Parameter : None
*
**DATE           ODR                   DEVELOPER               VERSION
*
*26/04/12      PACS00184204          Prabhu N                  Modification
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     IF Condition Added,VM TO @VM,FM TO @FM
*20-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_System
    $INSERT I_CONTEXT.FLOW
    $INSERT I_F.REDO.APAP.STO.DUPLICATE



MAIN:

    GOSUB OPENFILES
    IF CF$NAV.OPERATION NE 'BACK' THEN
        GOSUB GET.ARR.DETAILS
        GOSUB GET.LOC.REF.DETAILS
        GOSUB VALIDATE.AMOUNT

    END
RETURN
OPENFILES:

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.APAP.STO.DUPLICATE = 'F.REDO.APAP.STO.DUPLICATE'
    F.REDO.APAP.STO.DUPLICATE  = ''
    CALL OPF(FN.REDO.APAP.STO.DUPLICATE,F.REDO.APAP.STO.DUPLICATE)


    APPLS = 'FUNDS.TRANSFER':@FM:'AA.PRD.DES.TERM.AMOUNT'
    F.FIELDS = 'L.NO.OF.INSTAL':@VM:'L.AA.PART.ALLOW':@VM:'L.ADV.INS.CNT':@VM:'L.FT.BIL.OVRDUE':@VM:'L.FT.INSTAL.AMT':@VM:'L.FT.MIN.AMOUNT':@FM:'L.AA.PART.ALLOW':@VM:'L.AA.PART.PCNT'
    POS.VAL = ''
    CALL MULTI.GET.LOC.REF(APPLS,F.FIELDS,POS.VAL)
    POS.NO.INS = POS.VAL<1,1>
    POS.PART.ALLW = POS.VAL<1,2>
    POS.ADV.INS = POS.VAL<1,3>
    POS.BIL.OVR = POS.VAL<1,4>
    POS.INS.AMT=POS.VAL<1,5>
    POS.PART.PAY.AMT=POS.VAL<1,6>
    POS.PART = POS.VAL<2,1>
    POS.PART.PERC = POS.VAL<2,2>

RETURN
****************
GET.ARR.DETAILS:
****************


    VAR.AA.ID = System.getVariable('CURRENT.CREDIT.ACCT.NO')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        VAR.AA.ID = ""
    END ;*R22 Auto code conversion-END
    IF VAR.AA.ID[1,2] NE 'AA' THEN
        CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        Y.CUS = R.ACCOUNT<AC.CUSTOMER>
    END
    PROP.CLASS='TERM.AMOUNT'
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(VAR.AA.ID,EFF.DATE,PROP.CLASS, PROPERTY,R.CONDITION,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    Y.PART.VAL = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART.ALLW>
    Y.PARTIAL = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART.PERC>
    Y.PART = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART>
    IF VAR.AA.ID[1,2] NE 'AA' THEN
        CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        Y.CUS = R.ACCOUNT<AC.CUSTOMER>
    END ELSE
        CALL F.READ(FN.AA.ARRANGEMENT,VAR.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARR.ERR)
        Y.CUS = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    END

RETURN

********************
GET.LOC.REF.DETAILS:
*********************
    CHECK.PART.FLG=''

    IF Y.PART EQ 'YES' OR Y.PART EQ 'SI' THEN
        CHECK.PART.FLG=1
    END

    Y.TOT.SETT.AMT= System.getVariable('CURRENT.ARR.AMT')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.TOT.SETT.AMT = ""
    END ;*R22 Auto code conversion-END
    Y.TOT.BILL.SETT.AMT=R.NEW(REDO.SO.CURRENT.AMOUNT.BAL)
    Y.BILL.OVERDUE.CNT= System.getVariable('CURRENT.UNP.BILL')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.BILL.OVERDUE.CNT = ""
    END ;*R22 Auto code conversion-END
    Y.PART.AMT.FR.PAY= System.getVariable('CURRENT.PART.AMT')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.PART.AMT.FR.PAY = ""
    END ;*R22 Auto code conversion-END

RETURN

***************
VALIDATE.AMOUNT:
***************

    IF Y.BILL.OVERDUE.CNT GT 1 THEN
        GOSUB PROCESS.OVERDUE
    END
    ELSE
        GOSUB PROCESS.DUE
    END
RETURN
************
PROCESS.DUE:
************
    IF NOT(CHECK.PART.FLG) THEN
        Y.PART.BILL.AMT = Y.TOT.SETT.AMT
    END
    ELSE
        Y.PART.BILL.AMT=Y.PART.AMT.FR.PAY
    END
    IF Y.TOT.BILL.SETT.AMT LT Y.PART.BILL.AMT THEN
        AF= REDO.SO.CURRENT.AMOUNT.BAL
        AV=''
        ETEXT='EB-REDO.LESS.PARTL.PYMT'
        CALL STORE.END.ERROR
    END
RETURN
****************
PROCESS.OVERDUE:
****************
    Y.TOT.BILL.LIST=System.getVariable('CURRENT.BILL.AMT')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.TOT.BILL.LIST = ""
    END ;*R22 Auto code conversion-END
    CHANGE'#' TO @FM IN Y.TOT.BILL.LIST
    Y.TOT.BILL.CNT =DCOUNT(Y.TOT.BILL.LIST,@FM)
    Y.PREV.DUE.AMT =Y.TOT.BILL.LIST<Y.TOT.BILL.CNT>
    Y.TOT.DUE.AMT  =SUM(Y.TOT.BILL.LIST)
    IF Y.TOT.BILL.SETT.AMT EQ Y.PREV.DUE.AMT OR Y.TOT.BILL.SETT.AMT GE Y.TOT.DUE.AMT ELSE
        AF= REDO.SO.CURRENT.AMOUNT.BAL
        AV=''
        ETEXT='EB-REDO.LESS.PARTL.PYMT'
        CALL STORE.END.ERROR
    END
RETURN
END
