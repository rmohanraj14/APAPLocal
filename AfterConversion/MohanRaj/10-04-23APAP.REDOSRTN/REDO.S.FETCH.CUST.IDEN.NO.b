* @ValidationCode : MjoxNjQyNjk3NTc0OkNwMTI1MjoxNjgxMTE1MjkwMjk3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:58:10
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
SUBROUTINE REDO.S.FETCH.CUST.IDEN.NO(RES)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.FETCH.CUST.IDEN
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to check the customer record Field and get
*                   identification field and display in the deal slip
*[IDENTITY ID  >> "EEEE" = LEGAL.ID or L.CU.CIDENT or L.CU.NOUNICO or L.CU.ACTANAC
*    Just one of these values will be populated on CUSTOMER (so pick up the one being populated from above))
*LINKED WITH       :


* Revision History
*-------------------------
*    Date             Who               Reference       Description
* 01-JUL-2011        KAVITHA            PACS00062260    Issue fix
*Modification history
*Date                Who               Reference                  Description
*06-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*06-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.LATAM.CARD.ORDER
    $INSERT I_F.ACCOUNT.CLOSURE


    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*-----*
INIT:
*-----*

*PACS00062260 -S

*    Y.CUST.ID=RES
    Y.CUST.ID = R.NEW(CARD.IS.CUSTOMER.NO)<1,1>

*PACS00062260 -E

    RES=''
    LOC.REF.APPLICATION="CUSTOMER"
    LOC.REF.FIELDS="L.CU.CIDENT":@VM:"L.CU.NOUNICO":@VM:"L.CU.ACTANAC"
    LOC.REF.POS=''
RETURN
*---------*
OPEN.FILES:
*----------*
    FN.CUST='F.CUSTOMER'
    F.CUST=''
    CALL OPF(FN.CUST,F.CUST)

RETURN
*-------*
PROCESS:
*-------*

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    Y.LOC.CIDENT =LOC.REF.POS<1,1>
    Y.LOC.NOUNICO=LOC.REF.POS<1,2>
    Y.LOC.ACTANAC=LOC.REF.POS<1,3>

    CALL F.READ(FN.CUST,Y.CUST.ID,R.CUSTOMER,F.CUST,CUS.ERROR)
    LEGAL.ID=R.CUSTOMER<EB.CUS.LEGAL.ID>
    CIDENT=R.CUSTOMER<EB.CUS.LOCAL.REF><1,Y.LOC.CIDENT>
    NOUNICO=R.CUSTOMER<EB.CUS.LOCAL.REF><1,Y.LOC.NOUNICO>
    ACTANAC=R.CUSTOMER<EB.CUS.LOCAL.REF><1,Y.LOC.ACTANAC>
    IF LEGAL.ID OR CIDENT THEN
        IF LEGAL.ID THEN
            RES=LEGAL.ID
        END
        ELSE
            RES=CIDENT
        END
    END
    ELSE
        IF NOUNICO THEN
            RES=NOUNICO
        END
        ELSE
            RES=ACTANAC
        END
    END
RETURN
END
