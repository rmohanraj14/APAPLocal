* @ValidationCode : MjotNTY2MDMyOTg2OkNwMTI1MjoxNjgxMjE0MjMxNTE4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:27:11
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
SUBROUTINE REDO.INP.REINV.AZ.ACC.BAL.FT.TAX
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.INP.REINV.AZ.ACC.BAL.FT.TAX
*--------------------------------------------------------------------------------
* Description:
*--------------------------------------------------------------------------------
*          This validation routine should be attached to the VERSION TELLER,REINV.WDL to populate
* ACCOUNT.1 field and currency
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 10.07.2012       Sudhar         Group11      CREATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
*   $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER


    GOSUB GET.LOC.VALUES
    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------------------
GET.LOC.VALUES:
*----------------
* Get the Needed Local table position
*
    LOC.REF.APPL='FUNDS.TRANSFER'
    LOC.REF.FIELDS="L.FT.REINV.AMT":@VM:"INTEREST.AMOUNT"
    LOC.REF.POS=" "
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.FT.REINV.AMT=LOC.REF.POS<1,1>
    POS.INTEREST.AMOUNT=LOC.REF.POS<1,2>

RETURN
*--------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------
    VAR.DEBIT.AMOUNT =  R.NEW(FT.DEBIT.AMOUNT)
    VAR.INT.AMT = R.NEW(FT.LOCAL.REF)<1,POS.INTEREST.AMOUNT>
    Y.INT.REINV.AMT = R.NEW(FT.LOCAL.REF)<1,POS.L.FT.REINV.AMT>
    IF VAR.INT.AMT NE VAR.DEBIT.AMOUNT THEN
        AF = FT.DEBIT.AMOUNT
        ETEXT = 'FT-DEBIT.INT.AMOUNT':@FM:VAR.INT.AMT
        CALL STORE.END.ERROR
        RETURN
    END

    IF VAR.DEBIT.AMOUNT GT Y.INT.REINV.AMT THEN
        AF = FT.DEBIT.AMOUNT
        ETEXT="FT-REINV.WDL"
        CALL STORE.END.ERROR
    END


RETURN
END
