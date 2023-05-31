* @ValidationCode : MjotMTg2NDY1NDk0NjpDcDEyNTI6MTY4NTUzMTM4NzU1OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:39:47
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
SUBROUTINE REDO.POST.DEAL.SLIP
*---------------------------------------------------------
* Description: This is a Post routine for Lending-Change-Principalint activity
* to produce a deal slip @ auth level
* In Param  : NA
* Out Param : NA

*--------------------------------------------------------------------------------
*Modification History:
*   DATE            WHO           REFERENCE                  DESCRIPTION
* 05-Sep-2011      H Ganesh      PACS00113076 - B.16         Initial Draft
* 08-May-2017      D Edwin Charles PACS00585816              Changes in post routins
*----------------------------------------------------------------------------------
*Modification History:
*Date           Who                     Reference                                  Descripition
* 29-03-2023  Conversion Tool    Auto R22 code conversion                 FM TO @FM , VM TO @VM, SM TO @SM
* 29-03-2023     Samaran T       Manual R22 code conversion                Package Name Added APAP.AA, CALL method format changed
*-------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.CUSTOMER
    $INSERT I_F.OFS.SOURCE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.EB.SECURE.MESSAGE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.OVERRIDE
    $INSERT I_F.REDO.ISSUE.EMAIL
    $INSERT I_F.REDO.APAP.PARAM.EMAIL
    $INSERT I_F.REDO.RATE.CHANGE.MESSAGE
    $USING APAP.TAM
    Y.EFFECTIVE.DATE = c_aalocActivityEffDate
    Y.ARR.ID         = c_aalocArrId

    IF c_aalocActivityStatus EQ 'AUTH' AND c_aalocPropClassId EQ 'INTEREST' AND c_aalocPropertyId EQ 'PRINCIPALINT' THEN          ;* Mail needs to triggered only when lending-change-principalint
        IF c_aalocArrangementRec<AA.ARR.ARR.STATUS> EQ 'CURRENT' THEN ;* Only Loan that are disbursed needs to sent mail - PACS00180420 - B.16
            IF R.NEW(AA.INT.EFFECTIVE.RATE) NE R.OLD(AA.INT.EFFECTIVE.RATE) AND c_aalocArrActivityId EQ c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA> THEN       ;* Mail needs to generated only when rate changes and also it should during RR.
                GOSUB OPEN.FILES
                LOCATE 'FIXED.RATE' IN R.NEW(AA.INT.CHANGED.FIELDS)<1,1>  SETTING POS.YES THEN
*fixed rate in CHANGED FIELDS MEANS THAT A RATE CHANGE OCUR
                    CALL OCOMO("R.NEW(AA.INT.CHANGED.FIELDS) ":R.NEW(AA.INT.CHANGED.FIELDS))
                    GOSUB POST.OFS
                END
            END
        END
    END

    IF c_aalocActivityStatus MATCHES  'UNAUTH':@VM:'UNAUTH-CHG' AND c_aalocPropClassId EQ 'INTEREST' AND c_aalocArrActivityId EQ c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA> THEN   ;* It should be executed during RR.
        IF R.NEW(AA.INT.EFFECTIVE.RATE) NE R.OLD(AA.INT.EFFECTIVE.RATE) THEN
            GOSUB OPEN.FILES
            GOSUB UPDATE.RATE.DETAILS
        END
    END

*Following lines are commented since we are going to update the observation field from REDO.AA.SCHEDULE + REDO.GET.NEXT.PAYMENT.AMOUNT
*IF c_aalocActivityStatus EQ 'AUTH' AND c_aalocPropClassId EQ 'PAYMENT.SCHEDULE' THEN
*GOSUB OPEN.FILES
*GOSUB UPDATE.RATE.DETAILS.REMAINING
*END
RETURN
*---------------------------------------------------------
OPEN.FILES:
*---------------------------------------------------------

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER  = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.REDO.APAP.PARAM.EMAIL = 'F.REDO.APAP.PARAM.EMAIL'
    F.REDO.APAP.PARAM.EMAIL = ''
    CALL OPF(FN.REDO.APAP.PARAM.EMAIL,F.REDO.APAP.PARAM.EMAIL)

    FN.REDO.ISSUE.EMAIL = 'F.REDO.ISSUE.EMAIL'
    F.REDO.ISSUE.EMAIL = ''
    CALL OPF(FN.REDO.ISSUE.EMAIL,F.REDO.ISSUE.EMAIL)

    FN.REDO.NOTIFY.RATE.CHANGE = 'F.REDO.NOTIFY.RATE.CHANGE'
    F.REDO.NOTIFY.RATE.CHANGE = ''
    CALL OPF(FN.REDO.NOTIFY.RATE.CHANGE,F.REDO.NOTIFY.RATE.CHANGE)

    FN.REDO.RATE.CHANGE.MESSAGE = 'F.REDO.RATE.CHANGE.MESSAGE'
    F.REDO.RATE.CHANGE.MESSAGE = ''
    CALL OPF(FN.REDO.RATE.CHANGE.MESSAGE,F.REDO.RATE.CHANGE.MESSAGE)


    LOC.REF.APPLICATION="AA.PRD.DES.INTEREST"
    LOC.REF.FIELDS='L.INT.OBSERVE':@VM:'L.AA.POOL.RATE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.INT.RT.AR = LOC.REF.POS<1,1>
    POS.POOL.RTE = LOC.REF.POS<1,2>

RETURN
*---------------------------------------------------------
PROCESS:
*---------------------------------------------------------

    CALL F.READ(FN.REDO.RATE.CHANGE.MESSAGE,'EMAIL',R.MESSAGE.EMAIL,F.REDO.RATE.CHANGE.MESSAGE,MSG.ERR)
    CALL F.READ(FN.REDO.RATE.CHANGE.MESSAGE,'ARCIB',R.MESSAGE.ARCIB,F.REDO.RATE.CHANGE.MESSAGE,MSG.ERR)

    OFS.REQ.MSG.FINAL = ''
    Y.SUBJECT.EMAIL  = R.MESSAGE.EMAIL<REDO.RT.MSG.SUBJECT>
    Y.SUBJECT.ARCIB  = R.MESSAGE.ARCIB<REDO.RT.MSG.SUBJECT>
    Y.OLD.INT.RATE   = TRIMB(FMT(R.OLD(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))
    Y.NEW.INT.RATE   = TRIMB(FMT(R.NEW(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))

    IN.ACC.ID = ''

    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion
    APAP.TAM.redoGetNextPaymentAmount(Y.ARR.ID,Y.EFFECTIVE.DATE,Y.NEXT.PAY.AMT);* R22 Manual conversion

    Y.NEXT.PAY.AMT = TRIMB(FMT(Y.NEXT.PAY.AMT,'L2,#19'))
    Y.ADD.VALUE = Y.EFFECTIVE.DATE[7,2]:'/':Y.EFFECTIVE.DATE[5,2]:'/':Y.EFFECTIVE.DATE[3,2]:@FM:OUT.ID:@FM:Y.OLD.INT.RATE:@FM:Y.NEW.INT.RATE:@FM:Y.NEXT.PAY.AMT
    Y.MSG.ARCIB = R.MESSAGE.ARCIB<REDO.RT.MSG.MESSAGE.BODY>
    Y.ORD.ARCIB = R.MESSAGE.ARCIB<REDO.RT.MSG.DATA.ORDER>
    Y.MSG.EMAIL = R.MESSAGE.EMAIL<REDO.RT.MSG.MESSAGE.BODY>
    Y.ORD.EMAIL = R.MESSAGE.EMAIL<REDO.RT.MSG.DATA.ORDER>
    APAP.TAM.redoFormatMessage(Y.MSG.ARCIB,Y.ORD.ARCIB,Y.ADD.VALUE,Y.FMT.MSG.ARCIB);* R22 Manual conversion
    APAP.TAM.redoFormatMessage(Y.MSG.EMAIL,Y.ORD.EMAIL,Y.ADD.VALUE,Y.FMT.MSG.EMAIL);* R22 Manual conversion
    CHANGE @VM TO ' ' IN Y.FMT.MSG.EMAIL
    GOSUB GET.MAIL.IDS
    IF Y.EMAIL.IDS THEN
        GOSUB SEND.EMAIL
    END
    GOSUB UPDATE.CONCAT
    GOSUB UPDATE.RATE.DETAILS.REMAINING

RETURN
*----------------------------------------------------------------------
ARCIB.SECURE.MESSAGE:
*----------------------------------------------------------------------

    R.SEC.MSG<EB.SM.TO.CUSTOMER> = Y.CUS.ID
    R.SEC.MSG<EB.SM.SUBJECT>     = Y.SUBJECT.ARCIB
    R.SEC.MSG<EB.SM.MESSAGE>     = Y.FMT.MSG.ARCIB

    OFS.SOURCE.ID            = 'REDO.OFS.AZ.UPDATE'
    APPLICATION.NAME         = 'EB.SECURE.MESSAGE'
    TRANS.FUNC.VAL           = 'I'
    TRANS.OPER.VAL           = 'PROCESS'
    APPLICATION.NAME.VERSION = 'EB.SECURE.MESSAGE,OFS'
    NO.AUT                   = '0'
    OFS.MSG.ID               = ''
    APPLICATION.ID           = ''
    OFS.POST.MSG             = ''
    OFS.ERR                  = ''
    CALL OFS.BUILD.RECORD(APPLICATION.NAME,TRANS.FUNC.VAL,TRANS.OPER.VAL,APPLICATION.NAME.VERSION,"",NO.AUT,APPLICATION.ID,R.SEC.MSG,OFS.REQ.MSG)

    OFS.REQ.MSG.FINAL<-1> = OFS.REQ.MSG

RETURN
*----------------------------------------------------------------------
UPDATE.CONCAT:
*----------------------------------------------------------------------
    R.ARR = ''
    CALL F.READ(FN.REDO.NOTIFY.RATE.CHANGE,Y.ARR.ID,R.ARR,F.REDO.NOTIFY.RATE.CHANGE,NOT.ERR)
    R.ARR<1> = Y.FMT.MSG.EMAIL
    R.ARR<2> = Y.EFFECTIVE.DATE
    R.ARR<3> = Y.OLD.INT.RATE
    R.ARR<4> = Y.NEW.INT.RATE
    R.ARR<5> = Y.NEXT.PAY.AMT
    R.ARR<6> = OPERATOR
    CALL F.WRITE(FN.REDO.NOTIFY.RATE.CHANGE,Y.ARR.ID,R.ARR)

RETURN
*----------------------------------------------------------------------
GET.MAIL.IDS:
*----------------------------------------------------------------------

    Y.EMAIL.IDS = ''
    EFF.DATE    = ''
    PROP.CLASS  = 'CUSTOMER'
    R.CUST.COND = ''
    ERR.MSG     = ''
    Y.PROPERTY  = ''
    APAP.AA.redoCrrGetConditions(Y.ARR.ID,EFF.DATE,PROP.CLASS,Y.PROPERTY,R.CUST.COND,ERR.MSG);* R22 Manual conversion

*Y.OWNER       = R.CUST.COND<AA.CUS.OWNER>
    Y.OWNER       = R.CUST.COND<AA.CUS.CUSTOMER>;*R22 Manual conversion
    Y.OTHER.PARTY = R.CUST.COND<AA.CUS.OTHER.PARTY>
    Y.DEBTORS = Y.OWNER:@VM:Y.OTHER.PARTY

    Y.DEBT.CNT =  DCOUNT(Y.DEBTORS,@VM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.DEBT.CNT
        Y.CUS.ID = Y.DEBTORS<1,Y.VAR1>
        IF Y.CUS.ID THEN
            CALL F.READ(FN.CUSTOMER,Y.CUS.ID,R.CUS,F.CUSTOMER,CUS.ERR)
            Y.EMAIL.IDS<1,-1> = R.CUS<EB.CUS.EMAIL.1>
            GOSUB ARCIB.SECURE.MESSAGE
        END
        Y.VAR1 += 1
    REPEAT

    CALL OFS.POST.MESSAGE(OFS.REQ.MSG.FINAL,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
    CHANGE @VM TO ',' IN Y.EMAIL.IDS

RETURN
*----------------------------------------------------------------------
SEND.EMAIL:
*----------------------------------------------------------------------

    CALL CACHE.READ(FN.REDO.APAP.PARAM.EMAIL,'SYSTEM',R.EMAIL,MAIL.ERR)
    Y.FILE.PATH = R.EMAIL<REDO.PRM.MAIL.IN.PATH.MAIL>
    CALL ALLOCATE.UNIQUE.TIME(UNIQUE.TIME)

    FILENAME = UNIQUE.TIME
    FN.HRMS.FILE = ''
    OPEN Y.FILE.PATH TO FN.HRMS.FILE THEN
    END ELSE
        RETURN
    END

    CALL CACHE.READ(FN.REDO.ISSUE.EMAIL,'SYSTEM',R.REDO.ISSUE.EMAIL,MAIL.ERR)
    BK.MAIL.ID  = R.REDO.ISSUE.EMAIL<ISS.ML.MAIL.ID>
    Y.FROM.MAIL = BK.MAIL.ID
    Y.TO.MAIL   = Y.EMAIL.IDS
    Y.BODY      = Y.FMT.MSG.EMAIL
    RECORD      = Y.FROM.MAIL:"#":Y.TO.MAIL:"#":Y.SUBJECT.EMAIL:"#":Y.BODY
    WRITE RECORD TO FN.HRMS.FILE,FILENAME

RETURN
*----------------------------------------------------------------------
UPDATE.RATE.DETAILS:
*----------------------------------------------------------------------
    Y.CURR.PROPERTY = c_aalocPropertyId
    IF Y.CURR.PROPERTY EQ 'PRINCIPALINT' THEN
        Y.OLD.PAYMENT.AMOUNT = 0
        APAP.TAM.redoGetNextPaymentAmountOld(Y.ARR.ID,Y.EFFECTIVE.DATE,Y.OLD.PAYMENT.AMOUNT);* R22 Manual conversion
        Y.OLD.INT.RATE   = TRIMB(FMT(R.OLD(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))
        Y.NEW.INT.RATE   = TRIMB(FMT(R.NEW(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.RT.AR> = 'Cambio de Tasa (de ':Y.OLD.INT.RATE:' a ':Y.NEW.INT.RATE:')'

*  :', Valor de la Cuota (de ':TRIMB(FMT(Y.OLD.PAYMENT.AMOUNT,'L2#19'))
    END
    IF Y.CURR.PROPERTY EQ 'PENALTINT' THEN
        Y.OLD.INT.RATE   = TRIMB(FMT(R.OLD(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))
        Y.NEW.INT.RATE   = TRIMB(FMT(R.NEW(AA.INT.EFFECTIVE.RATE)<1,1>,'L2,#10'))
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.RT.AR> = 'Cambio de Tasa (de ':Y.OLD.INT.RATE:' a ':Y.NEW.INT.RATE:')'
    END

RETURN
*----------------------------------------------------------------------
UPDATE.RATE.DETAILS.REMAINING:
*----------------------------------------------------------------------

    Y.NEW.PAYMENT.AMOUNT = Y.NEXT.PAY.AMT
    Y.OLD.PAYMENT.AMOUNT = 0
    APAP.TAM.redoGetNextPaymentAmountOld(Y.ARR.ID,Y.EFFECTIVE.DATE,Y.OLD.PAYMENT.AMOUNT);*R22 Manual conversion
    Y.INT.DETAIL         = R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.RT.AR,1>
    R.CONDITION.INTEREST = ''
    R.CONDITION.INTEREST<AA.INT.LOCAL.REF,POS.L.AA.INT.RT.AR,1> = Y.INT.DETAIL

    GOSUB POST.OFS

RETURN
*-----------------------------
POST.OFS:
*-----------------------------
    Y.INT.DETAIL         = R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.RT.AR,1>
    R.CONDITION.INTEREST<AA.INT.LOCAL.REF,POS.L.AA.INT.RT.AR,1> = Y.INT.DETAIL
    Y.PROP.ACTIVITY<1> = 'PRINCIPALINT'
    IF c_aalocPropertyId EQ 'PRINCIPALINT' THEN
        Y.PROP.ACTIVITY<2> = 'REDO.PRINT.OBSERVE'
    END
    IF c_aalocPropertyId EQ 'PENALTINT' THEN
        Y.PROP.ACTIVITY<2> = 'REDO.PENINT.OBSERVE'
    END

    APAP.AA.redoAaBuildOfs(c_aalocArrId,R.CONDITION.INTEREST,Y.PROP.ACTIVITY,OFS.MSG);* R22 Manual conversion

    OFS.SRC = 'AA.INT.UPDATE'
    OPTIONS = ''
    OFS.STRING.FINAL = ''
    OFS.STRING.FINAL:=OFS.MSG:"EFFECTIVE.DATE:1:1=":TODAY   ;* Changed from effective date to TODAY's date to avoid RR
    CALL OFS.POST.MESSAGE(OFS.STRING.FINAL,OFS.MSG.ID,OFS.SRC,OPTIONS)

RETURN
END
