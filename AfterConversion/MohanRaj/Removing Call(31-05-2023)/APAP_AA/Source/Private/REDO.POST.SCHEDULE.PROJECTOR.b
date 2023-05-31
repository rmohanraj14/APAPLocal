$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.POST.SCHEDULE.PROJECTOR
*------------------------------------------------------------
*Description: This post routine is to update the concat table about the schedule projector
* for each arrangement. We need to trigger the schedule projector during auth stage and store
* in a concat table.
*---------------------------------------------------------------------------------------------
*Modification History
*Date           Who                 Reference                                    Descripition
* 29-03-2023     Samaran T         Manual R22 code conversion                Package Name Added APAP.AA
* 29-03-2023   Conversion Tool        Auto R22 code conversion                    VM TO @VM
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    IF c_aalocActivityStatus MATCHES 'AUTH':@VM:'AUTH-REV' THEN ;*AUTO R22 CODE CONVERSION

        GOSUB OPEN.FILES
        GOSUB PROCESS
    END
RETURN
*------------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------------

    FN.REDO.B.PENDING.SCH.PROJECTOR.LIST = 'F.REDO.B.PENDING.SCH.PROJECTOR.LIST'
    F.REDO.B.PENDING.SCH.PROJECTOR.LIST  = ''
    CALL OPF(FN.REDO.B.PENDING.SCH.PROJECTOR.LIST,F.REDO.B.PENDING.SCH.PROJECTOR.LIST)

RETURN
*------------------------------------------------------------
PROCESS:
*------------------------------------------------------------

    Y.AA.ID        =  c_aalocArrId
    Y.UNIQUE.KEY   =  c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA>      ;* We are using the master AAA id as @ID for this file
*                                                    since we dont need to duplicate the same AA ids during
*                                                    applypayment.

    Y.REC = Y.AA.ID:'*': Y.UNIQUE.KEY
    R.RECORD.LIST = ''
    CALL F.READ(FN.REDO.B.PENDING.SCH.PROJECTOR.LIST,Y.UNIQUE.KEY,R.RECORD.LIST,F.REDO.B.PENDING.SCH.PROJECTOR.LIST,PROJ.ERR)
    IF R.RECORD.LIST ELSE
        CALL F.WRITE(FN.REDO.B.PENDING.SCH.PROJECTOR.LIST,Y.UNIQUE.KEY,Y.REC)       ;* Write only when record doesnt exist.
    END

RETURN
END
