* @ValidationCode : MjoyMjA0NzY1MjU6Q3AxMjUyOjE2ODI0MjM3NjA3NDc6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 25 Apr 2023 17:26:00
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
$PACKAGE APAP.REDOCHNLS

SUBROUTINE AI.REDO.V.TRD.PARTY.EMAIL
*-----------------------------------------------------------------------------
* This subroutine will validate a field containing an e-mail address.
*-----------------------------------------------------------------------------
*       Revision History
*
*       First Release:  February 8th
*       Developed for:  APAP
*       Developed by:   Martin Macias - Temenos - MartinMacias@temenos.com
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      Call Method Format Modified

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ADD.THIRDPARTY

    GOSUB VALIDA
RETURN

*---------
VALIDA:
*---------

    Y.EMAIL = R.NEW(ARC.TP.EMAIL)

    IF LEN(Y.EMAIL) EQ 0 THEN
        RETURN
    END

    AF = ARC.TP.EMAIL

    CALL APAP.REDOCHNLS.AI.REDO.V.EMAIL(Y.EMAIL) ;*R22 Manual Code Conversion

RETURN

END
