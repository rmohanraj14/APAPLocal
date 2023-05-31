* @ValidationCode : MjotMTM4NTU2MTQ5MjpDcDEyNTI6MTY4NTUyOTYyNTQyODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:10:25
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
SUBROUTINE REDO.CHECK.ACCOUNTCLOSURE.AA

*---------------------------------------------------
* Description: This routine is input routine for account closure
* version to make sure that account cannot be closed (if it is a direct debit account of a loan) and also update the reason details
*
* Input  Arg  : N/A
* Output Arg  : N/A
* Linked With : ACCOUNT.CLOSURE,REDO.TELLER, ACCOUNT.CLOSURE,REDO.EN.LINEA
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE
* 29-MAR-2023    Conversion Tool      R22 Auto Conversion  - VM to @VM , FM to @FM ,SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - CALL method format changed
*---------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLOSURE
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM

    GOSUB OPEN.FILES
    GOSUB PROCESS
    GOSUB UPD.REASON
RETURN
*---------------------------------------------------
OPEN.FILES:
*---------------------------------------------------

    FN.REDO.DIRECT.DEBIT.ACCOUNTS = 'F.REDO.DIRECT.DEBIT.ACCOUNTS'
    F.REDO.DIRECT.DEBIT.ACCOUNTS = ''
    CALL OPF(FN.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM  = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    LOC.REF.APPLICATION='AA.PRD.DES.PAYMENT.SCHEDULE':@FM:'ACCOUNT.CLOSURE':@FM:'ACCOUNT'
    LOC.REF.FIELDS='L.AA.PAY.METHD':@VM:'L.AA.DEBT.AC':@FM:'L.AC.CAN.REASON'::@VM:'L.AC.OTH.REASON':@FM:'L.AC.CAN.REASON':@VM:'L.AC.OTH.REASON'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.PAY.METHD = LOC.REF.POS<1,1>
    POS.L.AA.DEBT.AC   = LOC.REF.POS<1,2>
    Y.L.AC.CAN.REASON.POS  = LOC.REF.POS<2,1>
    Y.L.AC.OTH.REASON.POS  = LOC.REF.POS<2,2>
    Y.L.AC.CAN.REASON.POS1 = LOC.REF.POS<3,1>
    Y.L.AC.OTH.REASON.POS1 = LOC.REF.POS<3,2>

RETURN
*---------------------------------------------------
PROCESS:
*---------------------------------------------------

    Y.ACCOUNT.CLOSE  = ID.NEW
    R.DD.ACCOUNTS = ''
    Y.ERROR.ARR = ''
    CALL F.READ(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.ACCOUNT.CLOSE,R.DD.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,DD.ERR)

    IF R.DD.ACCOUNTS ELSE
        RETURN
    END
    Y.NO.OF.ARR = DCOUNT(R.DD.ACCOUNTS,@FM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.ARR
        ARR.ID = R.DD.ACCOUNTS<Y.VAR1>
        Y.CHECK.ARRANGEMENT = ''

        GOSUB CHECK.DD

        CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ERR)
        Y.ARR.STATUS = R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>

        GOSUB CHECK.LOAN.STATUS

        IF Y.CHECK.ARRANGEMENT EQ 'YES' AND Y.FLAG THEN
*TUS AA Changes 20161021
*      IF Y.ARR.STATUS NE 'MATURED' AND Y.ARR.STATUS NE '' THEN
            IF Y.ARR.STATUS NE 'PENDING.CLOSURE' AND Y.ARR.STATUS NE 'CLOSE' AND Y.ARR.STATUS NE '' THEN
*TUS END
                Y.ERROR.ARR:=ARR.ID
                Y.VAR1 = Y.NO.OF.ARR+ 1 ;* Instead of break statement
            END
        END
        Y.VAR1 += 1    ;*R22 Auto Conversion
    REPEAT

    IF Y.ERROR.ARR THEN
        CURR.NO=DCOUNT(R.NEW(AC.ACL.CURR.NO),@VM) + 1
        TEXT = 'EB-REDO.ACCOUNT.CLOSE.DD'
        CALL STORE.OVERRIDE(CURR.NO)
        RETURN
    END
RETURN
*---------------------------------------------------
CHECK.DD:
*---------------------------------------------------
* To check whether it is a direct debit account for this the arrangement.

    EFF.DATE = ''
    PROP.CLASS='PAYMENT.SCHEDULE'
    PROPERTY = ''
    R.CONDITION = ''
    ERR.MSG = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion

    Y.PAY.METHOD       = R.CONDITION<AA.PS.LOCAL.REF,POS.L.AA.PAY.METHD>
    Y.DIRECT.DEBIT.ACC = R.CONDITION<AA.PS.LOCAL.REF,POS.L.AA.DEBT.AC>

    IF Y.PAY.METHOD EQ 'Direct Debit' AND Y.DIRECT.DEBIT.ACC EQ Y.ACCOUNT.CLOSE THEN
        Y.CHECK.ARRANGEMENT = 'YES'
    END
RETURN
*--------------------------------------------------------------
UPD.REASON:
*---------------------------------------------------------------
*This part has to update the reason values to account record
    Y.ID = ID.NEW
    Y.CAN.REASON = R.NEW(AC.ACL.LOCAL.REF)<1,Y.L.AC.CAN.REASON.POS>
    Y.OTH.REASON = R.NEW(AC.ACL.LOCAL.REF)<1,Y.L.AC.OTH.REASON.POS>
    CALL F.READ(FN.ACCOUNT,Y.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    IF R.ACCOUNT THEN
        R.ACCOUNT<AC.LOCAL.REF,Y.L.AC.CAN.REASON.POS1> = Y.CAN.REASON
        R.ACCOUNT<AC.LOCAL.REF,Y.L.AC.OTH.REASON.POS1> = Y.OTH.REASON
        CALL F.WRITE(FN.ACCOUNT,Y.ID,R.ACCOUNT)
    END
RETURN
*----------------------------------------------------------------
*---------------------------------------------------------------
* Check whether the Loan was cancelled
CHECK.LOAN.STATUS:

    Y.FLAG = 1
    Y.PRODUCT.GROUP.ID = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    Y.PAYOFF.ACTIVITY = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PAYOFF.ACTIVITY>
    Y.PAYOFF.ACTIVITY.CNT = DCOUNT(Y.PAYOFF.ACTIVITY,@VM)
    CALL F.READ(FN.AA.ACTIVITY.HISTORY, ARR.ID, R.AA.ACTIVITY.HISTORY, F.AA.ACTIVITY.HISTORY, ACT.ERR)
    Y.ACTIVITY.HISTORY        = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>
    Y.ACTIVITY.STATUS.HISTORY = R.AA.ACTIVITY.HISTORY<AA.AH.ACT.STATUS>
    CHANGE @SM TO @FM IN Y.ACTIVITY.HISTORY
    CHANGE @VM TO @FM IN Y.ACTIVITY.HISTORY
    CHANGE @SM TO @FM IN Y.ACTIVITY.STATUS.HISTORY
    CHANGE @VM TO @FM IN Y.ACTIVITY.STATUS.HISTORY

    Y.PAYOFF.POS = 1
    LOOP
    WHILE Y.PAYOFF.POS LE Y.PAYOFF.ACTIVITY.CNT
        Y.CANCEL.ACTIVITY = Y.PAYOFF.ACTIVITY<1,Y.PAYOFF.POS>
        LOCATE Y.CANCEL.ACTIVITY IN Y.ACTIVITY.HISTORY<1> SETTING POS.ACT THEN  ;* Here we are checking whether loan has payoff activity in auth stage. we are locating once cos the latest applypayment-rp.payoff is in AUTH stage(During payoff cheque reversal, we wont trigger applypayment-rp.payoff, So we can presume that applypayment-rp.payoff is in AUTH stage then loan is cancelled).

            IF Y.ACTIVITY.STATUS.HISTORY<POS.ACT> EQ 'AUTH' THEN
                Y.FLAG = 0    ;* Skip this loan.
            END
        END

        Y.PAYOFF.POS += 1    ;*R22 Auto Conversion
    REPEAT

RETURN

*---------------------------------------------------------------
END
