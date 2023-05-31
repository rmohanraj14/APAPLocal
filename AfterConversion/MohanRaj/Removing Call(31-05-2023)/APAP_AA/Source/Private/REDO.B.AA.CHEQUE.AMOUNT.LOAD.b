* @ValidationCode : Mjo1OTUxODIzNjA6Q3AxMjUyOjE2ODAxODc3NTc2Nzc6SVRTUzotMTotMTo0OTM6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 493
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.B.AA.CHEQUE.AMOUNT.LOAD
*-------------------------------------------------------------------------------------
* Description: This routine is a Load routine of batch routine to update the cheque amount among the transaction.
*-----------------------------------------------------------------------------------------
* Input  Arg: N/A
* Output Arg: N/A
*--------------------------------------------------------------------------------------
* MODIFICATION HISTORY:
*-----------------------
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       No changes
* 29-MAR-2023      Harishvikram C     Manual R22 conversion     No changes
*-----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_REDO.B.AA.CHEQUE.AMOUNT.COMMON

    GOSUB PROCESS
RETURN
*---------------------------------------------------
PROCESS:
*---------------------------------------------------

    FN.REDO.TRANSACTION.CHAIN = 'F.REDO.TRANSACTION.CHAIN'
    F.REDO.TRANSACTION.CHAIN = ''
    CALL OPF(FN.REDO.TRANSACTION.CHAIN,F.REDO.TRANSACTION.CHAIN)

    FN.REDO.LOAN.FT.TT.TXN = 'F.REDO.LOAN.FT.TT.TXN'
    F.REDO.LOAN.FT.TT.TXN = ''
    CALL OPF(FN.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN)

    FN.REDO.CONCAT.CHQ.TXN = 'F.REDO.CONCAT.CHQ.TXN'
    F.REDO.CONCAT.CHQ.TXN = ''
    CALL OPF(FN.REDO.CONCAT.CHQ.TXN,F.REDO.CONCAT.CHQ.TXN)

    FN.REDO.TEMP.WORK = 'F.REDO.TEMP.WORK'
    F.REDO.TEMP.WORK = ''
    CALL OPF(FN.REDO.TEMP.WORK,F.REDO.TEMP.WORK)

    FN.REDO.TEMP.WORK.TXN = 'F.REDO.TEMP.WORK.TXN'
    F.REDO.TEMP.WORK.TXN = ''
    CALL OPF(FN.REDO.TEMP.WORK.TXN,F.REDO.TEMP.WORK.TXN)

RETURN
END
