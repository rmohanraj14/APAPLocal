* @ValidationCode : MjotMTM2NDgwMTE2ODpDcDEyNTI6MTY4MTEyODUzNjk0Mzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 17:38:56
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
SUBROUTINE REDO.S.GET.ID.NEW
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :MGUDINO
*Program   Name    :REDO.S.GET.ID.NEW
*---------------------------------------------------------------------------------

*DESCRIPTION       :GETS ID NEW.. IN ORDER TO POPULATE L.INITIAL.ID

* ----------------------------------------------------------------------------------
*Modification Details:
*   Date               who           Reference            Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
    $INSERT I_F.TELLER
*GET THE id.new

    LREF.APP = 'TELLER'
    LREF.FIELDS = 'L.INITIAL.ID'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)
    POS.L.INITIAL.ID = LREF.POS<1,1>

    R.NEW(TT.TE.LOCAL.REF)<1,POS.L.INITIAL.ID> = ID.NEW


RETURN
