$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.POST.RESTRUCTURED.MIG
*--------------------------------------------------------------------------------
* Description: This routine is to update the concat table REDO.AA.LOAN.UPD.STATUS
*              with the restructured date.
*--------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                        Descripition
* 29-03-2023     Samaran T           Manual R22 code conversion                Package Name Added APAP.AA
* 29-03-2023  Conversion Tool       Auto R22 Code Conversion                    VM TO @VM
*----------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE

    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN
*--------------------------------------------------------------------------------
INIT:
*--------------------------------------------------------------------------------

    LOC.REF.APPLICATION = "AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS      = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@VM:'L.STATUS.CHG.DT' ;*AUTO R22 CODE CONVERSION
    LOC.REF.POS         = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.LOAN.STATUS.1 = LOC.REF.POS<1,1>
    POS.L.LOAN.COND     = LOC.REF.POS<1,2>
    POS.L.STATUS.CHG.DT = LOC.REF.POS<1,3>

    FN.REDO.AA.LOAN.UPD.STATUS = 'F.REDO.AA.LOAN.UPD.STATUS'
    F.REDO.AA.LOAN.UPD.STATUS  = ''
    CALL OPF(FN.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS)

RETURN
*--------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------
    Y.LOAN.STATUS = R.NEW(AA.OD.LOCAL.REF)<1,POS.L.LOAN.STATUS.1,1>
    IF Y.LOAN.STATUS EQ 'Restructured' THEN
        Y.DATE = R.NEW(AA.OD.LOCAL.REF)<1,POS.L.STATUS.CHG.DT,1>
        IF Y.DATE ELSE
            Y.DATE = c_aalocActivityEffDate
        END
        CALL F.WRITE(FN.REDO.AA.LOAN.UPD.STATUS,c_aalocArrId,Y.DATE)
    END

RETURN
END
