* @ValidationCode : MjotMjEyNTgzNDg2MDpDcDEyNTI6MTY4MTgyMTczNTgyMTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 18:12:15
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
SUBROUTINE REDO.V.TT.AUTH.UPD.NCF
*----------------------------------------------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : GANESH R
* Program Name  : REDO.V.TT.AUTH.UPD.NCF
* ODR NUMBER    : ODR-2009-10-0321
*----------------------------------------------------------------------------------------------------------------------
* Description : This Auth routine is triggered when TT transaction is Authorised
* In parameter : None
* out parameter : None
*----------------------------------------------------------------------------------------------------------------------
*Modification history:
*----------------------------------------------------------------------------------------------------------------------
* Date          who                Reference        Description
* 10-AUG-2010   Prabhu.N           HD1026443        NCF generated for charge account
* 22-NOV-2011   Nava V.                             Tax Amount calculation without CURRENCY concatenation (Valid only for NCF purposes)
* 01-DEC-2011   Nava V.                             Taken a valid CUSTOMER.ID from REDO.CUS.IDENTIFICATION, to generate NCF number on transactions between Internal
*                                                   Accounts (NO Customer linked), when there is a valid "APAP CLIENT"
* 25-JAN-2012   Nava V.                             New NCF Tax and Commission amount calculation regarding PACS00163682
* 25-JUN-2013   Vignesh Kumaar R   PACS00265097     NCF ISSUE - ENRICHMENT FOR ID.NUMBER
* 15-JUL-2013   VIGNESH KUMAAR R   PACS00294931     FOR OTHER BANK CUSTOMER ID.NUMBER TO BE DISPLAYED IN CUSTOMER FIELD
* 10-MAY-2015   VIGNESH KUMAAR R   PACS00456843     NCF PERFORMANCE FIX
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    I TO I.VAR,VM TO @VM,FM TO @FM,++ TO +=1,F.READ TO CACHE.READ
*18-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
*----------------------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_System ;* VNL 2011DIC01 - S/E
*
    $INSERT I_F.TELLER
    $INSERT I_F.USER
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCOUNT.CLASS ;* Fix for PACS00265097
*
    $INSERT I_F.REDO.L.NCF.STATUS
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $INSERT I_F.REDO.NCF.ISSUED
*
    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
*
RETURN
*
********
PROCESS:
********
*Checking for the Local Field
*
    GOSUB ANALIZE.GENERATE.COMM.NCF
    GOSUB ANALIZE.GENERATE.TAX.NCF
*
RETURN
*
* ========================
ANALIZE.GENERATE.COMM.NCF:
* ========================
*
    WCOM.VAL    = 0
    WCOM.WAIVED = 0
    WARR.COM    = ''
    YNUM.COMM   = DCOUNT(Y.COM.COD,@SM)
*
    I.VAR = 1 ;*R22 Auto code conversion-START
    LOOP
        Y.WV.CM.YN = ''
    WHILE (I.VAR LE YNUM.COMM)
        Y.WV.CM.YN = Y.WV.COM<1,1,I.VAR>
        IF Y.WV.CM.YN EQ "NO" THEN
            WCOM.VAL += Y.COM.AMT<1,1,I.VAR>
            WARR.COM<-1> = Y.COM.COD<1,1,I.VAR>
        END ELSE
            WCOM.WAIVED += Y.COM.AMT<1,1,I.VAR>
        END
        I.VAR += 1 ;*R22 Auto code conversion-END
    REPEAT
*
    VAR.CHG.AMT = WCOM.VAL
*
    IF FT.DR.CURRENCY EQ LCCY THEN
        CHARGE.AMOUNT = LCCY:' ':VAR.CHG.AMT
    END ELSE
        CHARGE.AMOUNT = FT.DR.CURRENCY:' ':VAR.CHG.AMT
    END
*
RETURN
*
* =======================
ANALIZE.GENERATE.TAX.NCF:
* =======================
*
    WTAX.VAL    = 0
    WTAX.WAIVED = 0
    WARR.TAX    = ''
    YNUM.TAX    = DCOUNT(Y.TAX.COD,@SM)

    J.VAR = 1 ;*R22 Auto code conversion-START
    LOOP
        Y.WV.TX.YN = ''
    WHILE (J.VAR LE YNUM.TAX)
        Y.WV.TX.YN = Y.WV.TAX<1,1,J.VAR>
        IF Y.WV.TX.YN EQ 'NO' THEN
            WTAX.VAL += Y.TAX.AMT<1,1,J.VAR>
            WARR.TAX<-1> = Y.TAX.COD<1,1,J.VAR>
        END ELSE
            WTAX.WAIVED += Y.TAX.AMT<1,1,J.VAR>
        END
        J.VAR += 1 ;*R22 Auto code conversion-END
    REPEAT
*
    Y.TAX.AMT   = WTAX.VAL
    VAR.TAX.AMT = Y.TAX.AMT

* COMBINED BOTH COMMISSION AND TAX CALC TO MAKE SINGLE REQUEST TO THE NCF GENERATION

    Y.NCF.CNT = 0

    IF VAR.CHG.AMT NE "" AND VAR.CHG.AMT GT 0 THEN
        IF VAR.NCF.REQ EQ 'YES' THEN
            Y.NCF.CNT += 1
            Y.COM.FLAG = 1
        END ELSE

            Y.COM.FLAG = 2
        END
    END

    IF WTAX.VAL GT 0 THEN
        IF VAR.NCF.REQ EQ 'YES' THEN
            Y.NCF.CNT += 1
            Y.TAX.FLAG = 1
        END ELSE
            Y.TAX.FLAG = 2
        END
    END

    IF Y.NCF.CNT NE 0 THEN
        CALL APAP.TAM.REDO.NCF.PERF.RTN(Y.NCF.CNT,Y.NCF.LIST) ;* R22 Manual Conversion - CALL method format modified
    END

    BEGIN CASE
        CASE Y.COM.FLAG EQ 1
            GOSUB PROCESS1
        CASE Y.COM.FLAG EQ 2
            GOSUB UPDATE.TABLE2
    END CASE

    BEGIN CASE
        CASE Y.TAX.FLAG EQ 1
            GOSUB PROCESS.TAX
        CASE Y.TAX.FLAG EQ 2
            GOSUB UPDATE.TABLE2
    END CASE

    IF CHK.UPD.TAB2 THEN
        GOSUB WRITE.NCF.UNMAPPED
    END

RETURN
*
*********
PROCESS1:
*********
*
* Updating NCF Stock Param table for CHARGES
*
    NCF.NUMBER = Y.NCF.LIST<1>
    DEL Y.NCF.LIST<1>

    IF NCF.NUMBER THEN
        GOSUB UPDATE.TABLE1
    END ELSE
        GOSUB UPDATE.TABLE2
    END
*

RETURN
*
**************
UPDATE.TABLE1:
**************
*
*Updating ISSUED and Status Table for CHARGES
*** Update code
    NCF.ISSUE.ID = Y.ORG.CUS.ID:'.':VAR.DATE:'.':TXN.ID
***
    R.REDO.NCF.ISSUED<ST.IS.TXN.ID>=TXN.ID
* VNL - 2012JAN25 - Including MV set fields values - S
    WARR.COM = CHANGE(WARR.COM,@FM,@VM)
    R.REDO.NCF.ISSUED<ST.IS.TXN.CHARGE>=WARR.COM
* VNL - 2012JAN25 - E
    R.REDO.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>    = CHARGE.AMOUNT
    R.REDO.NCF.ISSUED<ST.IS.DATE>             = VAR.DATE
    R.REDO.NCF.ISSUED<ST.IS.MODIFIED.NCF>     = VAR.NCF.NO
    R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>         = VAR.CUS
    NCF.IS.CNT = DCOUNT(R.REDO.NCF.ISSUED<ST.IS.NCF>,@VM)
    R.REDO.NCF.ISSUED<ST.IS.NCF,NCF.IS.CNT+1> = NCF.NUMBER
    R.REDO.NCF.ISSUED<ST.IS.ACCOUNT>          = VAR.ACCOUNT
*** Add code

* Fix for PACS00265097[NCF ISSUE - ENRICHMENT FOR ID.NUMBER #1]

*    IF Y.PROCESS.NONAPAP THEN
    IF NOSTRO.FLAG THEN

* End of Fix

        R.REDO.NCF.ISSUED<ST.IS.ID.TYPE>      = WDOC.TYPE
        R.REDO.NCF.ISSUED<ST.IS.ID.NUMBER>    = WDOC.NUM
        R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>     = WDOC.NUM        ;* Added for PACS00294931
    END
***
    CALL F.WRITE(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED)
*
    CALL F.READ(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.MSG)
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>  = ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>     = VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>            = VAR.DATE
    R.REDO.L.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>   = CHARGE.AMOUNT
    NCF.CNT = DCOUNT(R.REDO.L.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.REDO.L.NCF.STATUS<NCF.ST.NCF,NCF.CNT+1>   = NCF.NUMBER
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>          = 'AVAILABLE'
    R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.NCF.NO>   = NCF.NUMBER
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
*
RETURN
*
*---------------
PROCESS.TAX:
*---------------
** Updating NCF Stock Param table for TAXES
*

    NCF.NUMBER.TAX = Y.NCF.LIST<1>
    DEL Y.NCF.LIST<1>

    IF NCF.NUMBER.TAX THEN
        GOSUB UPDATE.TABLE.TAX
    END ELSE
        GOSUB UPDATE.TABLE2
    END

*
RETURN
*
*******************
UPDATE.TABLE.TAX:
*******************
*
*Updating ISSUED and Status Table for TAXES
*** Update code variable
    NCF.ISSUE.ID=Y.ORG.CUS.ID:'.':VAR.DATE:'.':TXN.ID
*** S-PACS00510571
* R.REDO.NCF.ISSUED= ''
*E-PACS00510571
    R.REDO.NCF.ISSUED<ST.IS.TXN.ID>=TXN.ID
* VNL - 2012JAN25 - Including MV set fields values - S

    WARR.TAX = CHANGE(WARR.TAX,@FM,@VM)
    R.REDO.NCF.ISSUED<ST.IS.TXN.TAX>=WARR.TAX
* VNL - 2012JAN25 - Including MV set fields values - E
    R.REDO.NCF.ISSUED<ST.IS.TAX.AMOUNT>=VAR.TAX.AMT
    R.REDO.NCF.ISSUED<ST.IS.DATE> = VAR.DATE
    R.REDO.NCF.ISSUED<ST.IS.MODIFIED.NCF> = VAR.NCF.NO
    R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>=VAR.CUS
    NCF.IS.CNT = DCOUNT(R.REDO.NCF.ISSUED<ST.IS.NCF>,@VM)
* VNL - 2012JAN25 - Second NCF number was missing to be saved.   R.REDO.NCF.ISSUED<ST.IS.NCF,NCF.IS.CNT>= NCF.NUMBER.TAX
    R.REDO.NCF.ISSUED<ST.IS.NCF,NCF.IS.CNT+1>= NCF.NUMBER.TAX
    R.REDO.NCF.ISSUED<ST.IS.ACCOUNT>=VAR.ACCOUNT
*** Add code
* Fix for PACS00265097[NCF ISSUE - ENRICHMENT FOR ID.NUMBER #2]
*    IF Y.PROCESS.NONAPAP THEN
    IF NOSTRO.FLAG THEN
* End of Fix

        R.REDO.NCF.ISSUED<ST.IS.ID.TYPE>      = WDOC.TYPE
        R.REDO.NCF.ISSUED<ST.IS.ID.NUMBER>    = WDOC.NUM
        R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>     = WDOC.NUM        ;* Added for PACS00294931
    END
***
    CALL F.WRITE(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED)
*
    CALL F.READ(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.MSG)
    NCF.CNT = DCOUNT(R.REDO.L.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>    = ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>       = VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>              = VAR.DATE
    R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>        = VAR.TAX.AMT
    R.REDO.L.NCF.STATUS<NCF.ST.NCF,NCF.CNT+1>     = NCF.NUMBER.TAX
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>            = 'AVAILABLE'
    R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.TAX.NCF.NO> = NCF.NUMBER.TAX
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
*
RETURN
*
**************
UPDATE.TABLE2:
**************
*
*   Updating UNMAPPED and Status Table for CHARGES and TAXES
*** Update code
    NCF.ISSUE.ID=Y.ORG.CUS.ID:'.':VAR.DATE:'.':TXN.ID
***
*** Add code
    CHK.UPD.TAB2 =1
***
    R.REDO.L.NCF.UNMAPPED<ST.UN.TXN.ID>        = ID.NEW
    R.REDO.L.NCF.UNMAPPED<ST.UN.CHARGE.AMOUNT> = CHARGE.AMOUNT
    R.REDO.L.NCF.UNMAPPED<ST.UN.TAX.AMOUNT>    = VAR.TAX.AMT
    R.REDO.L.NCF.UNMAPPED<ST.UN.DATE>          = VAR.DATE
    R.REDO.L.NCF.UNMAPPED<ST.UN.ACCOUNT>       = VAR.ACCOUNT
    R.REDO.L.NCF.UNMAPPED<ST.UN.BATCH>         = 'NO'
*** Add code
* Fix for PACS00265097[NCF ISSUE - ENRICHMENT FOR ID.NUMBER #3]
*    IF Y.PROCESS.NONAPAP THEN
    IF NOSTRO.FLAG THEN
* End of Fix
        R.REDO.L.NCF.UNMAPPED<ST.UN.ID.TYPE>   = WDOC.TYPE
        R.REDO.L.NCF.UNMAPPED<ST.UN.ID.NUMBER> = WDOC.NUM
        R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>      = WDOC.NUM       ;* Added for PACS00294931
    END
***
***
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>  = ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>     = VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>            = VAR.DATE
    R.REDO.L.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>   = CHARGE.AMOUNT
    R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>      = VAR.TAX.AMT
    R.REDO.L.NCF.STATUS<NCF.ST.NCF>             = ''
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>          = 'UNAVAILABLE'
RETURN
*
* ===================
GET.LOCAL.FIELDS.POS:
* ===================
*
    LRF.APP  ='TELLER'
* VNL - 2012JAN03 - Tax and Commissions change    LRF.FIELD='L.NCF.REQUIRED':VM:'L.NCF.NUMBER':VM:'L.TT.TAX.TYPE':VM:'TAX.AMOUNT':VM:'L.NCF.TAX.NUM':VM:'WAIVE.TAX':VM:'L.TT.LEGAL.ID'
*
    LRF.FIELD  = 'L.NCF.REQUIRED':@VM:'L.NCF.NUMBER':@VM:'L.TT.TAX.TYPE':@VM:'RESERVED99':@VM:'L.NCF.TAX.NUM':@VM:'WAIVE.TAX'
    LRF.FIELD := @VM:'L.TT.LEGAL.ID':@VM:'L.TT.TAX.AMT':@VM:'L.TT.TAX.CODE':@VM:'L.TT.COMM.AMT':@VM:'L.TT.COMM.CODE':@VM:'L.TT.WV.COMM':@VM:'L.TT.WV.TAX'
    LRF.FIELD := @VM:"L.TT.DOC.DESC":@VM:"L.TT.DOC.NUM":@VM:"L.TT.CLIENT.COD"
*
    LRF.POS=''
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)
    POS.TT.NCF.REQ      = LRF.POS<1,1>
    POS.L.TT.NCF.NO     = LRF.POS<1,2>
    TT.TAX.POS          = LRF.POS<1,3>
    TT.TAX.AMT          = LRF.POS<1,4>
    POS.L.TT.TAX.NCF.NO = LRF.POS<1,5>
    TT.WAIVE.TAX.POS    = LRF.POS<1,6>
    L.TT.LEGAL.ID.POS   = LRF.POS<1,7>    ;* VNL - 2011DEC01 - S
    POS.L.TT.TAX.AMT    = LRF.POS<1,8>
    POS.L.TT.TAX.COD    = LRF.POS<1,9>
    POS.L.TT.COM.AMT    = LRF.POS<1,10>
    POS.L.TT.COM.COD    = LRF.POS<1,11>
    POS.L.TT.WV.COM     = LRF.POS<1,12>
    POS.L.TT.WV.TAX     = LRF.POS<1,13>
    POS.DOC.DESC        = LRF.POS<1,14>
    POS.DOC.NUM         = LRF.POS<1,15>
    POS.CLIENT.COD      = LRF.POS<1,16>   ;*PACS00255151 & PACS00255152
*
RETURN
*
* =============
LOAD.RNEW.INFO:
* =============
*
    Y.TAX.AMT        = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.TAX.AMT>
    Y.TAX.COD        = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.TAX.COD>
    Y.COM.AMT        = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.COM.AMT>
    Y.COM.COD        = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.COM.COD>
    Y.WV.COM         = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.WV.COM>
    Y.WV.TAX         = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.WV.TAX>
    Y.TT.LEGAL.ID    = R.NEW(TT.TE.LOCAL.REF)<1,L.TT.LEGAL.ID.POS>
    VAR.NCF.REQ      = R.NEW(TT.TE.LOCAL.REF)<1,POS.TT.NCF.REQ>
    VAR.NCF.NO       = R.NEW(TT.TE.LOCAL.REF)<1,POS.L.TT.NCF.NO>
    WDOC.TYPE        = R.NEW(TT.TE.LOCAL.REF)<1,POS.DOC.DESC>
    WDOC.NUM         = R.NEW(TT.TE.LOCAL.REF)<1,POS.DOC.NUM>
    WCLNT.ID         = R.NEW(TT.TE.LOCAL.REF)<1,POS.CLIENT.COD>
    VAR.DR.CR.MARKER = R.NEW(TT.TE.DR.CR.MARKER)
    VAR.TXN.DATE     = R.NEW(TT.TE.DATE.TIME)
    VAR.DATE         = 20:VAR.TXN.DATE[1,6]
    TXN.ID           = ID.NEW
*
    IF VAR.DR.CR.MARKER EQ 'DEBIT' THEN
        FT.DR.CURRENCY = R.NEW(TT.TE.CURRENCY.1)
        TRANS.DR.AMT   = R.NEW(TT.TE.NET.AMOUNT)
        VAL.DATE       = R.NEW(TT.TE.VALUE.DATE.1)
        ACCOUNT.DR     = R.NEW(TT.TE.ACCOUNT.1)
        ACCOUNT.CR     = R.NEW(TT.TE.ACCOUNT.2)
        FT.CR.CURRENCY = R.NEW(TT.TE.CURRENCY.2)
    END ELSE
        FT.DR.CURRENCY = R.NEW(TT.TE.CURRENCY.2)
        TRANS.DR.AMT   = R.NEW(TT.TE.NET.AMOUNT)
        VAL.DATE       = R.NEW(TT.TE.VALUE.DATE.2)
        ACCOUNT.DR     = R.NEW(TT.TE.ACCOUNT.2)
        ACCOUNT.CR     = R.NEW(TT.TE.ACCOUNT.1)
        FT.CR.CURRENCY = R.NEW(TT.TE.CURRENCY.1)
    END
*
* VNL - 2012JAN24 - S
*
    ID.CUSIDE = FIELD(Y.TT.LEGAL.ID,".",2)
    Y.ID.TYPE = FIELD(Y.TT.LEGAL.ID,".",1)          ;* VNL 2011DIC01 - E
*
RETURN
*
* ================
GET.CUSTOMER.INFO:
* ================
*
    GOSUB GET.CUSTOMER
*
    IF NOT(VAR.CUS) AND NOT(Y.ORG.CUS.ID) THEN      ;* VNL - 2011DIC01 - S
        GOSUB TYPE.PROOF.CHECK
        VAR.CUS = CUSTOMER.NO
    END     ;* VNL - 2011DIC01 - E
*
RETURN
*
*------------
GET.CUSTOMER:
*------------
*
    CALL F.READ(FN.ACCOUNT,ACCOUNT.DR,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)
    VAR.CUS           = R.ACCOUNT<AC.CUSTOMER>
    GET.ACCT.OFFICER  = R.ACCOUNT<AC.ACCOUNT.OFFICER>
    GET.PROD.CATEGORY = R.ACCOUNT<AC.CATEGORY>
    GET.ACCT.CATEG = R.ACCOUNT<AC.CATEGORY>
    VAR.ACCOUNT       = ACCOUNT.DR
*
    IF NOT(VAR.CUS) THEN
        CALL F.READ(FN.ACCOUNT,ACCOUNT.CR,R.ACCOUNT,F.ACCOUNT,ACCT.ERR)
        VAR.CUS     = R.ACCOUNT<AC.CUSTOMER>
        VAR.ACCOUNT = ACCOUNT.CR
        GET.ACCT.CATEG = R.ACCOUNT<AC.CATEGORY>
    END
*** Add code

* Fix for PACS00265097[NCF ISSUE - ENRICHMENT FOR ID.NUMBER #4]

    CALL CACHE.READ(FN.ACCOUNT.CLASS, 'NOSTRO', R.ACCOUNT.CLASS, ACCOUNT.CLASS.ERR) ;*R22 Auto code conversion
    GET.NOSTRO.LIST = R.ACCOUNT.CLASS<AC.CLS.CATEGORY>

    NOSTRO.FLAG = ''
    LOCATE GET.ACCT.CATEG IN GET.NOSTRO.LIST<1,1> SETTING CATEG.POS THEN
        NOSTRO.FLAG = 1
    END

    IF VAR.CUS THEN
        IF NOSTRO.FLAG THEN
            Y.ORG.CUS.ID=WDOC.NUM
        END ELSE

* End of Fix

            Y.ORG.CUS.ID=VAR.CUS
        END
    END ELSE
        Y.ORG.CUS.ID=WCLNT.ID
    END
***
RETURN
*
*
****************
TYPE.PROOF.CHECK:
****************
*** New code
**PACS00190839 - S

    BEGIN CASE
        CASE Y.ID.TYPE EQ "CEDULA"
            R.CUS.CIDENT = ''
            CALL F.READ(FN.CUS.L.CU.CIDENT,ID.CUSIDE,R.CUS.CIDENT,F.CUS.L.CU.CIDENT,CID.ERR)
            CUS.ID = FIELD(R.CUS.CIDENT,"*",2)

        CASE Y.ID.TYPE EQ "PASAPORTE"
            R.CUS.LEGAL = ''
            CALL F.READ(FN.CUS.LEGAL.ID,ID.CUSIDE,R.CUS.LEGAL,F.CUS.LEGAL.ID,LEGAL.ERR)
            CUS.ID = FIELD(R.CUS.LEGAL,"*",2)
    END CASE

    IF CUS.ID NE "" THEN
        CUSTOMER.NO  = CUS.ID
        Y.ORG.CUS.ID = CUS.ID
    END

    IF NOT(CUS.ID) THEN
        GOSUB CHECK.NONAPAP.NCF
    END
**PACS00190839 - E
RETURN
*
*******
INIT:
*******
*
    PROCESS.GOAHEAD = 1
    VAR.TAX.AMT     = 0
    STOCK.ID        = 'SYSTEM'
    MULTI.STMT      = ''
    Y.PROCESS.NONAPAP=''

    GOSUB GET.LOCAL.FIELDS.POS
*
    GOSUB LOAD.RNEW.INFO
*
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''

    FN.REDO.L.NCF.UNMAPPED='F.REDO.L.NCF.UNMAPPED'
    F.REDO.L.NCF.UNMAPPED=''

    FN.REDO.NCF.ISSUED='F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED=''

    FN.REDO.L.NCF.STATUS='F.REDO.L.NCF.STATUS'
    F.REDO.L.NCF.STATUS=''

    FN.CUSTOMER= 'F.CUSTOMER'   ;* VNL - 2011DEC01 - S
    F.CUSTOMER= ''
*** Add code
*PACS00190839 - S
    FN.CUS.L.CU.RNC = 'F.CUSTOMER.L.CU.RNC'
    F.CUS.L.CU.RNC  = ''

    FN.CUS.L.CU.CIDENT = 'F.CUSTOMER.L.CU.CIDENT'
    F.CUS.L.CU.CIDENT  = ''

    FN.CUS.LEGAL.ID = 'F.REDO.CUSTOMER.LEGAL.ID'
    F.CUS.LEGAL.ID  = ''
*PACS00190839 - E
***
    FN.ACCOUNT.CLASS = 'F.ACCOUNT.CLASS'
    F.ACCOUNT.CLASS = ''

RETURN

***********
OPEN.FILES:
***********
*Opening Files

    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    CALL OPF(FN.REDO.L.NCF.UNMAPPED,F.REDO.L.NCF.UNMAPPED)

    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)

    CALL OPF(FN.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS)

    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
*PACS00190839 - S
    CALL OPF(FN.CUS.L.CU.RNC,F.CUS.L.CU.RNC)

    CALL OPF(FN.CUS.L.CU.CIDENT,F.CUS.L.CU.CIDENT)

    CALL OPF(FN.CUS.LEGAL.ID,F.CUS.LEGAL.ID)

*PACS00190839 - E
    CALL OPF(FN.ACCOUNT.CLASS,F.ACCOUNT.CLASS)

RETURN
*
*======================
CHECK.PRELIM.CONDITIONS:
*======================
*
    LOOP.CNT  = 1
    MAX.LOOPS = 3
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
*** Update code

            CASE LOOP.CNT EQ 2
                GOSUB GET.CUSTOMER.INFO
*** Update code
                IF NOT(VAR.CUS) AND NOT(Y.ORG.CUS.ID) THEN
***
                    PROCESS.GOAHEAD = ""
                END
            CASE LOOP.CNT EQ 3
                VAL.STATUS=R.NEW(TT.TE.RECORD.STATUS)
                IF VAL.STATUS[1,1] EQ 'R' THEN
                    PROCESS.GOAHEAD = ""
                END

        END CASE
        LOOP.CNT +=1
*
    REPEAT
*
RETURN
*
*** Add code
*==================
CHECK.NONAPAP.NCF:
*==================

    IF WDOC.NUM AND WDOC.TYPE THEN
        Y.ORG.CUS.ID=WDOC.NUM
        Y.PROCESS.NONAPAP=1
        NOSTRO.FLAG = 1 ;* Fix for PACS00265097[NCF ISSUE - ENRICHMENT FOR ID.NUMBER #5]
    END
*
RETURN
*

*==================
WRITE.NCF.UNMAPPED:
*==================
    CALL F.WRITE(FN.REDO.L.NCF.UNMAPPED,NCF.ISSUE.ID,R.REDO.L.NCF.UNMAPPED)
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
*
RETURN
***
END
