* @ValidationCode : MjotNDg3NzE3OTE2OkNwMTI1MjoxNjgwMTg0NjcyMjY3OklUU1M6LTE6LTE6MzY4OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 368
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.E.AA.ACT.REVERSE(ENQ.DATA)
*-----------------------------------------------------------------------------
*
* Bank name: APAP
* Decription: The arragement history will be checked for AUTH and TRANSACTION activities
* Developed By: Edwin Charles D
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.REDO.AA.ACTIVITY.LOG

    GOSUB INIT
    GOSUB PROCESS

RETURN

INIT:
*----

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY, F.AA.ACTIVITY.HISTORY)

    FN.REDO.AA.ACTIVITY.LOG = 'F.REDO.AA.ACTIVITY.LOG'
    F.REDO.AA.ACTIVITY.LOG = ''
    CALL OPF(FN.REDO.AA.ACTIVITY.LOG, F.REDO.AA.ACTIVITY.LOG)

    LOCATE "ARRANGEMENT.ID" IN D.FIELDS SETTING CUS.POS THEN
        Y.ARR.ID = D.RANGE.AND.VALUE<CUS.POS>
    END

RETURN

PROCESS:
*-------
    CALL F.READ(FN.AA.ACTIVITY.HISTORY,Y.ARR.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,ACT.HIS.ERR)
    Y.EFFECTIVE.DATE.LIST = '' ; Y.SYSTEM.DATE.LIST = '' ; Y.ACTIVITY.LIST = '' ; Y.ACTIVITY.REF.LIST = '' ; Y.INIT.LIST = '' ; Y.STATUS.LIST = '' ; Y.EFFECTIVE.DATE = ''

    Y.EFFECTIVE.DATE.LIST = R.AA.ACTIVITY.HISTORY<AA.AH.EFFECTIVE.DATE>

    Y.SYSTEM.DATE.LIST    = R.AA.ACTIVITY.HISTORY<AA.AH.SYSTEM.DATE>
    Y.ACTIVITY.LIST       = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>
    Y.ACTIVITY.REF.LIST   = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY.REF>
    Y.INIT.LIST           = R.AA.ACTIVITY.HISTORY<AA.AH.INITIATION>
    Y.STATUS.LIST         = R.AA.ACTIVITY.HISTORY<AA.AH.ACT.STATUS>

    CHANGE @VM TO @FM IN Y.EFFECTIVE.DATE.LIST

    TOT.CNT = DCOUNT(Y.EFFECTIVE.DATE.LIST, @FM)
    CNT = 1

    LOOP
    WHILE CNT LE TOT.CNT
        IF Y.EFFECTIVE.DATE.LIST<CNT> THEN
            Y.EFFECTIVE.DATE = Y.EFFECTIVE.DATE.LIST<CNT>
        END
        TOT.SM = DCOUNT(Y.ACTIVITY.REF.LIST<1,CNT>, @SM)
        SM.CNT = 1
        LOOP
        WHILE SM.CNT LE TOT.SM
            Y.SYSTEM.DATE  = Y.SYSTEM.DATE.LIST<1,CNT,SM.CNT>
            Y.ACTIVITY     = Y.ACTIVITY.LIST<1,CNT,SM.CNT>
            Y.ACTIVITY.REF = Y.ACTIVITY.REF.LIST<1,CNT,SM.CNT>
            Y.INIT         = Y.INIT.LIST<1,CNT,SM.CNT>
            Y.STATUS       = Y.STATUS.LIST<1,CNT,SM.CNT>

            IF (Y.INIT EQ 'USER' OR Y.INIT EQ 'TRANSACTION') AND Y.STATUS EQ 'AUTH' THEN
                GOSUB CHECK.REDO.ACTIVITY.LOG
                GOSUB CHECK.ACTIVITY.NAME
                IF Y.ACTIVITY.REF THEN
                    ENQ.DATA<-1> = Y.ARR.ID:'*':Y.ACTIVITY.REF:'*':Y.EFFECTIVE.DATE:'*':Y.ACTIVITY:'*':Y.INIT:'*':Y.STATUS:'*':Y.ACTUAL.VER
                    Y.EFFECTIVE.DATE = ''; Y.ACTIVITY.REF = '' ; Y.ACTIVITY = '' ; Y.INIT = '' ; Y.STATUS = ''; Y.ACTUAL.VER = ''
                END
            END
            SM.CNT += 1 ;* R22 Auto Conversion
        REPEAT

        CNT += 1 ;* R22 Auto Conversion
    REPEAT

RETURN

CHECK.REDO.ACTIVITY.LOG:
*----------------------
    R.REDO.AA.ACTIVITY.LOG = ''
    CALL F.READ(FN.REDO.AA.ACTIVITY.LOG,Y.ACTIVITY.REF,R.REDO.AA.ACTIVITY.LOG,F.REDO.AA.ACTIVITY.LOG,ACT.LOG.ERR)
    IF R.REDO.AA.ACTIVITY.LOG THEN
        Y.ACTIVITY.REF = ''
    END
RETURN

CHECK.ACTIVITY.NAME:
*-------------------
    IF Y.ACTIVITY EQ 'LENDING-NEW-ARRANGEMENT' THEN
        Y.ACTUAL.VER = 'AA.ARRANGEMENT.ACTIVITY,AA.AUTH'
    END ELSE
        Y.ACTUAL.VER = 'AA.ARRANGEMENT.ACTIVITY,REDO.REV.AA'
    END
RETURN

PROGRAM.EXT:
*-----------
END
