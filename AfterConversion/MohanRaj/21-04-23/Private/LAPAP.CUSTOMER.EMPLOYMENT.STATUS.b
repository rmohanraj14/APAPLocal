* @ValidationCode : MjoyOTUxMDQ5MjY6Q3AxMjUyOjE2ODIwNzI0MzAxNDQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:50:30
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
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CUSTOMER.EMPLOYMENT.STATUS

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.CUSTOMER

    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ""
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    EMPLOYMENT.STATUS = COMI

    IF EMPLOYMENT.STATUS EQ 04 OR EMPLOYMENT.STATUS EQ 62 THEN
        ETEXT = "VALOR NO VALIDO"
        CALL STORE.END.ERROR
    END

RETURN

END
