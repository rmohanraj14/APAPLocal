* @ValidationCode : MjotMTY3NzIwMDQ2MjpDcDEyNTI6MTY4NTUyODI2MjgxNzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:47:42
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
SUBROUTINE REDO.AA.GET.INTERST.PAID
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used as post routine to post interest and charge with previous balance
*------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who                 Reference                                    Description
* 14-dec-2011          Prabhu.N            PACS00167681 and PACS00167681                 Initial Creation
* 24-01-2012           H GANESH            PACS00175283 -N.45                          Modified to add a condition to check the repay account has in
* 29-03-2023          CONVERSTION TOOL     R22 AUTO CONVERSTION                         VM TO @VM AND FM TO @FM
* 29-03-2023          ANIL KUMAR B         R22 MANUAL CONVERSTION                       CALL method format changed
*----------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.AA.INTEREST.CHARGE
    $INSERT I_F.REDO.L.NCF.STOCK
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $INSERT I_F.REDO.NCF.ISSUED
    $INSERT I_F.REDO.L.NCF.STATUS
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM

    IF c_aalocActivityStatus EQ 'AUTH' AND c_aalocArrActivityId EQ c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA> ELSE      ;* Routine should trigger during auth of master repayment activity.
        RETURN
    END
    GOSUB INIT
    GOSUB PROCESS
RETURN
*---------------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------------

    Y.ACCOUNT.ID              =c_aalocArrangementRec<AA.ARR.LINKED.APPL.ID>
    Y.TXN.ID                  =c_aalocArrActivityRec<AA.ARR.ACT.TXN.CONTRACT.ID>
    Y.TXN.SYSTEM.ID           =c_aalocArrActivityRec<AA.ARR.ACT.TXN.SYSTEM.ID>

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.REDO.NCF.ISSUED = 'F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED  = ''
    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)

    FN.REDO.L.NCF.STATUS = 'F.REDO.L.NCF.STATUS'
    F.REDO.L.NCF.STATUS  = ''
    CALL OPF(FN.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS)

    LOC.REF.APPLICATION   = "FUNDS.TRANSFER"
    LOC.REF.FIELDS        = 'L.NCF.NUMBER':@VM:'L.NCF.REQUIRED'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.NCF.NUMBER      = LOC.REF.POS<1,1>
    POS.L.NCF.REQUIRED    = LOC.REF.POS<1,2>

RETURN
*---------------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------------

    IF Y.TXN.SYSTEM.ID NE 'FT' THEN
        RETURN          ;* We need to process only for the parent activity with FT Ref.
    END

    CALL F.READ(FN.FUNDS.TRANSFER,Y.TXN.ID,R.FUNDS.TRANSFER,F.FUNDS.TRANSFER,FT.ERR)

    IF R.FUNDS.TRANSFER ELSE
        RETURN
* Below lines are commented because when FT txn is in INAU, then we will write to FT$NAU but we had problem with RECORD.STATUS field &
* also we had two records like one record in live and one record in INAU. So we will generate NCF for TELLER & COLLECTION area from FT AUTH routine
* REDO.V.AUT.AA.NCF.GEN, and we will generate NCF from ACTIVITY.API routine for DD, ARC & IVR(Zero auth version).
* CALL F.READ(FN.FUNDS.TRANSFER$NAU,Y.TXN.ID,R.FUNDS.TRANSFER,F.FUNDS.TRANSFER$NAU,FT.ERR)
* Y.FLAG = 'UNAUTH'
    END
    VAR.NCF.REQUIRED = R.FUNDS.TRANSFER<FT.LOCAL.REF,POS.L.NCF.REQUIRED>
    Y.NCF.NO         = R.FUNDS.TRANSFER<FT.LOCAL.REF,POS.L.NCF.NUMBER>
    IF VAR.NCF.REQUIRED EQ 'YES' AND Y.NCF.NO EQ '' ELSE      ;* Skip if it is not as YES & NCF no. is NULL i.e this FT is from DD or ARC or IVR.
        TEXT = 'REDO.INTERNAL.MSG':@FM:" NCF REQUIRED NOT SET IN FT"
        CALL STORE.OVERRIDE("")
        RETURN
    END

*PACS00175283 -N.45 -> S

    ACC.ID    = Y.ACCOUNT.ID
    TXN.REF   = Y.TXN.ID
    Y.AMT.RET = ""
    APAP.TAM.redoCheckInterestAmtNcf(ACC.ID,TXN.REF,Y.AMT.RET);* R22 Manual conversion
    IF Y.AMT.RET GT 0 ELSE      ;* Skip if parameterized balances not affected.
        TEXT = 'REDO.INTERNAL.MSG':@FM:" NCF AMOUNT IS ZERO SO NO NCF GENERATED"
        CALL STORE.OVERRIDE("")
        RETURN
    END

*PACS00175283 -N.45 -> E

    GOSUB GET.CORRECT.ACC.NO
    GOSUB GET.NCF
    GOSUB ASSIGN.NCF.FT


RETURN
*------------------------------------------------------------------
GET.CORRECT.ACC.NO:
*------------------------------------------------------------------
* Initially: Here we will get the debit account no. from FT transaction else we will use the credit acc no(i.e Loan acc no).
* Later    : For loan payment, TAX amount should refer DR customer, and AA interest + charge will be CR Customer.

*IF NUM(R.FUNDS.TRANSFER<FT.DEBIT.ACCT.NO>) THEN
*Y.ACC.NO   = R.FUNDS.TRANSFER<FT.DEBIT.ACCT.NO>
*Y.CUSTOMER = R.FUNDS.TRANSFER<FT.DEBIT.CUSTOMER>
*END ELSE
*Y.ACC.NO   = R.FUNDS.TRANSFER<FT.CREDIT.ACCT.NO>
*Y.CUSTOMER = R.FUNDS.TRANSFER<FT.CREDIT.CUSTOMER>
*END

    Y.ACC.NO   = R.FUNDS.TRANSFER<FT.CREDIT.ACCT.NO>
    Y.CUSTOMER = R.FUNDS.TRANSFER<FT.CREDIT.CUSTOMER>

RETURN

*--------------------------------------------------------------------------
GET.NCF:
*--------------------------------------------------------------------------
* Here we will get the NCF no. by calling the generic routine based on the user who performs the transaction.
* It may return the NCF no. assigned for that user else from the generic NCF stock.

    Y.REQ.CNT = 1
    Y.NCF.ID  = ""
    APAP.TAM.redoNcfPerfRtn(Y.REQ.CNT,Y.NCF.NUMBER);* R22 Manual conversion

    IF Y.NCF.NUMBER ELSE
        TEXT = 'REDO.INTERNAL.MSG':@FM:" NCF ID NOT GENERATED BY API"
        CALL STORE.OVERRIDE("")
        GOSUB END1
    END

RETURN
*---------------------------------------------------------------------------
ASSIGN.NCF.FT:
*---------------------------------------------------------------------------
*Here we will not handle the unmapped NCF, since API will return the NCF for sure.

    R.NCF.ISSUED   = ''
    R.NCF.STATUS   = ''
    Y.NCF.ID = Y.CUSTOMER:'.':R.FUNDS.TRANSFER<FT.CREDIT.VALUE.DATE>:'.':Y.TXN.ID
    CALL F.READ(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.NCF.ISSUED,F.REDO.NCF.ISSUED,NCF.ERR)
    CALL F.READ(FN.REDO.L.NCF.STATUS,Y.NCF.ID,R.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.ERR)

    R.NCF.ISSUED<ST.IS.TXN.ID>          = Y.TXN.ID
    R.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>   = Y.AMT.RET
    R.NCF.ISSUED<ST.IS.ACCOUNT>         = Y.ACC.NO
    R.NCF.ISSUED<ST.IS.CUSTOMER>        = Y.CUSTOMER
    R.NCF.ISSUED<ST.IS.TXN.TYPE>        = R.FUNDS.TRANSFER<FT.TRANSACTION.TYPE>
    R.NCF.ISSUED<ST.IS.DATE>            = R.FUNDS.TRANSFER<FT.CREDIT.VALUE.DATE>
    NCF.IS.CNT                          = DCOUNT(R.NCF.ISSUED<ST.IS.NCF>,@VM)
    R.NCF.ISSUED<ST.IS.NCF,NCF.IS.CNT+1>= Y.NCF.NUMBER

    R.NCF.STATUS<NCF.ST.TRANSACTION.ID> = Y.TXN.ID
    R.NCF.STATUS<NCF.ST.CUSTOMER.ID>    = Y.CUSTOMER
    R.NCF.STATUS<NCF.ST.STATUS>         = 'AVAILABLE'
    R.NCF.STATUS<NCF.ST.DATE>           = R.FUNDS.TRANSFER<FT.CREDIT.VALUE.DATE>
    R.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>  = Y.AMT.RET
    NCF.CNT                             = DCOUNT(R.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.NCF.STATUS<NCF.ST.NCF,NCF.CNT+1>  = Y.NCF.NUMBER

    GOSUB WRITE.NCF

RETURN
*---------
WRITE.NCF:
*---------

    R.FUNDS.TRANSFER<FT.LOCAL.REF,POS.L.NCF.NUMBER,-1> = Y.NCF.NUMBER
    CALL F.WRITE(FN.FUNDS.TRANSFER,Y.TXN.ID,R.FUNDS.TRANSFER)
    CALL F.WRITE(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.NCF.ISSUED)
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,Y.NCF.ID,R.NCF.STATUS)

RETURN
*---------
END1:
*---------
END
