* @ValidationCode : Mjo5MTUzMzQ5Nzc6Q3AxMjUyOjE2ODE4MTk3MTg3MDY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 18 Apr 2023 17:38:38
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
SUBROUTINE REDO.V.VAL.BENEF
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This is Validation routine for the field BENEFICIARY of TELLER to
* default in NARRATIVE
*
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
* Linked : TELLER
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.VAL.BENEF
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE WHO REFERENCE DESCRIPTION
* 16.03.2010 SUDHARSANAN S ODR-2009-10-0319 INITIAL CREATION
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER

    GOSUB LOCAL.REF
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
LOCAL.REF:
*-----------------------------------------------------------------------------
    LOC.REF.APPLICATION="TELLER"
    LOC.REF.FIELDS='L.TT.BENEFICIAR'
    LOC.REF.POS=''
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.BENEFICIARY =LOC.REF.POS<1,1>
RETURN
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------
    Y.BENEFICIARY.NAME=R.NEW(TT.TE.LOCAL.REF)<1,POS.BENEFICIARY>
    IF Y.BENEFICIARY.NAME THEN
        R.NEW(TT.TE.NARRATIVE.1)<1,1> = Y.BENEFICIARY.NAME
    END
RETURN
END
