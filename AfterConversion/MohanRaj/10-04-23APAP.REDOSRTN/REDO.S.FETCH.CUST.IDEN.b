* @ValidationCode : MjotODA1NjUzODUxOkNwMTI1MjoxNjgxMTE1MjM3OTcwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 13:57:17
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
SUBROUTINE REDO.S.FETCH.CUST.IDEN(RES)
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :GANESH.R
*Program Name :REDO.S.FETCH.CUST.IDEN
*---------------------------------------------------------------------------------

*DESCRIPTION :This program is used to check the customer record Field and get
* identification field and display in the deal slip
*LINKED WITH :
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT.CLOSURE

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS
*-----*
INIT:
*-----*
    LOC.REF.APPLICATION="CUSTOMER"
    LOC.REF.FIELDS="L.CU.CIDENT"
    LOC.REF.POS=''
RETURN
*---------*
OPEN.FILES:
*----------*
    FN.ACL.CLOSURE='F.ACCOUNT.CLOSURE'
    F.ACL.CLOSURE=''
    CALL OPF(FN.ACL.CLOSURE,F.ACL.CLOSURE)

    FN.CUST='F.CUSTOMER'
    F.CUST=''
    CALL OPF(FN.CUST,F.CUST)

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
RETURN
*-------*
PROCESS:
*-------*

    APPLN=APPLICATION
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    LOC.CIDENT=LOC.REF.POS<1,1>

    REC.ID=ID.NEW
    IF APPLN EQ "ACCOUNT.CLOSURE" THEN
        CALL F.READ(FN.ACCOUNT,REC.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERROR)
        RES=R.ACCOUNT<AC.CUSTOMER>
    END
    IF APPLN EQ "AZ.ACCOUNT" THEN
        CALL F.READ(FN.ACCOUNT,REC.ID,R.ACCOUNT,F.ACCOUNT,AZ.ERROR)
        CUS.REC=R.ACCOUNT<AC.CUSTOMER>
        CALL F.READ(FN.CUST,CUS.REC,R.CUSTOMER,F.CUST,CUS.ERROR)
        CIDENT=R.CUSTOMER<EB.CUS.LOCAL.REF><1,LOC.CIDENT>
        IF CIDENT NE '' THEN
            RES="CEDULA"
        END
        LE.VAL=R.CUSTOMER<EB.CUS.LEGAL.ID>
        IF LE.VAL NE '' THEN
            RES="PASAPORTE"
        END
        IF CIDENT EQ '' AND LE.VAL EQ '' THEN
            RES=''
        END

    END
RETURN
END
