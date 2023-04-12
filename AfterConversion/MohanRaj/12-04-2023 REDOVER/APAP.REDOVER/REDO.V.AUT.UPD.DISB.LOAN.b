* @ValidationCode : MjoxMjMzNjcwODg4OkNwMTI1MjoxNjgxMzAxMjc5NDYyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:37:59
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
SUBROUTINE REDO.V.AUT.UPD.DISB.LOAN
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*  This routine is an AUTH routine attached to FUNDS.TRANSFER,BRANCH.TO.BRANCH to
*  to update REDO.AA.DISB.LOAN
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
*   Date               who           Reference            Description
* 04-28-2011          Bharath G         N.45              INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ALTERNATE.ACCOUNT
    $INSERT I_F.LOCKING
    $INSERT I_F.REDO.AA.DISB.LOAN
    $INSERT I_F.REDO.AA.DISBURSE.UPDATE
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM

    GOSUB INIT
    GOSUB UPD.REDO.AA.DISB.LOAN
    GOSUB UPD.REDO.AA.DISBURSE.UPDATE

RETURN
*-----------------------------------------------------------------------------
******
INIT:
******
* Initialize all the variables

    FN.REDO.AA.DISB.LOAN = 'F.REDO.AA.DISB.LOAN'
    F.REDO.AA.DISB.LOAN  = ''
    R.REDO.AA.DISB.LOAN  = ''
    CALL OPF(FN.REDO.AA.DISB.LOAN,F.REDO.AA.DISB.LOAN)

    FN.REDO.AA.DISBURSE.UPDATE = 'F.REDO.AA.DISBURSE.UPDATE'
    F.REDO.AA.DISBURSE.UPDATE = ''
    R.REDO.AA.DISBURSE.UPDATE = ''
    CALL OPF(FN.REDO.AA.DISBURSE.UPDATE,F.REDO.AA.DISBURSE.UPDATE)

    FN.AA.ARRANGEMENT = "F.AA.ARRANGEMENT"
    F.AA.ARRANGEMENT = ''
    R.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.LOCKING = 'F.LOCKING'
    F.LOCKING = ''
    R.LOCKING = ''
    CALL OPF(FN.LOCKING,F.LOCKING)

    Y.LOCK.ID = 'F.REDO.AA.DISBURSE.UPDATE'
    RETRY = ''

RETURN
*-----------------------------------------------------------------------------
UPD.REDO.AA.DISB.LOAN:
*-----------------------------------------------------------------------------
*
    Y.DISB.ID = R.NEW(FT.PAYMENT.DETAILS)<1,1>
    CALL F.READ(FN.REDO.AA.DISB.LOAN,Y.DISB.ID,R.REDO.AA.DISB.LOAN,F.REDO.AA.DISB.LOAN,DISB.LN.ERR)
    IF R.REDO.AA.DISB.LOAN THEN
        Y.CREDIT.ACCOUNT = R.NEW(FT.CREDIT.ACCT.NO)
        Y.BR.DISB.AC = R.REDO.AA.DISB.LOAN<DISB.LN.BR.DISB.AC>
        LOCATE Y.CREDIT.ACCOUNT IN Y.BR.DISB.AC<1,1> SETTING POS THEN
            R.REDO.AA.DISB.LOAN<DISB.LN.BR.DISB.REF,POS> = ID.NEW

        END
        CALL F.WRITE(FN.REDO.AA.DISB.LOAN,Y.DISB.ID,R.REDO.AA.DISB.LOAN)
    END

RETURN
*--------------------------------------------------------------------------------
UPD.REDO.AA.DISBURSE.UPDATE:
*--------------------------------------------------------------------------------
*
    Y.AA.ID = R.REDO.AA.DISB.LOAN<DISB.LN.ARRANGEMENT.ID>
    CALL F.READ(FN.AA.ARRANGEMENT,Y.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARRANGEMENT.ERR)
    IF R.AA.ARRANGEMENT THEN
        Y.CUST = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    END

    GOSUB GET.ID

    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.REF.ID> = Y.DISB.ID
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.ARR.REF.ID>  = R.REDO.AA.DISB.LOAN<DISB.LN.ARRANGEMENT.ID>
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.BRANCH.ID>   = R.NEW(FT.PAYMENT.DETAILS)<1,3>
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.INTERNAL.AC> = Y.CREDIT.ACCOUNT
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.TYPE>   = R.NEW(FT.PAYMENT.DETAILS)<1,4>
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.AMT>    = R.NEW(FT.DEBIT.AMOUNT)
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.CREDIT.ACC>  = ''
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.TRANS.REF>   = ''
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.CHEQUE.TYPE> = ''
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.BENEFICIARY> = Y.CUST
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.NARRATIVE>   = ''
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.REMARKS>     = R.REDO.AA.DISB.LOAN<DISB.LN.LOAN.CCY>
    R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.INDICATOR> = 'NOT.DISB'

    CALL F.WRITE(FN.REDO.AA.DISBURSE.UPDATE,Y.DISB.UPD.ID,R.REDO.AA.DISBURSE.UPDATE)

RETURN
*--------------------------------------------------------------------------------
GET.ID:
*--------------------------------------------------------------------------------
* update the LOCKING Application with the today's date and extract the SEQ.NO
*
    CALL F.READU(FN.LOCKING,Y.LOCK.ID,R.LOCKING,F.LOCKING,LOCK.ERR,RETRY)
    IF R.LOCKING EQ '' THEN
        SEQ.NO = '000001'
        R.LOCKING<EB.LOK.REMARK> = TODAY
        R.LOCKING<EB.LOK.CONTENT> = SEQ.NO
    END
    ELSE
        IF  R.LOCKING<EB.LOK.REMARK> EQ TODAY THEN
            Y.CONTENT = R.LOCKING<EB.LOK.CONTENT>
            SEQ.NO = Y.CONTENT + 1
            R.LOCKING<EB.LOK.CONTENT> = SEQ.NO
        END
        ELSE
            SEQ.NO = '000001'
            R.LOCKING<EB.LOK.REMARK> = TODAY
            R.LOCKING<EB.LOK.CONTENT> = SEQ.NO
        END
    END
    CALL F.WRITE(FN.LOCKING,Y.LOCK.ID,R.LOCKING)
    CALL JULDATE(TODAY,Y.JUL.DATE)
    Y.DISB.UPD.ID = Y.JUL.DATE:FMT(SEQ.NO,"R%6")

RETURN
*--------------------------------------------------------------------------
END
