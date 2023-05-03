* @ValidationCode : MjoxMjc3MjMwNDA4OkNwMTI1MjoxNjgxMzkwNTA1MTU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:25:05
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
SUBROUTINE REDO.V.DEF.TEMP.INTERNAL.ACCT
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine is to default internal account FT versions
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : @ID
* CALLED BY :
*
* Revision History:
*------------------------------------------------------------------------------------------
*   Date               who           Reference            Description
* 09-06-2017        Edwin Charles D  R15 Upgrade       Initial Creation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM

    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

*----*
INIT:
*----*
*-----------*
*Initialising
*-----------*


    REC.ID='SYSTEM'

    Y.CMPNY.ID = COMI

RETURN

*---------*
OPEN.FILES:
*---------*
*------------*
*Opening files
*------------*

    FN.REDO.BRANCH.INT.ACCT.PARAM ='F.REDO.BRANCH.INT.ACCT.PARAM'
    F.REDO.BRANCH.INT.ACCT.PARAM = ''
    CALL OPF(FN.REDO.BRANCH.INT.ACCT.PARAM,F.REDO.BRANCH.INT.ACCT.PARAM)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

RETURN

*-------*
PROCESS:
*-------*
*-----------------------------------------------------*
*Raising Error Message if it is not an arrangement ID
*-----------------------------------------------------*
*
    Y.ARR.ID = R.NEW(FT.TN.DEBIT.ACCT.NO)

    IF Y.ARR.ID[1,2] EQ 'AA' THEN
        IN.ACC.ID = Y.ARR.ID
        IN.ARR.ID = ''
        OUT.ID = ''
        ERR.TEXT = ''
        CALL APAP.REDOVER.REDO.CONVERT.ACCOUNT(IN.ACC.ID,IN.ARR.ID,OUT.ID,ERR.TEXT) ;* R22 Manual Conversion - CALL method format modified
        Y.ARR.ID = OUT.ID
    END

    CALL F.READ(FN.ACCOUNT,Y.ARR.ID,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)
    IF R.ACCOUNT THEN
        CALL CACHE.READ(FN.REDO.BRANCH.INT.ACCT.PARAM,REC.ID,R.REDO.BRANCH.INT.ACCT.PARAM,Y.ERR)

        Y.CURRENCY.VAL = R.ACCOUNT<AC.CURRENCY>

        R.NEW(FT.TN.CREDIT.ACCT.NO) = ''

        LOCATE Y.CMPNY.ID IN R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.COMPANY,1> SETTING POS THEN
            LOCATE Y.CURRENCY.VAL IN R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.CURRENCY,POS,1> SETTING CURR.POS THEN
                R.NEW(FT.TN.CREDIT.ACCT.NO) = R.REDO.BRANCH.INT.ACCT.PARAM<BR.INT.ACCT.BRANCH.INT.ACCT,POS,CURR.POS>
                R.NEW(FT.TN.CREDIT.CURRENCY) = Y.CURRENCY.VAL
            END
        END
    END
RETURN
END
