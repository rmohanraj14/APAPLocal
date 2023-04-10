* @ValidationCode : MjoxNTgxNDIwOTk0OkNwMTI1MjoxNjgxMTE1NjI5MjA1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 14:03:49
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
SUBROUTINE REDO.S.FETCH.DEB.CUST.ACC
*----------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER

*DESCRIPTIONS:
*-------------
* This routine fetches the field value from Debit Account Number

*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*

* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*

*-----------------------------------------------------------------------------
* Modification History :
* Date            Who                    Reference             Description
* 12-OCT-2010    KAVITHA(TEMENOS)        ODR-2009-12-0290      INITIAL VERSION
* 02-FEB-2015    Vignesh Kumaar R        PACS00428443          ACH CATEGORY INSTEAD ACCOUNT
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes


*-----------------------------------------------------------------------------

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    CALL F.READ(FN.FUNDS.TRANSFER,COMI,R.FUNDS.TRANSFER,F.FUNDS.TRANSFER,FT.ERR)
    Y.ACCT.NO       = R.FUNDS.TRANSFER<FT.DEBIT.ACCT.NO>
    Y.TXN.TYPE      = R.FUNDS.TRANSFER<FT.TRANSACTION.TYPE>
    CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)
    Y.CUSTOMER = R.ACCOUNT<AC.CUSTOMER>
    IF Y.CUSTOMER THEN

* Fix for PACS00428443 [ACH CATEGORY INSTEAD ACCOUNT]
*        COMI =R.ACCOUNT<FT.DEBIT.ACCT.NO>
        COMI = Y.ACCT.NO
* End of Fix
    END ELSE
        IF Y.TXN.TYPE EQ 'AC25' THEN
            APPL.ARRAY = "FUNDS.TRANSFER"
            FIELD.ARRAY = "L.COMMENTS"
            FIELD.POS = ''
            CALL MULTI.GET.LOC.REF(APPL.ARRAY,FIELD.ARRAY,FIELD.POS)
            Y.LOC.COMMENTS.POS = FIELD.POS<1,1>
            FILE.PROCESS.ID = R.FUNDS.TRANSFER<FT.LOCAL.REF,Y.LOC.COMMENTS.POS>
            COMI = FIELD(FILE.PROCESS.ID,'.',5)
        END
    END

RETURN
*----------------------------------------------------------------------------
END
