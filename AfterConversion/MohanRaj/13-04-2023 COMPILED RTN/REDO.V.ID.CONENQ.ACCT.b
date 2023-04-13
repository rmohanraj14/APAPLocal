* @ValidationCode : MjoxOTQxNDcyODc0OkNwMTI1MjoxNjgxMzg4NjE2NzIxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:53:36
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
SUBROUTINE REDO.V.ID.CONENQ.ACCT
*----------------------------------------------------------------------------------------------------------------------
* Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By      : Temenos Application Management
* Program   Name    : REDO.V.ID.CONENQ.ACCT
*----------------------------------------------------------------------------------------------------------------------
* Description       : Routine to refresh all the enquiries displayed in CASHOFF.REDO.COS cos screen
* Linked With       : VERSION.CONTROL TT
* In  Parameter     : N/A
* Out Parameter     : N/A
* Files  Used       : TELLER
*----------------------------------------------------------------------------------------------------------------------
* Modification Details:
* =====================
* Date         Who                  Reference      Description
* ------       -----                ------------   -------------
* 22-05-2013   Joaquin Costa        PACS00269527   Refresh all the enquiries of CASHOFF.REDO.COS COS Screen
* 22-07-2013   Vignesh Kumaar M R   PACS00306799   REDO.CUST.ACCT.FULL.CASH NOT TO BE TRIGGERED FOR COS CASHIER.NV.COS
* 31-07-2013   Vignesh Kumaar M R   PACS00305984   CASHIER DEAL SLIP PRINT OPTION
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     I TO I.VAR,FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
*
    $INSERT I_GTS.COMMON
    $INSERT I_F.TELLER
    $INSERT I_S.COMMON
    $INSERT I_F.ENQUIRY
    $INSERT I_F.CONTEXT.ENQUIRY
    $INSERT I_BROWSER.TAGS
*

    IF APPLICATION EQ 'TELLER' THEN

        GOSUB INITIALISE
        GOSUB OPEN.FILES
        GOSUB CHECK.PRELIM.CONDITIONS
        IF PROCESS.GOAHEAD THEN
            GOSUB PROCESS
        END
    END

*
RETURN
*
*-------
PROCESS:
*-------
*
    IF ALPHA(Y.TT.ACCT1[1,3]) THEN
        Y.ACCT.FIN = Y.TT.ACCT2
        Y.CE.FIELD = 'ACCOUNT.2'
    END
*
    IF ALPHA(Y.TT.ACCT2[1,3]) THEN
        Y.ACCT.FIN = Y.TT.ACCT1
        Y.CE.FIELD = 'ACCOUNT.1'
    END
*
    GOSUB TRIG.AUX.ENQS
*
RETURN
*
*-------------
TRIG.AUX.ENQS:
*-------------
* Commented as no context enquiry is required to be raised seperately
*
*    GOSUB GET.CONTEXT.ENQ.DETS
*
*    I=1 ; Y.CNT.CENQ = '' ; Y.CNT.CENQ = DCOUNT(Y.CE.ENQ.NAME,VM)
*    LOOP
*    WHILE I LE Y.CNT.CENQ
*        Y.NEXT.TASK = ''
*        Y.NEXT.TASK = 'ENQ ' :Y.CE.ENQ.NAME<1,I>: ' ' :Y.CE.FLD.NAME<1,I>: ' ' :Y.CE.OPERAND<1,I>: ' ' :Y.ACCT.FIN
*        CALL EB.SET.NEW.TASK(Y.NEXT.TASK)
*        I += 1
*    REPEAT

* Condition to check whether TT is triggered from the CASHIER/SUPERVISOR/BUSINESS COS screens - Vignesh

* Fix for PACS00305984 [CASHIER DEAL SLIP PRINT OPTION]


    Y.GET.AUTHORISOR = R.NEW(TT.TE.AUTHORISER)
    Y.GET.RECORD.STATUS = R.NEW(TT.TE.RECORD.STATUS)

*    IF V$FUNCTION NE "I" OR V$FUNCTION NE "A" OR (V$FUNCTION EQ 'A' AND Y.GET.AUTHORISOR NE '' AND Y.GET.RECORD.STATUS EQ 'INAO') THEN
*        RETURN
*    END

    IF Y.COS.NAME[1,4] EQ Y.CASHIER.COS OR Y.COS.NAME[1,11] EQ Y.SUPER.COS OR Y.COS.NAME[1,11] EQ Y.BUSS.COS THEN
        GOSUB GET.CONTEXT.ADDIT
    END

* End of Fix

RETURN
*
* ----------------
GET.CONTEXT.ADDIT:
* ----------------
*
    GET.ENQ.LIST = 'ENQ REDO.ACCT.JHOLDER @ID EQ ':Y.ACCT.FIN
    GET.ENQ.LIST<-1> = 'ENQ REDO.ENQ.RBHP.PADRONE ACCOUNT.NO EQ ':Y.ACCT.FIN
    GET.ENQ.LIST<-1> = 'ENQ REDO.IM.CONSULTA.FIRMAS IMAGE.REFERENCE EQ ':Y.ACCT.FIN

* Fix for PACS00306799 [REDO.CUST.ACCT.FULL.CASH NOT TO BE TRIGGERED FOR COS CASHIER.NV.COS]

    IF Y.COS.NAME[1,11] EQ Y.SUPER.COS THEN
        GET.ENQ.LIST<-1> = 'ENQ REDO.CUST.ACCT.FULL.CASH @ID EQ ':Y.ACCT.FIN
    END

* End of Fix

    Y.CNT = 1 ; Y.ENQ.CNT = DCOUNT(GET.ENQ.LIST,@FM) ;

    LOOP
    WHILE I.VAR LE Y.ENQ.CNT ;*R22 Auto code conversion
        Y.NEXT.TASK = ''
        Y.NEXT.TASK = GET.ENQ.LIST<I.VAR> ;*R22 Auto code conversion
        CALL EB.SET.NEW.TASK(Y.NEXT.TASK)
        I.VAR += 1 ;*R22 Auto code conversion
    REPEAT
*
RETURN
*
* -------------------
*GET.CONTEXT.ENQ.DETS:
* -------------------
*
*    Y.CONTEXT.ENQUIRY.ID = APPLICATION:PGM.VERSION:"-":Y.CE.FIELD ; R.CONTEXT.ENQUIRY = '' ; YERR = ""
*    CALL F.READ(FN.CONTEXT.ENQUIRY,Y.CONTEXT.ENQUIRY.ID,R.CONTEXT.ENQUIRY,F.CONTEXT.ENQUIRY,YERR)
*    Y.CE.ENQ.NAME = '' ; Y.CE.FLD.NAME = '' ; Y.CE.OPERAND = ''
*    Y.CE.ENQ.NAME = R.CONTEXT.ENQUIRY<EB.CENQ.ENQUIRY.NAME> ; Y.CE.FLD.NAME = R.CONTEXT.ENQUIRY<EB.CENQ.SEL.FIELD>
*    Y.CE.OPERAND  = R.CONTEXT.ENQUIRY<EB.CENQ.OPERAND>
*
*    RETURN
*
* ---------
INITIALISE:
* ---------
    PROCESS.GOAHEAD    = 1
*
    FN.TELLER.NAU = 'F.TELLER$NAU'
    F.TELLER.NAU = ''
*
    FN.CONTEXT.ENQUIRY = 'F.CONTEXT.ENQUIRY'
    F.CONTEXT.ENQUIRY = ''
*
    ACCOUNT.1  = ''
    ACCOUNT.2  = ''
*
    Y.COS.NAME = OFS$WINDOW.NAME

    Y.CASHIER.COS = 'TXNS'
    Y.SUPER.COS = 'OFFICERTXNS'
    Y.BUSS.COS = 'BUSINESSTXN'

*
RETURN
*
*---------------
OPEN.FILES:
*---------------
*
    CALL OPF(FN.TELLER.NAU,F.TELLER.NAU)
*
    CALL OPF(FN.CONTEXT.ENQUIRY,F.CONTEXT.ENQUIRY)
*
RETURN
*
*-----------------------
CHECK.PRELIM.CONDITIONS:
*-----------------------
    LOOP.CNT  = 1   ;   MAX.LOOPS = 3
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
*
                IF V$FUNCTION NE "A" AND V$FUNCTION NE "D" AND V$FUNCTION NE "S" THEN
                    PROCESS.GOAHEAD  = ""
                END
*
            CASE LOOP.CNT EQ 2
*
                R.TELLER.NAU = '' ; YERR = '' ; TELLER.ID = COMI
                CALL F.READ(FN.TELLER.NAU,TELLER.ID,R.TELLER.NAU,F.TELLER.NAU,YERR)
                Y.TT.ACCT1 = "" ; Y.TT.ACCT2 = ""
                Y.TT.ACCT1 = R.TELLER.NAU<TT.TE.ACCOUNT.1> ; Y.TT.ACCT2 = R.TELLER.NAU<TT.TE.ACCOUNT.2>
*
                IF ALPHA(Y.TT.ACCT1[1,3]) AND ALPHA(Y.TT.ACCT2[1,3]) THEN
                    PROCESS.GOAHEAD  = ""
                END
*
            CASE LOOP.CNT EQ 3

        END CASE
*       Increase
        LOOP.CNT += 1
*
    REPEAT
*
RETURN
*
END
