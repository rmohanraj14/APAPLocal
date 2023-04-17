* @ValidationCode : MjotMTk5MTI1MzM4ODpDcDEyNTI6MTY4MTcyNzEwNzI5MDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 15:55:07
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
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.INP.COM.NAME
**************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.APAP.H.COMP.NAME
    $INSERT I_F.REDO.B2.FT.DATA


    FN.REDO.APAP.H.COMP.NAME = 'F.REDO.APAP.H.COMP.NAME'
    F.REDO.APAP.H.COMP.NAME = ''
    CALL OPF(FN.REDO.APAP.H.COMP.NAME,F.REDO.APAP.H.COMP.NAME)

    Y.VAL = COMI

    IF Y.VAL EQ 'CHEQUE' THEN
        Y.COMP = R.NEW(PAY.DAT.INS.COMPANY)
        CALL F.READ(FN.REDO.APAP.H.COMP.NAME,Y.COMP,R.REDO.APAP.H.COMP.NAME,F.REDO.APAP.H.COMP.NAME,NAM.ERR)
        IF R.REDO.APAP.H.COMP.NAME THEN
            R.NEW(PAY.DAT.BEN.NAME) = R.REDO.APAP.H.COMP.NAME<REDO.CMP.INS.COMP.NAME>
        END
    END
    IF Y.VAL EQ 'CREDITO' THEN
        R.NEW(PAY.DAT.BEN.NAME) = ''
    END

RETURN

END
