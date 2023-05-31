* @ValidationCode : MjotOTE0Nzg5MTY4OkNwMTI1MjoxNjgwMTg3NzU4MDg0OklUU1M6LTE6LTE6MTc5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 179
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.OVERPAYMENT(Y.REF.ID)
*-------------------------------------------------
*Description: This batch routine is to post the FT OFS messages for overpayment
*             and also to credit the interest in loan.
*-------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       FM TO @FM
* 29-MAR-2023      Harishvikram C     Manual R22 conversion       No changes

*-------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.AA.OVERPAYMENT
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_F.REDO.AA.OVERPAYMENT.PARAM
    $INSERT I_REDO.B.AA.OVERPAYMENT.COMMON

    GOSUB PROCESS
RETURN
*-------------------------------------------------
PROCESS:
*-------------------------------------------------

    CALL F.READ(FN.REDO.AA.OVERPAYMENT,Y.REF.ID,R.REDO.AA.OVERPAYMENT,F.REDO.AA.OVERPAYMENT,OVER.ERR)
    CALL OCOMO("Processing the id -":Y.REF.ID:" - ":R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.NO>)

    GOSUB FORM.OFS


RETURN
*-------------------------------------------------
FORM.OFS:
*-------------------------------------------------


    Y.DUE.DATE    = R.REDO.AA.OVERPAYMENT<REDO.OVER.NEXT.DUE.DATE>
    Y.OVERPAY.AMT = R.REDO.AA.OVERPAYMENT<REDO.OVER.AMOUNT>
    Y.INT.AMT     = R.REDO.AA.OVERPAYMENT<REDO.OVER.TOT.COMP.INTEREST>
    Y.CURRENCY    = R.REDO.AA.OVERPAYMENT<REDO.OVER.CURRENCY>
    Y.LOAN.ACC    = R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.NO>


    R.FT.OVERPAY  = ""

    R.FT.OVERPAY<FT.DEBIT.CURRENCY>    = Y.CURRENCY
    R.FT.OVERPAY<FT.DEBIT.AMOUNT>      = Y.OVERPAY.AMT
    R.FT.OVERPAY<FT.DEBIT.VALUE.DATE>  = Y.DUE.DATE
    R.FT.OVERPAY<FT.CREDIT.ACCT.NO>    = Y.LOAN.ACC
    R.FT.OVERPAY<FT.CREDIT.VALUE.DATE> = Y.DUE.DATE
    R.FT.OVERPAY<FT.ORDERING.CUST>     = Y.REF.ID

    GOSUB GET.PL.CATEGORY
    R.FT.INTEREST = ""
    R.FT.INTEREST<FT.DEBIT.ACCT.NO>    = "PL":Y.PL.CATEGORY
    R.FT.INTEREST<FT.DEBIT.CURRENCY>   = Y.CURRENCY
    R.FT.INTEREST<FT.DEBIT.AMOUNT>     = Y.INT.AMT
    R.FT.INTEREST<FT.CREDIT.ACCT.NO>   = Y.LOAN.ACC
    IF BATCH.DETAILS<3,1,1> EQ "DUE.DATE" THEN
        R.FT.INTEREST<FT.DEBIT.VALUE.DATE> = Y.DUE.DATE
        R.FT.INTEREST<FT.CREDIT.VALUE.DATE>= Y.DUE.DATE
    END ELSE
        R.FT.INTEREST<FT.DEBIT.VALUE.DATE> = TODAY
        R.FT.INTEREST<FT.CREDIT.VALUE.DATE>= TODAY
    END
    R.FT.INTEREST<FT.ORDERING.CUST>    = Y.REF.ID

    APP.NAME        = 'FUNDS.TRANSFER'
    OFSFUNCT        = 'I'
    PROCESS         = 'PROCESS'
    OFSVERSION      = 'FUNDS.TRANSFER,REDO.AA.OVERPAYMENT'
    GTSMODE         = ''
    TRANSACTION.ID  = ''
    R.FT.OVERPAY.OFS= ''
    OFS.MSG.ID      = ''
    OFS.ERR         = ''
    NO.OF.AUTH      = 0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.FT.OVERPAY,R.FT.OVERPAY.OFS)

    R.FT.INTEREST.OFS = ""
    OFSVERSION      = 'FUNDS.TRANSFER,REDO.AA.INTEREST'
    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.FT.INTEREST,R.FT.INTEREST.OFS)

    OFS.SRC    = "REDO.OVERPAY"
    OFS.MSG.ID = ""
    OFSRECORD  = R.FT.OVERPAY.OFS:@FM:R.FT.INTEREST.OFS
    OPTIONS    = ""
    CALL OFS.POST.MESSAGE(OFSRECORD,OFS.MSG.ID,OFS.SRC,OPTIONS)
    R.REDO.AA.OVERPAYMENT<REDO.OVER.STATUS> = 'APLICADO'
    CALL F.WRITE(FN.REDO.AA.OVERPAYMENT,Y.REF.ID,R.REDO.AA.OVERPAYMENT)
    CALL OCOMO("OFS MESSAGE ID -[": OFS.MSG.ID:"] [":Y.REF.ID:"]")
    CALL OCOMO("Processing completed - ":Y.REF.ID)
RETURN
*----------------------------------------------------------
GET.PL.CATEGORY:
*----------------------------------------------------------

    Y.LOAN.CATEGORY = R.REDO.AA.OVERPAYMENT<REDO.OVER.CATEGORY>
    Y.LOAN.STATUS   = R.REDO.AA.OVERPAYMENT<REDO.OVER.LOAN.MANUAL.STATUS>
    Y.PL.CATEGORY   = ""

    LOCATE Y.LOAN.CATEGORY IN R.REDO.AA.OVERPAYMENT.PARAM<REDO.OVER.PARAM.CATEGORY,1> SETTING CATEG.POS THEN
        LOCATE Y.LOAN.STATUS IN R.REDO.AA.OVERPAYMENT.PARAM<REDO.OVER.PARAM.L.LOAN.STATUS,CATEG.POS,1> SETTING PL.POS THEN
            Y.PL.CATEGORY = R.REDO.AA.OVERPAYMENT.PARAM<REDO.OVER.PARAM.PL.CATEGORY,CATEG.POS,PL.POS>
        END

    END
    IF Y.PL.CATEGORY EQ "" THEN
        CALL OCOMO("P&L CATEGORY NOT LOCATED - [":Y.REF.ID:"]")
    END
RETURN
END
