* @ValidationCode : MjoxNTIwMjQ0Nzk5OkNwMTI1MjoxNjg1NTMyNzI4OTk2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 17:02:08
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
SUBROUTINE REDO.V.AUT.AA.NCF.GEN
*-----------------------------------------------------------------------------
*DESCRIPTION:This AUTH routine will assign NCF for the AA advance payment
* ------------------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : Y.CUSTOMER.ID
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
* 26-MAR-2010        Prabhu.N       ODR-2009-10-0321     Initial Creation
* 23-07-2010         Prabhu.N       ODR-2010-01-0081-N.82 Code Added to update NCF number to field L.NCF.NUMBER
** 30-03-2023       Conversion Tool R22 Auto Conversion     FM TO @FM, VM to @VM, SM to @SM
** 30-03-2023       Skanda          R22 Manual Conversion   CALL method format changed
*---------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.NCF.ISSUED
    $INSERT I_F.REDO.L.NCF.STATUS
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $USING APAP.TAM
    IF (R.NEW(FT.RECORD.STATUS)[1,2] EQ "IN" OR V$FUNCTION EQ "I") THEN ;* During Input, Logic to handle both single and zero Auth.
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN
*---------------------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------------------

    FN.REDO.L.NCF.ISSUED = 'F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED    = ''
    CALL OPF(FN.REDO.L.NCF.ISSUED,F.REDO.L.NCF.ISSUED)

    FN.REDO.L.NCF.STATUS = 'F.REDO.L.NCF.STATUS'
    F.REDO.L.NCF.STATUS  = ''
    CALL OPF(FN.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS)

    FN.REDO.L.NCF.UNMAPPED = 'F.REDO.L.NCF.UNMAPPED'
    F.REDO.L.NCF.UNMAPPED  = ''
    CALL OPF(FN.REDO.L.NCF.UNMAPPED,F.REDO.L.NCF.UNMAPPED)

    LOC.REF.APPLICATION   = "FUNDS.TRANSFER"
    LOC.REF.FIELDS        = 'L.NCF.NUMBER':@VM:'L.NCF.REQUIRED':@VM:'L.TT.TAX.CODE':@VM:'L.TT.WV.TAX':@VM:'L.TT.TAX.AMT':@VM:'L.NCF.TAX.NUM'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.L.NCF.NUMBER      = LOC.REF.POS<1,1>
    POS.L.NCF.REQUIRED    = LOC.REF.POS<1,2>
    POS.L.TT.TAX.CODE     = LOC.REF.POS<1,3>
    POS.L.TT.WV.TAX       = LOC.REF.POS<1,4>
    POS.L.TT.TAX.AMT      = LOC.REF.POS<1,5>
    POS.L.NCF.TAX.NUM     = LOC.REF.POS<1,6>

    R.REDO.NCF.ISSUED = ""
    R.REDO.NCF.STATUS = ""

RETURN

*---------------------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------------------
* AA NCD generation main process begins here.


    IF R.NEW(FT.LOCAL.REF)<1,POS.L.NCF.REQUIRED> EQ "YES" ELSE
        RETURN
    END
    GOSUB CHECK.IF.TAX.APPLICABLE
    GOSUB CHECK.AA.INT.APPLICABLE


    Y.NCF.CNT = (Y.GENERATE.NCF.TAX + Y.GENERATE.AA.NCF)
    IF Y.NCF.CNT GT 0 THEN
        GOSUB GET.GENERIC.INFO
        Y.NCF.NOS = ""
        APAP.TAM.redoNcfPerfRtn(Y.NCF.CNT,Y.NCF.NOS);* R22 Manual conversion
        IF Y.NCF.NOS EQ "" THEN
            GOSUB UPDATE.NCF.UNMAPPED
            RETURN
        END
    END ELSE
        RETURN
    END

    GOSUB FORM.NCF.ARRAY


    IF Y.GENERATE.NCF.TAX THEN
        REMOVE Y.NCF.NUMBER FROM Y.NCF.NOS SETTING DELIM
        R.REDO.NCF.ISSUED<ST.IS.NCF,-1>          = Y.NCF.NUMBER
        R.REDO.NCF.ISSUED<ST.IS.TAX.AMOUNT>      = Y.TAX.AMOUNT
        R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>   = Y.TAX.AMOUNT
        R.NEW(FT.LOCAL.REF)<1,POS.L.NCF.TAX.NUM> = Y.NCF.NUMBER
    END
    IF Y.GENERATE.AA.NCF THEN
        REMOVE Y.NCF.NUMBER FROM Y.NCF.NOS SETTING DELIM
        R.REDO.NCF.ISSUED<ST.IS.NCF,-1>           = Y.NCF.NUMBER
        R.REDO.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>    = Y.AA.CHARGE
        R.REDO.L.NCF.STATUS<NCF.ST.CHARGE.AMOUNT> = Y.AA.CHARGE
        R.NEW(FT.LOCAL.REF)<1,POS.L.NCF.NUMBER>   = Y.NCF.NUMBER
    END
    CALL F.WRITE(FN.REDO.L.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED)
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
RETURN
*---------------------------------------------------------------------------------------------
CHECK.IF.TAX.APPLICABLE:
*---------------------------------------------------------------------------------------------
* Check whether we need to generate the NCF for TAX amount. Assuming that only one TAX per txn. so we will not mulit-value the tax code.

    Y.GENERATE.NCF.TAX = ""
    IF R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.CODE> NE "" AND R.NEW(FT.LOCAL.REF)<1,POS.L.TT.WV.TAX> NE "YES" AND R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.AMT> THEN

        Y.GENERATE.NCF.TAX = "1"

    END

RETURN
*---------------------------------------------------------------------------------------------
CHECK.AA.INT.APPLICABLE:
*---------------------------------------------------------------------------------------------
* In NV Chain, we will put the FT transaction in INAU then we will commit in the fast path enquiry, so we will have records in
* AA.ACTIVITITY.BALANCE for this txn. so that we can get the NCF balances affected for this txn. So by calling the API we will get the
* amount for this transaction.

    Y.GENERATE.AA.NCF = ""
    ACC.ID  = R.NEW(FT.CREDIT.ACCT.NO)
    TXN.REF = ID.NEW
    APAP.TAM.redoCheckInterestAmtNcf(ACC.ID,TXN.REF,Y.AMT.RET);* R22 Manual conversion

    IF Y.AMT.RET THEN
        Y.GENERATE.AA.NCF = "1"
    END

RETURN
*---------------------------------------------------------------------------------------------
UPDATE.NCF.UNMAPPED:
*---------------------------------------------------------------------------------------------
* If NCF no. is returned by the API then we need to update in NCF unmapped table.

    R.REDO.L.NCF.UNMAPPED = ""
    R.REDO.L.NCF.UNMAPPED<ST.UN.TXN.ID>          =  ID.NEW
    R.REDO.L.NCF.UNMAPPED<ST.UN.CHARGE.AMOUNT>   =  Y.AA.CHARGE
    R.REDO.L.NCF.UNMAPPED<ST.UN.TXN.TYPE>        =  Y.TXN.TYPE
    R.REDO.L.NCF.UNMAPPED<ST.UN.TAX.AMOUNT>      =  Y.TAX.AMOUNT
    R.REDO.L.NCF.UNMAPPED<ST.UN.DATE>            =  Y.DATE
    R.REDO.L.NCF.UNMAPPED<ST.UN.CUSTOMER>        =  Y.CUSTOMER.ID
    R.REDO.L.NCF.UNMAPPED<ST.UN.ACCOUNT>         =  Y.ACCOUNT
    R.REDO.L.NCF.UNMAPPED<ST.UN.BATCH>           =  'NO'
    CALL F.WRITE(FN.REDO.L.NCF.UNMAPPED,NCF.ISSUE.ID,R.REDO.L.NCF.UNMAPPED)

RETURN
*---------------------------------------------------------------------------------------------
GET.GENERIC.INFO:
*---------------------------------------------------------------------------------------------
* Here we will form all the generic information for generating the NCF.

    IF R.NEW(FT.DEBIT.CUSTOMER) THEN      ;* In NV, we will have debit account as WT, so we will use credit cus.. in case of ARC then we will use debit customer.
        Y.CUSTOMER.ID = R.NEW(FT.DEBIT.CUSTOMER)
        Y.ACCOUNT     = R.NEW(FT.DEBIT.ACCT.NO)
    END ELSE
        Y.CUSTOMER.ID = R.NEW(FT.CREDIT.CUSTOMER)
        Y.ACCOUNT     = R.NEW(FT.CREDIT.ACCT.NO)
    END
    Y.TAX.AMOUNT     = SUM(R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.AMT>)
    Y.AA.CHARGE      = Y.AMT.RET
    Y.TXN.TYPE       = R.NEW(FT.TRANSACTION.TYPE)
    Y.DATE           = R.NEW(FT.CREDIT.VALUE.DATE)

RETURN
*---------------------------------------------------------------------------------------------
FORM.NCF.ARRAY:
*---------------------------------------------------------------------------------------------
* Form the generic array.

    R.REDO.NCF.ISSUED   = ""
    R.REDO.L.NCF.STATUS = ""

    R.REDO.NCF.ISSUED<ST.IS.TXN.ID>              = ID.NEW
    R.REDO.NCF.ISSUED<ST.IS.ACCOUNT>             = Y.ACCOUNT
    R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>            = Y.CUSTOMER.ID
    R.REDO.NCF.ISSUED<ST.IS.TXN.TYPE>            = Y.TXN.TYPE
    R.REDO.NCF.ISSUED<ST.IS.DATE>                = Y.DATE

    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>   = ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>      = Y.CUSTOMER.ID
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>             = Y.DATE
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>           = 'AVAILABLE'
    NCF.ISSUE.ID = Y.CUSTOMER.ID:'.':Y.DATE:'.':ID.NEW
RETURN
END
