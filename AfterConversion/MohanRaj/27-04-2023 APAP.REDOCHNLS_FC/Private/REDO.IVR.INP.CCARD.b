* @ValidationCode : MjoxMjgyOTI5ODpDcDEyNTI6MTY4MTM4MDg2NDUzMjpJVFNTOi0xOi0xOi0xNDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -14
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.INP.CCARD
**
* Subroutine Type : VERSION
* Attached to     : FUNDS.TRANSFER,REDO.IVR.PAGTC,
*                   FUNDS.TRANSFER,REDO.IVR.PAGTCBEN
* Attached as     : Field CREDIT.CURRENCY as VALIDATION.RTN
* Primary Purpose : Assign the internel account depending of currency used.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 07/02/13 - First Version
*            ODR Reference: ODR-2011-02-0099
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER

    $INSERT I_F.REDO.IVR.PARAMS.ALLOPER

    GOSUB INITIALSE
    GOSUB PROCESS

RETURN

*---------
INITIALSE:
*---------

    FN.REDO.IVR.PARAMS.ALLOPER = 'F.REDO.IVR.PARAMS.ALLOPER'

RETURN

*-------
PROCESS:
*-------

    Y.CURRENCY = COMI

    CALL CACHE.READ(FN.REDO.IVR.PARAMS.ALLOPER,'SYSTEM',R.REDO.IVR.PARAMS.ALLOPER,ERR.MPAR)
    VAR.CURRENCY = R.REDO.IVR.PARAMS.ALLOPER<IVR.AO.CCARD.CUR>
    VAR.INT.ACCT = R.REDO.IVR.PARAMS.ALLOPER<IVR.AO.CCARD.INT.ACCT>

    LOCATE Y.CURRENCY IN VAR.CURRENCY<1,1> SETTING POS.CUR THEN
        VAR.INT.ACCT = R.REDO.IVR.PARAMS.ALLOPER<IVR.AO.CCARD.INT.ACCT,POS.CUR>
        R.NEW(FT.CREDIT.ACCT.NO) = VAR.INT.ACCT
    END

RETURN

END
