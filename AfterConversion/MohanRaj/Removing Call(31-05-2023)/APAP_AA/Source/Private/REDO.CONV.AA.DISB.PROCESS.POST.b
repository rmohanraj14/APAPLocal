$PACKAGE APAP.AA
SUBROUTINE REDO.CONV.AA.DISB.PROCESS.POST
*-------------------------------------------------
*Description: This batch routine is to post the FT OFS messages for overpayment
*             and also to credit the interest in loan.
*-------------------------------------------------
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023   Conversion Tool              R22 Auto Conversion  - FM to @FM
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes                             
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_REDO.CONV.AA.DISB.PROCESS.COMMON

    GOSUB PROCESS

RETURN
*-------------------------------------------------
PROCESS:
*-------------------------------------------------

    FINAL.ARRAY.LIST = ''
    Y.SEQ.NO = 1
    SEL.CMD = "SSELECT ":FN.TEMP.FILE.PATH
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,RET.CODE)

    LOOP
        REMOVE Y.TEMP.ID FROM SEL.LIST SETTING TEMP.POS
    WHILE Y.TEMP.ID:TEMP.POS
        R.TEMP.FILE.PATH = '';  TEMP.ERR = ''
        CALL F.READ(FN.TEMP.FILE.PATH,Y.TEMP.ID,R.TEMP.FILE.PATH, F.TEMP.FILE.PATH,TEMP.ERR)
        IF R.TEMP.FILE.PATH THEN
            Y.SEQ.NO = FMT(Y.SEQ.NO,"R%7")
            FINAL.ARRAY.LIST<-1> = R.TEMP.FILE.PATH
        END
    REPEAT

    CHANGE @FM TO CHARX(13):CHARX(10) IN FINAL.ARRAY.LIST

    WRITE FINAL.ARRAY.LIST ON F.EXP.FILE.PATH, Y.FILE.NAME ON ERROR
        Y.ERR.MSG = "Unable to Write '":F.EXP.FILE.PATH:"'"
    END

    Y.DEL.CMD = "rm -r ../EXTRACT/MASSIVE.BP/temp1"
    EXECUTE Y.DEL.CMD
RETURN
END
