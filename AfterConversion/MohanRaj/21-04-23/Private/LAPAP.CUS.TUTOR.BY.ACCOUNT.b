* @ValidationCode : MjoxMjg3ODU0ODQ4OkNwMTI1MjoxNjgyMDcyMzA0NjMzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:48:24
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
$PACKAGE APAP.LAPAP
*========================================================================
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
SUBROUTINE LAPAP.CUS.TUTOR.BY.ACCOUNT(ACCOUNT.NO, R.CUSTOMER, CUS.ID)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.CUSTOMER
*========================================================================
* Technical report:
* =================
* Company Name   : APAP
* Program Name   : LAPAP.CUS.TUTOR.BY.ACCOUNT
* Date           : 2018-06-14
* Item ID        : CN008702
*========================================================================
* Brief description :
* -------------------
* This routine returns information from the tutor of a minor client account
*========================================================================
* Modification History :
* ======================
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2018-06-14     Anthony Martinez  Initial Development
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*========================================================================

    GOSUB PROCESS

PROCESS:

*-------
    FN.ACCOUNT = 'F.ACCOUNT' ; F.ACCOUNT = ''; R.ACCOUNT = ''; ACCOUNT.ERR = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)
    CALL F.READ(FN.ACCOUNT,ACCOUNT.NO,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)

    FN.CUSTOMER = 'F.CUSTOMER' ; F.CUSTOMER = ''; CUSTOMER.ERR = ''
    CALL OPF(FN.CUSTOMER, F.CUSTOMER)

    Y.JOINT.HOLDER  = R.ACCOUNT<AC.JOINT.HOLDER>
    Y.RELATION.CODE = R.ACCOUNT<AC.RELATION.CODE>
    CUS.ID    = R.ACCOUNT<AC.CUSTOMER>

    Y.CANT.RECS = DCOUNT(Y.JOINT.HOLDER, @VM)

    FOR A = 1 TO Y.CANT.RECS STEP 1
        IF Y.RELATION.CODE<1,A> EQ "510" THEN
            CALL F.READ(FN.CUSTOMER,Y.JOINT.HOLDER<1,A>,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ERR)
            CUS.ID = Y.JOINT.HOLDER<1,A>
        END
    NEXT A

    IF NOT(R.CUSTOMER) THEN
        CALL F.READ(FN.CUSTOMER,CUS.ID,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ERR)
    END

RETURN
*-------
