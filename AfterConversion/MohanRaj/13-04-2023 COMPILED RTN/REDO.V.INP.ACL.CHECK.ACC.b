* @ValidationCode : MjoxNDM4MDIyNTIyOkNwMTI1MjoxNjgxMzg4ODk5MDYxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:58:19
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
SUBROUTINE REDO.V.INP.ACL.CHECK.ACC
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.INP.ACL.CHECK.ACC
*---------------------------------------------------------------------------------

*DESCRIPTION       :Input routine generates  override when Account involves to Account.closure which
*                   is not active
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
* Name                ID Ref          Date              Description
* Sudharsanan S      PACS00194263     02/05/2012        Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT.CLOSURE
    $INSERT I_F.CUSTOMER
    GOSUB INIT
    GOSUB FILEOPEN
    GOSUB PROCESS
    GOSUB PGM.END
RETURN
*----
INIT:
*----
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER =''
    LREF.APP='ACCOUNT':@FM:'ACCOUNT.CLOSURE'
    LREF.FIELD='L.AC.STATUS1':@VM:'L.AC.STATUS2':@FM:'L.CLOSE.MODE'
RETURN
*--------
FILEOPEN:
*--------
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    LREF.POS = ''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
    POS.STATUS1    = LREF.POS<1,1>
    POS.STATUS2    = LREF.POS<1,2>
    POS.CLOSE.MODE = LREF.POS<2,1>

RETURN
*--------
PROCESS:
*--------
*VAR.CLOSE.MODE = R.NEW(AC.ACL.CLOSE.MODE)
    VAR.CLOSE.MODE = R.NEW(AC.ACL.LOCAL.REF)<1,POS.CLOSE.MODE>
    IF VAR.CLOSE.MODE EQ 'TELLER' THEN
        Y.CR.DEB.ID = ID.NEW
        GOSUB OVERRIDE.GEN
    END ELSE
        Y.CR.DEB.ID=R.NEW(AC.ACL.SETTLEMENT.ACCT)
        GOSUB CHECK.CUSTOMER.STATUS
        GOSUB OVERRIDE.GEN
        GOSUB CHECK.DECEASE
        Y.CR.DEB.ID = ID.NEW
        GOSUB OVERRIDE.GEN
    END
RETURN
*-----------
OVERRIDE.GEN:
*-----------
    CALL F.READ(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT,F.ACCOUNT,CRE.ERR)
    Y.STATUS=R.ACCOUNT<AC.LOCAL.REF,POS.STATUS1>
    Y.STATUS2= R.ACCOUNT<AC.LOCAL.REF,POS.STATUS2>
    IF Y.STATUS NE 'ACTIVE' AND Y.STATUS NE '' AND R.ACCOUNT<AC.CUSTOMER> NE '' THEN
        GOSUB CHECK.STATUS
        TEXT="REDO.AC.CHECK.ACTIVE":@FM:Y.CR.DEB.ID:@VM:Y.MESSAGE
*OVERRIDE.FIELD.VALUE = R.NEW(AC.OVERRIDE)
*CURR.NO = DCOUNT(OVERRIDE.FIELD.VALUE,'VM') + 1
        CURR.NO = ''
        CALL STORE.OVERRIDE(CURR.NO)
    END
RETURN
*---------------------
CHECK.CUSTOMER.STATUS:
*---------------------
    CALL F.READ(FN.ACCOUNT,Y.CR.DEB.ID,R.ACCOUNT,F.ACCOUNT,CRE.ERR)
    VAR.CUSTOMER.NO = R.ACCOUNT<AC.CUSTOMER>
    CALL F.READ(FN.CUSTOMER,VAR.CUSTOMER.NO,R.CUSTOMER,F.CUSTOMER,CUST.ERR)
    VAR.CUST.STATUS = R.CUSTOMER<EB.CUS.CUSTOMER.STATUS>
    IF VAR.CUST.STATUS EQ '3' THEN
        AF = AC.ACL.SETTLEMENT.ACCT
        ETEXT = 'EB-REDO.AC.DECESED'
        CALL STORE.END.ERROR
        GOSUB PGM.END
    END
RETURN
*-------------------------------
CHECK.STATUS:
*--------------------------------
    VIRTUAL.TAB.ID='L.AC.STATUS1'
    CALL EB.LOOKUP.LIST(VIRTUAL.TAB.ID)
    Y.LOOKUP.LIST=VIRTUAL.TAB.ID<2>
    Y.LOOKUP.DESC=VIRTUAL.TAB.ID<11>
    CHANGE '_' TO @FM IN Y.LOOKUP.LIST
    CHANGE '_' TO @FM IN Y.LOOKUP.DESC
    LOCATE Y.STATUS IN Y.LOOKUP.LIST SETTING POS1 THEN
        IF R.USER<EB.USE.LANGUAGE> EQ 1 THEN          ;* This is for english user
            Y.MESSAGE=Y.LOOKUP.DESC<POS1,1>
        END
        IF R.USER<EB.USE.LANGUAGE> EQ 2 AND Y.LOOKUP.DESC<POS1,2> NE '' THEN
            Y.MESSAGE=Y.LOOKUP.DESC<POS1,2>   ;* This is for spanish user
        END ELSE
            Y.MESSAGE=Y.LOOKUP.DESC<POS1,1>
        END
    END
RETURN
*-------------------------------
CHECK.DECEASE:
*-------------------------------
*This para is used to generate the error message for settlement account and the same validation for @id is handle in REDO.CHK.ACC.UPDATE routine
    CHANGE @SM TO @FM IN Y.STATUS2
    LOCATE 'DECEASED' IN Y.STATUS2 SETTING POS THEN
        AF = AC.ACL.SETTLEMENT.ACCT
        ETEXT = 'EB-REDO.AC.DECESED'
        CALL STORE.END.ERROR
        GOSUB PGM.END
    END
RETURN
*------------------
PGM.END:
*------------------
END
