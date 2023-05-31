$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.UNC.PENDING(Y.ARR.ID)
*-------------------------------------------------
*Description:
*-------------------------------------------------
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
* 29-MAR-2023      Conversion Tool       R22 Auto Conversion - No changes
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.AA.UNC.PENDING
    $INSERT I_REDO.B.AA.UNC.PENDING.COMMON

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

OPEN.FILES:
***********

RETURN

PROCESS:
********

    R.AA.ARRANGEMENT = '' ; ARR.ERR = ''
    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    IF R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> EQ 'PENDING.CLOSURE' THEN
        R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS> = 'CURRENT'
        WRITE R.AA.ARRANGEMENT ON F.AA.ARRANGEMENT, Y.ARR.ID ON ERROR
            Y.ERR.MSG = "Unable to Write '":Y.ARR.ID:"'"
        END

        IF Y.ARR.ID THEN
            RETURN.ERROR = ''
            AAA.REQUEST<AA.ARR.ACT.ARRANGEMENT> = Y.ARR.ID
            AAA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-ADJUST.SUSP.BALANCE-MANT.SALD.CUOTA'
            AAA.REQUEST<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
            APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
            IN.FUNCTION = 'I'
            VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ADJ.AUTH'
            CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, AAA.REQUEST, PROCESS.MSG)      ;*Form the OFS Message
            OFS.MSG.ID = ''
            OFS.SOURCE = 'FT.UNC.CK'
            OFS.ERR = ''
            CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)
        END
    END

RETURN
END
