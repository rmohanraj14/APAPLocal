* @ValidationCode : MjotMjA4Nzk3NTM2NjpDcDEyNTI6MTY4MTg4ODE1MDE2MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:39:10
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
SUBROUTINE REDO.V.VAL.CUST.CREDIT
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :PRABHU.N
*Program   Name    :REDO.V.VAL.CUST.CREDIT
*---------------------------------------------------------------------------------

*DESCRIPTION       :It is the input routine to validate the credit and debit accounts
*
*
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 16-APR-2010        Prabhu.N       ODR-2010-08-0031   Initial Creation
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     IF Condition Added
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_System
    GOSUB INIT
RETURN
*---
INIT:
*---
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    Y.VAR.ACC.NO = COMI
    CALL F.READ(FN.ACCOUNT,Y.VAR.ACC.NO,R.ACCOUNT,F.ACCOUNT,ERR)

    GOSUB CHECK.CUSTOMER
    GOSUB CHECK.CATEGORY

RETURN
*--------------
CHECK.CUSTOMER:
*--------------
    Y.CUSTOMER =System.getVariable('EXT.SMS.CUSTOMERS')
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto code conversion-START
        Y.CUSTOMER = ""
    END ;*R22 Auto code conversion-END

    IF Y.CUSTOMER NE R.ACCOUNT<AC.CUSTOMER> THEN
        ETEXT ='EB-NOT.USER.ACCT'
        CALL STORE.END.ERROR
    END
RETURN
*--------------
CHECK.CATEGORY:
*--------------
    Y.CATEG = R.ACCOUNT<AC.CATEGORY>

    IF Y.CATEG GE 1003 AND Y.CATEG LE 6000 THEN
        ETEXT = 'EB-INVALID.ACCT'
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.CATEG GE 6013 AND Y.CATEG LE 6499 THEN
        ETEXT = 'EB-INVALID.ACCT'
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.CATEG LT 1000 OR Y.CATEG GT 6508 THEN
        ETEXT = 'EB-INVALID.ACCT'
        CALL STORE.END.ERROR
    END

RETURN
END
*---------------------------------------------*END OF SUBROUTINE*-------------------------------------------
