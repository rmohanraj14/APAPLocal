* @ValidationCode : MjotMTMwNDc3Mzk4NDpDcDEyNTI6MTY4MDE4Nzc1NzQ0OTpJVFNTOi0xOi0xOjI3OToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 279
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AUTH.AA.CHEQUE.REV.REAPPLY
*-----------------------------------------------------
*Description: This routine is the auth routine for AA cheque reversal reapply
*              to update the reference in REDO.LOAN.FT.TT.TXN.
*-----------------------------------------------------

*-----------------------------------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion       No changes
* 29-MAR-2023      Harishvikram C     Manual R22 conversion      No changes
*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.LOAN.FT.TT.TXN
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_F.REDO.LOAN.CHQ.RETURN

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*-------------------------------------------------------
OPEN.FILES:
*-------------------------------------------------------

    LOC.REF.APPLICATION   = "FUNDS.TRANSFER"
    LOC.REF.FIELDS        = 'L.INITIAL.ID'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.INITIAL.ID    =      LOC.REF.POS<1,1>

    FN.REDO.LOAN.FT.TT.TXN = 'F.REDO.LOAN.FT.TT.TXN'
    F.REDO.LOAN.FT.TT.TXN  = ''
    CALL OPF(FN.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN)

RETURN
*-------------------------------------------------------
PROCESS:
*-------------------------------------------------------

    Y.RLT.ID = R.NEW(FT.LOCAL.REF)<1,POS.L.INITIAL.ID>
    CALL F.READU(FN.REDO.LOAN.FT.TT.TXN,Y.RLT.ID,R.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN,RLT.ERR,"")
    IF R.REDO.LOAN.FT.TT.TXN ELSE
        RETURN
    END
    Y.FT.ID = R.NEW(FT.CREDIT.THEIR.REF)
    LOCATE Y.FT.ID IN R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.FT.TRANSACTION.ID,1> SETTING POS1 THEN
        GOSUB PROCESS.TXN
    END
    LOCATE Y.FT.ID IN R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.RETURN.FT.REF,1> SETTING POS1 THEN
        GOSUB PROCESS.TXN
    END

RETURN
*-------------------------------------------------------
PROCESS.TXN:
*-------------------------------------------------------
    Y.DATE = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.DATE>
    R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.RETURN.FT.REF,POS1> = ID.NEW
    CALL F.WRITE(FN.REDO.LOAN.FT.TT.TXN,Y.RLT.ID,R.REDO.LOAN.FT.TT.TXN)
RETURN
END
