* @ValidationCode : MjozODM2NzQ5NDI6Q3AxMjUyOjE2ODEzODA3ODUzMzQ6SVRTUzotMTotMTotMTQ6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:05
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
SUBROUTINE AI.REDO.CONVERT.PERIOD.TO.MONTHS
*-----------------------------------------------------------------------------
* Company Name :        ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By :        Martin Macias
* Program Name :        AI.REDO.CONVERT.PERIOD.TO.MONTHS
*-----------------------------------------------------------------------------
* Description    :  This routine will convert a period of time in month
* Linked with    :      ARC-IB / Loan - Deatil Page
* In Parameter   :      Period of time
* Out Parameter  :      Period of time in month
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN

*----------*
INITIALISE:
*----------*

    PERIOD.STR = O.DATA
    PERIOD.IN.MONTH = 0
RETURN

*--------*
PROCESS:
*--------*

    PERIOD.FREQ = PERIOD.STR[LEN(PERIOD.STR),1]
    Y.PERIOD = PERIOD.STR[1,LEN(PERIOD.STR)-1]

    BEGIN CASE
        CASE PERIOD.FREQ EQ "Y"
            PERIOD.IN.MONTH = Y.PERIOD * 12
        CASE PERIOD.FREQ EQ "M"
            PERIOD.IN.MONTH = Y.PERIOD
        CASE PERIOD.FREQ EQ "W"
            PERIOD.IN.MONTH = DROUND (Y.PERIOD/4,2)
        CASE PERIOD.FREQ EQ "D"
            PERIOD.IN.MONTH = DROUND (Y.PERIOD/30,2)
        CASE OTHERWISE
            PERIOD.IN.MONTH = PERIOD.STR
    END CASE

    O.DATA = PERIOD.IN.MONTH

RETURN

END
