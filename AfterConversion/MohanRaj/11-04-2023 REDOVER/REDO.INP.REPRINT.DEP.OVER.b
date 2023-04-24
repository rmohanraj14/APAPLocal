* @ValidationCode : MjotMTk2NzU1MDI0ODpDcDEyNTI6MTY4MTIxNDI5MzYwOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:28:13
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
SUBROUTINE REDO.INP.REPRINT.DEP.OVER
******************************************************************************
*  Company   Name    :Asociacion Popular de Ahorros y Prestamos
*  Developed By      :Temenos Development
*  Program   Name    :REDO.INP.REPRINT.DEP.OVER
***********************************************************************************
*Description:    This is an input routine attached to the Enquiry used
*                to PRINT a deal slip when the User clicks on PRINT option
*****************************************************************************
*linked with:
*In parameter:
*Out parameter:
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
**********************************************************************
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.APAP.H.REPRINT.DEP

    GOSUB INIT

RETURN
*--------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------
    VAR.REPRINT.FLAG = R.NEW(REDO.REP.DEP.REPRINT.FLAG)
    VAR.ID = FIELD(ID.NEW,"-",1)
    CURR.NO = 0
    CALL STORE.OVERRIDE(CURR.NO)
    IF OFS$OPERATION EQ 'PROCESS' AND VAR.REPRINT.FLAG EQ 'YES' THEN
        TEXT = "REDO.DEP.REPRINT.OVR":@FM:VAR.ID
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
END
