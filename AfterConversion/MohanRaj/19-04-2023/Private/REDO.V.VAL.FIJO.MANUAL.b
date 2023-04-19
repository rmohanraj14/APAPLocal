* @ValidationCode : MjotMjI5MTIwMzUwOkNwMTI1MjoxNjgxODkwNTkyMzM4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:19:52
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
SUBROUTINE REDO.V.VAL.FIJO.MANUAL
*---------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Sivakumar K
* Program Name  : REDO.V.VAL.FIJO.MANUAL
* ODR NUMBER    :
*----------------------------------------------------------------------------------
* Description   : This VALIDATION routine will do check if TYPE.RATE.REV is "FIJO"
*                 then assign the value for the field FORM.REVIEW as "MANUAL" else
*                 assign as "AUTOMATIC".
*
* In parameter  : None
* out parameter : None
*----------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 12-Mar-2013      Sivakumar K        PACS00254290      Initial creation
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CREATE.ARRANGEMENT

    GOSUB OPENFILES
    GOSUB PROCESS

RETURN

*----------------------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------------------


    FN.REDO.CREATE.ARRANGEMENT = 'F.REDO.CREATE.ARRANGEMENT'
    F.REDO.CREATE.ARRANGEMENT = ''
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)

RETURN

*----------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------------------

    IF COMI EQ 'FIJO' THEN
        R.NEW(REDO.FC.FORM.REVIEW) = "MANUAL"
    END ELSE
        IF COMI EQ 'BACK.TO.BACK' THEN
            R.NEW(REDO.FC.FORM.REVIEW) = "AUTOMATICA"
        END
    END

RETURN
END
