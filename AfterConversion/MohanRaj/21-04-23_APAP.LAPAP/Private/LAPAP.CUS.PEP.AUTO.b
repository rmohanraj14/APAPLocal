* @ValidationCode : MjotNTk0MzEzMzA1OkNwMTI1MjoxNjgyMDcyMTMwNzAwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:45:30
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
$PACKAGE APAP.LAPAP
*========================================================================
SUBROUTINE LAPAP.CUS.PEP.AUTO
*========================================================================
* Technical report:
* =================
* Company Name   : APAP
* Program Name   : LAPAP.CUS.PEP.AUTO
* Date           : 2019-08-13
* Item ID        :
*========================================================================
* Brief description :
* -------------------
* This program validate Pep's status
*========================================================================
* Modification History :
* ======================
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2019-08-13     Richard HC                Initial Development
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*========================================================================
* Content summary :
* =================
* Table name     : CUSTOMER
* Auto Increment : N/A
* Views/versions : ALL VERSION IN CUSTOMER
* EB record      : LAPAP.CUS.PEP.AUTO
* Routine        : LAPAP.CUS.PEP.AUTO
*========================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER

    FN.CUS = "F.CUSTOMER"
    F.CUS = ""
    CALL OPF(FN.CUS,F.CUS)


    CALL GET.LOC.REF("CUSTOMER","L.CU.PEPS",POS)

    PEPS = R.NEW(EB.CUS.LOCAL.REF)<1,POS>

    IF PEPS EQ "" THEN

        R.NEW(EB.CUS.LOCAL.REF)<1,POS> = "NO"

    END



RETURN

END
