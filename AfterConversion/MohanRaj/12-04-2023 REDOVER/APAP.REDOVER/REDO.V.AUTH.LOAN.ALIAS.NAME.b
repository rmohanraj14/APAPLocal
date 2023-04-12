* @ValidationCode : MjotMTE3NDY0NDgwMTpDcDEyNTI6MTY4MTMwMzg0Nzg3ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:20:47
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
SUBROUTINE REDO.V.AUTH.LOAN.ALIAS.NAME
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : Prabhu N
* Program Name : REDO.V.AUTH.LOAN.ALIAS.NAME
*-----------------------------------------------------------------------------
* Description :
* Linked with :
* In Parameter : ENQ.DATA
* Out Parameter : None
*
**DATE           ODR                   DEVELOPER               VERSION
*
*16/10/11      PACS00102015           PRABHU N                   MODIFICATION
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AI.REDO.ARCIB.ALIAS.TABLE



    GOSUB OPEN.FILES
    GOSUB UPDATE.LOAN.SHORT.NAME
RETURN
*-----------*
OPEN.FILES:
*-----------*
    FN.ALIAS = 'F.AI.REDO.ARCIB.ALIAS.TABLE'
    F.ALIAS = ''
    CALL OPF(FN.ALIAS,F.ALIAS)


RETURN

*-----------------------*
UPDATE.LOAN.SHORT.NAME:
*-----------------------*

    CALL F.READ(FN.ALIAS,ID.NEW,R.ALIAS.REC,F.ALIAS,ACC.ERR)
    IF R.ALIAS.REC THEN
        Y.NEW.NAME = R.NEW(AC.SHORT.TITLE)
        Y.OLD.NAME = R.OLD(AC.SHORT.TITLE)
        IF Y.OLD.NAME NE Y.NEW.NAME THEN
            R.ALIAS.REC<AI.ALIAS.ALIAS.NAME,1> = R.NEW(AC.SHORT.TITLE)
            CALL F.WRITE(FN.ALIAS,ID.NEW,R.ALIAS.REC)
        END
    END ELSE
        R.ALIAS.REC<AI.ALIAS.ALIAS.NAME,1> = R.NEW(AC.SHORT.TITLE)
        CALL F.WRITE(FN.ALIAS,ID.NEW,R.ALIAS.REC)
    END
RETURN
END
