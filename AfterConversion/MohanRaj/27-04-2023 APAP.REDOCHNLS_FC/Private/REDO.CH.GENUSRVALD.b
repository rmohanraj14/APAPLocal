* @ValidationCode : MjotMTE2NTkwNTk5OTpDcDEyNTI6MTY4MTczMzY4ODQ3OTpJVFNTOi0xOi0xOjA6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:48
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GENUSRVALD
**
* Subroutine Type : VERSION
* Attached to     : EB.EXTERNAL.USER,REDO.PERS.NEWINT,
*                   EB.EXTERNAL.USER,REDO.PERS.NEWTEL,
*                   EB.EXTERNAL.USER,REDO.CORP.NEWINTADM,
*                   EB.EXTERNAL.USER,REDO.CORP.NEWINTAUTH,
*                   EB.EXTERNAL.USER,REDO.CORP.NEWINTINP
* Attached as     : CHECK.REC.RTN
* Primary Purpose : Assign one year as valid period for Channel User to be
*                   activated
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   ++ to +=
* 12-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.EB.EXTERNAL.USER

    STAT = R.NEW(EB.XU.STATUS)

    IF STAT EQ "ACTIVE" THEN
        INITIALDATE = TODAY
        ENDDATE1 = LEFT(INITIALDATE,4)
        ENDDATE2 = RIGHT(INITIALDATE,4)
        ENDDATE1 += 1
        ENDDATE = ENDDATE1 : ENDDATE2
        R.NEW(EB.XU.END.DATE) = ENDDATE
    END

RETURN

END
