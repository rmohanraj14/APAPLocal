* @ValidationCode : MjotMTA0OTUzNzIzNDpDcDEyNTI6MTY4MTEyMzY4MzkwODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 16:18:03
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.FORMAT.TIME
*----------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER

*DESCRIPTIONS:
*-------------
* This is Hook routine attached to TIME field in RAD.CONDUIT.MAPPING table
* This routine format time

*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*

* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*

*-----------------------------------------------------------------------------
* Modification History :
* Date            Who                    Reference             Description
* 12-OCT-2010    KAVITHA(TEMENOS)        ODR-2009-12-0290      INITIAL VERSION
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-----------------------------------------------------------------------------

    FETCH.TIME = COMI[1,2]
    FETCH.MIN = COMI[4,2]
    COMI = FETCH.TIME:FETCH.MIN

RETURN
*----------------------------------------------------------------------------
END
