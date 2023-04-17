* @ValidationCode : MjotMjkzNDQ5MDY5OkNwMTI1MjoxNjgxNzI3NDUyODk3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 16:00:52
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
SUBROUTINE REDO.V.INP.CUST.END.DATE
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :SARAVANAKUMAR
*Program Name :REDO.V.INP.CUST.END.DATE
*----------------------------------------------------------------------
* * Input / Output
* --------------
* IN : -NA-
* OUT : -NA-
*----------------------------------------------------------------------
*DESCRIPTION :THIS PROGRAM WILL CHECK WHETHER THE LOCAL FIELD L.CU.DAT.END.CO OF CUSTOMER APPLICATION IS GIVEN
* WITH THE DATE GREATER THAT TODAY
*LINKED WITH : CUSTOMER APPL AS AN INPUT ROUTINE
* ----------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE WHO REFERENCE DESCRIPTION
*08.11.2009 SARAVANAKUMAR ODR-2009-10-0526 INITIAL CREATION
*12.05.2010 SUDHARSANAN S HD1018074 MODIFICATION AS PER THE ISSUE
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     No changes
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER

    GOSUB INITIALIZE
    GOSUB CHECKDATE
RETURN
INITIALIZE:

    LOC.FLD.VALUE=''
    CALL GET.LOC.REF('CUSTOMER','L.CU.DAT.END.CO',LOC.FLD.VALUE)
    Y.CU.DAT.END.CO=R.NEW(EB.CUS.LOCAL.REF)<1,LOC.FLD.VALUE>
RETURN

CHECKDATE:

    IF Y.CU.DAT.END.CO NE '' THEN
        IF Y.CU.DAT.END.CO LE TODAY THEN
            AF=EB.CUS.LOCAL.REF
            AV=LOC.FLD.VALUE
            ETEXT="EB-CU.END.DATE.ERROR"
            CALL STORE.END.ERROR
        END
    END
RETURN
END
