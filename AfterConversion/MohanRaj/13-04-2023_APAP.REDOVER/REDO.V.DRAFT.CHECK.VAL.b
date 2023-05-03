* @ValidationCode : MjotMTA3ODgxNTE1NTpDcDEyNTI6MTY4MTM4Nzg3MTE0NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:41:11
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
SUBROUTINE REDO.V.DRAFT.CHECK.VAL
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.DRAFT.CHECK.VAL
*--------------------------------------------------------------------------------
* Description:
*--------------------------------------------------------------------------------
*            This validation routine is be attached to the VERSION FUNDS.TRANSFER,REINV.WDL
* to populate DEBIT.ACCOUNT number and currency
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 22-AUG-2011     JEEVA T      PACS00103288       changes made (DRAFT.CHECK)
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,F.READ TO CACHE.READ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.FT.TXN.TYPE.CONDITION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_REDO.TELLER.PROCESS.COMMON
    $INSERT I_F.REDO.CHEQUE.PROCESS
    GOSUB OPEN.FILE

    GOSUB INIT

RETURN

*---------------------------------------------------------------------------------
OPEN.FILE:
*---------------------------------------------------------------------------------
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.FTTC = 'F.FT.TXN.TYPE.CONDITION'
    F.FTTC = ''
    CALL OPF(FN.FTTC,F.FTTC)

    FN.REDO.CHEQUE.PROCESS = 'F.REDO.CHEQUE.PROCESS'
    F.REDO.CHEQUE.PROCESS = ''
    CALL OPF(FN.REDO.CHEQUE.PROCESS,F.REDO.CHEQUE.PROCESS)


    FN.FT.COMMISSION.TYPE = 'F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE = ''
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
    Y.BEN.NAME = ''
    Y.NAME1 = ''
    Y.NAME2 = ''
    Y.ACCOUNT = ''
    Y.CUS = ''

    LOC.REF.APPL="FUNDS.TRANSFER"
    LOC.REF.FIELDS='BENEFIC.NAME':@VM:'L.FT.AZ.ACC.REF':@VM:'WAIVE.TAX'
    LOC.REF.POS=" "
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)

    POS.BENEFIC.NAME       = LOC.REF.POS<1,1>
    POS.FT.AZ.ACC.REF.POS  = LOC.REF.POS<1,2>
    POS.WAIVE.TAX          = LOC.REF.POS<1,3>

RETURN
*---------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------
******



    Y.REDO.CHEQUE.PROCESS.ID = VAR.PROCESS.ID
    CALL F.READ(FN.REDO.CHEQUE.PROCESS,Y.REDO.CHEQUE.PROCESS.ID,R.REDO.CHEQUE.PROCESS,F.REDO.CHEQUE.PROCESS,Y.ERR)
    Y.AMOUNT = R.REDO.CHEQUE.PROCESS<CHQ.PRO.DEBIT.AMOUNT>
    Y.FT.TRANSACTION.TYPE = R.NEW(FT.TRANSACTION.TYPE)
    CALL CACHE.READ(FN.FTTC, Y.FT.TRANSACTION.TYPE, R.FTTC, FTTC.ERR) ;*R22 Auto code conversion
    Y.FT.COMM.TYPES  =  R.FTTC<FT6.COMM.TYPES>
    CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.FT.COMM.TYPES, R.FT.COMMISSION.TYPE, FT.COMMISSION.TYPE.ERR) ;*R22 Auto code conversion
    Y.FC.PERCENTAGE = R.FT.COMMISSION.TYPE<FT4.PERCENTAGE>/100
    Y.COMMISSION.AMOUNT =  Y.AMOUNT * Y.FC.PERCENTAGE
    Y.FINAL.AMOUNT  = Y.AMOUNT - Y.COMMISSION.AMOUNT
    Y.CHECK  = R.NEW(FT.COMMISSION.AMT)
    Y.WAIVE.TAX = R.NEW(FT.LOCAL.REF)<1,POS.WAIVE.TAX>
    IF Y.WAIVE.TAX EQ 'NO' THEN
        R.NEW(FT.COMMISSION.AMT) = R.NEW(FT.DEBIT.CURRENCY):' ':Y.COMMISSION.AMOUNT
        R.NEW(FT.TOTAL.CHARGE.AMOUNT) = R.NEW(FT.DEBIT.CURRENCY):' ':Y.COMMISSION.AMOUNT
        R.NEW(FT.LOCAL.CHARGE.AMT) = Y.COMMISSION.AMOUNT
        R.NEW(FT.LOC.POS.CHGS.AMT) = Y.COMMISSION.AMOUNT
        R.NEW(FT.TOT.SND.CHG.CRCCY) = Y.COMMISSION.AMOUNT
    END ELSE
        R.NEW(FT.CHARGES.ACCT.NO) = ''
        R.NEW(FT.CHARGE.TYPE) = ''
        R.NEW(FT.CHARGE.AMT) = ''
        R.NEW(FT.COMMISSION.TYPE) = ''
        R.NEW(FT.COMMISSION.AMT)  = ''
        R.NEW(FT.COMMISSION.CODE) = "WAIVE"
        R.NEW(FT.CHARGE.CODE) = "WAIVE"

    END
*******
RETURN

END
