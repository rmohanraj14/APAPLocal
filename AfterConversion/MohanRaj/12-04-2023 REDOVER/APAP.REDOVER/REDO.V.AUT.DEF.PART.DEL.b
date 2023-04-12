* @ValidationCode : MjotNzU1OTYzNTk0OkNwMTI1MjoxNjgxMjg1NTA2NzIwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 13:15:06
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
SUBROUTINE REDO.V.AUT.DEF.PART.DEL
*-----------------------------------------------------------------------------------
*Description
*This is an authorization routine for the version APAP.H.GARNISH.DETAILS,DEL
*-----------------------------------------------------------------------------------
* Company Name  : APAP
* Developed By  : PRABHU
* Program Name  : REDO.V.AUT.DEF.PART.DEL
* ODR NUMBER    : PACS00133294
*----------------------------------------------------------------------
*Input param = none
*output param =none
*-------------------------------------------------------------------------
*01 JUN 2011     Prabhu N        PACS00133294      Routine Logic completely Modified to Support deletion
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.APAP.H.GARNISH.DETAILS

    GOSUB INIT

RETURN
*----
INIT:
*----

    Y.GAR.ACC.ELIMINATION=R.NEW(APAP.GAR.ACC.ELIMINATION)
    Y.GAR.DATE.ELIMINATON=R.NEW(APAP.GAR.DATE.ELIMINATON)
    Y.GAR.GARNISH.AMT.DEL=R.NEW(APAP.GAR.GARNISH.AMT.DEL)
    Y.GAR.SPL.REL.RECORDS=R.NEW(APAP.GAR.SPL.REL.RECORDS)
    Y.GAR.lOCKED.DEL.TYPE=R.NEW(APAP.GAR.LOCKED.DEL.TYPE)
    Y.APAP.GAR.BENEFICIARY =R.NEW(APAP.GAR.BENEFICIARY)
    Y.APAP.GAR.PAYMENT.AMT =R.NEW(APAP.GAR.PAYMENT.AMT)
    Y.APAP.GAR.PAYMENT.DESC=R.NEW(APAP.GAR.PAYMENT.DESC)
    Y.APAP.GAR.COMMENTS    =R.NEW(APAP.GAR.COMMENTS)

    INS '' BEFORE Y.GAR.ACC.ELIMINATION<1,1>
    INS '' BEFORE Y.GAR.DATE.ELIMINATON<1,1>
    INS '' BEFORE Y.GAR.GARNISH.AMT.DEL<1,1>
    INS '' BEFORE Y.GAR.SPL.REL.RECORDS<1,1>
    INS '' BEFORE Y.GAR.lOCKED.DEL.TYPE<1,1>
    INS '' BEFORE Y.APAP.GAR.BENEFICIARY<1,1>
    INS '' BEFORE Y.APAP.GAR.PAYMENT.AMT<1,1>
    INS '' BEFORE Y.APAP.GAR.PAYMENT.DESC<1,1>
    INS '' BEFORE Y.APAP.GAR.COMMENTS<1,1>

    R.NEW(APAP.GAR.ACC.ELIMINATION)=Y.GAR.ACC.ELIMINATION
    R.NEW(APAP.GAR.DATE.ELIMINATON)=Y.GAR.DATE.ELIMINATON
    R.NEW(APAP.GAR.GARNISH.AMT.DEL)=Y.GAR.GARNISH.AMT.DEL
    R.NEW(APAP.GAR.SPL.REL.RECORDS)=Y.GAR.SPL.REL.RECORDS
    R.NEW(APAP.GAR.LOCKED.DEL.TYPE)=Y.GAR.lOCKED.DEL.TYPE
    R.NEW(APAP.GAR.BENEFICIARY)    =Y.APAP.GAR.BENEFICIARY
    R.NEW(APAP.GAR.PAYMENT.AMT)    =Y.APAP.GAR.PAYMENT.AMT
    R.NEW(APAP.GAR.PAYMENT.DESC)   =Y.APAP.GAR.PAYMENT.DESC
    R.NEW(APAP.GAR.COMMENTS)       =Y.APAP.GAR.COMMENTS

RETURN
END
