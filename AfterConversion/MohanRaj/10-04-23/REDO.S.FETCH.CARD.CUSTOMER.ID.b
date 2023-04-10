* @ValidationCode : MjotNTQyNzY3MTM3OkNwMTI1MjoxNjgxMTE0ODA3NTE5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:50:07
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
SUBROUTINE REDO.S.FETCH.CARD.CUSTOMER.ID(IN.PARAM)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :KAVITHA
*Program   Name    :REDO.S.FETCH.CARD.CUSTOMER.ID
*-------------------------------------------------------------------------------

*DESCRIPTION       :This subroutine is used to get the value of CUSTOMER ID
*
* ----------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* Revision History
*-------------------------
*    Date             Who               Reference       Description
* 01-JUL-2011        KAVITHA            PACS00062260    Initial creation
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*----------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.LATAM.CARD.ORDER

    FN.CUST='F.CUSTOMER'
    F.CUST=''
    CALL OPF(FN.CUST,F.CUST)

    IN.PARAM = R.NEW(CARD.IS.CUSTOMER.NO)<1,1>


RETURN
END
