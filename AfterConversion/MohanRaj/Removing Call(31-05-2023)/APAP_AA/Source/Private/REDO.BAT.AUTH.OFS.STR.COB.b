$PACKAGE APAP.AA
SUBROUTINE REDO.BAT.AUTH.OFS.STR.COB
*-----------------------------------------------------------------------------
*DESCRIPTIONS:
*-------------
* This is a SERVICE routine for B16 development
* Once after running the service REDO.PRE.PRIN.INT.PENAL.INT routine
* and OFS.MESSAGE.SERVICE, this routine should trigger
* This Routine will read the unauth record ID from the flat file which is created when a ofs service is ran
*
*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
*-----------------------------------------------------------------------------
* Modification History :
* Date            Who              Reference            Description
* 08-OCT-10    Kishore.SP       ODR-2009-10-0325      Initial Creation
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
* 29-MAR-2023      Conversion Tool       R22 Auto Conversion - No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_AA.ACTION.CONTEXT
*
    GOSUB PROCESS
RETURN
*------------------------------------------------------------------------
PROCESS:
*---------
*
    FILE.NAME = 'TAM.BP'
    RECORD.NAME = "AA.ACT.COB"
    F.FILE.PATH = ''
*
    OPEN FILE.NAME TO F.FILE.PATH ELSE

        CRT 'CANNOT OPEN  FILE'
    END
*
    READ Y.REC.ARRAY FROM F.FILE.PATH,RECORD.NAME ELSE

        CRT 'CANNOT READ  FILE'
    END
*
    LOOP
        REMOVE Y.REC FROM Y.REC.ARRAY SETTING Y.POS
    WHILE Y.REC:Y.POS
        ACTIVITY.ID = Y.REC
        GOSUB FORM.OFS.AUTH.ARRAY
    REPEAT
RETURN
*------------------------------------------------------------------------
FORM.OFS.AUTH.ARRAY:
*-------------------
*
    Y.COMPANY = ID.COMPANY
    Y.OFS.MESSAGE = 'AA.ARRANGEMENT.ACTIVITY,REDO.COB/A/PROCESS///,//':Y.COMPANY:'/////,':ACTIVITY.ID
    Y.MSG = Y.OFS.MESSAGE
    Y.MSG.KEY = ""
    Y.OFS.SOURCE.ID = "REDO.RATE.MANUAL"
    Y.ERROR = ""
    CALL OFS.POST.MESSAGE(Y.MSG,Y.MSG.KEY,Y.OFS.SOURCE.ID,Y.ERROR)
RETURN
END
