* @ValidationCode : Mjo2NjYwOTIyNjQ6Q3AxMjUyOjE2ODE4MTU4Nzc2Nzk6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:34:37
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE  REDO.V.TXN.INT
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : This routine is used to validate the REDO.LY.PROGRAM table fields
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : RMONDRAGON
* PROGRAM NAME : REDO.V.DISDELAY
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                REFERENCE         DESCRIPTION
*26.07.2011    RMONDRAGON         ODR-2011-06-0243       UPDATE
* -----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.LY.PROGRAM
    $INSERT I_GTS.COMMON

    IF VAL.TEXT THEN
        RETURN
    END ELSE
        GOSUB PROCESS
    END

RETURN

*-------
PROCESS:
*-------
    VAR.POINT.USE = COMI

    IF VAR.POINT.USE EQ '2' THEN
        T(REDO.PROG.TXN.TYPE.F.INT)<3> = 'NOINPUT'
        T(REDO.PROG.PRODUCT)<3> = 'NOINPUT'
        T(REDO.PROG.INT.ACCT)<3> = 'NOINPUT'
        R.NEW(REDO.PROG.TXN.TYPE.F.INT) = ''
        R.NEW(REDO.PROG.PRODUCT) = ''
        R.NEW(REDO.PROG.INT.ACCT) = ''
    END

    IF VAR.POINT.USE EQ '1' THEN
        T(REDO.PROG.GEN.FREC)<3> = 'NOINPUT'
        R.NEW(REDO.PROG.GEN.FREC) = ''
    END

    IF VAR.POINT.USE EQ '3' OR VAR.POINT.USE EQ '4' THEN
        T(REDO.PROG.GEN.FREC)<3> = 'NOINPUT'
        T(REDO.PROG.TXN.TYPE.F.INT)<3> = 'NOINPUT'
        T(REDO.PROG.PRODUCT)<3> = 'NOINPUT'
        T(REDO.PROG.INT.ACCT)<3> = 'NOINPUT'
        R.NEW(REDO.PROG.GEN.FREC) = ''
        R.NEW(REDO.PROG.TXN.TYPE.F.INT) = ''
        R.NEW(REDO.PROG.PRODUCT) = ''
        R.NEW(REDO.PROG.INT.ACCT) = ''
    END

RETURN
*------------------------------------------------------------------------------------
END
