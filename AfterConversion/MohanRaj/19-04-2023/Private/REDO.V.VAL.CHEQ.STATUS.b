* @ValidationCode : MjotMTc4NTg5ODI0OTpDcDEyNTI6MTY4MTg4NzAyNDUzMDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:20:24
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
SUBROUTINE REDO.V.VAL.CHEQ.STATUS
*------------------------------------------------------------------------------
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: S SUDHARSANAN
* PROGRAM NAME: REDO.V.VAL.CHEQ.STATUS
* ODR NO      : ODR-2009-12-0275
*----------------------------------------------------------------------
* DESCRIPTION: This routine will be used to raise an error message ,
* whenever user selects the CHEQ.STATUS EQ 85
* IN PARAMETER: NONE
* OUT PARAMETER: NONE
* LINKED WITH: Validate routine for REDO.H.SOLICITUD.CK,GRAL
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*26.02.2010  S SUDHARSANAN    ODR-2009-12-0275  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.SOLICITUD.CK
    GOSUB PROCESS
RETURN
*********
PROCESS:
*********
    CHEQ.NEW=R.NEW(REDO.H.SOL.CHEQUE.STATUS)
    IF CHEQ.NEW EQ 85 THEN
        AF = REDO.H.SOL.CHEQUE.STATUS
        ETEXT = "EB-INVALID.STATUS"
        CALL STORE.END.ERROR
    END
RETURN
*-----------------------------------------------------------------------
END
