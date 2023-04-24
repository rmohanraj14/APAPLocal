* @ValidationCode : MjotMTkzNzU4NjU3NDpDcDEyNTI6MTY4MTIxNjc0NzU2MDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:09:07
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
SUBROUTINE REDO.V.ANC.DMG.EMBOSS

*-----------------------------------------------------------------------------

*DESCRIPTION:
*------------
* *this routine is to clear the fields of REDO.CARD.DMG.EMBOSS on input mode

* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-

*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------

* Modification History :
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who                   Reference               Description
*  21-MAY-2011  BALAGURUNATHAN        ODR-2010-03-0400         INITIAL VERSION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-----------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CARD.DMG.EMBOSS
    $INSERT I_REDO.CRD.DMG.LST.COMMON
    $INSERT I_GTS.COMMON


    R.NEW(DMG.LST.REG.ID)=''
    R.NEW(DMG.LST.CARD.TYPE)=''
    R.NEW( DMG.LST.SERIES)=''
    R.NEW( DMG.LST.LOST)=''
    R.NEW( DMG.LST.LOST.DESC )=''
    R.NEW( DMG.LST.DAMAGE)=''
    R.NEW( DMG.LST.DAM.DESC)=''
    R.NEW( DMG.LST.MOVE.FROM.INIT)=''

RETURN

END
