* @ValidationCode : MjoxMTQzMTcwNjc1OkNwMTI1MjoxNjgxMzg3ODA3MTc3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:40:07
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
SUBROUTINE  REDO.V.DISDELAY
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
*19.07.2011    RMONDRAGON         ODR-2011-06-0243       UPDATE
*28.11.2011    RMONDRAGON         ODR-2011-06-0243       UPDATE
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion    CALL method format modified
* -----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.LY.PROGRAM

    IF VAL.TEXT THEN
        Y.DIS.DELAY = R.NEW(REDO.PROG.AVAIL.IF.DELAY)
    END ELSE
        Y.DIS.DELAY = COMI
    END

    GOSUB PROCESS

RETURN

*-------
PROCESS:
*-------

    IF VAL.TEXT EQ '' THEN
        VAL.TEXT = 'VALIDATED'
        CALL APAP.REDOVER.REDO.V.AVAIL.PROGRAM ;* R22 Manual Conversion - CALL method format modified
        VAL.TEXT = ''
    END ELSE
        CALL APAP.REDOVER.REDO.V.AVAIL.PROGRAM ;* R22 Manual Conversion - CALL method format modified
    END

    IF Y.DIS.DELAY EQ 'NO' THEN
        T(REDO.PROG.PROD.DELAY)<3> = 'NOINPUT'
        T(REDO.PROG.PER.IF.DELAY)<3> = 'NOINPUT'
    END

RETURN

*------------------------------------------------------------------------------------
END
