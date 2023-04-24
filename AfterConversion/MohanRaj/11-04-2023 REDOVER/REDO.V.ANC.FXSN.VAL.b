* @ValidationCode : MjotMTA0NzAyMDUxMDpDcDEyNTI6MTY4MTIxNjc4OTUzNDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:09:49
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
SUBROUTINE REDO.V.ANC.FXSN.VAL
*-------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : Chandra Prakash T
* Program Name  : REDO.V.ANC.FXSN.VAL
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Description   : This AUTO NEW CONTENT routine attached to the FX/TT/FT VERSIONs of FXSN to populate FX.LEGAL.ID/TT.LEGAL.ID/FT.LEGAL.ID local reference
*                 fields Using common variable VAR.CUS.DETAILS
* In parameter  : None
* out parameter : None
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
* Date             Author             Reference         Description
* 13-Jul-2010      Chandra Prakash T  ODR-2010-01-0213  Initial creation
* 15-Sep-2010      Chandra Prakash T  ODR-2010-09-0014  Change Request CR 023 - CURRENCY MARKET & Exchange Rates
* 21-Mar-2011      Sudharsanan S      PACS00034123      Instead of C$SPARE variable using common variable mentioned in I_REDO.ID.CARD.CHECK.COMMON
* 31-Mar-2011      Sudharsanan S      PACS00052349      Fetching the currency market value based on APAP Customer and APAP Employee customer
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System
*
    $INSERT I_F.FOREX
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.CUSTOMER
    $INSERT I_F.USER
    $INSERT I_GTS.COMMON
*
    $INSERT I_F.REDO.EMPLOYEE.ACCOUNTS
    $INSERT I_F.REDO.CCY.MKT.FXSN
    $INSERT I_REDO.ID.CARD.CHECK.COMMON
*
    GOSUB OPEN.FILES
    GOSUB GET.LOCAL.REFS
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FN.REDO.CCY.MKT.FXSN = 'F.REDO.CCY.MKT.FXSN'
    F.REDO.CCY.MKT.FXSN = ''
    CALL OPF(FN.REDO.CCY.MKT.FXSN,F.REDO.CCY.MKT.FXSN)

    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)


    FN.USER = 'F.USER'
    F.USER = ''
    CALL OPF(FN.USER,F.USER)

    FN.REDO.EMPLOYEE.ACCOUNTS = 'F.REDO.EMPLOYEE.ACCOUNTS'
    F.REDO.EMPLOYEE.ACCOUNTS = ''
    CALL OPF(FN.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS)
*
    WVAR.NAME = "CURRENT.VAR.DETAILS"
    WVAR.VAL  = ""
    WPOS.X    = 0
*
    CALL System.getUserVariables( U.VARNAMES, U.VARVALS )
*

    LOOP
        REMOVE WWVAR FROM WVAR.NAME SETTING WVAR.POS
    WHILE WWVAR : WVAR.POS DO
        WPOS.X += 1
        LOCATE WWVAR IN U.VARNAMES SETTING YPOS.VAR THEN
            WVAR.VAL<WPOS.X> = U.VARVALS<YPOS.VAR>
        END
    REPEAT
*
    Y.OFS.SRC = OFS$SOURCE.ID
*
RETURN
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
GET.LOCAL.REFS:
*--------------------------------------------------------------------------------------------------------------------------------------------------------------------
    APPL.NAME = "FOREX":@FM:"FUNDS.TRANSFER":@FM:"TELLER"
    FIELD.ARR = "L.FX.LEGAL.ID":@FM:"L.FT.LEGAL.ID":@FM:"L.TT.LEGAL.ID":@VM:"L.TT.CLIENT.COD"
    FIELD.POS = ""
    CALL MULTI.GET.LOC.REF(APPL.NAME,FIELD.ARR,FIELD.POS)

    L.FX.LEGAL.ID.POS = FIELD.POS<1,1>
    L.FT.LEGAL.ID.POS = FIELD.POS<2,1>
    L.TT.LEGAL.ID.POS = FIELD.POS<3,1>
    L.TT.CLIENT.COD.POS = FIELD.POS<3,2>

RETURN
*
*-----------------------
CHECK.PRELIM.CONDITIONS:
*-----------------------
*
    PROCESS.GOAHEAD    = 1
    LOOP.CNT  = 1   ;   MAX.LOOPS = 2
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1

                IF APPLICATION EQ "TELLER" AND Y.OFS.SRC EQ "FASTPATH" THEN     ;* PACS00249338 - S
                    PROCESS.GOAHEAD = ""
                    RETURN
                END ;* PACS00249338 - E
*
                IF WVAR.VAL EQ "" THEN
                    Y.ERR.MSG = "EB-USER.VARIABLE.&.NOT.DEFINED":@FM:WVAR.NAME
                    PROCESS.GOAHEAD = ""
                END

            CASE LOOP.CNT EQ 2

                GOSUB GET.CCY.MKT.FXSN  ;* Code Review

                IF APPLICATION EQ "TELLER" AND REDO.CCY.MKT.FXSN.ERR THEN
                    Y.ERR.MSG = "EB-REDO.CCY.MKT.FXSN.REC.MISS"
                    PROCESS.GOAHEAD = ""
                END


        END CASE
*       Message Error
        GOSUB CONTROL.MSG.ERROR
*       Increase
        LOOP.CNT += 1
*
    REPEAT
*
RETURN
*
*
* ================
CONTROL.MSG.ERROR:
* ================
*
*   Paragraph that control the error in the subroutine
*
    IF Y.ERR.MSG THEN
        E           = Y.ERR.MSG
        AF          = TT.TE.AMOUNT.LOCAL.1
    END
*
RETURN
*

*------------------------------------------------------------------------------------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------------------------------------------------------------------------------------
*INTERCEPT.VAR = C$SPARE(444)
*CONVERT "*" TO FM IN INTERCEPT.VAR

*PACS00034123 - S
* INTERCEPT.VAR = VAR.CUS.DETAILS
*
    INTERCEPT.VAR = WVAR.VAL<1>
    CHANGE "*" TO @FM IN INTERCEPT.VAR
    IDENTITY.REFERENCE = ""
    IDENTITY.REFERENCE = INTERCEPT.VAR<1>:".":INTERCEPT.VAR<2>:".":INTERCEPT.VAR<3>
    CUSTOMER.NO = INTERCEPT.VAR<4>

*PACS00034123 - E

    APAP.STAFF = 0

    CCY.MKT.CODES  = R.REDO.CCY.MKT.FXSN<REDO.CMKT.CCY.MKT.CODE>
    CCY.MARKETS    = R.REDO.CCY.MKT.FXSN<REDO.CMKT.CCY.MKT>
    TT.VERSIONS    = R.REDO.CCY.MKT.FXSN<REDO.CMKT.TT.VERSION>
    TT.TRANS.CODES = R.REDO.CCY.MKT.FXSN<REDO.CMKT.TT.TRANS.CODE>

    BEGIN CASE
        CASE APPLICATION EQ 'FOREX'
            GOSUB POPULATE.FX.VALUES
        CASE APPLICATION EQ 'FUNDS.TRANSFER'
            GOSUB POPULATE.FT.VALUES
        CASE APPLICATION EQ 'TELLER'
            GOSUB POPULATE.TT.VALUES
    END CASE

RETURN
*
*------------------------------------------------------------------------------------------------------------------------------------------------------
GET.CCY.MKT.FXSN:
*------------------------------------------------------------------------------------------------------------------------------------------------------
    CALL CACHE.READ(FN.REDO.CCY.MKT.FXSN,"SYSTEM",R.REDO.CCY.MKT.FXSN,REDO.CCY.MKT.FXSN.ERR)
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
POPULATE.FX.VALUES:
*------------------------------------------------------------------------------------------------------------------------------------------------------
    IF R.NEW(FX.LOCAL.REF)<1,L.FX.LEGAL.ID.POS> EQ "" THEN
        R.NEW(FX.LOCAL.REF)<1,L.FX.LEGAL.ID.POS> = IDENTITY.REFERENCE
    END
    IF CUSTOMER.NO NE "" THEN
        R.NEW(FX.COUNTERPARTY) = CUSTOMER.NO
    END
RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
POPULATE.FT.VALUES:
*------------------------------------------------------------------------------------------------------------------------------------------------------
    IF R.NEW(FT.LOCAL.REF)<1,L.FT.LEGAL.ID.POS> EQ "" THEN
        R.NEW(FT.LOCAL.REF)<1,L.FT.LEGAL.ID.POS> = IDENTITY.REFERENCE
    END

RETURN
*------------------------------------------------------------------------------------------------------------------------------------------------------
POPULATE.TT.VALUES:
*------------------------------------------------------------------------------------------------------------------------------------------------------
    IF R.NEW(TT.TE.LOCAL.REF)<1,L.TT.LEGAL.ID.POS> EQ "" THEN
        R.NEW(TT.TE.LOCAL.REF)<1,L.TT.LEGAL.ID.POS> = IDENTITY.REFERENCE
        R.NEW(TT.TE.LOCAL.REF)<1,L.TT.CLIENT.COD.POS> = CUSTOMER.NO
    END
    CURR.VERSION.NAME = APPLICATION:PGM.VERSION

    R.CUSTOMER = ''
    CUSTOMER.ERR = ''
    CALL F.READ(FN.CUSTOMER,CUSTOMER.NO,R.CUSTOMER,F.CUSTOMER,CUSTOMER.ERR)


*PACS00052349 - S
    R.REDO.EMPLOYEE.ACCOUNTS = ''
    CALL F.READ(FN.REDO.EMPLOYEE.ACCOUNTS,CUSTOMER.NO,R.REDO.EMPLOYEE.ACCOUNTS,F.REDO.EMPLOYEE.ACCOUNTS,REDO.EMP.ERR)
    IF R.REDO.EMPLOYEE.ACCOUNTS THEN
        APAP.STAFF = 1
    END
    CCY.MKT.CODES.TOTAL = DCOUNT(CCY.MKT.CODES,@VM)
    LOCAL.CNT = 1
    LOOP
    WHILE LOCAL.CNT LE CCY.MKT.CODES.TOTAL
        CURR.CCY.MKT.CODE = CCY.MKT.CODES<1,LOCAL.CNT>
        CURR.CCY.MARKET = CCY.MARKETS<1,LOCAL.CNT>
        CURR.TT.VERSION = TT.VERSIONS<1,LOCAL.CNT>
        CURR.TT.TRANS.CODE = TT.TRANS.CODES<1,LOCAL.CNT>
* For APAP employee, check the REDO.CCY.MKT.FXSN table and pick the relevant TELLER.TRANSACTION code based on the VERSION name and CCY.MKT.CODE (begins
* with TT.APAP.STAFF
        IF CURR.CCY.MKT.CODE[1,13] EQ "TT.APAP.STAFF" AND APAP.STAFF EQ 1 AND CURR.VERSION.NAME EQ CURR.TT.VERSION THEN
            R.NEW(TT.TE.TRANSACTION.CODE) = CURR.TT.TRANS.CODE
            R.NEW(TT.TE.CURR.MARKET.1) = CURR.CCY.MARKET
            RETURN
        END
* For others, check the REDO.CCY.MKT.FXSN table and pick the relevant TELLER.TRANSACTION code based on the VERSION name and CCY.MKT.CODE (begins with
* TT.BANK.CUS
        IF CURR.CCY.MKT.CODE[1,11] EQ "TT.BANK.CUS" AND APAP.STAFF EQ 0 AND CURR.VERSION.NAME EQ CURR.TT.VERSION THEN
            R.NEW(TT.TE.TRANSACTION.CODE) = CURR.TT.TRANS.CODE
            R.NEW(TT.TE.CURR.MARKET.1) = CURR.CCY.MARKET
            RETURN
        END
        LOCAL.CNT += 1
    REPEAT
*PACS00052349 - E
RETURN
END
