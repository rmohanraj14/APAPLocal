* @ValidationCode : MjoxMjU3OTk4NDkzOkNwMTI1MjoxNjgxMzkwNzIxMzExOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:28:41
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.DEF.TEMP.STATUS.COND.DISB
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This is the internal call routine which updates the value of the local reference fields
* L.LOAN.STATUS.1 & L.LOAN.COND in REDO.FT.TT.TRSANSACTION application
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : REDO.CRR.GET.CONDITIONS
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 05-JUN-2017   Edwin Charles       R15 Upgrade           Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT

    IF cTxn_CommitRequests EQ '1' THEN
        RETURN
    END

    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.COMI = COMI
    IF Y.COMI[1,2] EQ 'AA' THEN
        CALL F.READ(FN.AA.ARRANGEMENT,Y.COMI,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARR.ERR)
        IF NOT(R.AA.ARRANGEMENT) THEN
            AF = FT.TN.CREDIT.ACCT.NO
            ETEXT = 'AA-MISSING.ARRANGEMENT.ID'
            CALL STORE.END.ERROR
        END
    END ELSE
        CALL F.READ(FN.ACCOUNT,Y.COMI,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        IF R.ACCOUNT THEN
            IF NOT(R.ACCOUNT<AC.ARRANGEMENT.ID>) THEN
                AF = FT.TN.CREDIT.ACCT.NO
                ETEXT = 'EB-NOT.ARRANGEMENT.ID'
                CALL STORE.END.ERROR
            END
        END
    END
    GOSUB GET.LRF.POS
    GOSUB PROCESS
RETURN

*-----------
GET.LRF.POS:
*-----------
*----------------------------------------------------------------------
* This section gets the position of the local reference field positions
*----------------------------------------------------------------------

    LR.APP = 'AA.PRD.DES.OVERDUE'
    LR.FLDS = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@FM
    LR.POS = ''
    CALL MULTI.GET.LOC.REF(LR.APP,LR.FLDS,LR.POS)

    OD.LOAN.STATUS.POS = LR.POS<1,1>
    OD.LOAN.COND.POS =  LR.POS<1,2>

RETURN

*-------
PROCESS:
*-------
*------------------------------------------------------------------------------------------------------------------------------------
* This section gets the latest overdue record for the arrangement id and stores the value of loan status and condition in R.NEW of FT
*------------------------------------------------------------------------------------------------------------------------------------

** PACS00082427 - S
    IF PGM.VERSION EQ ',REDO.MULTI.AA.ACRP.DISB' OR PGM.VERSION EQ ',REDO.MULTI.REPAY.CHQ.DISB' OR PGM.VERSION EQ ',REDO.MULTI.AA.ACCRAP.DISB' THEN
        CALL APAP.REDOVER.REDO.V.VAL.DEFAULT.AMT ;* R22 Manual Conversion - CALL method format modified
    END
** PACS00082427 - E
    ACC.ID =  COMI
    PROP.CLASS = 'OVERDUE'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    EFF.DATE = ''
    CALL APAP.REDOVER.REDO.CONVERT.ACCOUNT(ACC.ID,Y.ARR.ID,ARR.ID,ERR.TEXT) ;* R22 Manual Conversion - CALL method format modified
    CALL APAP.REDOVER.REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    LOAN.STATUS = R.Condition<AA.OD.LOCAL.REF,OD.LOAN.STATUS.POS>
    LOAN.COND = R.Condition<AA.OD.LOCAL.REF,OD.LOAN.COND.POS>
    CHANGE @SM TO @VM IN LOAN.STATUS
    CHANGE @SM TO @FM IN LOAN.COND
    Y.CNT = DCOUNT(LOAN.COND,@FM)
    Y.START.VAL =1
    LOOP
    WHILE Y.START.VAL LE Y.CNT
        LOAN.COND1<-1> = LOAN.COND<Y.START.VAL>
        LOAN.COND1 = CHANGE(LOAN.COND1,@FM,@SM)
        R.NEW(FT.TN.L.LOAN.COND) = LOAN.COND1
        Y.START.VAL += 1
    REPEAT
    R.NEW(FT.TN.L.LOAN.STATUS.1) = LOAN.STATUS
    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARR.ERR)
    Y.CURR = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
**PACS00112741 -S
    R.NEW(FT.TN.CREDIT.CURRENCY) = Y.CURR
**PACS00112741 -E
RETURN
END
