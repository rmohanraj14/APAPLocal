* @ValidationCode : MjotMjE2MDc0ODE0OkNwMTI1MjoxNjg1NTMxNzUzOTc0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:45:53
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
SUBROUTINE REDO.POST.RTN.OVERDUE
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.POST.RTN.OVERDUE
* ODR NO      : ODR-2009-10-0324
*----------------------------------------------------------------------
*DESCRIPTION: This is POST Routine for OVERDUE property class to raise
* penalty interest for overdue BILLS



*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: NA
*---------------------------------------------------------------------------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*16.08.2010  H GANESH     ODR-2009-10-0324  INITIAL CREATION
*-----------------------------------------------------------------------------------
*Modification History:
*Date           Who                 Reference                                     Descripition
* 29-03-2023  Conversion Tool     Auto R22 code conversion                 FM TO @FM, VM TO @VM,SM TO @SM
* 29-03-2023     Samaran T          Manual R22 code conversion               Package Name Added APAP.AA, CALL method format changed
*-------------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.ACCT.BALANCE.ACTIVITY
    $INSERT I_ACCOUNTING.HANDOFF
    $INSERT I_F.AA.INTEREST
    $INSERT I_AA.ACTION.CONTEXT
    $USING APAP.TAM
*   $INSERT I_AA.LOCAL.COMMON





    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    FN.ACCT.ACTIVITY='F.ACCT.BALANCE.ACTIVITY'
    F.ACCT.ACTIVITY=''
    CALL OPF(FN.ACCT.ACTIVITY,F.ACCT.ACTIVITY)

    FN.AA.INTEREST.ACCRUALS='F.AA.INTEREST.ACCRUALS'
    F.AA.INTEREST.ACCRUALS=''
    CALL OPF(FN.AA.INTEREST.ACCRUALS,F.AA.INTEREST.ACCRUALS)



RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    ARR.ID=c_aalocArrId
    GOSUB GET.OVERDUE
    Y.OVERDUE.STATUS= OVERDUE.CONDITION<AA.OD.OVERDUE.STATUS>
    Y.AGING.DAYS=OVERDUE.CONDITION<AA.OD.AGEING>
    Y.MOVE.BAL=OVERDUE.CONDITION<AA.OD.MOVE.BALANCE>
*  CHANGE VM TO FM IN Y.OVERDUE.STATUS
*  CHANGE VM TO FM IN Y.AGING.DAYS
*  CHANGE VM TO FM IN Y.MOVE.BAL
    CHANGE @SM TO @FM IN Y.OVERDUE.STATUS ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.AGING.DAYS ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.MOVE.BAL ;*AUTO R22 CODE CONVERSION

    LOCATE 'DEL' IN Y.OVERDUE.STATUS SETTING POS1 THEN
        Y.DEL.DAYS = Y.AGING.DAYS<POS1>
    END

    LOCATE 'GRC' IN Y.OVERDUE.STATUS SETTING POS2 THEN
        IF Y.MOVE.BAL<POS2> EQ 'NO' THEN
            Y.BAL.FIELD='DUE'
        END ELSE
            Y.BAL.FIELD='GRC'
        END
    END ELSE
        Y.BAL.FIELD='DUE'
    END

    GOSUB CALC.BALANCE
    GOSUB GET.INTEREST
    GOSUB RAISE.ACCOUNTING

RETURN
*----------------------------------------------------------------------
GET.OVERDUE:
*----------------------------------------------------------------------
    EFF.DATE = ''
    PROP.CLASS='OVERDUE'
    PROPERTY = ''
    OVERDUE.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,OVERDUE.CONDITION,ERR.MSG);* R22 Manual conversion
RETURN
*----------------------------------------------------------------------
CALC.BALANCE:
*----------------------------------------------------------------------
    APAP.TAM.redoConvertAccount(IN.ACC.ID,ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion

*TUS change START
*   SEL.CMD='SSELECT ':FN.ACCT.ACTIVITY:' WITH @ID LIKE ':OUT.ID:'.':Y.BAL.FIELD:'ACCOUNT...'
    SEL.CMD='SSELECT ':FN.ACCT.ACTIVITY:' WITH @ID LIKE ':OUT.ID:'...'
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)
    Y.ACCT.ID=SEL.LIST<SEL.NOR>
    Y.BALANCE = Y.BAL.FIELD:'ACCOUNT'
    CALL F.READ(FN.ACCT.ACTIVITY,Y.ACCT.ID,R.ACCT.BAL.ACTIVITY,F.ACCT.ACTIVITY,ACCT.ERR)
    R.ACCT.ACTIVITY  = ''
    R.ACCT.ACTIVITY.TEMP = ''
    R.ACCT.BAL.ACTIVITY = ''

    ACCT.ACTIVITY.ER = ''
    CALL F.READ(FN.ACCT.ACTIVITY,Y.ACCT.ID,R.ACCT.BAL.ACTIVITY,F.ACCT.ACTIVITY,ACCT.ACTIVITY.ER)
    IF R.ACCT.BAL.ACTIVITY THEN
        LOCATE Y.BALANCE IN R.ACCT.BAL.ACTIVITY<1, 1> SETTING BALANCE.TYPE.POS THEN
            R.ACCT.ACTIVITY.TEMP = R.ACCT.BAL.ACTIVITY<2, BALANCE.TYPE.POS>
            R.ACCT.ACTIVITY=RAISE(RAISE(R.ACCT.ACTIVITY.TEMP))
        END
    END

*TUS change END
    Y.BALANCE=R.ACCT.ACTIVITY<IC.ACT.BALANCE>
    Y.BALANCE.CNT=DCOUNT(Y.BALANCE,@VM) ;*AUTO R22 CODE CONVERSION
    Y.BAL.AMT=ABS(Y.BALANCE<1,Y.BALANCE.CNT>)
RETURN
*----------------------------------------------------------------------
GET.INTEREST:
*----------------------------------------------------------------------
    EFF.DATE = ''
    PROP.CLASS='INTERST'
    PROPERTY = 'PENALTYINT'
    INTEREST.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,INTEREST.CONDITION,ERR.MSG);* R22 Manual conversion
    Y.DAY.BASIS=INTEREST.CONDITION<AA.INT.DAY.BASIS>
    IF Y.DAY.BASIS EQ 'A' OR Y.DAY.BASIS EQ 'B' THEN
        Y.CALC.DAYS='360'
    END
    IF Y.DAY.BASIS EQ 'C' OR Y.DAY.BASIS EQ 'D' THEN
        Y.CALC.DAYS='366'
    END
    IF Y.DAY.BASIS EQ 'E' OR Y.DAY.BASIS EQ 'F' THEN
        Y.CALC.DAYS='365'
    END




    Y.EFF.RATE=INTEREST.CONDITION<AA.INT.EFFECTIVE.RATE,1>
    IF Y.EFF.RATE EQ '' THEN
        Y.FLOAT.INDEX=INTEREST.CONDITION<AA.INT.FLOATING.INDEX,1>
        Y.CURRENCY=c_aalocArrCurrency
        Y.BASIC.ID=Y.FLOAT.INDEX:Y.CURRENCY:TODAY
        CALL EB.GET.INTEREST.RATE(Y.BASIC.ID,BASIC.RATE)

        Y.MARGIN.RATE=INTEREST.CONDITION<AA.INT.MARGIN.RATE,1,1>
        Y.MARGIN.OPER=INTEREST.CONDITION<AA.INT.MARGIN.OPER,1,1>

        IF Y.MARGIN.OPER EQ 'ADD' THEN
*	BASIC.RATE=BASIC.RATE+Y.MARGIN.RATE
            BASIC.RATE += Y.MARGIN.RATE ;*AUTO R22 CODE CONVERSION
        END
        IF Y.MARGIN.OPER EQ 'SUB' THEN
*	BASIC.RATE=BASIC.RATE-Y.MARGIN.RATE
            BASIC.RATE -= Y.MARGIN.RATE ;*AUTO R22 CODE CONVERSION
        END
        IF Y.MARGIN.OPER EQ 'MULTIPLY' THEN
            BASIC.RATE=BASIC.RATE*Y.MARGIN.RATE
        END
        Y.PENAL.AMT=(Y.BAL.AMT*BASIC.RATE*Y.DEL.DAYS)/(100*Y.CALC.DAYS)
    END ELSE
        Y.PENAL.AMT=(Y.BAL.AMT*Y.EFF.RATE*Y.DEL.DAYS)/(100*Y.CALC.DAYS)
    END


RETURN

*----------------------------------------------------------------------
RAISE.ACCOUNTING:
*----------------------------------------------------------------------

    LIFECYLE.STATUS = 'ACC'   ;* Accrued
    PROPERTY='PENALTYINT'
* TUS START - AA.PROPERTY.GET.BALANCE.NAME - API changes - ARRANGEMENT.ID & CHARGEOFF.TYPE
    CHARGEOFF.TYPE = ''
    CALL AA.PROPERTY.GET.BALANCE.NAME(ARR.ID,PROPERTY, LIFECYLE.STATUS, "", CHARGEOFF.TYPE, BALANCE.TYPE)
* TUS END
    ACCT.EVENT.ARRAY=''
    IF c_aalocActivityStatus EQ 'UNAUTH' THEN
        ACCT.TYPE='VAL'
    END
    IF c_aalocActivityStatus EQ 'AUTH' THEN
        ACCT.TYPE='AUT'
    END
    SIGN="DEBIT"
    EVENT.LIST = 'CURRENT.MONTH':@VM:'PREVIOUS.MONTH':@VM:'PREVIOUS.YEAR' ;*AUTO R22 CODE CONVERSION
    COMMITTED.INT=Y.PENAL.AMT:@FM:'':@FM:'' ;*AUTO R22 CODE CONVERSION
    EVENT.SPLIT = DCOUNT(EVENT.LIST,@VM) ;*AUTO R22 CODE CONVERSION
    VAR1=1
    LOOP
    WHILE VAR1 LE EVENT.SPLIT
        EVENT.AMT = COMMITTED.INT<VAR1>
        GOSUB PROCESS.EVENTS
        VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
    IF ACCT.EVENT.ARRAY THEN

        CALL AA.ACCOUNTING.MANAGER(ACCT.TYPE, "PENALTYINT", "ACCRUE", "", ACCT.EVENT.ARRAY, RET.ERROR)

    END
RETURN
*----------------------------------------------------------------------
PROCESS.EVENTS:
*----------------------------------------------------------------------
    IF EVENT.AMT THEN
        EVENT.ARRAY<E_EVENT.TYPE> = EVENT.LIST<1,VAR1>
        EVENT.ARRAY<E_AMOUNT> = EVENT.AMT
        EVENT.ARRAY<E_SIGN> = SIGN
        EVENT.ARRAY<E_BALANCE.TYPE> = BALANCE.TYPE
        EVENT.ARRAY<E_VALUE.DATE> = TODAY
        ACCT.EVENT.ARRAY<-1> = LOWER(EVENT.ARRAY)
        EVENT.ARRAY = ''
    END
RETURN

END
