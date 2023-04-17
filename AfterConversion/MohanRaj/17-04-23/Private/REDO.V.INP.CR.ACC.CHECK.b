* @ValidationCode : MjoxNDkxOTUwNDQ0OkNwMTI1MjoxNjgxNzI3MzI5NTYzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 15:58:49
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
SUBROUTINE REDO.V.INP.CR.ACC.CHECK
*-----------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Temenos India
*Program   Name    :REDO.V.INP.DB.ACC.CHECK
*---------------------------------------------------------------------------------

*DESCRIPTION       :This Input Routine used to filter AA, Reinvested Interest
*                   Liquidation Account and AZ.Account
*LINKED WITH       :DB Account No field in FT

* ----------------------------------------------------------------------------------
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*17-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*=========-----------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER
*
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER
*
    GOSUB INIT
    GOSUB PROCESS

RETURN

*-----------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------
*
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
*
    FN.AI.REDO.ARCIB.PARAM = 'F.AI.REDO.ARCIB.PARAMETER'
    F.AI.REDO.ARCIB.PARAM = ''
*
    CALL OPF(FN.AI.REDO.ARCIB.PARAM,F.AI.REDO.ARCIB.PARAM)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
*
    R.AI.REDO.ARCIB.PARAM = ''
    R.ACCOUNT            = ''
*
RETURN
*
*-----------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------
*

    V.DB.ACCT.NO = R.NEW(FT.CREDIT.ACCT.NO)

    CALL F.READ(FN.ACCOUNT,V.DB.ACCT.NO,R.ACCOUNT,F.ACCOUNT,ACC.ERR)

    V.AA.FLAG = R.ACCOUNT<AC.ARRANGEMENT.ID>
    V.ACC.CATEG = R.ACCOUNT<AC.CATEGORY>
    AF = FT.CREDIT.ACCT.NO
    IF V.AA.FLAG NE '' THEN
        ETEXT = 'FT-AA.AZ.ACC.NOT.ALLOWED'
        CALL STORE.END.ERROR
    END

    CALL CACHE.READ(FN.AI.REDO.ARCIB.PARAM,'SYSTEM',R.AI.REDO.ARCIB.PARAM,Y.ERR.PAR)
    Y.ACC.TYPE = R.AI.REDO.ARCIB.PARAM<AI.PARAM.ACCOUNT.TYPE>
    CHANGE @VM TO @FM IN Y.ACC.TYPE

    LOCATE 'DEPOSIT' IN Y.ACC.TYPE SETTING ACC.POS THEN
        V.CATEG.ST = R.AI.REDO.ARCIB.PARAM<AI.PARAM.CATEG.START,ACC.POS>
        V.CATEG.END = R.AI.REDO.ARCIB.PARAM<AI.PARAM.CATEG.END,ACC.POS>
        IF V.ACC.CATEG GE V.CATEG.ST AND V.ACC.CATEG LE V.CATEG.END THEN
            ETEXT = 'FT-AA.AZ.ACC.NOT.ALLOWED'
            CALL STORE.END.ERROR
        END
    END

RETURN
*
END
