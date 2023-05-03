* @ValidationCode : MjoxMjAyNzYzMzUxOkNwMTI1MjoxNjgwNzczMjY0MzM3OkhhcmlzaHZpa3JhbUM6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 14:57:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.VALARRID
**
* Subroutine Type : VERSION
* Attached to     : EB.EXTERNAL.USER,REDO.USER.AUTH
* Attached as     : AUTH.ROUTINE
* Primary Purpose : Validate an AA Arrangement ID is assigned before authorize
*                   the Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
* DATE              WHO                REFERENCE                 DESCRIPTION
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.EB.EXTERNAL.USER

    ARR = ""
    E = ""

    ARR = R.NEW(EB.XU.ARRANGEMENT)

    IF ARR EQ "" THEN
        E = "Arreglo no asignado a este usuario. Por favor esperar la asignacion para autorizar."
    END

RETURN

END
