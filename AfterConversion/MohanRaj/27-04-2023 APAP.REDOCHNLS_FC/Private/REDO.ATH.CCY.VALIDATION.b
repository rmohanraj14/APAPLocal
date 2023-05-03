* @ValidationCode : MjoyNjY5ODIxMTA6Q3AxMjUyOjE2ODEyMTUxNjM5NzY6SVRTUzotMTotMTotNzoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:43
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
SUBROUTINE REDO.ATH.CCY.VALIDATION
***********************************************************************************
*  Company   Name    :Asociacion Popular de Ahorros y Prestamos
*  Developed By      :Prabhu N
*  Program   Name    :REDO.ATH.CCY.VALIDATION
***********************************************************************************
*Description: This routine is to validate both source and detination to DOP
*
*****************************************************************************
*linked with: NA
*In parameter: NA
*Out parameter: REDO.ATH.CCY.VALIDATION
**********************************************************************
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*29.03.2013   Prabhu N       PACS00255610-ODR-2010-08-0469  INITIAL CREATION
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CURRENCY
    $INSERT I_REDO.ATH.STLMT.FILE.PROCESS.COMMON
    $INSERT I_F.REDO.ATH.SETTLMENT



    IF ERROR.MESSAGE NE '' THEN
        RETURN
    END

    GOSUB PROCESS
RETURN

*******
PROCESS:
********
    DST.CURRENCY=TRIM(R.REDO.STLMT.LINE<ATH.SETT.ISSUER.CCY.CODE>)
    SRC.CURRENCY=TRIM(Y.FIELD.VALUE)


    Y.CCY.NUM.CODE=C$R.LCCY<EB.CUR.NUMERIC.CCY.CODE>

    IF SRC.CURRENCY EQ Y.CCY.NUM.CODE THEN
        IF Y.CCY.NUM.CODE NE R.REDO.STLMT.LINE<ATH.SETT.ISSUER.CCY.CODE> THEN
            ERROR.MESSAGE='INVALID.CURRENCY'
        END
    END ELSE
        ERROR.MESSAGE='INVALID.CURRENCY'
    END

RETURN

END
