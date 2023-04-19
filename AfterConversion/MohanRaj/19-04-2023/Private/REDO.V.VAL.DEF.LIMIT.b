* @ValidationCode : MjoxNTQ3NjU5NzY4OkNwMTI1MjoxNjgxODg5OTUwMTQyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:09:10
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
SUBROUTINE REDO.V.VAL.DEF.LIMIT
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.V.VAL.DEF.LIMIT
*Reference Number  :ODR-2010-08-0039
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to populate the Maximum and Minimum Limits
*                   in the local fields in Teller.ID Application using TOLERANCE.CATEG.RANGE
*                    local table
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER.ID
    $INSERT I_F.TOLERANCE.CATEG.RANGE

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

INIT:

    BRANCH.LIMIT=''
    TILL.LIMIT=''
    VAULT.LIMIT=''

    FLAG=''
    TELL.ID=''

    LOC.TT.BRAN.LIM=''
    LOC.TT.CURRENCY=''
    LOC.TT.MAX.LIM=''
    LOC.TT.MIN.LIM=''
    LOC.TT.MN.VAU.LIM=''
    LOC.TT.MAX.TL.LIM=''
    LOC.TT.MIN.TL.LIM=''
    LOC.TT.TILL.LIM=''
    LOC.TT.MAX.BR.LIM=''
    LOC.TT.MIN.BR.LIM=''
    LOC.TT.TOL.CAT.RG=''

    LOC.REF.APPLICATION="TELLER.ID"
    LOC.REF.FIELDS='L.TT.BRAN.LIM':@VM:'L.TT.TOL.CAT.RG':@VM:'L.TT.MIN.BR.LIM':@VM:'L.TT.MAX.BR.LIM':@VM:'L.TT.TILL.LIM':@VM:'L.TT.MIN.TL.LIM':@VM:'L.TT.MAX.TL.LIM':@VM:'L.TT.MN.VAU.LIM':@VM:'L.TT.MIN.LIM':@VM:'L.TT.MAX.LIM':@VM:'L.TT.CURRENCY'
    LOC.REF.POS=''
RETURN

OPEN.FILES:

    FN.TELLER='F.TELLER.ID'
    F.TELLER.ID=''
    CALL OPF(FN.TELLER,F.TELLER.ID)

    FN.TOL.CATEG='F.TOLERANCE.CATEG.RANGE'
    F.TOL.CATEG=''
    CALL OPF(FN.TOL.CATEG,F.TOL.CATEG)

RETURN

PROCESS:
*Processes the Types of limits defined
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    LOC.TT.BRAN.LIM=LOC.REF.POS<1,1>
    LOC.TT.TOL.CAT.RG=LOC.REF.POS<1,2>
    LOC.TT.MIN.BR.LIM=LOC.REF.POS<1,3>
    LOC.TT.MAX.BR.LIM=LOC.REF.POS<1,4>
    LOC.TT.TILL.LIM=LOC.REF.POS<1,5>
    LOC.TT.MIN.TL.LIM=LOC.REF.POS<1,6>
    LOC.TT.MAX.TL.LIM=LOC.REF.POS<1,7>
    LOC.TT.MN.VAU.LIM=LOC.REF.POS<1,8>
    LOC.TT.MIN.LIM=LOC.REF.POS<1,9>
    LOC.TT.MAX.LIM=LOC.REF.POS<1,10>
    LOC.TT.CURRENCY=LOC.REF.POS<1,11>
    VAR.CURRENCY = R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.CURRENCY>

    BRANCH.LIMIT=R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.BRAN.LIM,AS>
    TILL.LIMIT=R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.TILL.LIM,AS>
    VAULT.LIMIT=R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MN.VAU.LIM,AS>
    CATG.RANG=''
    CATG.RANG = COMI
    TELL.ID=CATG.RANG
    IF BRANCH.LIMIT NE '' THEN
        GOSUB BRANCH.PROCESS
    END
    IF TILL.LIMIT NE '' THEN
        GOSUB TELLER.PROCESS
    END

    IF VAULT.LIMIT NE '' THEN
        GOSUB VAULT.PROCESS
    END

RETURN

BRANCH.PROCESS:
*Gets the Value of Branch limit and Category Range and defaults the Minimum and maximum limit
    MIN.VAL=''
    MAX.VAL=''
    MIN.CASH.AMT=''
    MAX.CASH.AMT=''
    R.TOL.CATEG=''
    IF TELL.ID NE '' THEN
        CALL F.READ(FN.TOL.CATEG,TELL.ID,R.TOL.CATEG,F.TOL.CATEG,ERR)
        MIN.CASH.AMT=R.TOL.CATEG<TR.MIN.LIM.CASHIER>
        MAX.CASH.AMT=R.TOL.CATEG<TR.MAX.LIM.CASHIER>
        MIN.VAL=(MIN.CASH.AMT/100)*BRANCH.LIMIT
        MAX.VAL=((MAX.CASH.AMT/100)*BRANCH.LIMIT)+BRANCH.LIMIT
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MIN.BR.LIM,AS>=MIN.VAL
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MAX.BR.LIM,AS>=MAX.VAL
    END
RETURN

TELLER.PROCESS:
*Gets the Value of Teller limit and Category Range and defaults the Minimum and maximum limit
    MIN.VAL=''
    MAX.VAL=''
    MIN.TILL.LIMIT=''
    MAX.TILL.LIMIT=''
    R.TOL.CATEG=''
    IF TELL.ID NE '' THEN
        CALL F.READ(FN.TOL.CATEG,TELL.ID,R.TOL.CATEG,F.TOL.CATEG,ERR)
        MIN.TILL.LIMIT=R.TOL.CATEG<TR.MIN.LIM.CASHIER>
        MAX.TILL.LIMIT=R.TOL.CATEG<TR.MAX.LIM.CASHIER>
        MIN.VAL=(MIN.TILL.LIMIT/100)*TILL.LIMIT
        MAX.VAL=((MAX.TILL.LIMIT/100)*TILL.LIMIT)+TILL.LIMIT
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MIN.TL.LIM,AS>=MIN.VAL
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MAX.TL.LIM,AS>=MAX.VAL
    END
RETURN


VAULT.PROCESS:
*Gets the Value of Vault limit and Category Range and defaults the Minimum and maximum limit
    MIN.VAL=''
    MAX.VAL=''
    MIN.VAULT.LIMIT=''
    MAX.VAULT.LIMIT=''
    R.TOL.CATEG=''
    IF TELL.ID NE '' THEN
        CALL F.READ(FN.TOL.CATEG,TELL.ID,R.TOL.CATEG,F.TOL.CATEG,ERR)
        MIN.VAULT.LIMIT = R.TOL.CATEG<TR.MIN.LIM.AGNCY>
        MAX.VAULT.LIMIT = R.TOL.CATEG<TR.MAX.LIM.AGNCY>
        MIN.VAL=(MIN.VAULT.LIMIT/100)*VAULT.LIMIT
        MAX.VAL=((MAX.VAULT.LIMIT/100)*VAULT.LIMIT)+VAULT.LIMIT
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MIN.LIM,AS>=MIN.VAL
        R.NEW(TT.TID.LOCAL.REF)<1,LOC.TT.MAX.LIM,AS>=MAX.VAL
    END

RETURN
END
