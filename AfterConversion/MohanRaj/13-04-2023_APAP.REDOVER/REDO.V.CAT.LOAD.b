* @ValidationCode : MjoxNDI0NjkxODg6Q3AxMjUyOjE2ODEzODI5OTk2MTI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:19:59
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
SUBROUTINE REDO.V.CAT.LOAD
****************************************************************
*--------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : MGUDINO
* Program Name  : REDO.V.CAT.LOAD
* ODR NUMBER    :
*-------------------------------------------------------------------------

* Description :This i/p routine is triggered when TELLER transaction is made
* In parameter : None
* out parameter : None
*--------------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM,F.READ TO CACHE.READ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CATEGORY
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
*
    GOSUB INITIALISE
    GOSUB OPEN.FILES
*
    GOSUB PROCESS
*
RETURN
* ======
PROCESS:
* ======
*
    IF APPLICATION EQ "AZ.ACCOUNT" THEN
        Y.ID.CATEGORY = R.NEW(AZ.CATEGORY)
        CALL CACHE.READ(FN.CATEGORY, Y.ID.CATEGORY, R.CATEGORY, Y.ERROR) ;*R22 Auto code conversion
        R.NEW(AZ.LOCAL.REF)<1,POS.AZACC.COD> = R.CATEGORY<EB.CAT.LOCAL.REF,POS.CAT.COD>
    END
*
    IF APPLICATION EQ "ACCOUNT" THEN
        Y.ID.CATEGORY = R.NEW(AC.CATEGORY)
        CALL CACHE.READ(FN.CATEGORY, Y.ID.CATEGORY, R.CATEGORY, Y.ERROR) ;*R22 Auto code conversion
        R.NEW(AC.LOCAL.REF)<1,POS.ACC.COD> = R.CATEGORY<EB.CAT.LOCAL.REF,POS.CAT.COD>
    END
RETURN

INITIALISE:
*----------
*
    Y.ID.CATEGORY = ''
*
    FN.CATEGORY = "F.CATEGORY"
    F.CATEGORY = ""
    Y.ERROR = ""
    R.CATEGORY = ""

    LRF.APP='AZ.ACCOUNT':@FM:'CATEGORY':@FM:'ACCOUNT'
    LRF.FIELD='L.INV.FACILITY':@FM:'L.CU.AGE':@FM:'L.INV.FACILITY'
    LRF.POS=''
RETURN
*----------
OPEN.FILES:
*----------
*
    CALL OPF(FN.CATEGORY,F.CATEGORY)
*
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)
*
    POS.AZACC.COD = LRF.POS<1,1>
    POS.CAT.COD   = LRF.POS<2,1>
    POS.ACC.COD   = LRF.POS<3,1>
RETURN

END
