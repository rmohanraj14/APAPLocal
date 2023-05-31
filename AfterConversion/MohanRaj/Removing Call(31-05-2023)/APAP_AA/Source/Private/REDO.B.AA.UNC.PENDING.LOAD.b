$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.UNC.PENDING.LOAD
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
    $INSERT I_F.REDO.AA.UNC.PENDING
    $INSERT I_REDO.B.AA.UNC.PENDING.COMMON

    GOSUB PROCESS

RETURN


PROCESS:
*-------

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    FN.REDO.AA.UNC.PENDING = 'F.REDO.AA.UNC.PENDING'
    F.REDO.AA.UNC.PENDING = ''

    CALL OPF(FN.AA.ARRANGEMENT, F.AA.ARRANGEMENT)
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
    CALL OPF(FN.REDO.AA.UNC.PENDING,F.REDO.AA.UNC.PENDING)

RETURN
END
