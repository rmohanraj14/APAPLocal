* @ValidationCode : Mjo0NzYyNjQyOTM6Q3AxMjUyOjE2ODU1Mjk2NTU3Njg6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:10:55
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
SUBROUTINE REDO.CHECK.SUSPENSION

* This routine does the following:
*
*   1. If Arrangement is in NAB, then triggers LENDING-SUSPEND-ARRANGEMENT
*
*   2. If Arrangement is moved out of NAB, then triggers LENDING-RESUME-ARRANGEMENT
*
*
* Activity API Setup:
*
* ACTIVITY : LENDING-UPDATE-OD.STATUS
* WHEN     : POST ROUTINE
* PROPERTY : ACCOUNT
* ACTION   : MAINTAIN
*
*
* Input/Output:
*----------------
*
* IN  : -NA-
* OUT : -NA-
*---------------
*
*----------------------------------------------------------------------------------------------------------------------------
*
* Modification History
*
*----------------------------------------------------------------------------------------------------------------------------
*   Date               |           Who                    |           Reference                    |          Description
*----------------------------------------------------------------------------------------------------------------------------
*
*  Apr-12                      Ravikiran AV                      ODR-2012-01-0106 (CR-44)                    Zero Principal
*
* 29-MAR-2023  Conversion Tool             R22 Auto Conversion  - VM to @VM , FM to @FM and insert file commentted I_F.AA.ACCOUNT.DETAILS
* 29-MAR-2023      Harsha                R22 Manual Conversion -  CALL method format changed
*----------------------------------------------------------------------------------------------------------------------------
*
* All file INSERTS done here

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_AA.APP.COMMON
*   $INSERT I_F.AA.ACCOUNT.DETAILS           ;*R22 Auto Conversion
    $INSERT I_F.REDO.LOAN.ACCOUNT.STATUS
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $USING APAP.TAM
*----------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
MAIN.LOGIC:



    IF (c_aalocActivityStatus EQ 'UNAUTH') THEN     ;* Its enough to trigger secondary activity in INAU status alone. PACS00320182.

        GOSUB INITIALISE

        GOSUB PROCESS

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Initialise all the variables
*
INITIALISE:



    R.ACCOUNT.DETAILS = c_aalocAccountDetails

    ARR.ID = c_aalocArrId

    ARR.EFF.DATE = c_aalocAccountDetails<AA.AD.START.DATE>

    R.ACCOUNT.ID = c_aalocLinkedAccount

    AGING.STATUS = ''

    LOC.REF.FIELDS = 'L.OD.STATUS':@VM:'L.LOAN.STATUS'

    LOC.REF.APP = 'AA.ARR.ACCOUNT'

    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APP, LOC.REF.FIELDS, LOC.REF.POS)

    L.OD.STATUS.POS   = LOC.REF.POS<1,1>
    POS.L.LOAN.STATUS = LOC.REF.POS<1,2>

    GOSUB OPEN.FILES

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* List of Open Files
*
OPEN.FILES:

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.AA.ACT.HIS = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACT.HIS = ''
    CALL OPF(FN.AA.ACT.HIS,F.AA.ACT.HIS)

    FN.REDO.LOAN.ACCOUNT.STATUS = 'F.REDO.LOAN.ACCOUNT.STATUS'
    F.REDO.LOAN.ACCOUNT.STATUS = ''
    CALL OPF(FN.REDO.LOAN.ACCOUNT.STATUS,F.REDO.LOAN.ACCOUNT.STATUS)
    CALL F.READ(FN.REDO.LOAN.ACCOUNT.STATUS,'Write-off',R.REDO.LOAN.ACCOUNT.STATUS,F.REDO.LOAN.ACCOUNT.STATUS,AC.LOAN.ERR)
    Y.WRITE.OFF.STATUS = R.REDO.LOAN.ACCOUNT.STATUS<REDO.LN.AC.ST.CONSOL.KEY.VAL>

    CALL F.READ(FN.REDO.LOAN.ACCOUNT.STATUS,'JudicialCollection',R.REDO.LOAN.ACCOUNT.STATUS,F.REDO.LOAN.ACCOUNT.STATUS,AC.LOAN.ERR)
    Y.JUD.STATUS = R.REDO.LOAN.ACCOUNT.STATUS<REDO.LN.AC.ST.CONSOL.KEY.VAL>

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Processing Logic
*
PROCESS:

    GOSUB CHECK.ACTIVITY

    IF (MASTER.ACTIVITY.TYPE NE 'NEW') THEN         ;*Dont check aging for a NEW arrangement activity

        GOSUB GET.PREVIOUS.LOAN.STATUS

        GOSUB GET.CURRENT.LOAN.STATUS

        GOSUB CHECK.AGING

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Check whether the Master activity is a NEW arrangment activity
*
CHECK.ACTIVITY:

    MASTER.ACTIVITY = c_aalocMasterActivity<1,4,AA.ARR.ACT.ACTIVITY.CLASS>

    MASTER.ACTIVITY.TYPE = FIELD(MASTER.ACTIVITY,'-',2)

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Get the previous Loan Status
*
GET.PREVIOUS.LOAN.STATUS:

    CALL AA.GET.PREVIOUS.PROPERTY.RECORD("", 'ACCOUNT', AA$ARR.PC.ID, '', R.PREV.PROP.REC, RET.ERR)

    PREV.LOAN.STATUS = R.PREV.PROP.REC<AA.AC.LOCAL.REF,L.OD.STATUS.POS>

    APAP.TAM.redoGetOverduePosition(ARR.ID,PREV.LOAN.STATUS, PREV.POS, OD.COUNT)   ;* Get the Previous OD postion, R22 Manual conversion

RETURN

*----------------------------------------------------------------------------------------------------------------------------
* Get the Current Loan Status
*
GET.CURRENT.LOAN.STATUS:

    CURRENT.LOAN.STATUS = R.NEW(AA.AC.LOCAL.REF)<1,L.OD.STATUS.POS>

    APAP.TAM.redoGetOverduePosition(ARR.ID, CURRENT.LOAN.STATUS, CUR.POS, OD.COUNT);*Get the Current OD postion, R22 Manual conversion

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Check Aging status
*
CHECK.AGING:
    CURRENT.L.LOAN.STATUS = R.NEW(AA.AC.LOCAL.REF)<1,POS.L.LOAN.STATUS>
    BEGIN CASE

        CASE (PREV.POS LT CUR.POS) AND (CUR.POS EQ OD.COUNT)      ;* Current Arrangement OD Status is NAB, Suspend it
*CALL F.READ(FN.AA.ACT.HIS,ARR.ID,R.AA.ACT.HIS,F.AA.ACT.HIS,HIS.ERR)

            GOSUB CHECK.ALREADY.SUSP
            NEW.ACTIVITY.ID = 'LENDING-SUSPEND-ARRANGEMENT'
            IF Y.SUSP EQ '' THEN
                GOSUB TRIGGER.ACTIVITY
            END ELSE
                TEXT = 'REDO.INTERNAL.MSG':@FM:" - Suspend has been skipped  - ":Y.SUSP
                CALL STORE.OVERRIDE("")
            END

        CASE (PREV.POS GT CUR.POS) AND (PREV.POS EQ OD.COUNT) AND CURRENT.L.LOAN.STATUS NE Y.WRITE.OFF.STATUS AND CURRENT.L.LOAN.STATUS NE Y.JUD.STATUS     ;* Current Arrangement OD status is out of NAB, Post P&L
            NEW.ACTIVITY.ID = 'LENDING-RESUME-ARRANGEMENT'
            GOSUB TRIGGER.ACTIVITY

        CASE (PREV.POS EQ OD.COUNT) AND (CUR.POS EQ OD.COUNT)     ;* Do Nothing, Arrangement Already Suspended
            RETURN

        CASE 1  ;* Do Nothing, Arrangement Not Yet Suspended
            RETURN

    END CASE

RETURN

CHECK.ALREADY.SUSP:
*------------------------------------------------------------------
* Check in AA.ACCOUNT.DETAILS whether loan is already suspended else SUSPEND the loan.

    IF c_aalocAccountDetails<AA.AD.SUSPENDED> EQ 'YES' THEN
        Y.SUSP = 'Y'
    END ELSE
        Y.SUSP = ''
    END


*Y.ACSTS = R.AA.ACT.HIS<AA.AH.ACTIVITY> ; Y.ACSTS = CHANGE(Y.ACSTS,SM,VM)
*Y.ACT.STS = R.AA.ACT.HIS<AA.AH.ACT.STATUS> ; Y.ACT.STS = CHANGE(Y.ACT.STS,SM,VM)
*Y.VMC.CNT = DCOUNT(Y.ACSTS,VM) ; Y.SUSP = ''
*LOOP
*WHILE Y.VMC.CNT GT 0 DO
*LOCATE 'LENDING-SUSPEND-ARRANGEMENT' IN Y.ACSTS<1,1> SETTING POS.SP THEN
*IF Y.ACT.STS<1,POS.SP> EQ 'AUTH' THEN
*Y.VMC.CNT = 0
*Y.SUSP = 'Y'
*END ELSE
*DEL Y.ACSTS<1,POS.SP>
*END
*END ELSE
*Y.VMC.CNT = 0
*Y.SUSP = ''
*END
*REPEAT

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Trigger NEW Activity as a Secondary Activity to this Arrangment Activity
*
TRIGGER.ACTIVITY:

    AAA.FIELDS.REC = ''
    RETURN.ERR = ''
    Y.AC.DATE = c_aalocActivityEffDate
    Y.ACCT.ID = c_aalocArrActivityId
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)

RETURN
*----------------------------------------------------------------------------------------------------------------------------
END
