$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE E.APAP.H.INSURANCE.CUS.AA.ARR (ENQ.DATA)
*
*
*=====================================================================
* Subroutine Type : BUILD ROUTINE
* Attached to     :
* Attached as     :
* Primary Purpose :
*---------------------------------------------------------------------
* Modification History:
*
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar            R22 Manual Code Conversion        package added APAP.AA
* 29-March-2020       Conversion Tool                          R22 Auto Code Conversion         VM to @vm
* Development for : APAP
* Development by  : pgarzongavilanes
* Date            : 2011-07-07
*=====================================================================

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
*
************************************************************************
*


    CUSTOMER.LIST = R.NEW(INS.DET.CUSTOMER)
    CUSTOMER.LIST = CHANGE(CUSTOMER.LIST,@VM," ") ;*R22 Auto Code Conversion

    ENQ.DATA<2,1> = "CUSTOMER"
    ENQ.DATA<3,1> = "EQ"
    ENQ.DATA<4,1> = CUSTOMER.LIST

RETURN



END
