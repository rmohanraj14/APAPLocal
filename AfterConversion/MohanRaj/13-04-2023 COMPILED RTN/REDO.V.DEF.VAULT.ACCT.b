* @ValidationCode : MjotMTczOTQ5NTAxMDpDcDEyNTI6MTY4MTM4NzE5MzQ5Nzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:29:53
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
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.DEF.VAULT.ACCT

    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.COMPANY
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.PARAMETER
    $INSERT I_F.TELLER.TRANSACTION

    GOSUB INIT
    GOSUB PROCESS

RETURN


*******
INIT:
*******
*
    FN.TELLER.PARAMETER = 'F.TELLER.PARAMETER'
    F.TELLER.PARAMETER  = ''
    CALL OPF(FN.TELLER.PARAMETER, F.TELLER.PARAMETER)

    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    F.TELLER.TRANSACTION  = ''
    CALL OPF(FN.TELLER.TRANSACTION, F.TELLER.TRANSACTION)

    R.TELLER.PARAMETER = ''
    TP.ERR = ''

RETURN

*********
PROCESS:
*********
*

    ID.TRANSACTION = R.NEW(TT.TE.TRANSACTION.CODE)
    Y.AC.L         = R.NEW(TT.TE.ACCOUNT.1)[1,8]
    Y.AC.R         = R.NEW(TT.TE.ACCOUNT.1)[13,4]

    CALL CACHE.READ(FN.TELLER.TRANSACTION, ID.TRANSACTION, R.TELLER.TRANSACTION, TP.ERR) ;*R22 Auto code conversion


*CALL F.READ(FN.TELLER.PARAMETER, ID.COMPANY, R.TELLER.PARAMETER, F.TELLER.PARAMETER, TP.ERR)* Tus Start
    CALL CACHE.READ(FN.TELLER.PARAMETER, ID.COMPANY, R.TELLER.PARAMETER, TP.ERR)
* Tus End

    IF TP.ERR ELSE
        GOSUB POPULATE.TELLER.FIELD
    END

RETURN
*
POPULATE.TELLER.FIELD:
*

    WCAT1         = R.TELLER.TRANSACTION<TT.TR.CAT.DEPT.CODE.1>
    WCAT2         = R.TELLER.TRANSACTION<TT.TR.CAT.DEPT.CODE.2>
    WVAULTS       = RAISE(R.TELLER.PARAMETER<TT.PAR.TRAN.CATEGORY>)
    WVAULT.BRANCH = R.TELLER.PARAMETER<TT.PAR.VAULT.ID><1,1>

    IF WCAT1 THEN
        GOSUB ANALYZE.CAT.FIELDS
    END ELSE
        IF WCAT2 THEN
            IF WCAT2 EQ "10011" THEN
                R.NEW(TT.TE.ACCOUNT.1) = R.NEW(TT.TE.CURRENCY.1) : WCAT1 : WVAULT.BRANCH : R.COMPANY(EB.COM.SUB.DIVISION.CODE)
            END
        END

    END
*
RETURN
*
ANALYZE.CAT.FIELDS:
*

    IF WCAT1 EQ "10011" THEN
        R.NEW(TT.TE.ACCOUNT.1) = R.NEW(TT.TE.CURRENCY.1) : WCAT1 : WVAULT.BRANCH : R.COMPANY(EB.COM.SUB.DIVISION.CODE)
    END ELSE
        IF WCAT2 THEN
            IF WCAT2 EQ "10011" THEN
                R.NEW(TT.TE.ACCOUNT.2) = R.NEW(TT.TE.CURRENCY.2) : WCAT2 : WVAULT.BRANCH : R.COMPANY(EB.COM.SUB.DIVISION.CODE)
            END
        END
    END
*
RETURN
*
END
