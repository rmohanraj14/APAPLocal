* @ValidationCode : Mjo1NzI4NDU1NTU6Q3AxMjUyOjE2ODEzOTA3OTk5NjQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:29:59
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
SUBROUTINE REDO.V.DEF.TT.LOAN.STATUS.COND
*-------------------------------------------------------------------------------------------
*DESCRIPTION:
*             This routine is attached as routine to the ACCOUNT.2 field of teller versions
* used for payment.  The functionality of this routine is to display the values in TELLER local reference fields
* L.LOAN.STATUS.1 and L.LOAN.COND for the given arrangement id by fetching the values from AA.OVERDUE application
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
* 07-JUN-2010   N.Satheesh Kumar   ODR-2009-10-0331      Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM,VM TO @VM,SM TO @SM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*---------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.TELLER
    $INSERT I_GTS.COMMON
    $INSERT I_EB.TRANS.COMMON
    $INSERT I_F.AA.ARRANGEMENT


*    IF OFS$OPERATION EQ 'VALIDATE' THEN
*        RETURN
*    END


*Return in Commit stage
    IF cTxn_CommitRequests EQ '1' THEN
        RETURN
    END

    IF MESSAGE EQ 'VAL' THEN
        RETURN
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

    LR.APP = 'AA.PRD.DES.OVERDUE':@FM:'TELLER'
    LR.FLDS = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@FM
    LR.FLDS := 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    LR.POS = ''
    CALL MULTI.GET.LOC.REF(LR.APP,LR.FLDS,LR.POS)

    OD.LOAN.STATUS.POS = LR.POS<1,1>
    OD.LOAN.COND.POS =  LR.POS<1,2>
    TT.LOAN.STATUS.POS = LR.POS<2,1>
    TT.LOAN.COND.POS =  LR.POS<2,2>

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

RETURN

*-------
PROCESS:
*-------
*----------------------------------------------------------------------------------------------------------------------------------------
* This section gets the latest overdue record for the arrangement id and stores the value of loan status and condition in R.NEW of TELLER
*----------------------------------------------------------------------------------------------------------------------------------------
    ACC.ID=COMI

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
        R.NEW(TT.TE.LOCAL.REF)<1,TT.LOAN.COND.POS> = LOAN.COND1
        Y.START.VAL += 1
    REPEAT
    R.NEW(TT.TE.LOCAL.REF)<1,TT.LOAN.STATUS.POS> = LOAN.STATUS
RETURN
END
