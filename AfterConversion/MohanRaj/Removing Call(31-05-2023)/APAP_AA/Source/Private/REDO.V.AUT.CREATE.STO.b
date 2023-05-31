* @ValidationCode : MjoxNzI1NDM3NTMyOkNwMTI1MjoxNjg1NTMyODQyNDQwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:04:02
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
SUBROUTINE REDO.V.AUT.CREATE.STO
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
* This routine is attached as authorisation routine in the verison FUNDS.TRANSFER,AA.LS.LC.ACDI
* This routine will create STANDING.ORDER record based on the values in arrangement
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 15-JUNE-2010     SHANKAR RAJU    ODR-2009-10-0331      Initial Creation
** 30-03-2023      Conversion Tool  R22 Auto Conversion  FM TO @FM, VM to @VM, SM to @SM
** 30-03-2023       Skanda          R22 Manual Conversion CALL Method format changed
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.STANDING.ORDER
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FT.APPL.DEFAULT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.FT.TXN.TYPE.CONDITION
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER

    IF V$FUNCTION NE 'A' THEN
        RETURN
    END

    GOSUB OPEN.FILES
    GOSUB GET.LRF.POS
    GOSUB PROCESS
RETURN

*----------
OPEN.FILES:
*----------
*---------------------------------------
* This section opens the necessary files
*---------------------------------------

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.FT.APPL.DEFAULT = 'F.FT.APPL.DEFAULT'
    F.FT.APPL.DEFAULT = ''
    R.FT.APPL.DEFAULT = ''
    CALL OPF(FN.FT.APPL.DEFAULT,F.FT.APPL.DEFAULT)

    FN.FT.TXN.TYPE.CONDITION = 'F.FT.TXN.TYPE.CONDITION'
    F.FT.TXN.TYPE.CONDITION = ''
    R.FT.TXN.TYPE.CONDITION = ''
    CALL OPF(FN.FT.TXN.TYPE.CONDITION,F.FT.TXN.TYPE.CONDITION)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN

*-----------
GET.LRF.POS:
*-----------
*--------------------------------------------------------------------------------------------
* This section gets the position of the local reference fields LOAN.STATUS and LOAN.CONDITION
*--------------------------------------------------------------------------------------------

    APP.LST = 'STANDING.ORDER':@FM:'AA.ARR.PAYMENT.SCHEDULE':@FM:'FT.APPL.DEFAULT'
    LR.FLDS = 'L.LOAN.ARR.ID':@VM:'L.LOAN.ACCT.NO':@VM:'L.RETRY.DAYS':@FM
    LR.FLDS := 'L.AA.DEBT.AC':@VM:'L.AA.PAY.METHD':@FM
    LR.FLDS := 'L.RETRY.DAYS'
    LRF.POS = ''

    CALL MULTI.GET.LOC.REF(APP.LST,LR.FLDS,LRF.POS)

    POS.LOAN.ARR = LRF.POS<1,1>
    POS.LOAN.ACCT.NO = LRF.POS<1,2>
    POS.RETRY.DAYS = LRF.POS<1,3>
    POS.DEB.ACC = LRF.POS<2,1>
    POS.PAY.METHOD = LRF.POS<2,2>
    POS.RETRY.DAY.FT = LRF.POS<3,1>

RETURN

*-------
PROCESS:
*-------
*------------------------------------------------------------------
* This section updates the necesary fields in STANDING.ORDER record
*------------------------------------------------------------------

    DR.ACC = R.NEW(FT.DEBIT.ACCT.NO)
    CALL F.READ(FN.ACCOUNT,DR.ACC,R.ACCOUNT,F.ACCOUNT,AC.ERR)
    ARR.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    Y.ARRANGEMENT.ID=ARR.ID
    PROP.CLASS='PAYMENT.SCHEDULE'
    PROPERTY=''
    R.Condition.Pay=''
    ERR.MSG=''
    APAP.AA.redoCrrGetConditions(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition.Pay,ERR.MSG);* R22 Manual conversion

    IF R.Condition.Pay<AA.PS.LOCAL.REF,POS.PAY.METHOD> NE 'Direct Debit' THEN
        RETURN
    END

    STO.ID = R.Condition.Pay<AA.PS.LOCAL.REF,POS.DEB.ACC>
    PAY.FREQ = R.Condition.Pay<AA.PS.PAYMENT.FREQ,1>

    R.STANDING.ORDER<STO.TYPE> = "FI"
    R.STANDING.ORDER<STO.PAY.METHOD> = "ACPY"
    R.STANDING.ORDER<STO.LOCAL.REF,POS.LOAN.ARR> = Y.ARRANGEMENT.ID

    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARRANGEMENT.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ERR.AA.ARR.CUS)
    R.STANDING.ORDER<STO.CURRENCY> = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>

    GOSUB UPDATE.CUR.AMT.BAL
    R.STANDING.ORDER<STO.PRINT.ADVICE> = 'NO'
    GOSUB UPDATE.STO.END.DATE
    GOSUB UPDATE.CR.ACCT
    CALL F.READ(FN.FT.APPL.DEFAULT,ID.COMPANY,R.FT.APPL.DEFAULT,F.FT.APPL.DEFAULT,ERR.FT.APP)
    R.STANDING.ORDER<STO.LOCAL.REF,POS.RETRY.DAYS> = R.FT.APPL.DEFAULT<FT1.LOCAL.REF,POS.RETRY.DAY.FT>
    GOSUB UPDATE.COMM.DET
    R.STANDING.ORDER<STO.CUR.AMT.ROUTINE> = 'REDO.CHK.STO.STATUS.COND'
    R.STANDING.ORDER<STO.FT.ROUTINE> = '@REDO.UPD.FT.RESUB'
    GOSUB CREATE.STO

RETURN

*------------------
UPDATE.CUR.AMT.BAL:
*------------------
*--------------------------------------------------------------------
* This section updates the CURRENT.AMOUNT.BAL field of STANDING.ORDER
*--------------------------------------------------------------------

    FIRST.DUE.DATE = ''
    DUE.DATE.CNT = 0
    CUR.AMT.BAL = 0
    CALL AA.SCHEDULE.PROJECTOR(ARR.ID, SIM.REF, "", CYCLE.DATE, TOT.PAYMENT, DUE.DATES, DUE.TYPES, DUE.DEFER.DATES, DUE.METHODS, DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
    LOOP
        DUE.DATE.CNT += 1 ;** R22 Auto Conversion
        REMOVE DUE.DATE FROM DUE.DATES SETTING DUE.DATE.POS
    WHILE DUE.DATE:DUE.DATE.POS
        IF DUE.DATE GT TODAY THEN
            IF FIRST.DUE.DATE EQ '' THEN
                FIRST.DUE.DATE = DUE.DATE
            END ELSE
                IF FIRST.DUE.DATE NE DUE.DATE THEN
                    BREAK
                END
            END
        END
        CUR.AMT.BAL += TOT.PAYMENT<DUE.DATE.CNT>
    REPEAT
    R.STANDING.ORDER<STO.CURRENT.AMOUNT.BAL> = CUR.AMT.BAL
    R.STANDING.ORDER<STO.CURRENT.FREQUENCY> = PAY.FREQ
RETURN

*--------------
UPDATE.CR.ACCT:
*--------------
*--------------------------------------------------------------------------------------------------------
* This section updates the CPTY.ACCT.NO field of and local reference field LOAN.ACCT.NO of STANDING.ORDER
*--------------------------------------------------------------------------------------------------------

    ARR.LINK.APP = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>
    LOCATE 'ACCOUNT' IN ARR.LINK.APP SETTING APPL.POS THEN
        R.STANDING.ORDER<STO.CPTY.ACCT.NO> = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID,APPL.POS>
        R.STANDING.ORDER<STO.LOCAL.REF,POS.LOAN.ACCT.NO> = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID,APPL.POS>
    END
RETURN

*-------------------
UPDATE.STO.END.DATE:
*-------------------
*--------------------------------------------------------------
* This section updates CURRENT.END.DATE field in STANDING.ORDER
*--------------------------------------------------------------

    PROP.CLASS='TERM.AMOUNT'
    PROPERTY=''
    R.Condition.Term=''
    ERR.MSG.TERM =''
    APAP.AA.redoCrrGetConditions(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition.Term,ERR.MSG.TERM);* R22 Manual conversion
    R.STANDING.ORDER<STO.CURRENT.END.DATE> = R.Condition.Term<AA.AMT.MATURITY.DATE>
RETURN

*---------------
UPDATE.COMM.DET:
*---------------
*-----------------------------------------------------------------
* This section updates COMMISSION related fields in STANDING.ORDER
*------------------------------------------------------------------

    CALL CACHE.READ(FN.FT.TXN.TYPE.CONDITION, 'ACRP', R.FT.TXN.TYPE.CONDITION, ERR.FT.TXN) ;** R22 Auto Conversion
    R.STANDING.ORDER<STO.COMMISSION.TYPE> = R.FT.TXN.TYPE.CONDITION<FT6.COMM.TYPES>
    R.STANDING.ORDER<STO.COMMISSION.CODE> = "DEBIT PLUS CHARGES"
    COMM.TYPE.CNT = DCOUNT(R.FT.TXN.TYPE.CONDITION<FT6.COMM.TYPES>,@VM)
    FOR COMM.TYPE.POS = 1 TO COMM.TYPE.CNT
        R.STANDING.ORDER<STO.COMM.FREQUENCY,COMM.TYPE.POS> = PAY.FREQ
    NEXT COMM.TYPE.POS
RETURN

*----------
CREATE.STO:
*----------
*-----------------------------------------------
* This section creates the STANDING.ORDER record
*-----------------------------------------------

    APP.NAME = 'STANDING.ORDER'
    OFSFUNCT = 'I'
    PROCESS  = 'PROCESS'
    OFSVERSION = 'STANDING.ORDER,REDO.CREATE'
    GTSMODE = ''
    NO.OF.AUTH = 0
    OFS.SOURCE.ID = 'REDO.OFS.STATUS.COND'

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,STO.ID,R.STANDING.ORDER,OFSRECORD)
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)

RETURN
END
