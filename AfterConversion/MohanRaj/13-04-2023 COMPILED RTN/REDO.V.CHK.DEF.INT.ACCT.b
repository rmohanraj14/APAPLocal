* @ValidationCode : MjoxNTAyMjc5NjQyOkNwMTI1MjoxNjgxMzgzMzIzMTk1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:25:23
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
SUBROUTINE  REDO.V.CHK.DEF.INT.ACCT
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as the authorisation routine for the versions following:
*
* FUNDS.TRANSFER, CHQ.TAX
* FUNDS.TRANSFER, CHQ.OTHERS
* FUNDS.TRANSFER, REVERSE.CHQ
* FUNDS.TRANSFER, REINSTATE
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
*   Date               who           Reference            Description
*   ~~~~               ~~~           ~~~~~~~~~            ~~~~~~~~~~~
* 27-MAY-2010     SHANKAR RAJU     ODR-2010-03-0447     Initial Creation
* 04.01.2010      Janani           ODR-2010-11-0229     updated for sap teller
* 21-MAR-2011     SHANKAR RAJU     PACS00023913         Category changed for Teller cheque non-govt
* 22-may-2011     Bharath          PACS00055990         Version for Cheque Disbursement Added
* 01-07-2011      H GANESH         PACS00072695         Added logic for FUNDS.TRANSFER,CHQ.OTHERS.DEPOSIT
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.ADMIN.CHQ.PARAM

    GOSUB INITIALISE
    GOSUB PROCESS

RETURN
*--------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
    FN.CATEG.INT.ACCT = 'F.CATEG.INT.ACCT'
    F.CATEG.INT.ACCT = ''
    R.CATEG.INT.ACCT = ''

    FN.REDO.ADMIN.CHQ.PARAM = 'F.REDO.ADMIN.CHQ.PARAM'
    F.REDO.ADMIN.CHQ.PARAM = ''

    CALL OPF(FN.CATEG.INT.ACCT,F.CATEG.INT.ACCT)
    CALL OPF(FN.REDO.ADMIN.CHQ.PARAM,F.REDO.ADMIN.CHQ.PARAM)

    LF.APP = 'FUNDS.TRANSFER'
    LF.FLD = 'L.FT.COMM.CODE':@VM:'WAIVE.TAX'
    LF.POS = ''

    CALL MULTI.GET.LOC.REF(LF.APP,LF.FLD,LF.POS)
    LF.COMM.POS = LF.POS<1,1>
    LF.WAIVE.POS = LF.POS<1,2>
RETURN
*--------------------------------------------------------------------------
PROCESS:
*~~~~~~~

    BEGIN CASE

        CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",CHQ.TAX" OR PGM.VERSION EQ ",CHQ.NO.TAX" OR PGM.VERSION EQ ",SAP.NO.TAX" OR PGM.VERSION EQ ",SAP.CHQ.TAX" OR PGM.VERSION EQ ",SAP.CHQ.NO.TAX" OR PGM.VERSION EQ ",TWS" OR PGM.VERSION EQ ",CHQ.TAX.CHG" OR PGM.VERSION EQ ",CHQ.GOVT.WITH.TAX" OR PGM.VERSION EQ ",CHQ.NO.TAX.DEPOSIT" )
            Y.CATEGORY = '15006'
* PACS00055990 - S
*CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",CHQ.OTHERS" OR PGM.VERSION EQ ",SAP.OTHERS")
* PACS00072695 -> Added logic for version FUNDS.TRANSFER,CHQ.OTHERS.DEPOSIT
        CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",CHQ.OTHERS" OR PGM.VERSION EQ ",CHQ.OTHERS.LOAN" OR PGM.VERSION EQ ",SAP.OTHERS" OR PGM.VERSION EQ ",CHQ.OTHERS.DEPOSIT" )
* PACS00055990 - E
            Y.CATEGORY ='15005'
        CASE APPLICATION EQ 'TELLER' AND (PGM.VERSION EQ ",MGR.CHQ.TAX" OR PGM.VERSION EQ ",MGR.CHQ.NOTAX" OR PGM.VERSION EQ ",CHQ.TAX" OR PGM.VERSION EQ ",CHQ.NO.TAX" OR PGM.VERSION EQ ",CHQ.TAX.CHG" OR PGM.VERSION EQ ",REDO.ACCOUNT.CLOSURE.CHQADM.GOB.NOTAX" OR PGM.VERSION EQ ",REDO.CHEQUE.GOVERN.NOTAX.TRF" OR PGM.VERSION EQ ",REDO.CHQ.GERENCIA.NOTAX" OR PGM.VERSION EQ ",REDO.ADM.CHQ.NOTAX" OR PGM.VERSION EQ ",REDO.CHQ.NOTAX")
            Y.CATEGORY = '15006'
*>>>>>>PACS00023913-START - For CHEQUE NON GOVT, THE CATEGORY SHOULD BE 15005
        CASE APPLICATION EQ 'TELLER' AND PGM.VERSION EQ ",CHQ.OTHERS"
            Y.CATEGORY ='15005'
*>>>>>>PACS00023913-END
        CASE APPLICATION EQ 'TELLER' AND PGM.VERSION EQ ",PAY.EXPIRE.CHQ"
            Y.CATEGORY = '15015'
    END CASE

    GOSUB READ.ALL.ACCOUNT

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        R.NEW(FT.CREDIT.ACCT.NO) = Y.ACCOUNT
    END ELSE
        IF PGM.VERSION EQ ',REDO.ACCOUNT.CLOSURE.CHQADM.GOB.NOTAX' OR PGM.VERSION EQ ',REDO.ADM.CHQ.NOTAX' THEN
            R.NEW(TT.TE.ACCOUNT.2) = Y.ACCOUNT
        END ELSE
            R.NEW(TT.TE.ACCOUNT.1) = Y.ACCOUNT
        END
    END

*/ODR-2010-11-0229 -S
    BEGIN CASE
        CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",SAP.CHQ.TAX")
            R.NEW(FT.TRANSACTION.TYPE) = "OC-2"
            R.NEW(FT.COMMISSION.CODE) = "DEBIT PLUS CHARGES"
            R.NEW(FT.CREDIT.CURRENCY) = "DOP"
            R.NEW(FT.CHARGE.CODE) = "WAIVE"
            R.NEW(FT.LOCAL.REF)<1,LF.COMM.POS> = "DEBIT PLUS CHARGES"
            R.NEW(FT.DEBIT.CURRENCY) = "DOP"
            R.NEW(FT.LOCAL.REF)<1,LF.WAIVE.POS> = "NO"

        CASE APPLICATION EQ 'FUNDS.TRANSFER' AND (PGM.VERSION EQ ",SAP.CHQ.NO.TAX")
            R.NEW(FT.TRANSACTION.TYPE) = "OC-2"
            R.NEW(FT.COMMISSION.CODE) = "DEBIT PLUS CHARGES"
            R.NEW(FT.CREDIT.CURRENCY) = "DOP"
            R.NEW(FT.CHARGE.CODE) = "WAIVE"
            R.NEW(FT.DEBIT.CURRENCY) = "DOP"
            R.NEW(FT.LOCAL.REF)<1,LF.WAIVE.POS> = "YES"

    END CASE
*/ODR-2010-11-0229 -E
RETURN
*--------------------------------------------------------------------------
READ.ALL.ACCOUNT:
*--------------------------------------------------------------------------
    Y.ADMIN.ID = 'SYSTEM'
    CALL CACHE.READ(FN.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ID,R.REDO.ADMIN.CHQ.PARAM,Y.ADMIN.ERR)
    Y.ACCOUNT.ALL = R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ACCOUNT>
    LOOP
        REMOVE Y.ACCT.ID FROM Y.ACCOUNT.ALL SETTING POS1
    WHILE Y.ACCT.ID:POS1
        Y.VALUE = Y.ACCT.ID[4,5]
        IF Y.VALUE EQ Y.CATEGORY THEN
            Y.ACCOUNT = Y.ACCT.ID
        END
    REPEAT
RETURN
*-----------------------------------------------------------------------------
END
