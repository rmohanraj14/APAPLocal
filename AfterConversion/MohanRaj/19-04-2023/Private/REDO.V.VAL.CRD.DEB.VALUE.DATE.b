* @ValidationCode : MjoyMDgwMjM0Mjk6Q3AxMjUyOjE2ODE4OTMwMjA3MDA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 19 Apr 2023 14:00:20
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
SUBROUTINE REDO.V.VAL.CRD.DEB.VALUE.DATE
*----------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Bharath G
*Program   Name    :REDO.V.VAL.CRD.DEB.VALUE.DATE
*----------------------------------------------------------------------------------

*DESCRIPTION       :It is attached as validation routine in the version
*                   Debit and Credit Value Date Value Date must bring default
*                   today's date and allow modification system (must be able to record
*                   a date prior to the day, but cannot be earlier than the date
*                   of creation of the loan
*
*
*LINKED WITH       :VERSION>FUNDS.TRANSFER,REDO.AA.LTCC
* ---------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who             Reference            Description
* 16-APR-2010          Bharath G       PACS00055029         Initial Creation
* 20-AUG-2011          Shankar Raju    PACS00085821         CASE: If COMI is not having the ACCOUNT NUMBER
* 02-SEP-2011          Marimuthu S     PACS00080544
* 09-SEP-2011          Marimuthu S     PACS00121111
* 15-SEP-2011          Marimuthu S     PACS00128527
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     No changes
*19-04-2023      Mohanraj R          R22 Manual code conversion  Call Method Format Modified
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS

*----------------------------------------------------------------------------------


* PACS00121111 -S
    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END
* PACS00121111 -E

    GOSUB INIT

    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        GOSUB PROCESS.FT
    END

RETURN
*----------------------------------------------------------------------------------
INIT:
*----
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    R.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    R.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    LREF.APP = 'FUNDS.TRANSFER'
    LREF.FIELDS = 'L.FT.CUSTOMER'
    LREF.POS=''

    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELDS,LREF.POS)

    VAR.L.FT.CUSTOMER.POS   = LREF.POS<1,1>

RETURN
*----------------------------------------------------------------------------------
PROCESS.FT:
*---------
*


    Y.ARR.ID = R.NEW(FT.DEBIT.ACCT.NO)
*FOR FIX PACS00085821
    IF Y.ARR.ID EQ '' THEN
        Y.ARR.ID = COMI
    END
*FOR FIX PACS00085821
    IF Y.ARR.ID[1,2] EQ 'AA' THEN
        IN.ACC.ID = Y.ARR.ID
        IN.ARR.ID = ''
        OUT.ID = ''
        ERR.TEXT = ''
        CALL APAP.TAM.REDO.CONVERT.ACCOUNT(IN.ACC.ID,IN.ARR.ID,OUT.ID,ERR.TEXT) ;*R22 Manual Code Conversion-Call Method Format Modified
        Y.ARR.ID = OUT.ID
    END

    CALL F.READ(FN.ACCOUNT,Y.ARR.ID,R.ACCOUNT,F.ACCOUNT,ACCOUNT.ERR)
    R.NEW(FT.DEBIT.CURRENCY) = R.ACCOUNT<AC.CURRENCY>
    R.NEW(FT.LOCAL.REF)<1,VAR.L.FT.CUSTOMER.POS> = R.ACCOUNT<AC.CUSTOMER>

** 80544 -S
    IF R.ACCOUNT<AC.ARRANGEMENT.ID> EQ '' THEN
        AF = FT.DEBIT.ACCT.NO
        ETEXT = "EB-NOT.ARRANGEMENT.ID"
        CALL STORE.END.ERROR
        RETURN
    END
** 80544 -E

    IF Y.ARR.ID[1,2] NE 'AA' THEN
        IN.ACC.ID = Y.ARR.ID
        IN.ARR.ID = ''
        OUT.ID = ''
        ERR.TEXT = ''
        CALL APAP.TAM.REDO.CONVERT.ACCOUNT(IN.ACC.ID,IN.ARR.ID,OUT.ID,ERR.TEXT) ;*R22 Manual Code Conversion-Call Method Format Modified
        Y.ARR.ID = OUT.ID
    END

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.ARR.ERR)
    IF R.AA.ACCOUNT.DETAILS THEN
        Y.EFF.DATE = R.AA.ACCOUNT.DETAILS<AA.AD.CONTRACT.DATE>
    END
    IF Y.EFF.DATE NE '' THEN
        IF R.NEW(FT.DEBIT.VALUE.DATE) LT Y.EFF.DATE THEN
            AF = FT.DEBIT.VALUE.DATE
            ETEXT = "EB-VALUE.DATE.LT.ARR.DATE"
            CALL STORE.END.ERROR
        END
        IF R.NEW(FT.CREDIT.VALUE.DATE) LT Y.EFF.DATE THEN
            AF = FT.CREDIT.VALUE.DATE
            ETEXT = "EB-VALUE.DATE.LT.ARR.DATE"
            CALL STORE.END.ERROR
        END
    END

RETURN
END
