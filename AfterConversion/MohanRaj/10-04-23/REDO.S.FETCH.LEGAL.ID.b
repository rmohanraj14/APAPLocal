* @ValidationCode : MjoxMTQyODMxNzY3OkNwMTI1MjoxNjgxMTE1NzYzNDI3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 14:06:03
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
SUBROUTINE REDO.S.FETCH.LEGAL.ID
*----------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CUSTOMER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER

*DESCRIPTIONS:
*-------------
* This Hook routine attached to ORIGIN.IDENTIF field in RAD.CONDUIT.MAPPING table
* This routine fetches the field value from CUSTOMER L.CU.CIDENT or LEGAL.ID
*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-

* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*

*-----------------------------------------------------------------------------
* Modification History :
* Date            Who                    Reference             Description
* 12-OCT-2010    KAVITHA(TEMENOS)        ODR-2009-12-0290      INITIAL VERSION
* 02-FEB-2015    Vignesh Kumaar R        PACS00428443          ACH BLANK RNC
* 14-JUN-2015     Aslam                  PACS00459597          Modification
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM,VM TO@VM
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-----------------------------------------------------------------------------

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER':@FM:'CUSTOMER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    APPL.ARRAY = "FUNDS.TRANSFER":@FM:"CUSTOMER"
    FIELD.ARRAY = "L.COMMENTS":@FM:"L.CU.CIDENT":@VM:"L.CU.RNC"
    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(APPL.ARRAY,FIELD.ARRAY,FIELD.POS)
    Y.LOC.COMMENTS.POS = FIELD.POS<1,1>
    Y.L.CU.CIDENT.POS  = FIELD.POS<2,1>
    Y.L.CU.RNC.POS     = FIELD.POS<2,2>

    CALL F.READ(FN.FUNDS.TRANSFER,COMI,R.FUNDS.TRANSFER,F.FUNDS.TRANSFER,FT.ERR)
    Y.ACCT.NO       = R.FUNDS.TRANSFER<FT.DEBIT.ACCT.NO>
    Y.TXN.TYPE      = R.FUNDS.TRANSFER<FT.TRANSACTION.TYPE>
    CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)
    CUSTOMER.NO = R.ACCOUNT<AC.CUSTOMER>


    IF CUSTOMER.NO THEN
        GOSUB PERSONAL.IDENTITY.PARA
    END ELSE
        IF Y.TXN.TYPE EQ 'AC25' THEN
            FILE.PROCESS.ID = R.FUNDS.TRANSFER<FT.LOCAL.REF,Y.LOC.COMMENTS.POS>
            Y.ACCT.NO = FIELD(FILE.PROCESS.ID,'.',5)
            CALL F.READ(FN.ACCOUNT,Y.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)
            CUSTOMER.NO = R.ACCOUNT<AC.CUSTOMER>
            GOSUB CORPORATE.IDENTITY.PARA
        END
    END

RETURN
*---------------------
PERSONAL.IDENTITY.PARA:
*---------------------

    CALL F.READ(FN.CUSTOMER,CUSTOMER.NO,R.CUSTOMER,F.CUSTOMER,ERR)
    IF R.CUSTOMER THEN
        L.CU.CIDENT  = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.L.CU.CIDENT.POS>
        LEGAL.ID     = R.CUSTOMER<EB.CUS.LEGAL.ID,1>
        Y.REL.CUS = R.ACCOUNT<AC.JOINT.HOLDER,1>
        Y.REL.CODE = R.ACCOUNT<AC.RELATION.CODE,1>
        IF L.CU.CIDENT THEN
            COMI = L.CU.CIDENT
        END ELSE
            COMI = LEGAL.ID
        END

* Fix for PACS00428443 [ACH BLANK RNC]

        IF COMI EQ '' THEN
            COMI = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.L.CU.RNC.POS>
        END

* End of Fix
    END
*---------------PACS00459597-----------------------------------------
    IF COMI EQ "" AND Y.REL.CODE NE "" THEN

        R.CUS = ''
        CALL F.READ(FN.CUSTOMER,Y.REL.CUS,R.CUS,F.CUSTOMER,ERR)

        IF R.CUS THEN
            L.CU.CIDENT  = R.CUS<EB.CUS.LOCAL.REF,Y.L.CU.CIDENT.POS>
            LEGAL.ID     = R.CUS<EB.CUS.LEGAL.ID,1>
            IF L.CU.CIDENT THEN
                COMI = L.CU.CIDENT
            END ELSE
                COMI = LEGAL.ID
            END

        END
        IF COMI EQ '' THEN
            COMI = R.CUS<EB.CUS.LOCAL.REF,Y.L.CU.RNC.POS>
        END
    END
*-------------PACS00459597--------------------------------------------
RETURN
*----------------------
CORPORATE.IDENTITY.PARA:
*----------------------
    CALL F.READ(FN.CUSTOMER,CUSTOMER.NO,R.CUSTOMER,F.CUSTOMER,ERR)
    IF R.CUSTOMER THEN
        L.CU.RNC     = R.CUSTOMER<EB.CUS.LOCAL.REF,Y.L.CU.RNC.POS>
        LEGAL.ID     = R.CUSTOMER<EB.CUS.LEGAL.ID>
        IF L.CU.RNC THEN
            COMI = L.CU.RNC
        END ELSE
            COMI = LEGAL.ID
        END
    END
RETURN
*----------------------------------------------------------------------------
END
