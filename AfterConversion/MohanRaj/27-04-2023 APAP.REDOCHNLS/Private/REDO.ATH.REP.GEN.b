* @ValidationCode : MjotMTM1MTg5MDgzNzpDcDEyNTI6MTY4MTczMzY4NjY0MjpJVFNTOi0xOi0xOjI4NjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:46
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 286
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.REP.GEN
*********************************************************************************
*  Company   Name    :Asociacion Popular de Ahorros y Prestamos
*  Developed By      :DHAMU.S
*  Program   Name    :REDO.ATH.REP.GEN
***********************************************************************************
*Description: This is the single thread routine to generate report of ATH
*             Will be attached to a online service to retrieve the ATH reports by
*             executing the ENQUIRY.REPORT
*             The BATCH should contain the following details in DATA
*****************************************************************************
*linked with:
*In parameter:
*Out parameter:
**********************************************************************
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*07.12.2010   S DHAMU       ODR-2010-08-0469  INITIAL CREATION
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   SM to @SM
* 12-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ENQUIRY.REPORT
    $INSERT I_BATCH.FILES
    $INSERT I_RC.COMMON


    GOSUB INIT
    GOSUB PROCESS
RETURN

*******
INIT:
********
    FN.ENQUIRY.REPORT = 'F.ENQUIRY.REPORT'
    F.ENQUIRY.REPORT = ''
    CALL OPF(FN.ENQUIRY.REPORT,F.ENQUIRY.REPORT)
    REPORT.NUMBER=''
RETURN

********
PROCESS:
********

    DIM R.ENQUIRY.REPORT(C$SYSDIM)

    BATCH.RPTS=BATCH.DETAILS<3,1>

    BATCH.CNT=DCOUNT(BATCH.RPTS,@SM)
    BATCH.PATH=BATCH.DETAILS<3,1,BATCH.CNT>
    FOR LOOP.BATCH=1 TO BATCH.CNT-1

        Y.READ.ERR = ''
        Y.ENQ.RPT=BATCH.DETAILS<3,1,LOOP.BATCH>
        Y.ENQUIRY.REPORT.ID = Y.ENQ.RPT
        CALL F.MATREAD(FN.ENQUIRY.REPORT,Y.ENQUIRY.REPORT.ID,MAT R.ENQUIRY.REPORT,C$SYSDIM,F.ENQUIRY.REPORT,Y.READ.ERR)
        ID.NEW = Y.ENQUIRY.REPORT.ID
        MAT R.NEW = MAT R.ENQUIRY.REPORT
        CALL ENQUIRY.REPORT.RUN
        REPORT.NUMBER=C$LAST.HOLD.ID
        CPY.CMD =  'COPY FROM &HOLD& TO ' : BATCH.PATH : ' ' :REPORT.NUMBER :',':Y.ENQ.RPT :'.':TODAY
        EXECUTE CPY.CMD

    NEXT




RETURN
END
