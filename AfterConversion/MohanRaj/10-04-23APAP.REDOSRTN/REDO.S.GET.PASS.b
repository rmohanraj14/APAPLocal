* @ValidationCode : MjotMjQ5NzM4MzgzOkNwMTI1MjoxNjgxMTMwMDQxNTI2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 18:04:01
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.PASS(USER.PASS)
*-----------------------------------------------------------------------------
* Program Description
* Rutina que recupera el password y lo desencripta
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT JBC.h
    $INSERT I_F.REDO.AT.USER.PASS

*-----------------------------------------------------------------------------

    GOSUB INITIALISE

RETURN

*-----------------------------------------------------------------------------
INITIALISE:

    F.REDO.AT.USER.PASS = ''
    FN.REDO.AT.USER.PASS = 'F.REDO.AT.USER.PASS'
    R.REDO.AT.USER.PASS = ""
    SIGNON = USER.PASS
    CALL OPF (FN.REDO.AT.USER.PASS,F.REDO.AT.USER.PASS)
    CALL F.READ(FN.REDO.AT.USER.PASS,SIGNON,R.REDO.AT.USER.PASS,F.REDO.AT.USER.PASS,"")
    IF NOT(R.REDO.AT.USER.PASS) THEN
        USER.PASS = ""
        RETURN
    END
*  MPASS = FIELD( R.REDO.AT.USER.PASS<1> , @VM , 1)
*  CLAVE = FIELD( R.REDO.AT.USER.PASS<1> , @VM , 2)
* Tus Start
    MPASS = FIELD(R.REDO.AT.USER.PASS<AT.US.USER.PASS> , @VM , 1)
    CLAVE = FIELD(R.REDO.AT.USER.PASS<AT.US.USER.PASS> , @VM , 2)
* Tus End
    USER.PASS = DECRYPT(MPASS,CLAVE,JBASE_CRYPT_DES)
*PRINT R.REDO.AT.USER.PASS<1>:'_':MPASS:'_':CLAVE:'_':USER.PASS
RETURN

*-----------------------------------------------------------------------------
*
END
