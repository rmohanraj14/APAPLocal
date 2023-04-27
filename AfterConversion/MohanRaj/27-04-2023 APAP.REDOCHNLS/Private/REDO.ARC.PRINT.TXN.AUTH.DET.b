* @ValidationCode : MjotMzcwMzg1MjUzOkNwMTI1MjoxNjgxMjE1MTYzMDQxOklUU1M6LTE6LTE6NDkyOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:43
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 492
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ARC.PRINT.TXN.AUTH.DET
*-----------------------------------------------------------------------------
*Company   Name    : APAP
*Developed By      : Martin Macias
*Program   Name    : REDO.ARC.PRINT.TXN.AUTH.DET
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* 10-APR-2023     Conversion tool   R22 Auto conversion    VM to @VM, IF condition added
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_System

    FN.REDO.EB.USER.PRINT.VAR='F.REDO.EB.USER.PRINT.VAR'
    F.REDO.EB.USER.PRINT.VAR=''
    CALL OPF(FN.REDO.EB.USER.PRINT.VAR,F.REDO.EB.USER.PRINT.VAR)

    FN.FUNDS.TRANSFER='F.FUNDS.TRANSFER$NAU'
    F.FUNDS.TRANSFER=''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    CALL F.READ(FN.FUNDS.TRANSFER, ID.NEW, Y.TXN.DET, F.FUNDS.TRANSFER, ER.DET)

    LOC.REF.APPLICATION="FUNDS.TRANSFER"
    LOC.REF.FIELDS='L.ACTUAL.VERSIO':@VM
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.ACT.VER = LOC.REF.POS<1,1>
    Y.ACT.VER = Y.TXN.DET<FT.LOCAL.REF><1,POS.ACT.VER>

    PDF.VERSION = Y.ACT.VER
    PDF.RECORD = ID.NEW
    Y.USR = System.getVariable("EXT.EXTERNAL.USER")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - start
        Y.USR = ""
    END					;*R22 Auto conversion - end
    Y.USR.VAR = Y.USR:"-":"CURRENT.ARC.VER"

*  WRITE PDF.VERSION TO F.REDO.EB.USER.PRINT.VAR,Y.USR.VAR ;*Tus Start
    CALL F.WRITE(FN.REDO.EB.USER.PRINT.VAR,Y.USR.VAR,PDF.VERSION) ;*Tus End

    Y.USR.VAR = Y.USR:"-":"CURRENT.ARC.REC"

*  WRITE PDF.RECORD TO F.REDO.EB.USER.PRINT.VAR,Y.USR.VAR ;*Tus Start
    CALL F.WRITE(FN.REDO.EB.USER.PRINT.VAR,Y.USR.VAR,PDF.RECORD) ;*Tus End

RETURN
END
