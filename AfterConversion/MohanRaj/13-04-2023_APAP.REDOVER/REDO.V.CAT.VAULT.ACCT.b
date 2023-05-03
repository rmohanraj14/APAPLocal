* @ValidationCode : Mjo3NTY4NzY2MjE6Q3AxMjUyOjE2ODEzOTAwNjYwMDI6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:17:46
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
SUBROUTINE REDO.V.CAT.VAULT.ACCT
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION :   Field research and comparison. CATEGORY. in tables. ACCOUNT. and. ACCOUNT.CLASS.[1~
*------------------------------------------------------------------------------------------
*
* COMPANY NAME : APAP
* PROGRAM NAME : REDO.V.CAT.VAULT.ACCT
*
*------------------------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------------------------
*       DATE             WHO                REFERENCE         DESCRIPTION
*       17-07-2012       IVAN ROMAN         PACS00186440 G8
*       17-07-2012       JOAQUIN COSTA      PACS00186440 G8
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ,FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.TELLER

    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLASS

    $INSERT I_F.REDO.NOSTRO.ACCT.LIST

    GOSUB INIT
    GOSUB PROCESS
    CALL APAP.REDOVER.REDO.V.INP.TT.AC.VAL

RETURN

* =============
INIT:
* =============
*
    R.ACCOUNT       = ''
    R.ACCOUNT.CLASS = ''
    ACC.ERR         = ''
    CLASS.ERR       = ''
    TYPE.CURRENCY   = ''

    PROCESS.GOAHEAD = 1

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.ACCOUNT.CLASS = 'F.ACCOUNT.CLASS'
    F.ACCOUNT.CLASS  = ''
    CALL OPF(FN.ACCOUNT.CLASS,F.ACCOUNT.CLASS)

    FN.REDO.NOSTRO.ACCT.LIST = 'F.REDO.NOSTRO.ACCT.LIST'
    F.REDO.NOSTRO.ACCT.LIST = ''
    CALL OPF(FN.REDO.NOSTRO.ACCT.LIST,F.REDO.NOSTRO.ACCT.LIST)

RETURN

* =============
PROCESS:
* =============
*
    LOOP.CNT  = 1   ;   MAX.LOOPS = 5
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE
            CASE LOOP.CNT EQ 1
                GOSUB GET.ACCOUNT.CATEGORY

            CASE LOOP.CNT EQ 2
                GOSUB GET.ACCOUNT.CLASS.CATEGORY

            CASE LOOP.CNT EQ 3
                GOSUB ANALYZE.CAT.FIELDS

            CASE LOOP.CNT EQ 4
                GOSUB ANALYZE.CURRENCY

            CASE LOOP.CNT EQ 5
                GOSUB FIND.IN.NOSTRO.TABLE
        END CASE
*       Increase
        LOOP.CNT += 1
*
    REPEAT
*
RETURN
*
* ===================
GET.ACCOUNT.CATEGORY:
* ===================
*
    WID.ACCOUNT   = COMI

    CALL F.READ(FN.ACCOUNT,WID.ACCOUNT,R.ACCOUNT,F.ACCOUNT,ACC.ERR)

    IF ACC.ERR THEN
        ETEXT           = "AC-ACCOUNT.NOT.FOUND"
        PROCESS.GOAHEAD = ""
        CALL STORE.END.ERROR
    END ELSE
        W.CATEGORY = R.ACCOUNT<AC.CATEGORY>
        W.CURRENCY = R.ACCOUNT<AC.CURRENCY>
    END
*
RETURN
*
* =========================
GET.ACCOUNT.CLASS.CATEGORY:
* =========================
*
    ID.AC.CLS.CATEGORY = "NOSTRO"

    CALL CACHE.READ(FN.ACCOUNT.CLASS, ID.AC.CLS.CATEGORY, R.ACCOUNT.CLASS, CLASS.YERR) ;*R22 Auto code conversion
    IF CLASS.YERR THEN
        ETEXT           = "AC-ACCOUNT.CLASS.NOT.FOUND"
        PROCESS.GOAHEAD = ""
        CALL STORE.END.ERROR
    END ELSE
        WCLASS.CATEGORY = RAISE(R.ACCOUNT.CLASS<AC.CLS.CATEGORY>)
    END
*
RETURN
*
* =================
ANALYZE.CAT.FIELDS:
* =================
*
    LOCATE W.CATEGORY IN WCLASS.CATEGORY<1> SETTING CAT.POS ELSE
        ETEXT           = "EB-&.NOT.A.NOSTRO.ACCOUNT" : @FM : WID.ACCOUNT
        PROCESS.GOAHEAD = ""
        CALL STORE.END.ERROR
    END
*
RETURN
*
* ===============
ANALYZE.CURRENCY:
* ===============
*
    IF R.NEW(TT.TE.CURRENCY.1) NE W.CURRENCY THEN
        ETEXT           = "EB-ACCOUNT.SHOULD.HAVE.THE.SAME.CURRENCY" : @FM : WID.ACCOUNT
        PROCESS.GOAHEAD = ""
        CALL STORE.END.ERROR
    END

RETURN
*
* ===================
FIND.IN.NOSTRO.TABLE:
* ===================
*
    CALL F.READ(FN.REDO.NOSTRO.ACCT.LIST,WID.ACCOUNT,R.REDO.NOSTRO.ACCT.LIST,F.REDO.NOSTRO.ACCT.LIST,ERR.ACC.LIST)
    IF ERR.ACC.LIST THEN
        ETEXT = "EB-ACCOUNT.&.NOT.FOUND.NOSTRO.TABLE" : @FM : WID.ACCOUNT
        CALL STORE.END.ERROR
    END ELSE
        WBR.NOSTRO = RAISE(R.REDO.NOSTRO.ACCT.LIST<NOSTRO.ACCT.LIST.BRANCH.CODE>)
        WCO.CODE   = ID.COMPANY
        LOCATE WCO.CODE IN WBR.NOSTRO<1> SETTING BR.POS ELSE
            ETEXT = "EB-BRANCH.&.NOT.AUTHORISED" : @FM :  WCO.CODE
            CALL STORE.END.ERROR
        END
    END
*
RETURN
*
END
