* @ValidationCode : MjotMTQ0MDgwMzY0NzpDcDEyNTI6MTY4MTM4MDg2NDE1ODpJVFNTOi0xOi0xOjc1NjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:24
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 756
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.HISTORICOCTA(R.DATA)
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is an Nofile routine to get some data for enquiry REDO.IVR.HISTORICOCTA
* related to C.3 IVR Interface
*
* Input/Output:
*--------------
* IN : ACCOUNT.NO, START.DATE, END.DATE, TXN.TYPE
* OUT : R.DATA (ALL DATA)
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who                   Reference               Description
* 21-FEB-2011    RMONDRAGON            ODR-2011-02-0099          FIRST VERSION
* 22-MAR-2011    RMONDRAGON                                 USE OF CORE ROUTINE
*                                                           E.STMT.ENQ.BY.CONCAT
*                                                           INSTEAD OF SELECT IN
*                                                           STMT.ENTRY AND LOOP
*                                                           WHILE SENTENTE INSTEAD
*                                                           OF FOR NEXT  SENTENCE
* 11-JUN-2012    RMONDRAGON            ODR-2011-02-0099           PACS00200772
* 07-MAY-2013    RMONDRAGON            ODR-2011-02-0099           PACS00253631
* 23-APR-2014    RMONDRAGON            ODR-2011-02-0099           PENDING
*
* 11-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM, VM to @VM
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.STMT.ENTRY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.CURRENCY
    $INSERT I_F.TRANSACTION
* </region>
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*
*****
INIT:
*****

    ACCOUNT.NO.POS = ""
    Y.ACCOUNT = ""
    START.DATE.POS = ""
    Y.START.DATE = ""
    END.DATE.POS = ""
    Y.END.DATE = ""
    TXN.TYPE.POS = ""
    Y.TXN.TYPE = ""
    Y.TXN.FLG = ""
    Y.ID.LIST = ""
    Y.SEL.TXN = ""
    Y.CNT = ""
    Y.TXN = ""
    Y.STMT.NO = ""
    Y.STMT.ENTRY.REC = ""
    STMT.ENTRY.ERR = ""
    Y.ACCOUNT.REC = ""
    ACCT.REC = ""
    Y.DATA.OUT = ""
    Y.CUS.NAME = ""
    Y.CCY.COD = ""
    Y.CCY.DESC = ""

RETURN

*********
OPENFILES:
*********

    FN.ACCOUNT = "F.ACCOUNT"
    F.ACCOUNT = ""
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.STMT.ENTRY = "F.STMT.ENTRY"
    F.STMT.ENTRY = ""
    CALL OPF(FN.STMT.ENTRY,F.STMT.ENTRY)

    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ""
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)

    FN.CURRENCY = "F.CURRENCY"
    F.CURRENCY = ""
    CALL OPF(FN.CURRENCY,F.CURRENCY)

    FN.TRANSACTION = "F.TRANSACTION"
    F.TRANSACTION = ""
    CALL OPF(FN.TRANSACTION,F.TRANSACTION)

RETURN

********
PROCESS:
********

    LOCATE "ACCOUNT.NO" IN D.FIELDS<1> SETTING ACCOUNT.NO.POS THEN
        Y.ACCOUNT = D.RANGE.AND.VALUE<ACCOUNT.NO.POS>
        COMI = Y.ACCOUNT
        CALL IN2POSANT(19,'')
        Y.ACCOUNT = COMI
    END

    LOCATE "START.DATE" IN D.FIELDS<1> SETTING START.DATE.POS THEN
        Y.START.DATE = D.RANGE.AND.VALUE<START.DATE.POS>
    END

    LOCATE "END.DATE" IN D.FIELDS<1> SETTING END.DATE.POS THEN
        Y.END.DATE = D.RANGE.AND.VALUE<END.DATE.POS>
    END

    LOCATE "TXN.TYPE" IN D.FIELDS<1> SETTING TXN.TYPE.POS THEN
        Y.TXN.TYPE = D.RANGE.AND.VALUE<TXN.TYPE.POS>
    END

    BEGIN CASE
        CASE Y.TXN.TYPE EQ "CD"
            Y.TXN.FLG = "CD"
        CASE Y.TXN.TYPE EQ "D"
            Y.TXN.FLG = "D"
        CASE Y.TXN.TYPE EQ "C"
            Y.TXN.FLG = "C"
        CASE Y.TXN.TYPE EQ "DC"
            Y.TXN.FLG = "CD"
    END CASE

    D.FIELDS = "ACCOUNT":@FM:"BOOKING.DATE"
    D.RANGE.AND.VALUE = ""
    D.RANGE.AND.VALUE = Y.ACCOUNT:@FM:Y.START.DATE:@VM:Y.END.DATE
    D.LOGICAL.OPERANDS = "1":@FM:"2"

    CALL E.STMT.ENQ.BY.CONCAT(Y.ID.LIST)

    IF ENQ.ERROR NE '' THEN
        R.DATA<-1> = "2*****"
        RETURN
    END

    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,Y.ACCOUNT.REC,F.ACCOUNT,ACCT.ERR)
    IF Y.ACCOUNT.REC THEN
        Y.USR.COD = Y.ACCOUNT.REC<AC.CUSTOMER>
        Y.CCY = Y.ACCOUNT.REC<AC.CURRENCY>
    END

    CALL F.READ(FN.CUSTOMER,Y.USR.COD,Y.CUSTOMER.REC,F.CUSTOMER,CUSTOMER.ERR)
    IF Y.CUSTOMER.REC THEN
        Y.CUS.NAME = Y.CUSTOMER.REC<EB.CUS.SHORT.NAME>
    END

    CALL CACHE.READ(FN.CURRENCY, Y.CCY, Y.CURRENCY.REC, CURRENCY.ERR) ;*R22 Auto conversion
    IF Y.CURRENCY.REC THEN
        Y.CCY.COD = Y.CURRENCY.REC<EB.CUR.NUMERIC.CCY.CODE>
        Y.CCY.DESC = Y.CURRENCY.REC<EB.CUR.CCY.NAME>
    END

    Y.SEL.TXN = DCOUNT(Y.ID.LIST,@FM)

    IF Y.TXN.FLG EQ "CD" THEN
        Y.TXN.FLG = "C"
        GOSUB GET.TXNS
        Y.TXN.FLG = "D"
        GOSUB GET.TXNS
    END ELSE
        GOSUB GET.TXNS
    END

    Y.START.BAL = "-"

    R.DATA<-1> = "1*":Y.CUS.NAME:"*":Y.CCY.DESC:"*":Y.CCY.COD:"*":Y.START.BAL:"*":Y.DATA.OUT

RETURN

*********
GET.TXNS:
*********

    Y.CNT = Y.SEL.TXN

    Y.SEQ.NO = 1
    Y.STOP = "N"
    Y.CNT.D = 0
    Y.CNT.C = 0
    LOOP
    WHILE Y.STOP NE "Y"
        Y.TXN = ""
        Y.TXN = FIELD(Y.ID.LIST,@FM,Y.CNT)
        Y.STMT.NO = FIELD(Y.TXN,"*",2)
        CALL F.READ(FN.STMT.ENTRY,Y.STMT.NO,Y.STMT.ENTRY.REC,F.STMT.ENTRY,STMT.ENTRY.ERR)
        IF Y.STMT.ENTRY.REC THEN
            Y.AMOUNT = Y.STMT.ENTRY.REC<AC.STE.AMOUNT.LCY>
            IF Y.AMOUNT LT "0" THEN
                Y.TYPE = "DEBITO"
            END ELSE
                Y.TYPE = "CREDITO"
            END
            IF (Y.TXN.FLG EQ "D" AND Y.TYPE EQ "DEBITO") THEN
                GOSUB GET.REC
                Y.CNT.D += 1
                GOSUB CHK.CNTS
            END
            IF (Y.TXN.FLG EQ "C" AND Y.TYPE EQ "CREDITO") THEN
                GOSUB GET.REC
                Y.CNT.C += 1
                GOSUB CHK.CNTS
            END
        END
        Y.CNT -= 1
        IF Y.CNT LE 0 THEN
            Y.STOP = "Y"
        END
    REPEAT

RETURN

*********
CHK.CNTS:
*********

    IF Y.TXN.FLG EQ "D" AND Y.CNT.D EQ 5 THEN
        Y.STOP = "Y"
    END

    IF Y.TXN.FLG EQ "C" AND Y.CNT.C EQ 5 THEN
        Y.STOP = "Y"
    END

RETURN

********
GET.REC:
********

    Y.VALUE.DATE = Y.STMT.ENTRY.REC<AC.STE.VALUE.DATE>

    Y.TXN.CODE = Y.STMT.ENTRY.REC<AC.STE.TRANSACTION.CODE>
    R.TXN = ""; TXN.ERR = ""
    CALL CACHE.READ(FN.TRANSACTION, Y.TXN.CODE, R.TXN, TXN.ERR)
    IF R.TXN THEN
        Y.NARR = R.TXN<AC.TRA.NARRATIVE>
        IF LNGG EQ 1 THEN
            Y.DESC = FIELD(Y.NARR,@VM,1)
        END ELSE
            Y.DESC = FIELD(Y.NARR,@VM,2)
        END
    END

    Y.DOC.NO = Y.STMT.ENTRY.REC<AC.STE.TRANS.REFERENCE>
    Y.DATA.OUT := Y.VALUE.DATE:"/":Y.DESC:"/":Y.DOC.NO:"/":Y.AMOUNT:"/":Y.VALUE.DATE:"/":Y.SEQ.NO:"/":Y.USR.COD:"/":Y.TYPE:@VM
    Y.SEQ.NO += 1

RETURN

END
