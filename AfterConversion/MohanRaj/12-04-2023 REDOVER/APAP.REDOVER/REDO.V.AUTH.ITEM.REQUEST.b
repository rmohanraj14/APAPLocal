* @ValidationCode : MjotOTM3ODM2MDEyOkNwMTI1MjoxNjgxMzAzODAxMDA4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:20:01
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
SUBROUTINE REDO.V.AUTH.ITEM.REQUEST
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_F.REDO.ITEM.STOCK

*----------------------------------------------------------------------------
* Description:
* This routine will be attached to the version REDO.ORDER.DETAIL,ITEM.REQUEST as
* a auth routine
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.AUTH.ITEM.REQUEST
*-------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 12.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
* ------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------------------
    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------------
    FN.REDO.ITEM.STOCK = 'F.REDO.ITEM.STOCK'
    F.REDO.ITEM.STOCK  = ''
    CALL OPF(FN.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK)

RETURN
PROCESS:
*---------------------------------------------------------
    R.NEW(RE.ORD.ORDER.STATUS) = "Orden Pendiente de Despacho"
    Y.CO.CODE = R.NEW(RE.ORD.REQUEST.COMPANY)
    Y.BRANCH  = R.NEW(RE.ORD.BRANCH.CODE)
    Y.ITEM.CODE = R.NEW(RE.ORD.ITEM.CODE)
    Y.ID = Y.CO.CODE:'-':Y.BRANCH
    CALL F.READ(FN.REDO.ITEM.STOCK,Y.ID,R.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK,STOCK.ERR)
    Y.ITEM.LIST = R.REDO.ITEM.STOCK<ITEM.REG.ITEM.CODE>
    LOCATE Y.ITEM.CODE IN Y.ITEM.LIST<1,1> SETTING Y.ITEM.POS THEN
        R.REDO.ITEM.STOCK<ITEM.REG.ORDER.STATUS,Y.ITEM.POS> = 'SUBMITTED'
        CALL F.WRITE(FN.REDO.ITEM.STOCK,Y.ID,R.REDO.ITEM.STOCK)
    END
RETURN
END
