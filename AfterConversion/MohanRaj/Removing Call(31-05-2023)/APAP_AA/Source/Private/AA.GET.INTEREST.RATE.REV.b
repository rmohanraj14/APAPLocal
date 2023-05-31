$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE AA.GET.INTEREST.RATE.REV
    
*-----------------------------------------------------------------------------------
* Modification History: Code conversion
* Package Name added APAP.AA
*-----------------------------------------------------------------------------------

*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : AA.GET.INTEREST.RATE.REV
*--------------------------------------------------------------------------------
* Description: This is a Post routine for Interest property to reverse the AC.LOCKED.EVENTS
*
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE               DESCRIPTION
* 12-May-2011   H GANESH       PACS00054299 - B.37     INITIAL CREATION
* 29/03/2023    SURESH           MANUAL R22 CODE CONVERSION      Package Name added APAP.AA
* 29/03/2023    Conversion Tool  AUTO R22 CODE CONVERSION     Y.VAR1++ to Y.VAR1 += 1 , FM to @FM
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON

    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN
*----------------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------------

    FN.REDO.CONCAT.ARR.ALE='F.REDO.CONCAT.ARR.ALE'
    F.REDO.CONCAT.ARR.ALE=''
    CALL OPF(FN.REDO.CONCAT.ARR.ALE,F.REDO.CONCAT.ARR.ALE)

    R.OFS.FINAL.ARRAY=''

RETURN
*----------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------
    CALL F.READ(FN.REDO.CONCAT.ARR.ALE,c_aalocArrActivityId,R.REDO.CONCAT.ARR.ALE,F.REDO.CONCAT.ARR.ALE,ERR)
    IF R.REDO.CONCAT.ARR.ALE THEN
        Y.ALE.IDS=R.REDO.CONCAT.ARR.ALE
        NO.OF.IDS=DCOUNT(Y.ALE.IDS,@FM) ;*AUTO R22 CODE CONVERSION
        Y.VAR1=1
        LOOP
        WHILE Y.VAR1 LE NO.OF.IDS
            GOSUB POST.REVERSE
            Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
        REPEAT
    END
    IF R.OFS.FINAL.ARRAY THEN
        OFS.SRC='REDO.CHQ.ISSUE'
        OPTIONS=''
        CALL OFS.POST.MESSAGE(R.OFS.FINAL.ARRAY,OFS.MSG.ID,OFS.SRC,OPTIONS)
    END
RETURN
*----------------------------------------------------------------------------
POST.REVERSE:
*----------------------------------------------------------------------------
    APP.NAME = 'AC.LOCKED.EVENTS'
    OFSFUNCT='R'
    PROCESS  = ''
    OFSVERSION = 'AC.LOCKED.EVENTS,REDO.LOCK.LOAN.REV'
    GTSMODE = ''
    TRANSACTION.ID=Y.ALE.IDS<Y.VAR1>
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    R.OFS.ALE=''
    NO.OF.AUTH=0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.OFS.ALE,OFSRECORD)
    R.OFS.FINAL.ARRAY<-1>=OFSRECORD
RETURN

END
