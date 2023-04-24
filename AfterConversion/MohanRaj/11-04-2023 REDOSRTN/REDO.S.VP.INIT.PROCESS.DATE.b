* @ValidationCode : MjotOTkzMDc3ODE3OkNwMTI1MjoxNjgxMjE1NDkxODc5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:48:11
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
SUBROUTINE REDO.S.VP.INIT.PROCESS.DATE
*-----------------------------------------------------------------------------
* Developer    : Luis Fernando Pazmino (lpazminodiaz@temenos.com)
*                TAM Latin America
* Client       : Asociacion Popular de Ahorro & Prestamo (APAP)
* Date         : 04.27.2013
* Description  : Init process date for empty record
* Type         : Record Routine
* Attached to  : Version > REDO.VISION.PLUS.PARAM,INPUT
*-----------------------------------------------------------------------------
* Modification History:
*
* Version   Date           Who            Reference         Description
* 1.0       04.27.2013     lpazmino       -                 Initial Version
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
* Input/Output: NA
* Dependencies: NA
*-----------------------------------------------------------------------------

* <region name="INCLUDES">

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.REDO.VISION.PLUS.PARAM

* </region>

    GOSUB PROCESS
RETURN

* <region name="GOSUBS" description="Gosub blocks">

***********************
* Main Process
PROCESS:
***********************

    IF NOT(R.NEW(VP.PARAM.PROCESS.DATE)) THEN
        R.NEW(VP.PARAM.PROCESS.DATE) = TODAY
    END

RETURN

* </region>

END
