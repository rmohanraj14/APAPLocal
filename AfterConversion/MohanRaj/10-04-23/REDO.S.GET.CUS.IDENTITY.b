* @ValidationCode : MjoxMzI2NTMwNjI1OkNwMTI1MjoxNjgxMTI1MTEzNTUwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 16:41:53
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.CUS.IDENTITY(CUSTOMER.IDENTITY)

*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Chandra Prakash T
* Program Name  : REDO.S.GET.CUS.IDENTITY
*----------------------------------------------------------------------------------
* Description   : Deal slip routine attached to FX.FXSN.PSLIP, TT.FXSN.PSLIP & FT.FXSN.SLIP to retrieve CUSTOMER identity presented at the time
*                 of transaction input
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 13-Jul-2010      Chandra Prakash T  ODR-2010-01-0213  Initial creation
*Modify            :btorresalbornoz
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FOREX
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER

    GOSUB OPEN.FILES
    GOSUB GET.LOCAL.REF
    GOSUB PROCESS

RETURN

*----------------------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------------------
    FN.FOREX = 'F.FOREX'
    F.FOREX = ''
    CALL OPF(FN.FOREX,F.FOREX)

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

RETURN

*----------------------------------------------------------------------------------
GET.LOCAL.REF:
*----------------------------------------------------------------------------------

    APPL.ARR = "FOREX":@FM:"FUNDS.TRANSFER":@FM:"TELLER"
    FIELD.ARR = "L.FX.LEGAL.ID":@FM:"L.FT.LEGAL.ID":@FM:"L.TT.LEGAL.ID"
    FIELD.POS = ""
    CALL MULTI.GET.LOC.REF(APPL.ARR,FIELD.ARR,FIELD.POS)

    L.FX.LEGAL.ID.POS = FIELD.POS<1,1>
    L.FT.LEGAL.ID.POS = FIELD.POS<2,1>
    L.TT.LEGAL.ID.POS = FIELD.POS<3,1>

RETURN

*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------
    CONTRACT.NO = ID.NEW

    BEGIN CASE
        CASE APPLICATION EQ 'FOREX'
            FX.LEGAL.ID = R.NEW(FX.LOCAL.REF)<1,L.FX.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN FX.LEGAL.ID
            CUSTOMER.IDENTITY = FX.LEGAL.ID<1>:" ":FX.LEGAL.ID<2>
        CASE APPLICATION EQ 'FUNDS.TRANSFER'
            FT.LEGAL.ID = R.NEW(FT.LOCAL.REF)<1,L.FT.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN FT.LEGAL.ID
            CUSTOMER.IDENTITY = FT.LEGAL.ID<1>:" ":FT.LEGAL.ID<2>
        CASE APPLICATION EQ 'TELLER'
            TT.LEGAL.ID = R.NEW(TT.TE.LOCAL.REF)<1,L.TT.LEGAL.ID.POS>
            CHANGE '.' TO @FM IN TT.LEGAL.ID
            CUSTOMER.IDENTITY = TT.LEGAL.ID<1>:" ":TT.LEGAL.ID<2>
    END CASE
    CUSTOMER.IDENTITY = FMT(CUSTOMER.IDENTITY,'R#20')
RETURN

END
