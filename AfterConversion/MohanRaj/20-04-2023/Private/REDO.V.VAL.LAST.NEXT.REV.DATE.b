* @ValidationCode : MjotMTE4Nzc1NzU5NDpDcDEyNTI6MTY4MTk3MDk4NzU5Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:39:47
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
SUBROUTINE REDO.V.VAL.LAST.NEXT.REV.DATE
*-----------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.VAL.LAST.NEXT.REV.DATE
*-----------------------------------------------------------------------------
* DESCRIPTION:
*------------------------------------------------------------------------------------
*       This is a validation routine used to make the Local field L.AA.NXT.REV.DT
* and L.AA.LST.REV.DT in AA.PRD.DES.INTEREST as noinput field when L.AA.REV.RT.TY
* is periodic
*---------------------------------------------------------------------------------------
*Modification History:
*-----------------------------------------------------------------------------------------

*  DATE             WHO         REFERENCE          DESCRIPTION
* 6-06-2010      SUJITHA.S   ODR-2009-10-0326 N.3  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.INTEREST

    GOSUB INIT
    GOSUB PROCESS

RETURN

*-------------------------------------------------------------------------------
INIT:
*-------------------------------------------------------------------------------

    LOC.REF.APPLICATION='AA.PRD.DES.INTEREST'
    LOC.REF.FIELDS='L.AA.REV.RT.TY':@VM:'L.AA.LST.REV.DT':@VM:'L.AA.NXT.REV.DT'
    LOC.REF.POS=''

RETURN

*--------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    Y.TYPE.POS=LOC.REF.POS<1,1>
    Y.NEXT.POS=LOC.REF.POS<1,2>
    Y.LAST.POS=LOC.REF.POS<1,3>

    Y.REV.TY=R.NEW(AA.INT.LOCAL.REF)<1,Y.TYPE.POS>
    Y.NEXT.REV=R.NEW(AA.INT.LOCAL.REF)<1,Y.NEXT.POS>
    Y.LAST.REV=R.NEW(AA.INT.LOCAL.REF)<1,Y.LAST.POS>

    IF Y.REV.TY NE "PERIODICO" THEN
        T.LOCREF<Y.NEXT.POS,7> ='NOINPUT'
        T.LOCREF<Y.LAST.POS,7> ='NOINPUT'
    END
RETURN
END
