* @ValidationCode : MjotMTk4NTM3ODE4NDpDcDEyNTI6MTY4MTgxOTM4MjkxNzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 17:33:02
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
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.VAL.ATTEMPT.ADD
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : This validation routine is used to update SER.AGR.PERF based on Status selected in closed
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : PRABHU N
* PROGRAM NAME : REDO.V.VAL.UPDATE.CRM.STATUS
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 22.07.2010      PRABHU N            HD1100441         INITIAL CREATION
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.CLAIMS
    $INSERT I_F.REDO.ISSUE.COMPLAINTS
    $INSERT I_F.REDO.ISSUE.REQUESTS
    $INSERT I_F.REDO.CLAIM.STATUS.MAP
    IF VAL.TEXT THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN
*-------
INIT:
*-------
RETURN
*--------
PROCESS:
*--------

    IF APPLICATION EQ 'REDO.ISSUE.CLAIMS' THEN
        IF COMI EQ 'YES' THEN
            R.NEW(ISS.CL.STATUS)='RESOLVED-NOTIFIED'
            R.NEW(ISS.CL.SER.AGR.PERF)='RESOLVED-NOTIFIED'
        END
        ELSE
            R.NEW(ISS.CL.CONTACT.ATTEMPT)=R.OLD(ISS.CL.CONTACT.ATTEMPT)+1
            R.NEW(ISS.CL.STATUS)= R.OLD(ISS.CL.STATUS)
            R.NEW(ISS.CL.SER.AGR.PERF)=R.OLD(ISS.CL.STATUS)
        END
    END
    IF APPLICATION EQ 'REDO.ISSUE.COMPLAINTS' THEN
        IF COMI EQ 'YES' THEN
            R.NEW(ISS.COMP.STATUS)='RESOLVED-NOTIFIED'
            R.NEW(ISS.COMP.SER.AGR.PERF)='RESOLVED-NOTIFIED'
        END
        ELSE
            R.NEW(ISS.COMP.CONTACT.ATTEMPT)=R.OLD(ISS.COMP.CONTACT.ATTEMPT)+1
            R.NEW(ISS.COMP.STATUS)=R.OLD(ISS.COMP.STATUS)
            R.NEW(ISS.COMP.SER.AGR.PERF)=R.OLD(ISS.COMP.SER.AGR.PERF)
        END
    END
    IF APPLICATION EQ 'REDO.ISSUE.REQUESTS' THEN
        IF COMI EQ 'YES' THEN
            R.NEW(ISS.REQ.STATUS)='RESOLVED-NOTIFIED'
            R.NEW(ISS.REQ.SER.AGR.PERF)='RESOLVED-NOTIFIED'
        END
        ELSE
            R.NEW(ISS.REQ.CONTACT.ATTEMPT)=R.OLD(ISS.REQ.CONTACT.ATTEMPT)+1
            R.NEW(ISS.REQ.STATUS)=R.OLD(ISS.REQ.STATUS)
            R.NEW(ISS.REQ.SER.AGR.PERF)=R.OLD(ISS.REQ.SER.AGR.PERF)
        END
    END
RETURN
END
