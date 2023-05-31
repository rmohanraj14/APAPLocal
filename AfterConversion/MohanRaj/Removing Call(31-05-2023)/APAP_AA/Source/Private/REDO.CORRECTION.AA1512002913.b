$PACKAGE APAP.AA
SUBROUTINE REDO.CORRECTION.AA1512002913
*-----------------------------------------------------
*Description: This correction routine is to post the OFS message to change the loan
*             status to CUR, since aftr ter the adjustment of bill, bill got settled but loan didnt moved out of DEL.
*-----------------------------------------------------

* Ref :  PACS00459943
*-----------------------------------------------------
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023    Conversion Tool              R22 Auto Conversion  - SM to @SM
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes 

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY


    GOSUB PROCESS
RETURN
*-----------------------------------------------------
PROCESS:
*-----------------------------------------------------

    EXECUTE "COMO ON REDO.CORRECTION.AA1512002913"
    R.AAA = ""
    R.AAA<AA.ARR.ACT.ARRANGEMENT> = "AA1512002913"
    R.AAA<AA.ARR.ACT.ACTIVITY>    = "LENDING-UPDATE-OD.STATUS"
    R.AAA<AA.ARR.ACT.EFFECTIVE.DATE>  = TODAY
    R.AAA<AA.ARR.ACT.PROPERTY>    = "ACCOUNT"
    R.AAA<AA.ARR.ACT.FIELD.NAME>  = "L.OD.STATUS":@SM:"L.OD.STATUS.2"
    R.AAA<AA.ARR.ACT.FIELD.VALUE> = "CUR":@SM:"CUR"

    APP.NAME      = "AA.ARRANGEMENT.ACTIVITY"
    OFSFUNCT      = 'I'
    PROCESS       = 'PROCESS'
    OFSVERSION    = "AA.ARRANGEMENT.ACTIVITY,APAP"
    GTSMODE       = ''
    TRANSACTION.ID= ''
    OFSRECORD     = ''
    OFS.MSG.ID    = ''
    OFS.ERR       = ''
    NO.OF.AUTH    = 0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.AAA,OFSRECORD)
    OFS.MSG.ID = ''
    OFS.SRC    = "REDO.PENALTY"
    OPTIONS    = ''
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SRC,OPTIONS)

    CALL OCOMO(OFSRECORD)
    CALL OCOMO(OFS.MSG.ID)
    CALL OCOMO("Posted successfuly")
    EXECUTE "COMO OFF REDO.CORRECTION.AA1512002913"
    CALL JOURNAL.UPDATE("")
RETURN
END
