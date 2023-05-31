$PACKAGE APAP.AA
SUBROUTINE REDO.B.LOC.UPD.BAL.MAIN.LOAD
*---------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Marimuthu S
*Program   Name    :REDO.B.LOC.UPD.BAL.MAIN.LOAD
*----------------------------------------------------------------------------------
*DESCRIPTION       : This is multi-threaded cob routine will fetch the arrangement id from
*                    local template and make charge with scheduled payment for the loan
*---------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who             Reference            Description
* 26-JAN-2012       MARIMUTHU S       PACS00170057         Initial Creation
* 29-MAR-2023      Conversion Tool                R22 Auto Conversion  - VM to @VM
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.AA.PRODUCT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AC.BALANCE.TYPE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PRODUCT.DESIGNER
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_REDO.B.LOC.UPD.BAL.MAIN.COMMON

MAIN:

    GOSUB OPENFILES
    GOSUB PGM.END

OPENFILES:

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT  = ''
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.REDO.H.AA.DIS.CHG = 'F.REDO.H.AA.DIS.CHG'
    F.REDO.H.AA.DIS.CHG = ''

    FN.REDO.CONC.NEXT.ARR.BILL = 'F.REDO.CONC.NEXT.ARR.BILL'
    F.REDO.CONC.NEXT.ARR.BILL = ''
    CALL OPF(FN.REDO.CONC.NEXT.ARR.BILL,F.REDO.CONC.NEXT.ARR.BILL)

    LOC.REF.APPLICATION = "AA.PRD.DES.BALANCE.MAINTENANCE"
    LOC.REF.FIELDS = 'L.BILL.REF':@VM:'L.BILL.AMOUNT'
    LOC.REF.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.BILL.REF     = LOC.REF.POS<1,1>
    POS.L.BILL.AMOUNT  = LOC.REF.POS<1,2>

    CALL CACHE.READ(FN.REDO.H.AA.DIS.CHG,'SYSTEM',R.REDO.H.AA.DIS.CHG,PROP.PARAM.ERR)

RETURN

PGM.END:

END
