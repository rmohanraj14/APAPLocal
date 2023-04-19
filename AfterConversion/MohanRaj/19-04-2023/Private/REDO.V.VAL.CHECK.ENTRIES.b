* @ValidationCode : MjotNzgzODg1MzY4OkNwMTI1MjoxNjgxODg2Nzk3Mzk3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:16:37
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
SUBROUTINE REDO.V.VAL.CHECK.ENTRIES
*-------------------------------------------------------------------------
*DESCRIPTION:
*~~~~~~~~~~~~
* This routine is attached as the authorisation routine for the versions following:
*
* FUNDS.TRANSFER, CHQ.TAX
* FUNDS.TRANSFER, CHQ.OTHERS
* FUNDS.TRANSFER, REVERSE.CHQ
* FUNDS.TRANSFER, REINSTATE

* This routine is to raise statement and categ entries wheh the field L.FT.WAIVE.TAX
* is set to YES
*-------------------------------------------------------------------------
*DEVELOPMENT DETAILS:
*~~~~~~~~~~~~~~~~~~~~
*
* Date who Reference Description
* ~~~~ ~~~ ~~~~~~~~~ ~~~~~~~~~~~
* 22-APR-2010 SHANKAR RAJU ODR-2010-03-0447 Initial Creation
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ,FM TO @FM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.FT.CHARGE.TYPE
    $INSERT I_F.TAX


    GOSUB INITIALISE

    GOSUB PROCESS.TELLER


RETURN
*-------------------------------------------------------------------------
INITIALISE:
*~~~~~~~~~~
*Initialise the Variables

    FN.TELLER = 'F.TELLER'
    F.TELLER = ''
    R.TELLER = ''
    CALL OPF(FN.TELLER,F.TELLER)

    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    F.TELLER.TRANSACTION = ''
    R.TELLER.TRANSACTION = ''
    CALL OPF(FN.TELLER.TRANSACTION,F.TELLER.TRANSACTION)

    FN.FT.COMMISSION.TYPE = 'F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE = ''
    R.FT.COMMISSION.TYPE = ''
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)

    FN.FT.CHARGE.TYPE = 'F.FT.CHARGE.TYPE'
    F.FT.CHARGE.TYPE = ''
    R.FT.CHARGE.TYPE = ''
    CALL OPF(FN.FT.CHARGE.TYPE,F.FT.CHARGE.TYPE)

    FN.TAX = 'F.TAX'
    F.TAX = ''
    R.TAX = ''
    CALL OPF(FN.TAX,F.TAX)

    Y.TAX.AMT = ''

    CALL GET.LOC.REF("TELLER","L.TT.BASE.AMT",POS.BASE.AMT)

RETURN
*-------------------------------------------------------------------------
PROCESS.TELLER:
*~~~~~~~~~~~~~~
    Y.TELLER.TRANSACTION = R.NEW(TT.TE.TRANSACTION.CODE)
* Y.BASE.AMOUNT = R.NEW(TT.TE.LOCAL.REF)<1,POS.BASE.AMT>
    Y.BASE.AMOUNT = COMI

    CALL CACHE.READ(FN.TELLER.TRANSACTION, Y.TELLER.TRANSACTION, R.TELLER.TRANSACTION, ERR.TT) ;*R22 Auto code conversion

    Y.ALL.CHARGE.CODES = R.TELLER.TRANSACTION<TT.TR.CHARGE.CODE>

    Y.NO.CHARGE.CODES = DCOUNT(Y.ALL.CHARGE.CODES,@VM)
    START.COUNT = 1
    LOOP
    WHILE START.COUNT LE Y.NO.CHARGE.CODES
        Y.CHARGE.CODE = Y.ALL.CHARGE.CODES<1,START.COUNT>
        CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.CHARGE.CODE, R.FT.COMMISSION.TYPE, ERR.FTCT) ;*R22 Auto code conversion
        IF R.FT.COMMISSION.TYPE THEN
            IF R.FT.COMMISSION.TYPE<FT4.FLAT.AMT> NE '' THEN
                Y.AMOUNTS<-1> = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>
******************************************************************************************************
*PART TO ADD THE TAX AMOUNT FOR CHARGES [FS OWNER CONFIRMED THERE'LL NOT BE ANY SITUATION LIKE THIS] *
* Y.TAX.CODE = R.FT.COMMISSION.TYPE<FT4.TAX.CODE> *
* IF Y.TAX.CODE THEN *
* Y.TEMP.AMT = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT> *
* GOSUB PROCESS.TAX *
* END *
******************************************************************************************************
            END ELSE
                Y.AMOUNTS<-1> = (R.FT.COMMISSION.TYPE<FT4.PERCENTAGE>*Y.BASE.AMOUNT)/100
            END
        END ELSE
            CALL CACHE.READ(FN.FT.CHARGE.TYPE, Y.CHARGE.CODE, R.FT.CHARGE.TYPE, ERR.FTCT) ;*R22 Auto code conversion
            IF R.FT.CHARGE.TYPE THEN
                Y.AMOUNTS<-1> = R.FT.CHARGE.TYPE<FT5.FLAT.AMT>
            END ELSE
                Y.AMOUNTS<-1> = R.FT.CHARGE.TYPE<FT5.CHARGE.AMT>
            END
        END
        START.COUNT += 1
    REPEAT
**************************************************
* IF Y.TAX.AMOUNTS GT 0.005 THEN *
* Y.TAX.AMOUNTS = DROUND(Y.TAX.AMOUNTS,2) *
* Y.AMOUNTS<-1> = Y.TAX.AMOUNTS *
* END *
**************************************************
    POS.LAST = DCOUNT(Y.AMOUNTS,@FM)

    IF PGM.VERSION NE ',CHQ.NO.TAX' AND PGM.VERSION NE ',MGR.CHQ.NOTAX' THEN
        TOT.AMT = SUM(Y.AMOUNTS)
    END ELSE
        TOT.AMT = SUM(Y.AMOUNTS) - Y.AMOUNTS<POS.LAST>
    END

    Y.AMOUNTS = LOWER(Y.AMOUNTS)

* IF (R.OLD(TT.TE.LOCAL.REF)<1,POS.BASE.AMT> NE COMI) OR (R.NEW(TT.TE.AMOUNT.LOCAL.1) EQ '') THEN
    IF R.NEW(TT.TE.AMOUNT.LOCAL.1) EQ '' THEN
        TOT.AMT = DROUND(TOT.AMT,2)
        R.NEW(TT.TE.AMOUNT.LOCAL.1) = COMI+TOT.AMT
    END
* R.NEW(TT.TE.CHRG.AMT.LOCAL) = Y.AMOUNTS

RETURN
*---------------------------------------------------------------------------------
*PROCESS.TAX: -
*~~~~~~~~~~~ -
* SEL.CMD = 'SSELECT ':FN.TAX:' WITH @ID LIKE ':Y.TAX.KEY:'...' -
* CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,ERR) -
* Y.TAX.KEY = SEL.LIST<NOR> -
* -
* CALL F.READ(FN.TAX, Y.TAX.KEY, R.TAX, F.TAX, ERR.TAX) -
* IF R.TAX THEN -
* IF R.TAX<EB.TAX.RATE> NE '' THEN -
* Y.TAX.AMOUNTS = Y.TAX.AMOUNTS + (R.TAX<EB.TAX.RATE>*Y.TEMP.AMT)/100 -
* END -
* END -
* -
* RETURN -
*---------------------------------------------------------------------------------
END
