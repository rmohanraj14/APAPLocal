* @ValidationCode : MjoxNTg4ODg5MTEwOkNwMTI1MjoxNjgxMjE1MTY5NTk1OklUU1M6LTE6LTE6OTkwOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:49
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 990
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CLEARING.PROCESS.RUN

****************************************************************
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Ganesh R
* Program Name  : REDO.CLEARING.PROCESS.RUN
*-------------------------------------------------------------------------
* Description: This routine is a RUN routine used to update the serice record
*
*----------------------------------------------------------
* Linked with:
* In parameter :
* out parameter : None
*------------------------------------------------------------------------
* MODIFICATION HISTORY
*--------------------------------------------
*   DATE              ODR                             DESCRIPTION
* 21-09-10          ODR-2009-10-0334                 Initial Creation
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TSA.SERVICE
    $INSERT I_F.REDO.APAP.CLEARING.INWARD

    GOSUB OPENFILES
    GOSUB PROCESS
RETURN

OPENFILES:

    FN.TSA.SERVICE = 'F.TSA.SERVICE'
    F.TSA.SERVICE = ''
    CALL OPF(FN.TSA.SERVICE,F.TSA.SERVICE)

RETURN

PROCESS:

    VAR.ID = ID.NEW
    IF VAR.ID EQ 'INW.PROCESS' THEN
        TSA.PREPROCESS.ID = 'BNK/REDO.B.INW.PREPROCESS'
        CALL F.READ(FN.TSA.SERVICE,TSA.PREPROCESS.ID,R.PREPROCESS.SERVICE,F.TSA.SERVICE,PRE.ERR)
        R.PREPROCESS.SERVICE<TS.TSM.SERVICE.CONTROL>='START'
        CALL F.WRITE(FN.TSA.SERVICE,TSA.PREPROCESS.ID,R.PREPROCESS.SERVICE)

        TSA.PROCESS.ID = 'BNK/REDO.B.INW.PROCESS'
        CALL F.READ(FN.TSA.SERVICE,TSA.PROCESS.ID,R.PROCESS.SERVICE,F.TSA.SERVICE,PRO.ERR)
        R.PROCESS.SERVICE<TS.TSM.SERVICE.CONTROL>='START'
        CALL F.WRITE(FN.TSA.SERVICE,TSA.PROCESS.ID,R.PROCESS.SERVICE)
    END
    IF VAR.ID EQ 'OUT.PROCESS' THEN
        TSA.RETURN.ID = 'BNK/REDO.INWRETURN.PROCESS'
        CALL F.READ(FN.TSA.SERVICE,TSA.RETURN.ID,R.TSA.SERVICE,F.TSA.SERVICE,TSA.ERR)
        R.TSA.SERVICE<TS.TSM.SERVICE.CONTROL>='START'
        CALL F.WRITE(FN.TSA.SERVICE,TSA.SERVICE.ID,R.TSA.SERVICE)
    END
    TSM.SERVICE.ID = 'TSM'
    CALL F.READ(FN.TSA.SERVICE,TSM.SERVICE.ID,R.TSM.SERVICE,F.TSA.SERVICE,TSM.ERR)
    CHK.STATUS = R.TSM.SERVICE<TS.TSM.SERVICE.CONTROL>
    IF CHK.STATUS EQ 'STOP' THEN
        R.TSM.SERVICE<TS.TSM.SERVICE.CONTROL> = 'START'
        CALL F.WRITE(FN.TSA.SERVICE,TSM.SERVICE.ID,R.TSM.SERVICE)
    END
    CALL JOURNAL.UPDATE('')
RETURN
END
