* @ValidationCode : MjoxNDI0NTQ1Mzg2OkNwMTI1MjoxNjgyMDcyNTU4MzMwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:52:38
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
SUBROUTINE LAPAP.CUSTOMER.ID(ID,RS)

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER


    FN.CUS = "F.CUSTOMER"
    F.CUS = ""
    CALL OPF (FN.CUS,F.CUS)


    CALL F.READ(FN.CUS,ID,R.CUS,F.CUS,CUS.ERR)

    CALL GET.LOC.REF("CUSTOMER","L.CU.CIDENT",POS)
    CARD.ID = R.CUS<EB.CUS.LOCAL.REF,POS>

    CALL GET.LOC.REF("CUSTOMER","L.CU.NOUNICO",POS)
    NO.UNIC = R.CUS<EB.CUS.LOCAL.REF,POS>

    CALL GET.LOC.REF("CUSTOMER","L.CU.ACTANAC",POS)
    B.CERT = R.CUS<EB.CUS.LOCAL.REF,POS>

    CALL GET.LOC.REF("CUSTOMER","L.CU.PASS.NAT",POS)
    PASS.N = R.CUS<EB.CUS.LOCAL.REF,POS>

    CALL GET.LOC.REF("CUSTOMER","L.CU.RNC",POS)
    RNC.NO = R.CUS<EB.CUS.LOCAL.REF,POS>



    BEGIN CASE
        CASE CARD.ID NE ''
            RS = CARD.ID

        CASE NO.UNIC NE ''
            RS = NO.UNIC

        CASE B.CERT NE ''
            RS = B.CERT

        CASE PASS.N NE ''
            RS = PASS.N

        CASE RNC.NO NE ''
            RS = RNC.NO

    END CASE



END
