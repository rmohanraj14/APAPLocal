* @ValidationCode : MjoxNTMyNjE0MDM3OkNwMTI1MjoxNjgzNjk4NDIxOTk3OklUU1M6LTE6LTE6LTE5OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -19
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.INT.RATE.TYPE.DEFAULT
*
* Routine defaults the RATE.REVIEW.TYPE to 'Back to Back' for certain type of loans
* This is attached to a RECORD field in the ACTIVITY.API
*
*
*---------------------------------------------------------------------------------
*
* Modification History
*
* 04/04/2011 - PACS00032743 - Ravikiran AV - Initial Creation
* Date                 who                   Reference              
* 29-03-2023          Conversion Tool      R22 AUTO CONVERSTION - No Change
* 29-03-2023          ANIL KUMAR B         R22 MANUAL CONVERSTION -NO CHANGES
*
*
*---------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.INTEREST

*---------------------------------------------------------------------------------
MAIN.LOGIC:

    GOSUB INITIALISE

    GOSUB DEFAULT.INT.RATE.TYPE

RETURN
*---------------------------------------------------------------------------------
INITIALISE:

    CALL GET.LOC.REF("AA.PRD.DES.INTEREST","L.AA.REV.RT.TY",REVRATE.POS)


RETURN
*---------------------------------------------------------------------------------
DEFAULT.INT.RATE.TYPE:

    R.NEW(AA.INT.LOCAL.REF)<1,REVRATE.POS> = 'BACK.TO.BACK' ;* Default the field to Back to Back

RETURN
*---------------------------------------------------------------------------------
END
