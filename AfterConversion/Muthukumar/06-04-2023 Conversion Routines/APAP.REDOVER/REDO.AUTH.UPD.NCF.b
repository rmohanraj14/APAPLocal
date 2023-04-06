* @ValidationCode : MjotMTA4NTU5NTY4NjpDcDEyNTI6MTY4MDc3ODA1NDIwNzptdXRodTotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Apr 2023 16:17:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : muthu
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.AUTH.UPD.NCF
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : GANESH R
* Program Name  : REDO.V.FT.AUTH.UPD.NCF
* ODR NUMBER    : ODR-2009-10-0321
*-------------------------------------------------------------------------
* Description : This Auth routine is triggered when FT/TT transaction is Authorised
*--------------------------------------------------------------------------
*Modification History:
*----------------------------------------------------------------------------
* DATE            WHO                REFERENCE                   DESCRIPTION
* 05-05-2011    Sudharsanan S      PACS00189142                Initial Creation
* 06-04-2023	CONVERSION TOOL	   AUTO R22 CODE CONVERSION    FM to @FM, VM to @VM
* 06-04-2023	MUTHUKUMAR M	   MANUAL R22 CODE CONVERSION  NO CHANGE
*---------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.TELLER
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.L.NCF.STOCK
    $INSERT I_F.REDO.L.NCF.STATUS
    $INSERT I_F.REDO.L.NCF.UNMAPPED
    $INSERT I_F.REDO.NCF.ISSUED
    $INSERT I_F.REDO.TELLER.PROCESS


    GOSUB INIT
    GOSUB OPEN.FILES
    GOSUB CHECK.PRELIM.CONDITIONS
    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS
    END
RETURN
*----------------------------------------------------------------------------------
*******
INIT:
******
*Initialisation
    PROCESS.GOAHEAD = 1
    STOCK.ID='SYSTEM'
    MULTI.STMT = ''
    VAR.TXN.ID=''
    LRF.APP='FUNDS.TRANSFER':@FM:'TELLER'
    LRF.FIELD='L.NCF.REQUIRED':@VM:'L.NCF.NUMBER':@VM:'L.TT.TAX.CODE':@VM:'L.TT.WV.TAX':@VM:'L.TT.TAX.AMT':@VM:'L.NCF.TAX.NUM':@FM:'L.NCF.REQUIRED':@VM:'L.NCF.NUMBER':@VM:'L.TT.PROCESS':@VM:'L.TT.DOC.NUM':@VM:'L.TT.DOC.DESC'
    LRF.POS=''
RETURN
***********
OPEN.FILES:
***********
*Opening Files
    FN.REDO.L.NCF.UNMAPPED='F.REDO.L.NCF.UNMAPPED'
    F.REDO.L.NCF.UNMAPPED=''
    CALL OPF(FN.REDO.L.NCF.UNMAPPED,F.REDO.L.NCF.UNMAPPED)
    FN.REDO.NCF.ISSUED='F.REDO.NCF.ISSUED'
    F.REDO.NCF.ISSUED=''
    CALL OPF(FN.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED)
    FN.REDO.L.NCF.STATUS='F.REDO.L.NCF.STATUS'
    F.REDO.L.NCF.STATUS=''
    CALL OPF(FN.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS)
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    FN.REDO.TELLER.PROCESS = 'F.REDO.TELLER.PROCESS'
    F.REDO.TELLER.PROCESS = ''
    CALL OPF(FN.REDO.TELLER.PROCESS,F.REDO.TELLER.PROCESS)
RETURN
********
PROCESS:
********
*Checking for the values in the fields and Updating the Local Field
*Getting the local Field position
    CALL MULTI.GET.LOC.REF(LRF.APP,LRF.FIELD,LRF.POS)
    POS.FT.NCF.REQ = LRF.POS<1,1>
    POS.FT.NCF.NO  = LRF.POS<1,2>
    POS.L.TT.TAX.CODE= LRF.POS<1,3>
    POS.L.TT.WV.TAX  = LRF.POS<1,4>
    POS.L.TT.TAX.AMT = LRF.POS<1,5>
    POS.FT.NCF.NO.TAX= LRF.POS<1,6>
    POS.TT.NCF.REQ = LRF.POS<2,1>
    POS.TT.NCF.NO  = LRF.POS<2,2>
    POS.TT.PROCESS = LRF.POS<2,3>
    POS.DOC.NUM    = LRF.POS<2,4>
    POS.DOC.TYPE   = LRF.POS<2,5>
    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        GOSUB FT.PROCESS
    END ELSE
        GOSUB TT.PROCESS
    END
RETURN
*************
FT.PROCESS:
*************
*Checking for the Local Field
    VAL.DATE        = R.NEW(FT.CREDIT.VALUE.DATE)
    VAR.CHG.AMT=R.NEW(FT.CREDIT.AMOUNT)
    IF NOT(VAR.CHG.AMT) THEN
        VAR.CHG.AMT=R.NEW(FT.DEBIT.AMOUNT)
    END
    VAR.NCF.REQ=R.NEW(FT.LOCAL.REF)<1,POS.FT.NCF.REQ>
    VAR.TXN.TYPE=R.NEW(FT.TRANSACTION.TYPE)
    VAR.TXN.DATE=R.NEW(FT.DATE.TIME)
    VAR.DATE=20:VAR.TXN.DATE[1,6]
    VAR.CHG.CCY = R.NEW(FT.CREDIT.CURRENCY)
    CHARGE.AMOUNT=VAR.CHG.CCY:' ':VAR.CHG.AMT
    VAR.CUS = R.NEW(FT.DEBIT.CUSTOMER)
    VAR.ACCOUNT = R.NEW(FT.DEBIT.ACCT.NO)
    LOC.WAIVE.TAX=R.NEW(FT.LOCAL.REF)<1,POS.L.TT.WV.TAX>
    GOSUB CHECK.TAX.AMT
    Y.CNT=0
    IF VAR.NCF.REQ EQ 'YES' THEN
        IF VAR.CHG.AMT GT 0 AND VAR.CUS NE '' THEN
            Y.CNT+=1
        END
    END

    IF Y.TAX.AMT GT 0 AND LOC.WAIVE.TAX NE 'YES' AND VAR.NCF.REQ EQ 'YES' THEN
        Y.CNT+=1
    END

    IF Y.CNT THEN
        CALL REDO.NCF.PERF.RTN(Y.CNT,Y.NCF.NO.LIST)
    END

    GOSUB CHECK.PROCESS

    IF Y.TAX.AMT GT 0 AND LOC.WAIVE.TAX NE 'YES' AND VAR.NCF.REQ EQ 'YES' THEN
        GOSUB PROCESS.TAX
    END
RETURN
*************
TT.PROCESS:
*************
*Checking for the Local Field

    VAL.DATE        = R.NEW(TT.TE.VALUE.DATE.1)
    VAR.CHG.CCY =  LCCY
    VAR.CHG.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1>
    VAR.NCF.REQ=R.NEW(TT.TE.LOCAL.REF)<1,POS.TT.NCF.REQ>
    VAR.TXN.DATE=R.NEW(TT.TE.DATE.TIME)
    VAR.DATE=20:VAR.TXN.DATE[1,6]
    CHARGE.AMOUNT=VAR.CHG.CCY:' ':VAR.CHG.AMT
    TT.PROCESS.ID = R.NEW(TT.TE.LOCAL.REF)<1,POS.TT.PROCESS>
    CALL F.READ(FN.REDO.TELLER.PROCESS,TT.PROCESS.ID,R.TELL.PROCESS,F.REDO.TELLER.PROCESS,TELL.ERR)
    VAR.CUS = R.TELL.PROCESS<TEL.PRO.CLIENT.ID>
    IF NOT(VAR.CUS) THEN
        VAR.CUS     =R.NEW(TT.TE.LOCAL.REF)<1,POS.DOC.NUM>
        VAR.DOC.TYPE=R.NEW(TT.TE.LOCAL.REF)<1,POS.DOC.TYPE>
        Y.EXT.CUS=1
    END
    VAR.ACCOUNT = R.NEW(TT.TE.ACCOUNT.1)

    Y.CNT=0
    IF VAR.NCF.REQ EQ 'YES' THEN

        IF VAR.CHG.AMT GT 0 AND VAR.CUS NE '' THEN
            Y.CNT+=1
            CALL REDO.NCF.PERF.RTN(Y.CNT,Y.NCF.NO.LIST)
        END
    END

    GOSUB CHECK.PROCESS

RETURN
***************
CHECK.PROCESS:
****************
    TXN.ID = ID.NEW
    IF VAR.NCF.REQ EQ 'YES' THEN
        IF VAR.CHG.AMT GT 0 AND VAR.CUS NE '' THEN
            NCF.NUMBER=Y.NCF.NO.LIST<1>
            GOSUB PROCESS1
        END
    END ELSE
        GOSUB UPDATE.TABLE2
    END
RETURN
*********
PROCESS1:
*********
    IF NCF.NUMBER THEN
        GOSUB UPDATE.TABLE
    END ELSE
        GOSUB UPDATE.TABLE2
    END
RETURN
**************
UPDATE.TABLE:
**************
*Updating ISSUED and Status Table
    NCF.ISSUE.ID=VAR.CUS:'.':VAR.DATE:'.':TXN.ID
    CALL F.READ(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED,ISSUE.MSG)
    R.REDO.NCF.ISSUED<ST.IS.TXN.ID>=TXN.ID
    IF VAR.TXN.TYPE EQ 'AC85' THEN
        R.REDO.NCF.ISSUED<ST.IS.TAX.AMOUNT>=CHARGE.AMOUNT
    END ELSE
        R.REDO.NCF.ISSUED<ST.IS.CHARGE.AMOUNT>=CHARGE.AMOUNT
    END
    R.REDO.NCF.ISSUED<ST.IS.DATE> = VAR.DATE
    IF NOT(Y.EXT.CUS) THEN
        R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>=VAR.CUS
    END ELSE
        R.REDO.NCF.ISSUED<ST.IS.ID.TYPE>=VAR.DOC.TYPE
        R.REDO.NCF.ISSUED<ST.IS.ID.NUMBER>=VAR.CUS
    END
    R.REDO.NCF.ISSUED<ST.IS.ACCOUNT> = VAR.ACCOUNT
    NCF.CNT = DCOUNT(R.REDO.NCF.ISSUED<ST.IS.NCF>,@VM)
    R.REDO.NCF.ISSUED<ST.IS.NCF,NCF.CNT+1> = NCF.NUMBER
    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        R.NEW(FT.LOCAL.REF)<1,POS.FT.NCF.NO>=NCF.NUMBER
    END ELSE
        R.NEW(TT.TE.LOCAL.REF)<1,POS.TT.NCF.NO>=NCF.NUMBER
    END
    CALL F.WRITE(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED)
    CALL F.READ(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.MSG)
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>=ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>=VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>= VAR.DATE

    IF VAR.TXN.TYPE EQ 'AC85' THEN
        R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>=CHARGE.AMOUNT
    END ELSE
        R.REDO.L.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>=CHARGE.AMOUNT
    END
    NCF.ST.CNT = DCOUNT(R.REDO.L.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.REDO.L.NCF.STATUS<NCF.ST.NCF,NCF.ST.CNT+1>=NCF.NUMBER
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>='AVAILABLE'
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
RETURN
**************
UPDATE.TABLE2:
**************
*Updating UNMAPPED and Status Table
    NCF.ISSUE.ID=VAR.CUS:'.':VAR.DATE:'.':TXN.ID
    CALL F.READ(FN.REDO.L.NCF.UNMAPPED,NCF.ISSUE.ID,R.REDO.L.NCF.UNMAPPED,F.REDO.L.NCF.UNMAPPED,UNMAP.ERR)
    R.REDO.L.NCF.UNMAPPED<ST.UN.TXN.ID>=ID.NEW
    IF VAR.TXN.TYPE EQ 'AC85' THEN
        R.REDO.L.NCF.UNMAPPED<ST.UN.TAX.AMOUNT>=CHARGE.AMOUNT
    END ELSE
        R.REDO.L.NCF.UNMAPPED<ST.UN.CHARGE.AMOUNT>=CHARGE.AMOUNT
    END
    R.REDO.L.NCF.UNMAPPED<ST.UN.TXN.TYPE>=VAR.TXN.TYPE
    R.REDO.L.NCF.UNMAPPED<ST.UN.TAX.AMOUNT>=VAR.TAX.AMT
    R.REDO.L.NCF.UNMAPPED<ST.UN.DATE>=VAR.DATE

    IF NOT(Y.EXT.CUS) THEN
        R.REDO.L.NCF.UNMAPPED<ST.UN.CUSTOMER>=VAR.CUS
    END ELSE
        R.REDO.L.NCF.UNMAPPED<ST.UN.ID.TYPE>=VAR.DOC.TYPE
        R.REDO.L.NCF.UNMAPPED<ST.UN.ID.NUMBER>=VAR.CUS
    END
    R.REDO.L.NCF.UNMAPPED<ST.UN.ACCOUNT> = VAR.ACCOUNT
    R.REDO.L.NCF.UNMAPPED<ST.UN.BATCH>='NO'
    CALL F.WRITE(FN.REDO.L.NCF.UNMAPPED,NCF.ISSUE.ID,R.REDO.L.NCF.UNMAPPED)
    CALL F.READ(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.MSG)
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>=ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>=VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>=VAR.DATE
    IF VAR.TXN.TYPE EQ 'AC85' THEN
        R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>=CHARGE.AMOUNT
    END ELSE
        R.REDO.L.NCF.STATUS<NCF.ST.CHARGE.AMOUNT>=CHARGE.AMOUNT
    END
    R.REDO.L.NCF.STATUS<NCF.ST.NCF>=''
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>='UNAVAILABLE'
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
RETURN
*-----------
PROCESS.TAX:
*-----------
    L.NCF.NUMBER.TAX=Y.NCF.NO.LIST<2>
    IF L.NCF.NUMBER.TAX THEN
        GOSUB UPDATE.TABLE.TAX
    END ELSE
        GOSUB UPDATE.TABLE2
    END
RETURN
*-------------------------------------------------------------------
CHECK.TAX.AMT:
*-------------------------------------------------------------------
    FT.DR.CURRENCY  = R.NEW(FT.DEBIT.CURRENCY)
    TRANS.DR.AMT    = R.NEW(FT.DEBIT.AMOUNT)
    VAR.TAX.AMT     = ''
    VAR.TAX.AMT     = SUM(R.NEW(FT.LOCAL.REF)<1,POS.L.TT.TAX.AMT>)
    Y.TAX.AMT       = VAR.TAX.AMT
    IF VAR.TAX.AMT THEN
        VAR.TAX.AMT = FT.DR.CURRENCY:' ':VAR.TAX.AMT
    END ELSE
        VAR.TAX.AMT = '0.00'
    END
RETURN
*-------------------------------------------------------------------

*-----------------------
UPDATE.TABLE.TAX:
*-----------------------
    NCF.ISSUE.ID=VAR.CUS:'.':VAR.DATE:'.':TXN.ID
    CALL F.READ(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED,F.REDO.NCF.ISSUED,ISSUE.MSG)
    R.REDO.NCF.ISSUED<ST.IS.TXN.ID>=TXN.ID
    R.REDO.NCF.ISSUED<ST.IS.TAX.AMOUNT>=VAR.TAX.AMT
    R.REDO.NCF.ISSUED<ST.IS.DATE> = VAR.DATE
    R.REDO.NCF.ISSUED<ST.IS.CUSTOMER>=VAR.CUS
    R.REDO.NCF.ISSUED<ST.IS.ACCOUNT> = VAR.ACCOUNT
    NCF.CNT = DCOUNT(R.REDO.NCF.ISSUED<ST.IS.NCF>,@VM)
    R.REDO.NCF.ISSUED<ST.IS.NCF,NCF.CNT+1> = L.NCF.NUMBER.TAX
    R.NEW(FT.LOCAL.REF)<1,POS.FT.NCF.NO.TAX>=L.NCF.NUMBER.TAX
    CALL F.WRITE(FN.REDO.NCF.ISSUED,NCF.ISSUE.ID,R.REDO.NCF.ISSUED)
    CALL F.READ(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS,F.REDO.L.NCF.STATUS,STATUS.MSG)
    R.REDO.L.NCF.STATUS<NCF.ST.TRANSACTION.ID>=ID.NEW
    R.REDO.L.NCF.STATUS<NCF.ST.CUSTOMER.ID>=VAR.CUS
    R.REDO.L.NCF.STATUS<NCF.ST.DATE>= VAR.DATE
    R.REDO.L.NCF.STATUS<NCF.ST.TAX.AMOUNT>=VAR.TAX.AMT
    NCF.ST.CNT = DCOUNT(R.REDO.L.NCF.STATUS<NCF.ST.NCF>,@VM)
    R.REDO.L.NCF.STATUS<NCF.ST.NCF,NCF.ST.CNT+1>=L.NCF.NUMBER.TAX
    R.REDO.L.NCF.STATUS<NCF.ST.STATUS>='AVAILABLE'
    CALL F.WRITE(FN.REDO.L.NCF.STATUS,NCF.ISSUE.ID,R.REDO.L.NCF.STATUS)
RETURN
*-------------------------------------------------------------------
CHECK.PRELIM.CONDITIONS:
*-------------------------------------------------------------------
    IF APPLICATION EQ 'FUNDS.TRANSFER' THEN
        VAL.STATUS=R.NEW(FT.RECORD.STATUS)
    END ELSE
        VAL.STATUS=R.NEW(TT.TE.RECORD.STATUS)
    END

    IF VAL.STATUS[1,1] EQ 'R' THEN
        PROCESS.GOAHEAD = ""
    END

RETURN
END
