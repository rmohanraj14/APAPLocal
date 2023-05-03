* @ValidationCode : MjotMTI5OTM3NDIwNDpDcDEyNTI6MTY4MTM4MTY1MDQxMTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:57:30
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
SUBROUTINE REDO.V.AUTH.TAX.AMT
*-----------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* DESCRIPTION : This routine will be executed at Auth Level for the Following versions of
* TELLER,CHEQUE.GOVERNMENT.TAX and TELLER,CHEQUE.GOVERNMENT.BENEFICIARY. This Routine is used
* to calculate the Tax Amount and also raise the proper accounting entries
*------------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
* Linked : TELLER
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.AUTH.TAX.AMT
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 16.03.2010      SUDHARSANAN S     ODR-2009-10-0319  INITIAL CREATION
* 09.02.2011      SUDHARSANAN S     HD1048577          UPDATING ACCOUNTING ENTRIES
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ,VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CATEG.ENTRY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.USER
    $INSERT I_F.CURRENCY
    $INSERT I_F.CERTIFIED.CHEQUE.PARAMETER
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.TAX


    GOSUB INIT
    GOSUB PROCESS
RETURN
*-----------------------------------------------------------------------------
INIT:
    FN.FT.COMMISSION.TYPE='F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE=''
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
    FN.STMT.ENTRY='F.STMT.ENTRY'
    F.STMT.ENTRY=''
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)
    FN.CATEG.ENTRY='F.CATEG.ENTRY'
    F.CATEG.ENTRY=''
    CALL OPF(FN.CATEG.ENTRY,F.CATEG.ENTRY)
    FN.ACCOUNT='F.ACCOUNT'
    F.ACCOUNT=''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    FN.USER='F.USER'
    F.USER=''
    CALL OPF(FN.USER,F.USER)
    FN.CURRENCY='F.CURRENCY'
    F.CURRENCY=''
    CALL OPF(FN.CURRENCY,F.CURRENCY)
    FN.CERTIFIED.CHEQUE.PARAMETER='F.CERTIFIED.CHEQUE.PARAMETER'
    F.CERTIFIED.CHEQUE.PARAMETER=''
    CALL OPF(FN.CERTIFIED.CHEQUE.PARAMETER,F.CERTIFIED.CHEQUE.PARAMETER)
    LREF.APP='TELLER'
    LREF.FIELD='TAX.AMOUNT':@VM:'WAIVE.TAX'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
    POS.TAX.AMOUNT=LREF.POS<1,1>
    POS.WAIVE.TAX=LREF.POS<1,2>
    CALL CACHE.READ(FN.CERTIFIED.CHEQUE.PARAMETER,ID.COMPANY,R.CERT.CHEQ.PARAM,CERT.ERR)

    FN.TAX = 'F.TAX'
    F.TAX= ''
    CALL OPF(FN.TAX,F.TAX)

RETURN
*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------
*Generate Statement and Categ Entries
    Y.TAX.AMOUNT=R.NEW(TT.TE.LOCAL.REF)<1,POS.TAX.AMOUNT>
    Y.WAIVE.TAX=R.NEW(TT.TE.LOCAL.REF)<1,POS.WAIVE.TAX>
    Y.RECORD.STATUS=R.NEW(TT.TE.RECORD.STATUS)
    Y.DEBIT.ACCOUNT.NO = R.NEW(TT.TE.ACCOUNT.2)
    Y.CUSTOMER=R.NEW(TT.TE.CUSTOMER.2)
    IF V$FUNCTION EQ 'A' AND (Y.RECORD.STATUS EQ 'INAU' OR Y.RECORD.STATUS EQ 'INAO') THEN
        BEGIN CASE
            CASE PGM.VERSION EQ ',CHEQUE.GOVERNMENT.TAX'
                LOCATE 'GOVT' IN R.CERT.CHEQ.PARAM<CERT.CHEQ.TYPE,1> SETTING POS THEN
                    GOSUB ACCOUNTING.VALUES
                END
            CASE PGM.VERSION EQ ',CHEQUE.GOVERNMENT.BENEFICIARY'
                LOCATE 'NON.GOVT' IN R.CERT.CHEQ.PARAM<CERT.CHEQ.TYPE,1> SETTING POS THEN
                    GOSUB ACCOUNTING.VALUES
                END
        END CASE
        IF Y.WAIVE.TAX NE 'YES' THEN
            GOSUB GENERATE.STMT.ENTRIES
        END ELSE
            GOSUB GENERATE.WAIVE.STMT.ENTRIES
        END
    END
RETURN
*------------------------------------------------------------------------------------
GENERATE.STMT.ENTRIES:
*------------------------------------------------------------------------
*Raise the accounting entries
    CALL F.READ(FN.ACCOUNT,Y.DEBIT.ACCOUNT.NO,R.ACCT,F.ACCOUNT,ACC.ERR)
    Y.CURR = R.ACCT<AC.CURRENCY>
    Y.ACCT.OFFICER = R.ACCT<AC.ACCOUNT.OFFICER>
    CALL CACHE.READ(FN.CURRENCY, Y.CURR, R.CURR, CURR.ERR) ;*R22 Auto code conversion
    Y.EXCHANGE.RATE = R.CURR<EB.CUR.MID.REVAL.RATE,1>
    Y.PRODUCT.CATEGORY=R.ACCT<AC.CATEGORY>
    R.STMT.ARR = ''
    R.STMT.ARR<AC.STE.ACCOUNT.NUMBER> = Y.DEBIT.ACCOUNT.NO
    R.STMT.ARR<AC.STE.COMPANY.CODE> = ID.COMPANY
    R.STMT.ARR<AC.STE.AMOUNT.LCY> = -1*Y.TAX.AMOUNT
    R.STMT.ARR<AC.STE.TRANSACTION.CODE> =Y.DR.TXN.CODE
    R.STMT.ARR<AC.STE.THEIR.REFERENCE>=''
    R.STMT.ARR<AC.STE.CUSTOMER.ID> =Y.CUSTOMER
    R.STMT.ARR<AC.STE.ACCOUNT.OFFICER> = Y.ACCT.OFFICER
    R.STMT.ARR<AC.STE.PRODUCT.CATEGORY> = Y.PRODUCT.CATEGORY
    R.STMT.ARR<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ARR<AC.STE.CURRENCY> = Y.CURR
    R.STMT.ARR<AC.STE.POSITION.TYPE> = 'TR'
    IF Y.CURR EQ LCCY THEN
        R.STMT.ARR<AC.STE.AMOUNT.FCY> = ''
        R.STMT.ARR<AC.STE.EXCHANGE.RATE>=''
    END ELSE
        R.STMT.ARR<AC.STE.AMOUNT.FCY> = -1*Y.TAX.AMOUNT*Y.EXCHANGE.RATE
        R.STMT.ARR<AC.STE.EXCHANGE.RATE>=Y.EXCHANGE.RATE
    END
    R.STMT.ARR<AC.STE.DEPARTMENT.CODE>=R.USER<EB.USE.DEPARTMENT.CODE>
    R.STMT.ARR<AC.STE.CURRENCY.MARKET>='1'
    R.STMT.ARR<AC.STE.TRANS.REFERENCE>= ID.NEW
    R.STMT.ARR<AC.STE.SYSTEM.ID> = "TT"
    R.STMT.ARR<AC.STE.BOOKING.DATE> = TODAY
    MULTI.STMT=''
    MULTI.STMT<-1> = LOWER(R.STMT.ARR)
    GOSUB RAISE.CR.ENTRIES
    V = TT.TE.AUDIT.DATE.TIME
    CALL EB.ACCOUNTING("TT","SAO",MULTI.STMT,'')
RETURN
*---------------------------------------------------------------------
RAISE.CR.ENTRIES:
*---------------------------------------------------------------------
*Raise the catg.entries

    R.STMT.ENT = ''
    ACCOUNT.NO = LCCY:Y.TAX.CATEGORY:"0001"

    R.STMT.ENT<AC.STE.ACCOUNT.NUMBER> =ACCOUNT.NO
    R.STMT.ENT<AC.STE.COMPANY.CODE>=ID.COMPANY

    R.STMT.ENT<AC.STE.AMOUNT.LCY> =  Y.TAX.AMOUNT

    R.STMT.ENT<AC.STE.TRANSACTION.CODE> = Y.CR.TXN.CODE
    R.STMT.ENT<AC.STE.ACCOUNT.OFFICER> = Y.ACCT.OFFICER
    R.STMT.ENT<AC.STE.CUSTOMER.ID> = Y.CUSTOMER
    R.STMT.ENT<AC.STE.DEPARTMENT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
    R.STMT.ENT<AC.STE.PRODUCT.CATEGORY> = Y.PRODUCT.CATEGORY
    R.STMT.ENT<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ENT<AC.STE.CURRENCY> = Y.CURR
    R.STMT.ENT<AC.STE.EXCHANGE.RATE> = ''
    R.STMT.ENT<AC.STE.CURRENCY.MARKET> = "1"
    R.STMT.ENT<AC.STE.TRANS.REFERENCE> = ID.NEW
    R.STMT.ENT<AC.STE.SYSTEM.ID> = "FT"
    R.STMT.ENT<AC.STE.BOOKING.DATE> = TODAY
    R.STMT.ENT<AC.STE.NARRATIVE> ='TAX ENTRY'

    MULTI.STMT<-1> = LOWER(R.STMT.ENT)


RETURN
*----------------------------------------------------------------------------
*------------------------------------------------------------------------------------
GENERATE.WAIVE.STMT.ENTRIES:
*------------------------------------------------------------------------
*Raise the accounting entries
    Y.ACCOUNT.NO = Y.DEBIT.ACCOUNT.NO
    R.ACCT=''
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.NO,R.ACCT,F.ACCOUNT,ACC.ERR)
    Y.CUST = R.ACCT<AC.CUSTOMER>
    Y.CURR = R.ACCT<AC.CURRENCY>
    Y.ACCT.OFFICER = R.ACCT<AC.ACCOUNT.OFFICER>
    Y.PROD.CATEGORY =R.ACCT<AC.CATEGORY>

    CALL CACHE.READ(FN.CURRENCY, Y.CURR, R.CURR, CURR.ERR) ;*R22 Auto code conversion
    Y.EXCHANGE.RATE = R.CURR<EB.CUR.MID.REVAL.RATE,1>
    R.STMT.ARR = ''
    R.STMT.ARR<AC.STE.ACCOUNT.NUMBER> = Y.ACCOUNT.NO
    R.STMT.ARR<AC.STE.COMPANY.CODE> = ID.COMPANY
    R.STMT.ARR<AC.STE.AMOUNT.LCY> = Y.TAX.AMOUNT
    R.STMT.ARR<AC.STE.TRANSACTION.CODE> =Y.CR.TXN.CODE
    R.STMT.ARR<AC.STE.THEIR.REFERENCE>=''
    R.STMT.ARR<AC.STE.CUSTOMER.ID> =Y.CUST
    R.STMT.ARR<AC.STE.ACCOUNT.OFFICER> = Y.ACCT.OFFICER
    R.STMT.ARR<AC.STE.PRODUCT.CATEGORY> = Y.PROD.CATEGORY
    R.STMT.ARR<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ARR<AC.STE.CURRENCY> = Y.CURR
    R.STMT.ARR<AC.STE.POSITION.TYPE> = 'TR'
    IF Y.CURR EQ LCCY THEN
        R.STMT.ARR<AC.STE.AMOUNT.FCY> = ''
        R.STMT.ARR<AC.STE.EXCHANGE.RATE>=''
    END ELSE
        R.STMT.ARR<AC.STE.AMOUNT.FCY> = Y.TAX.AMOUNT*Y.EXCHANGE.RATE
        R.STMT.ARR<AC.STE.EXCHANGE.RATE>=Y.EXCHANGE.RATE
    END
    R.STMT.ARR<AC.STE.DEPARTMENT.CODE>=R.USER<EB.USE.DEPARTMENT.CODE>
    R.STMT.ARR<AC.STE.CURRENCY.MARKET>='1'
    R.STMT.ARR<AC.STE.TRANS.REFERENCE>= ID.NEW
    R.STMT.ARR<AC.STE.SYSTEM.ID> = "TT"
    R.STMT.ARR<AC.STE.BOOKING.DATE> = TODAY
    MULTI.STMT=''
    MULTI.STMT<-1> = LOWER(R.STMT.ARR)
    GOSUB RAISE.WAIVE.CATG.ENTRIES
    V = TT.TE.AUDIT.DATE.TIME
    CALL EB.ACCOUNTING("TT","SAO",MULTI.STMT,'')
RETURN
*---------------------------------------------------------------------
RAISE.WAIVE.CATG.ENTRIES:
*---------------------------------------------------------------------
*Raise the catg.entries

    R.STMT.ENT = ''
    ACCOUNT.NO = LCCY:Y.TAX.CATEGORY:"0001"

    R.STMT.ENT<AC.STE.ACCOUNT.NUMBER> =ACCOUNT.NO
    R.STMT.ENT<AC.STE.COMPANY.CODE>=ID.COMPANY

    R.STMT.ENT<AC.STE.AMOUNT.LCY> =  -1*Y.TAX.AMOUNT
    R.STMT.ENT<AC.STE.TRANSACTION.CODE> = Y.DR.TXN.CODE
    R.STMT.ENT<AC.STE.ACCOUNT.OFFICER> = Y.ACCT.OFFICER
    R.STMT.ENT<AC.STE.CUSTOMER.ID> = Y.CUSTOMER
    R.STMT.ENT<AC.STE.DEPARTMENT.CODE> = R.USER<EB.USE.DEPARTMENT.CODE>
    R.STMT.ENT<AC.STE.PRODUCT.CATEGORY> = Y.PROD.CATEGORY
    R.STMT.ENT<AC.STE.VALUE.DATE> = TODAY
    R.STMT.ENT<AC.STE.CURRENCY> = Y.CURR
    R.STMT.ENT<AC.STE.EXCHANGE.RATE> = ''
    R.STMT.ENT<AC.STE.CURRENCY.MARKET> = "1"
    R.STMT.ENT<AC.STE.TRANS.REFERENCE> = ID.NEW
    R.STMT.ENT<AC.STE.SYSTEM.ID> = "FT"
    R.STMT.ENT<AC.STE.BOOKING.DATE> = TODAY
    R.STMT.ENT<AC.STE.NARRATIVE> ='TAX ENTRY'

    MULTI.STMT<-1> = LOWER(R.STMT.ENT)

RETURN
*-----------------------------------------------------------------
ACCOUNTING.VALUES:
*--------------------------------------------------------------------
*    Y.PL.CATEGORY = R.CERT.CHEQ.PARAM<CERT.CHEQ.PL.CATEGORY,POS>
    Y.TAX.KEY = R.CERT.CHEQ.PARAM<CERT.CHEQ.TAX.KEY,POS>
    CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.TAX.KEY, R.FT.COMMISSION.TYPE, TAX.ERR) ;*R22 Auto code conversion
*   Y.CR.TXN.CODE=R.FT.COMMISSION.TYPE<FT4.TXN.CODE.CR>
*  Y.DR.TXN.CODE=R.FT.COMMISSION.TYPE<FT4.TXN.CODE.DR>

    Y.TAX.ACCOUNT = R.FT.COMMISSION.TYPE<FT4.CATEGORY.ACCOUNT>
    Y.TAX = R.FT.COMMISSION.TYPE<FT4.TAX.CODE>

    SEL.TAX = 'SSELECT ':FN.TAX:' WITH @ID LIKE ':Y.TAX:'...'
    CALL EB.READLIST(SEL.TAX,SEL.TAX.LIST,'',NOR,ERR.1)
    Y.TAX.KEY = SEL.TAX.LIST<NOR>

    CALL CACHE.READ(FN.TAX, Y.TAX.KEY, R.TAX, TAX.ERR) ;*R22 Auto code conversion
    Y.TAX.CATEGORY =R.TAX<EB.TAX.CATEGORY>
    Y.CR.TXN.CODE = R.TAX<EB.TAX.TR.CODE.CR>
    Y.DR.TXN.CODE = R.TAX<EB.TAX.TR.CODE.DR>



RETURN
*----------------------------------------------------------------------------
END
