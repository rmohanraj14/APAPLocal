* @ValidationCode : MjoxMjI2ODE3NTUzOkNwMTI1MjoxNjgxMzgyMzU0MDExOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:09:14
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
SUBROUTINE  REDO.V.AVAIL.PROGRAM
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
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.AVAIL.PROGRAM
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                REFERENCE         DESCRIPTION
*23.06.2010      SUDHARSANAN S     ODR-2009-12-0276 INITIAL CREATION
*18.07.2011    RMONDRAGON          ODR-2011-06-0243 UPDATE
*28.11.2011    RMONDRAGON          ODR-2011-06-0243 UPDATE
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.LY.PROGRAM

    IF VAL.TEXT THEN
        VAR.AVAILABILITY = R.NEW(REDO.PROG.AVAILABILITY)
    END ELSE
        VAR.AVAILABILITY = COMI
    END

    GOSUB PROCESS

RETURN

*-------
PROCESS:
*-------

    IF VAR.AVAILABILITY NE '4' THEN
        T(REDO.PROG.AVAIL.DATE)<3> = 'NOINPUT'
    END

RETURN

*------------------------------------------------------------------------------------
END
