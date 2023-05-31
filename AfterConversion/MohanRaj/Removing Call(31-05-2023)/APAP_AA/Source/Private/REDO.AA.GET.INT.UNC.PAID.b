* @ValidationCode : Mjo1MjY3ODk3MDM6Q3AxMjUyOjE2ODU1MjgxODAwOTM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 15:46:20
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
SUBROUTINE REDO.AA.GET.INT.UNC.PAID
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
*   Date               who           Reference                                    Description
* 14-dec-2011          Prabhu.N     PACS00167681 and PACS00167681                 Initial Creation
* 24-01-2012           H GANESH       PACS00175283 -N.45                          Modified to add a condition to check the repay account has in
* 29-03-2023          CONVERSTION TOOL      R22 AUTO CONVERSTION                    VM TO @VM AND FM TO @FM
* 29-03-2023          ANIL KUMAR B          R22 MANUAL CONVERSTION                  CALL method format changed

*----------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
    $INSERT I_AA.APP.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.AA.INTEREST.CHARGE
    $INSERT I_F.REDO.L.NCF.STOCK
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $INSERT I_F.REDO.NCF.ISSUED
    $INSERT I_F.REDO.L.NCF.STATUS
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM

    IF c_aalocActivityStatus EQ 'AUTH' ELSE       ;*AND c_aalocArrActivityId EQ c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA> ELSE    ;* Routine should trigger during auth of master repayment activity.
        IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
            GOSUB DELETE.EXISTING.NCF
        END
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
    Y.TXNREF = c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA>

    FN.REDO.NCF.ISSUED = 'F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED  = ''
    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)

    FN.REDO.L.NCF.STATUS = 'F.REDO.L.NCF.STATUS'
    F.REDO.L.NCF.STATUS  = ''
    CALL OPF(FN.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

RETURN
*---------------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------------

    ACC.ID    = Y.ACCOUNT.ID
    TXN.REF   = Y.TXN.ID

    Y.AMT.RET = ""
    APAP.TAM.redoChkIntUncAmtNcf(ACC.ID,TXN.REF,Y.AMT.RET);* R22 Manual conversion


    IF Y.AMT.RET GT 0 ELSE    ;* Skip if parameterized balances not affected.
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

    Y.ACC.NO   = Y.ACCOUNT.ID
    CALL F.READ(FN.ACCOUNT, Y.ACC.NO, R.ACCOUNT, F.ACCOUNT, Y.ERR.AC)
    Y.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>

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
    Y.TXN.ID = c_aalocArrActivityId
    R.NCF.ISSUED   = ''
    R.NCF.STATUS   = ''
*Y.NCF.ID = Y.CUSTOMER:'.':TODAY:'.':Y.TXN.ID
    Y.EFFECTIVE.DATE = c_aalocArrActivityRec<AA.ARR.ACT.EFFECTIVE.DATE>
    Y.NCF.ID =Y.CUSTOMER:'.':Y.EFFECTIVE.DATE:'.':Y.TXN.ID

    CALL F.READ(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.NCF.ISSUED,F.REDO.NCF.ISSUED,NCF.ERR)
    CALL F.READ(FN.REDO.L.NCF.STATUS,Y.NCF.ID,R.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.ERR)

    R.NCF.ISSUED<ST.IS.TXN.ID>          = Y.TXN.ID
    R.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>   = Y.AMT.RET
    R.NCF.ISSUED<ST.IS.ACCOUNT>         = Y.ACC.NO
    R.NCF.ISSUED<ST.IS.CUSTOMER>        = Y.CUSTOMER
    R.NCF.ISSUED<ST.IS.TXN.TYPE>        = 'N/A'
    R.NCF.ISSUED<ST.IS.DATE>            = TODAY
    NCF.IS.CNT                          = DCOUNT(R.NCF.ISSUED<ST.IS.NCF>,@VM)
    R.NCF.ISSUED<ST.IS.NCF,NCF.IS.CNT+1>= Y.NCF.NUMBER

    R.NCF.STATUS<NCF.ST.TRANSACTION.ID> = Y.TXN.ID
    R.NCF.STATUS<NCF.ST.CUSTOMER.ID>    = Y.CUSTOMER
    R.NCF.STATUS<NCF.ST.STATUS>         = 'AVAILABLE'
    R.NCF.STATUS<NCF.ST.DATE>           = TODAY
    R.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>  = Y.AMT.RET
    NCF.CNT                             = DCOUNT(R.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.NCF.STATUS<NCF.ST.NCF,NCF.CNT+1>  = Y.NCF.NUMBER

    GOSUB WRITE.NCF

RETURN
*---------
WRITE.NCF:
*---------
*  WRITE R.NCF.ISSUED TO F.REDO.NCF.ISSUED,Y.NCF.ID
*  WRITE R.NCF.STATUS TO F.REDO.L.NCF.STATUS,Y.NCF.ID
    CALL F.WRITE(FN.REDO.NCF.ISSUED,Y.NCF.ID,R.NCF.ISSUED)
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,Y.NCF.ID,R.NCF.STATUS)

RETURN
*-------------------
DELETE.EXISTING.NCF:
*-------------------
    GOSUB INIT
    Y.EFFECTIVE.DATE = c_aalocArrActivityRec<AA.ARR.ACT.EFFECTIVE.DATE>
    Y.TXN.ID = c_aalocArrActivityId
    GOSUB GET.CORRECT.ACC.NO
    NCF.ID.DEL=Y.CUSTOMER:'.':Y.EFFECTIVE.DATE:'.':Y.TXN.ID
*  DELETE F.REDO.L.NCF.STATUS, NCF.ID.DEL
*  DELETE F.REDO.NCF.ISSUED, NCF.ID.DEL

    CALL F.DELETE(FN.REDO.L.NCF.STATUS,NCF.ID.DEL)
    CALL F.DELETE(FN.REDO.NCF.ISSUED,NCF.ID.DEL)
RETURN
*---------
END1:
*---------
END
