* @ValidationCode : MjoxMzEyNzM2NzA0OkNwMTI1MjoxNjgxMjg1NzM5Njk2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:18:59
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
SUBROUTINE REDO.V.AUT.FT.CHECK.ACC
*--------------------------------------------------------------------------------
*Company Name :Asociacion Popular de Ahorros y Prestamos
*Developed By :PRABHU.N
*Program Name :REDO.V.AUT.FT.CHECK.ACC
*---------------------------------------------------------------------------------

*DESCRIPTION :Routine changes L.AC.STATUS1 to ACTIVE when FT
* involves account which is not active and transaction is authorized
*LINKED WITH :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*02/17/2009 -
*Development for setting local field L.AC.STATUS1 to ACTIVE
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM, FM TO @FM,CONVERT TO CHANGE
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.CUST.PRD.LIST
    GOSUB INIT
    GOSUB FILEOPEN
    GOSUB PROCESS
RETURN
*----
INIT:
*----

    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    FN.CUST.PRD.LIST='F.REDO.CUST.PRD.LIST'
    F.CUST.PRD.LIST =''
    LREF.APP='ACCOUNT'
    LREF.FIELD='L.AC.STATUS1'
RETURN
*--------
FILEOPEN:
*--------
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.CUST.PRD.LIST,F.CUST.PRD.LIST)
    CALL GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)

RETURN
*---------
PROCESS:
*---------
    Y.CR.DEB.ID=R.NEW(FT.CREDIT.ACCT.NO)
    GOSUB ACTIVATE
    Y.CR.DEB.ID=R.NEW(FT.DEBIT.ACCT.NO)
    GOSUB ACTIVATE
RETURN
*-------
ACTIVATE:
*-------
    CALL F.READ(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    IF R.ACCOUNT <AC.LOCAL.REF,LREF.POS> NE 'ACTIVE' THEN
        R.ACCOUNT <AC.LOCAL.REF,LREF.POS>='ACTIVE'
        Y.CUSTOMER.ID=R.ACCOUNT<AC.CUSTOMER>
        CALL F.WRITE(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT)
        CUST.JOIN='CUSTOMER'
        GOSUB UPD.PRD.LIST
        GOSUB PRD.UPD.JOIN
    END
RETURN
*------------
UPD.PRD.LIST:
*------------
    CALL F.READ(FN.CUST.PRD.LIST,Y.CUSTOMER.ID,R.CUST.PRD.LIST,F.CUST.PRD.LIST,CUS.ERR)
    Y.PRD.LIST=R.CUST.PRD.LIST<PRD.PRODUCT.ID>
    CHANGE @VM TO @FM IN Y.PRD.LIST ;*R22 Auto Code Conversion
    LOCATE Y.CR.DEB.ID IN Y.PRD.LIST SETTING PRD.POS ELSE
    END

    R.CUST.PRD.LIST<PRD.PRD.STATUS,PRD.POS> ='ACTIVE'
    R.CUST.PRD.LIST<PRD.TYPE.OF.CUST,PRD.POS>=CUST.JOIN
    R.CUST.PRD.LIST<PRD.DATE,PRD.POS>=TODAY
    R.CUST.PRD.LIST<PRD.PROCESS.DATE> = TODAY
    CALL F.WRITE(FN.CUST.PRD.LIST,Y.CUSTOMER.ID,R.CUST.PRD.LIST)
RETURN
PRD.UPD.JOIN:
    IF R.ACCOUNT<AC.JOINT.HOLDER> NE '' THEN
        Y.CUSTOMER.ID=R.ACCOUNT<AC.JOINT.HOLDER>
        CUST.JOIN='JOINT.HOLDER'
        GOSUB UPD.PRD.LIST
    END
RETURN
END
