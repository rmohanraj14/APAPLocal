* @ValidationCode : MjotODAyMjk1NTkyOkNwMTI1MjoxNjgxMzkwODg4ODkxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:31:28
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
SUBROUTINE REDO.V.INP.CHECK.OUTSTANDING.AMT
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*  This routine is an Input routine attached to below versions,
*  REDO.AA.DISB.LOAN,DISBURSE
*
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
*-----------------------------------------------------------------------------
*   Date           who           Reference              Description
* 04--2011     Bharath G          N.45              INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO FM,++ TO +=1,VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
*-----------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.AA.DISB.LOAN
*-----------------------------------------------------------------------------
*
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
******
INIT:
******
* Initialize all the variables

    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    FN.AA.BILL.DETAILS='F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS=''
    Y.DISBURSED.AMOUNT=''
    Y.CHARGE.AMOUNT=0
    Y.AMOUNT=0

RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
*
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AA.ARRANGEMENT.ACTIVITY='F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY=''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
*
    Y.ARRANGEMENT.ID = R.NEW(DISB.LN.ARRANGEMENT.ID)
    DISB.AMOUNT = R.NEW(DISB.LN.TOT.DISB.AMT)

    IF DISB.AMOUNT LE 0 OR DISB.AMOUNT EQ '' THEN
        AF = DISB.LN.TOT.DISB.AMT
        ETEXT = 'EB-NOTHING.TO.DISBURSE'
        CALL STORE.END.ERROR
    END

    GOSUB CHARGE
    IF DISB.AMOUNT GT Y.OUTSTANDING.AMT THEN
        AF = DISB.LN.TOT.DISB.AMT
        ETEXT = 'EB-REDO.CHRG.CHK':@FM:FMT(Y.OUTSTANDING.AMT,"R2")
        CALL STORE.END.ERROR
    END

RETURN
*----------------------------------------------------------------------
CHARGE:
*----------------------------------------------------------------------
* This part gets the details of the arrangement
*
    PROP.CLASS='TERM.AMOUNT'
    PROPERTY=''
    R.Condition=''
    ERR.MSG=''
    CALL APAP.REDOVER.REDO.CRR.GET.CONDITIONS(Y.ARRANGEMENT.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    Y.COMMITMENT.AMOUNT=R.Condition<AA.AMT.AMOUNT>

*------------------------

* Here we gets the  outstanding principal from the customer

    OUT.PROPERTY = '' ;   OUT.ID = ''   ;  IN.ACC.ID = ''
    CALL APAP.REDOVER.REDO.GET.PROPERTY.NAME(Y.ARRANGEMENT.ID,'TERM.AMOUNT',R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR) ;* R22 Manual Conversion - CALL method format modified
    CALL APAP.REDOVER.REDO.CONVERT.ACCOUNT(IN.ACC.ID,Y.ARRANGEMENT.ID,OUT.ID,ERR.TEXT) ;* R22 Manual Conversion - CALL method format modified
    Y.PRIN.BAL = 0
    BALANCE.TO.CHECK="CUR":OUT.PROPERTY
    RET.ERROR = ''
    BALANCE.AMOUNT = ''
    CALL AA.GET.ECB.BALANCE.AMOUNT(OUT.ID,BALANCE.TO.CHECK,TODAY,BALANCE.AMOUNT,RET.ERROR)
    Y.OUTSTANDING.AMT = ABS(BALANCE.AMOUNT)

*-----------------------

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARRANGEMENT.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ERR.ACC.DET)
    Y.BILL.TYPE=R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>
    Y.BILL.ID=R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.SET.STATUS=R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>

    CHANGE @SM TO @FM IN Y.BILL.TYPE
    CHANGE @VM TO @FM IN Y.BILL.TYPE
    CHANGE @SM TO @FM IN Y.BILL.ID
    CHANGE @VM TO @FM IN Y.BILL.ID
    CHANGE @SM TO @FM IN Y.SET.STATUS
    CHANGE @VM TO @FM IN Y.SET.STATUS
    Y.BILL.COUNT=DCOUNT(Y.BILL.TYPE,@FM)
    VAR2=1
    LOOP
    WHILE VAR2 LE Y.BILL.COUNT
        IF Y.BILL.TYPE<VAR2> EQ "ACT.CHARGE" AND Y.SET.STATUS<VAR2> EQ 'UNPAID' THEN
            Y.BILL=Y.BILL.ID<VAR2>
            GOSUB AMOUNT.CALC
        END
        VAR2 += 1
    REPEAT

RETURN
*----------------------------------------------------------------------
AMOUNT.CALC:
*----------------------------------------------------------------------
* Calculates the amount for charges Bills
    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL,R.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
    Y.CHARGE.AMOUNT += R.BILL.DETAILS<AA.BD.OS.TOTAL.AMOUNT>

RETURN
*----------------------------------------------------------------------
END
