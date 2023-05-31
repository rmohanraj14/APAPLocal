* @ValidationCode : MjotMTUyOTY2MTU3MDpDcDEyNTI6MTY4MDE4NDY3MjE0OTpJVFNTOi0xOi0xOi0xODoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -18
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.CUS.AA.BRTN(ENQ.DATA)
*
*
*--------------------------------------------------------------------------
* This routine fetches the Collateral IDs for the arrangement Specified
*
*---------------------------------------------------------------------------------------------------------
*
*Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*
*---------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
    $INSERT I_B02.COMMON

*---------------------------------------------------------------------------------------------------------
MAIN.LOGIC:
    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*---------------------------------------------------------------------------------------------------------
INITIALISE:
    COMM.CUS = ""

RETURN
*---------------------------------------------------------------------------------------------------------
PROCESS:

    COMM.CUS = R.NEW(INS.DET.CUSTOMER)


RETURN
*---------------------------------------------------------------------------------------------------------
END
