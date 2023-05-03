* @ValidationCode : MjotNzk3OTMwMjIzOkNwMTI1MjoxNjgxMTI3MzAwNzg1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 17:18:20
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
SUBROUTINE REDO.S.GET.CUS.NO(CUS.OUT)
*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Chandra Prakash T
* Program Name  : REDO.S.GET.CUS.NO
* ODR NUMBER    : ODR-2010-01-0213
*----------------------------------------------------------------------------------
* Description   : Deal slip routine attached to FT.FXSN.SLIP to retrieve CUSTOMER no from the transaction, which
*                 depends on the application name
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 30-Jul-2010      Chandra Prakash T  ODR-2010-01-0213  Initial creation
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.FOREX.SEQ.NUM

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------------------

    FN.REDO.FOREX.SEQ.NUM = "F.REDO.FOREX.SEQ.NUM"
    F.REDO.FOREX.SEQ.NUM  = ""
    CALL OPF(FN.REDO.FOREX.SEQ.NUM, F.REDO.FOREX.SEQ.NUM)

RETURN
*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------

    CONTRACT.ID = FIELD(CUS.OUT,'-',2)
    R.REDO.FOREX.SEQ.NUM = ""
    REDO.FOREX.SEQ.NUM.ERR = ""
    CALL F.READ(FN.REDO.FOREX.SEQ.NUM,CONTRACT.ID,R.REDO.FOREX.SEQ.NUM,F.REDO.FOREX.SEQ.NUM,REDO.FOREX.SEQ.NUM.ERR)
    CUS.OUT = R.REDO.FOREX.SEQ.NUM<REDO.FXSN.CUSTOMER.NO>

RETURN

END
