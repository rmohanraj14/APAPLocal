* @ValidationCode : Mjo1NTI2NDIwNTpDcDEyNTI6MTY4MTM5MTEyODc5Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:35:28
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
SUBROUTINE REDO.V.CONV.ADMIN.DESC

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

*DESCRIPTION:
*------------
*This routine is used to show the descriptions and act as conversion routine
*-------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 12-APR-2012       S.MARIMUTHU      PACS00189769
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------

    Y.VAL = O.DATA


    VIRTUAL.TAB.ID = 'ADMIN.CHQ.TYPE'
    CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
    Y.LOOKUP.LIST = VIRTUAL.TAB.ID<2>
    Y.LOOKUP.LIST = CHANGE(Y.LOOKUP.LIST,'_',@FM )
    Y.DESC.LIST = VIRTUAL.TAB.ID<11>
    Y.DESC.LIST = CHANGE(Y.DESC.LIST,'_',@FM)

    LOCATE Y.VAL IN Y.LOOKUP.LIST SETTING POS THEN

        Y.DATA = Y.DESC.LIST<POS,LNGG>
        IF Y.DATA EQ '' THEN
            O.DATA = Y.DESC.LIST<POS,1>
        END ELSE
            O.DATA = Y.DESC.LIST<POS,LNGG>
        END
    END

RETURN

END
