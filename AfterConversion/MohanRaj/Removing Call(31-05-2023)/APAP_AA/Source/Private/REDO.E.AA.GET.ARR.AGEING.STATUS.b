* @ValidationCode : MjotMTc3NTI4NDA4NDpDcDEyNTI6MTY4NTUyOTkxMzU3Mzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:15:13
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
SUBROUTINE REDO.E.AA.GET.ARR.AGEING.STATUS
**********************************
*Description:   This routine gets the settlement status of the Arrangement
* It will get the status of the Oldest Bill that is not settled
*
*
**********************************
*MODIFICATION HISTORY
* Date            Who           Development       Details
* 15 May 2012   H Ganesh        Zero Principal    Initial Draft.
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            CALL RTN METHOD CHANGED
**********************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ACCOUNT
**********************************

    GOSUB PROCESS
RETURN

**********************************
PROCESS:
**********************************



    LOC.REF.APPLICATION="AA.PRD.DES.ACCOUNT"
    LOC.REF.FIELDS='L.OD.STATUS'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.OD.STATUS = LOC.REF.POS<1,1>

    ARR.ID = O.DATA
    R.AC.DETAILS = ''
    PROCESS.END = ''
    RET.ERR = ''

    LOCATE "SIM.REF" IN ENQ.SELECTION<2,1> SETTING SIM.POS THEN
        SIM.REF = ENQ.SELECTION<4,SIM.POS>
    END ELSE
        SIM.REF = ''
    END

    IF ARR.ID ELSE
        LOCATE "ARRANGEMENT.ID" IN ENQ.SELECTION<2,1> SETTING ARR.POS THEN
            ARR.ID = ENQ.SELECTION<4,ARR.POS>
        END ELSE
            PROCESS.END = 1
        END
    END

    IF PROCESS.END ELSE
        IF SIM.REF THEN
            FILE.NAME = 'F.AA.ARR.ACCOUNT'
            CALL SIM.GET.IDS(SIM.REF,FILE.NAME,IDS.LIST)
            REC.ID = IDS.LIST
            CALL SIM.READ(SIM.REF,FILE.NAME,REC.ID,SIM.RECORD,SIM.REC.ONLY,SIM.UPDATED,READ.ERROR)
            Y.OD.STATUS = SIM.RECORD<AA.AC.LOCAL.REF,POS.L.OD.STATUS>
        END ELSE
            EFF.DATE = ''
            PROP.CLASS='ACCOUNT'
            PROPERTY = ''
            R.CONDITION = ''
            ERR.MSG = ''
            APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 MANUAL CODE CONVERSION - Changed CALL format
            Y.OD.STATUS = R.CONDITION<AA.AC.LOCAL.REF,POS.L.OD.STATUS>
        END
    END

    O.DATA = Y.OD.STATUS
RETURN
END
