* @ValidationCode : MjotMzE5NjE5MTYzOkNwMTI1MjoxNjgxNzk3MjQxOTk0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 11:24:01
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
SUBROUTINE REDO.V.INP.TT.AC.VAL
*-----------------------------------------------------------------------------
* Description:
* This routine is a multithreaded routine to select the records in the mentioned applns
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : Deepak Kumar K
* PROGRAM NAME : REDO.V.INP.TT.AC.VAL
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE           WHO                REFERENCE        DESCRIPTION
* 12.08.2013     Deepak Kumar K     PACS00310290     PACS00310290
* 25-10-2013     Vignesh Kumaar R   PACS00319189     AA AND AZ Account should n't be used in the below version
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT

* Get Account numbers

    Y.AC = COMI
    SET.FLAG = ''

* Open file for reading

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    F.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)

    Y.READ.ERR = ''
    R.ACCOUNT = ''
    CALL F.READ(FN.ACCOUNT, Y.AC, R.ACCOUNT, F.ACCOUNT, Y.READ.ERR)

    Y.GET.ACCT = COMI[9,4]

    IF NOT(NUM(COMI)) AND NOT(R.ACCOUNT) AND COMI[1,2] NE 'PL' THEN

        IF APPLICATION EQ 'TELLER' AND COMI[9,4] EQ R.NEW(TT.TE.TELLER.ID.1) ELSE
            SET.FLAG = '1'
            ETEXT = 'TT-REDO.AC.MISS'
            CALL STORE.END.ERROR
        END
    END

* Fix for PACS00319189 [AA Account should n't be used in the below version]

    IF NOT(SET.FLAG) AND (PGM.VERSION EQ ',REDO.EFECT.REC.BC.ML' OR PGM.VERSION EQ ',REDO.DEP.EFECT.ML' OR PGM.VERSION EQ ',REDO.DEP.EFECT.ME' OR PGM.VERSION EQ ',REDO.LCY.CASHWDL' OR PGM.VERSION EQ ',REDO.FCY.CASHWDL' OR PGM.VERSION EQ ',REDO.FCY.CASHIN') AND (APPLICATION EQ 'TELLER') THEN

        R.AZ.ACCOUNT = ''
        CALL F.READ(FN.AZ.ACCOUNT,Y.AC,R.AZ.ACCOUNT,F.AZ.ACCOUNT,AZ.ACCOUNT.ERR)

        IF R.ACCOUNT<AC.ARRANGEMENT.ID> THEN
            SET.FLAG = '1'
            ETEXT = 'EB-REDO.LOAN.ACC.NOT.ALLOWED'
            CALL STORE.END.ERROR
        END

        IF R.AZ.ACCOUNT THEN
            SET.FLAG = '1'
            ETEXT = 'EB-REDO.DEPOSIT.ACC.NOT.ALLOWED'
            CALL STORE.END.ERROR
        END
    END

* End of Fix

    Y.DR.AC.NO = FT.DEBIT.ACCT.NO
    Y.CR.AC.NO = FT.CREDIT.ACCT.NO

    IF APPLICATION EQ 'FUNDS.TRANSFER' AND AF EQ Y.DR.AC.NO THEN

        Y.DR.ACCT = COMI
        Y.CR.ACCT = R.NEW(FT.CREDIT.ACCT.NO)
        GOSUB FT.PROCESS
    END ELSE
        IF APPLICATION EQ 'FUNDS.TRANSFER' AND AF EQ Y.CR.AC.NO THEN
            Y.DR.ACCT = R.NEW(FT.DEBIT.ACCT.NO)
            Y.CR.ACCT = COMI
            GOSUB FT.PROCESS
        END
    END

RETURN
*---------------------
FT.PROCESS:
*-------------------
    IF Y.DR.ACCT AND Y.CR.ACCT THEN
        CALL F.READ(FN.ACCOUNT,Y.DR.ACCT,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        Y.DR.CUST = R.ACCOUNT<AC.CUSTOMER>
        R.ACCOUNT = ''
        CALL F.READ(FN.ACCOUNT,Y.CR.ACCT,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        Y.CR.CUST = R.ACCOUNT<AC.CUSTOMER>

        IF NOT(Y.DR.CUST) AND NOT(Y.CR.CUST) THEN
            R.NEW(FT.ORDERING.CUST) = 'APAP'
        END
    END
RETURN
*------------------
END
