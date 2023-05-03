* @ValidationCode : MjotMTE1OTE3NjU5MDpDcDEyNTI6MTY4MTk3NDAyODU0ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:30:28
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
	
SUBROUTINE REDO.V.VAL.REQ.SPL.DATE.RESOL
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is Validation routine to check the date resolution is not less than today
* at the time of commitment
* This development is for ODR Reference PACS00071066
* Input/Output:
*--------------
* IN  : N/A
* OUT : N/A
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
* Revision History:
*------------------------------------------------------------------------------------------
* Date              who              Reference            Description
* 25-MAY-2011       Pradeep S        PACS00060849        Initial Creation
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ISSUE.REQUESTS

    GOSUB PROCESS
RETURN

*********
PROCESS:
*********

    IF COMI AND COMI LT TODAY THEN
        ETEXT = 'EB-DATE.NOT.LT.TODAY'
        CALL STORE.END.ERROR
    END

RETURN

*---------------------------------------------------------------------------------------------------
END
