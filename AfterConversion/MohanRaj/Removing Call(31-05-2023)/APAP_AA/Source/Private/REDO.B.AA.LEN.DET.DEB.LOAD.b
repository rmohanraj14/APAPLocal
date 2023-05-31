* @ValidationCode : MjotODIxMTUyNjExOkNwMTI1MjoxNjg1NTI5MTI4MjM1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:02:08
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
SUBROUTINE REDO.B.AA.LEN.DET.DEB.LOAD
*--------------------------------------------------------------------------------------------------
* Description           : This is the Batch Load Routine used to initalize all the required variables
*
* Developed By          : Vijayarani G
*
* Development Reference : 786844(FS-207-DE21)
*
*--------------------------------------------------------------------------------------------------
* Input Parameter:
* ---------------*
* Argument#1 : NA
*-----------------*
* Output Parameter:
* ----------------*
* Argument#2 : NA
*--------------------------------------------------------------------------------------------------
*  M O D I F I C A T I O N S
* ***************************
*--------------------------------------------------------------------------------------------------
* Defect Reference       Modified By                    Date of Change        Change Details
* (RTC/TUT/PACS)
* PACS00361224           Ashokkumar.V.P                 30/10/2014            New mapping changes - Rewritten the whole source.
* PACS00464363           Ashokkumar.V.P                 22/06/2015            Changed to avoid ageing problem and mapping changes.

*
* Date             Who                   Reference      Description
* 21.04.2023       Conversion Tool       R22            Auto Conversion     - FM TO @FM, INSERT file folder name removed T24.BP, TAM.BP, LAPAP.BP
* 21.04.2023       Shanmugapriya M       R22            Manual Conversion   - Add call routine prefix
*
*--------------------------------------------------------------------------------------------------
* Include files
*--------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON                         ;** R22 Auto conversion - START
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_BATCH.FILES
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.H.REPORTS.PARAM
    $INSERT I_REDO.B.AA.LEN.DET.DEB.COMMON
    $INSERT I_F.RE.STAT.REP.LINE
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_TSA.COMMON
    $INSERT I_F.DATES                        ;** R22 Auto conversion - END
    $USING APAP.REDOCHNLS
    GOSUB INITIALISATION
    GOSUB FIND.LOC.REF.FLDS
    GOSUB GET.BATCH.VALUE
RETURN
*
*--------------
INITIALISATION:
*-------------
*
    FN.COMPANY = ""
    F.COMPANY = ""
    FN.AA.ARR = ""
    F.AA.ARR = ""
    FN.RE.STAT.REP.LINE = ""
    F.RE.STAT.REP.LINE = ""
    FN.AA.ACCT.DET = ""
    F.AA.ACCT.DET = ""
    FN.EB.CONT.BAL = ""
    F.EB.CONT.BAL = ""
    FN.PRODUCT = ""
    F.PRODUCT = ""
    FN.ACCOUNT = ""
    F.ACCOUNT = ""
    FN.AA.BILL.DET = ""
    F.AA.BILL.DET = ""
    Y.REPORT.PARAM.ID = ""
    Y.RCL.ID = ""
    Y.FILE.NAME = ""
    Y.FIELD.NME.ARR = ""
    Y.FIELD.VAL.ARR = ""
    Y.DISP.TEXT.ARR = ""
    Y.ERR.MSG = ""
    Y.L.LOAN.STATUS.1.POS = ''
*
    FN.AA.ARR = "F.AA.ARRANGEMENT"
    F.AA.ARR = ""
    CALL OPF(FN.AA.ARR,F.AA.ARR)
*
    FN.RE.STAT.REP.LINE = "F.RE.STAT.REP.LINE"
    F.RE.STAT.REP.LINE = ""
    CALL OPF(FN.RE.STAT.REP.LINE,F.RE.STAT.REP.LINE)
*
    FN.AA.ACCT.DET = "F.AA.ACCOUNT.DETAILS"
    F.AA.ACCT.DET = ""
    CALL OPF(FN.AA.ACCT.DET,F.AA.ACCT.DET)
*
    FN.COMPANY = "F.COMPANY"
    F.COMPANY = ""
    CALL OPF(FN.COMPANY,F.COMPANY)
*
    FN.EB.CONT.BAL = "F.EB.CONTRACT.BALANCES"
    F.EB.CONT.BAL = ""
    CALL OPF(FN.EB.CONT.BAL,F.EB.CONT.BAL)
*
    FN.AA.OVERDUE = "F.AA.ARR.OVERDUE"
    F.AA.OVERDUE = ""
    CALL OPF(FN.AA.OVERDUE,F.AA.OVERDUE)
*
    FN.PRODUCT = "F.AA.PRODUCT"
    F.PRODUCT = ""
    CALL OPF(FN.PRODUCT,F.PRODUCT)
*
    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
*
    FN.REDO.H.REPORTS.PARAM = "F.REDO.H.REPORTS.PARAM"
    F.REDO.H.REPORTS.PARAM = ""
    CALL OPF(FN.REDO.H.REPORTS.PARAM,F.REDO.H.REPORTS.PARAM)
*
    FN.AA.BILL.DET = "F.AA.BILL.DETAILS"
    F.AA.BILL.DET = ""
    CALL OPF(FN.AA.BILL.DET,F.AA.BILL.DET)

    FN.REDO.CONCAT.ACC.NAB = 'F.REDO.CONCAT.ACC.NAB'
    F.REDO.CONCAT.ACC.NAB = ''
    CALL OPF(FN.REDO.CONCAT.ACC.NAB,F.REDO.CONCAT.ACC.NAB)

    FN.DR.REG.DE21.WORKFILE = 'F.DR.REG.DE21.WORKFILE'; F.DR.REG.DE21.WORKFILE =''
    CALL OPF(FN.DR.REG.DE21.WORKFILE,F.DR.REG.DE21.WORKFILE)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'; F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'; F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)
RETURN
*
FIND.LOC.REF.FLDS:
*----------------
    Y.APPL = 'AA.PRD.DES.OVERDUE':@FM:'ACCOUNT'
    Y.FLD = 'L.LOAN.STATUS.1':@FM:'L.OD.STATUS'
    Y.POS = ''
    CALL MULTI.GET.LOC.REF(Y.APPL,Y.FLD,Y.POS)
    Y.L.LOAN.STATUS.1.POS = Y.POS<1,1>
    L.OD.STATUS.POS = Y.POS<2,1>
RETURN

*---------------
GET.BATCH.VALUE:
*---------------
*
    Y.LAST.WORK.DAY = R.DATES(EB.DAT.LAST.WORKING.DAY)
    Y.TODAY = TODAY
    YLST.TODAY = Y.TODAY
    CALL CDT('',YLST.TODAY,'-1C')
    IF Y.LAST.WORK.DAY[5,2] NE YLST.TODAY[5,2] THEN
        COMI = Y.LAST.WORK.DAY[1,6]:'01'
        CALL LAST.DAY.OF.THIS.MONTH
        YLST.TODAY = COMI
    END

    Y.REPORT.PARAM.ID = "REDO.DE21"
    Y.RCL.ID          = "REDO.RCL.DE21"
    CALL CACHE.READ(FN.REDO.H.REPORTS.PARAM,Y.REPORT.PARAM.ID,R.REDO.H.REPORTS.PARAM,PARAM.ERR)
    IF R.REDO.H.REPORTS.PARAM NE '' THEN
        Y.FILE.NAME = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.OUT.FILE.NAME>
        Y.FIELD.NME.ARR = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.FIELD.NAME>
        Y.FIELD.VAL.ARR = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.FIELD.VALUE>
        Y.DISP.TEXT.ARR = R.REDO.H.REPORTS.PARAM<REDO.REP.PARAM.DISPLAY.TEXT>
    END
RETURN
*
RAISE.ERR.C.22:
*-----------------------------------------------------------------------------------------------------------------
*Handling Fatal error to halt the process
*-----------------------------------------------------------------------------------------------------------------
    MON.TP    = "21"
    Y.ERR.MSG = Y.ERR.MSG
    REC.CON   = "DE21-LOAD-":Y.ERR.MSG
    DESC      = "DE21-LOAD-":Y.ERR.MSG
    INT.CODE  = 'REP001'
    INT.TYPE  = 'ONLINE'
    BAT.NO    = ''
    BAT.TOT   = ''
    INFO.OR   = ''
    INFO.DE   = ''
    ID.PROC   = ''
    EX.USER   = ''
    EX.PC     = ''
*CALL REDO.INTERFACE.REC.ACT(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC)
** R22 Manual conversion
    APAP.REDOCHNLS.redoInterfaceRecAct(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC);* R22 Manual conversion
*
RETURN
END
