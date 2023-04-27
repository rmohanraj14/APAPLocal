* @ValidationCode : Mjo0NzQwMzYyMTc6Q3AxMjUyOjE2ODEzODA4NDIxNTE6SVRTUzotMTotMTotNzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:02
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -7
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.INP.CHGPROF
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PROFILE,CHANGE
* Attached as     : INPUT.ROUTINE
* Primary Purpose : Validate the change of the profile for Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 20/12/12 - First Version
*            ODR Reference: ODR-2010-06-0155
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*            Roberto Mondragon - TAM Latin America
*            rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_F.REDO.CH.PROFILE

    GOSUB PROCESS

RETURN

********
PROCESS:
********

    Y.PRODUCT = R.NEW(REDO.CH.PROF.PRODUCT)
    Y.PROFILE.OLD = R.OLD(REDO.CH.PROF.PROFILE)

    IF Y.PRODUCT EQ 'PERSONAL' AND Y.PROFILE.OLD EQ 'Apapenlinea.Consultas' THEN
        R.NEW(REDO.CH.PROF.PROFILE) = 'Apapenlinea.Txns'
    END

    IF Y.PRODUCT EQ 'PERSONAL' AND Y.PROFILE.OLD EQ 'Apapenlinea.Txns' THEN
        R.NEW(REDO.CH.PROF.PROFILE) = 'Apapenlinea.Consultas'
    END

    IF Y.PRODUCT EQ 'PERSONAL.TEL' AND Y.PROFILE.OLD EQ 'Teleapap.Consultas' THEN
        R.NEW(REDO.CH.PROF.PROFILE) = 'Teleapap.Txns'
    END

    IF Y.PRODUCT EQ 'PERSONAL.TEL' AND Y.PROFILE.OLD EQ 'Teleapap.Txns' THEN
        R.NEW(REDO.CH.PROF.PROFILE) = 'Teleapap.Consultas'
    END

RETURN

END
