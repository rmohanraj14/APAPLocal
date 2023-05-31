* @ValidationCode : MjoyMTQ2Mzg1NTU4OkNwMTI1MjoxNjg1NTMyNTA2OTg0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:58:26
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
*Modification History
** 29-03-2023 Conversion Tool R22 Auto Conversion FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - CALL method format changed

$PACKAGE APAP.AA
SUBROUTINE REDO.UPDATE.JUD.COL.SUSP

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_AA.LOCAL.COMMON

MAIN:

    FN.AA.ACT.HIS = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACT.HIS = ''
    CALL OPF(FN.AA.ACT.HIS,F.AA.ACT.HIS)

    AA.OD.LRF.POS = ''
    AA.LOAN.STATUS.POS = ''
    AA.LOAN.COND.POS = ''
    AA.OD.LRF = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@VM:'L.LOAN.COMMENT1':@FM:'L.OD.STATUS'
    LOC.REF.APPLICATION   = "AA.PRD.DES.OVERDUE":@FM:"AA.PRD.DES.ACCOUNT"

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,AA.OD.LRF,AA.OD.LRF.POS)
    AA.LOAN.STATUS.POS = AA.OD.LRF.POS<1,1>
    AA.LOAN.COND.POS   = AA.OD.LRF.POS<1,2>
    AA.LC.COMMENT.POS  = AA.OD.LRF.POS<1,3>
    POS.L.OD.STATUS    = AA.OD.LRF.POS<2,1>

    OLD.LOAN.STATUS.LST = R.OLD(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    OLD.LOAN.COND.LST   = R.OLD(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>
    NEW.LOAN.STATUS.LST = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    NEW.LOAN.COND.LST   = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>

    IF OLD.LOAN.STATUS.LST EQ NEW.LOAN.STATUS.LST THEN
        RETURN
    END ELSE
        GOSUB PROCESS
    END
*
RETURN

PROCESS:

    Y.AA.ID = c_aalocArrId

    OLD.LOAN.STATUS.LST = CHANGE(OLD.LOAN.STATUS.LST,@SM,@VM) ; OLD.LOAN.STATUS.LST = CHANGE(OLD.LOAN.STATUS.LST,@VM,@FM)
    NEW.LOAN.STATUS.LST = CHANGE(NEW.LOAN.STATUS.LST,@SM,@VM) ; NEW.LOAN.STATUS.LST = CHANGE(NEW.LOAN.STATUS.LST,@VM,@FM)
    LOCATE 'JudicialCollection' IN OLD.LOAN.STATUS.LST SETTING POS.C THEN
        LOCATE 'Normal' IN NEW.LOAN.STATUS.LST  SETTING POS.CC THEN
            GOSUB PROCESS.RESUME
        END ELSE
            LOCATE 'Restructured' IN NEW.LOAN.STATUS.LST SETTING POS.RR THEN
                GOSUB PROCESS.RESUME
            END
        END
    END

RETURN

PROCESS.RESUME:

    GOSUB GET.AGING.STATUS
    IF Y.L.OD.STATUS EQ 'NAB' THEN
        RETURN          ;* If the Loan is out of NAB then only we need to resume the loan if JC is removed
    END

    CALL F.READ(FN.AA.ACT.HIS,Y.AA.ID,R.AA.ACT.HIS,F.AA.ACT.HIS,HIS.ERR)

    Y.ACT.HIS = R.AA.ACT.HIS<AA.AH.ACTIVITY> ; Y.ACT.HIS = CHANGE(Y.ACT.HIS,@SM,@VM) ; Y.ACT.HIS = CHANGE(Y.ACT.HIS,@VM,@FM)

    LOCATE 'LENDING-SUSPEND-ARRANGEMENT' IN Y.ACT.HIS SETTING POS.SUS THEN
        NEW.ACTIVITY.ID = 'LENDING-RESUME-ARRANGEMENT'
        GOSUB TRIGGER.ACTIVITY
    END

RETURN

TRIGGER.ACTIVITY:

    AAA.FIELDS.REC = ''
    RETURN.ERR = ''
    Y.AC.DATE = c_aalocActivityEffDate
    Y.ACCT.ID = c_aalocArrActivityId
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(Y.AA.ID, NEW.ACTIVITY.ID, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)

RETURN
*------------------------------------------------------------------------
GET.AGING.STATUS:
*------------------------------------------------------------------------
* Here we will get the loan aging status account property. we need to resume the arrangement
* only when loan is out of NAB and being removed from Judicial collection


    EFF.DATE    = c_aalocActivityEffDate
    PROP.CLASS  = 'ACCOUNT'
    PROPERTY    = ''
    R.ACC.COND  = ''
    ERR.MSG     = ''
    APAP.AA.redoCrrGetConditions(Y.AA.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.ACC.COND,ERR.MSG);* R22 Manual conversion

    Y.L.OD.STATUS = R.ACC.COND<AA.AC.LOCAL.REF,POS.L.OD.STATUS>

RETURN
END
