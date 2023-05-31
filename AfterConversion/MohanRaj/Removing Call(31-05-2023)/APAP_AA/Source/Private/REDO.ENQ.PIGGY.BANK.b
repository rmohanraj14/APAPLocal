* @ValidationCode : MjoyMTI3MzE5NjE3OkNwMTI1MjoxNjgwMTg0NjczMjUwOklUU1M6LTE6LTE6OTMwOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:53
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 930
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.ENQ.PIGGY.BANK(Y.OUT.ARRAY)
*--------------------------------------------------------------------------------------------------------
*Company   Name    : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
*Developed By      : T.Jeeva, Temenos Application Management
*Program   Name    : REDO.E.APAP.INV.BRANCH
*ODR Reference     : ODR-2010-03-0183
*--------------------------------------------------------------------------------------------------------
*Description  :
*In Parameter : Y.PROCESSED.IDS
*Out Parameter: Y.OUT.ARRAY
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES
*--------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.USER
    $INSERT I_F.REDO.ITEM.STOCK
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_F.REDO.H.DEPOSIT.RECEIPTS
    $INSERT I_F.REDO.H.PASSBOOK.INVENTORY
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.H.BANK.DRAFTS
    $INSERT I_F.REDO.H.REASSIGNMENT
    $INSERT I_F.REDO.PIGGY.STOCK.BY.DATE
    $INSERT I_F.REDO.H.ITEM.DETAILS
    $INSERT I_F.REDO.H.MAIN.COMPANY
    $INSERT I_F.REDO.TELLER.PROCESS
*--------------------------------------------------------------------------------------------------------
MAIN.PARA:
*--------------------------------------------------------------------------------------------------------

    GOSUB OPEN.PARA
    GOSUB SEL.CMD
    GOSUB PROCESS

RETURN
*--------------------------------------------------------------------------------------------------------
OPEN.PARA:
*--------------------------------------------------------------------------------------------------------
    Y.DATA.LIST1 = '' ;Y.STATUS.VAL = '' ; Y.DEP.VAL = '' ; Y.BR.VAL = ''
    FN.REDO.H.ORDER.DETAILS = 'F.REDO.H.ORDER.DETAILS'
    F.REDO.H.ORDER.DETAILS = ''
    CALL OPF(FN.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS)

    FN.REDO.PIGGY.STOCK.BY.DATE = 'F.REDO.PIGGY.STOCK.BY.DATE'
    F.REDO.PIGGY.STOCK.BY.DATE = ''
    CALL OPF(FN.REDO.PIGGY.STOCK.BY.DATE,F.REDO.PIGGY.STOCK.BY.DATE)

    FN.REDO.H.MAIN.COMPANY = 'F.REDO.H.MAIN.COMPANY'
    F.REDO.H.MAIN.COMPANY = ''
    CALL OPF(FN.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY)

    FN.REDO.TELLER.PROCESS = 'F.REDO.TELLER.PROCESS'
    F.REDO.TELLER.PROCESS = ''
    CALL OPF(FN.REDO.TELLER.PROCESS,F.REDO.TELLER.PROCESS)

    FN.REDO.H.ITEM.DETAILS = 'F.REDO.H.ITEM.DETAILS'
    F.REDO.H.ITEM.DETAILS = ''
    CALL OPF(FN.REDO.H.ITEM.DETAILS,F.REDO.H.ITEM.DETAILS)

    CALL CACHE.READ(FN.REDO.H.ITEM.DETAILS,'SYSTEM',R.REDO.H.ITEM.DETAILS,Y.ITEM.ERR)

    Y.ITEM.LIST.PARA = R.REDO.H.ITEM.DETAILS<IT.DT.SUPPLY.CODE>
    Y.DES.LIST.PARA = R.REDO.H.ITEM.DETAILS<IT.DT.DESCRIPTION>

    FN.REDO.H.REASSIGNMENT = 'F.REDO.H.REASSIGNMENT'
    F.REDO.H.REASSIGNMENT = ''
    CALL OPF(FN.REDO.H.REASSIGNMENT,F.REDO.H.REASSIGNMENT)

    FN.REDO.H.PASSBOOK.INVENTORY = 'F.REDO.H.PASSBOOK.INVENTORY'
    F.REDO.H.PASSBOOK.INVENTORY= ''
    CALL OPF(FN.REDO.H.PASSBOOK.INVENTORY,F.REDO.H.PASSBOOK.INVENTORY)

    Y.ITEM.VAL = ''    ; Y.BRANCH.VAL = '' ; Y.DATE.VAL = ''
    Y.SEL.FLAG = ''    ; Y.ASSIGN.QNTY = 0 ; Y.CANCEL.QNTY = 0
    Y.DES.QNTY = 0     ; Y.PREV.QNTY = 0

    LOCATE "ITEM" IN D.FIELDS<1> SETTING Y.ITEM.POS  THEN
        Y.ITEM.VAL= D.RANGE.AND.VALUE<Y.ITEM.POS>
        Y.SEL.FLAG = '1'
    END

    LOCATE "STATUS" IN D.FIELDS<1> SETTING Y.BRANCH.POS THEN
        Y.STATUS.VAL = D.RANGE.AND.VALUE<Y.BRANCH.POS>
        Y.SEL.FLAG = '1'
    END

    LOCATE "DATE" IN D.FIELDS<1> SETTING Y.DATE.POS THEN
        Y.DATE.VAL = D.RANGE.AND.VALUE<Y.DATE.POS>
        Y.SEL.FLAG = '1'
        Y.DATE.FLAG = '1'

    END

    LOCATE "BRANCH" IN D.FIELDS<1> SETTING Y.BR.POS THEN
        Y.BR.VAL = D.RANGE.AND.VALUE<Y.BR.POS>
        Y.SEL.FLAG = '1'
        Y.DATE.FLAG = '1'

    END

    LOCATE "DEPT" IN D.FIELDS<1> SETTING Y.DEP.POS THEN
        Y.DEP.VAL = D.RANGE.AND.VALUE<Y.DEP.POS>
        Y.SEL.FLAG = '1'
        Y.DATE.FLAG = '1'

    END
    Y.DATE.VAL.FROM = FIELD(Y.DATE.VAL,@SM,1)
    Y.DATE.VAL.TO =   FIELD(Y.DATE.VAL,@SM,2)
    IF Y.DATE.VAL.FROM AND Y.DATE.VAL.TO THEN
        IF NOT(NUM(Y.DATE.VAL.FROM)) OR LEN(Y.DATE.VAL.FROM) NE '8' OR NOT(NUM(Y.DATE.VAL.TO)) OR LEN(Y.DATE.VAL.TO) NE '8' THEN
            ENQ.ERROR = 'EB-REDO.DATE.RANGE'
            RETURN
        END

        IF Y.DATE.VAL.FROM[5,2] GT 12 OR Y.DATE.VAL.TO[5,2] GT 12 OR Y.DATE.VAL.FROM[7,2] GT 31 OR Y.DATE.VAL.TO[7,2] GT 31 THEN
            ENQ.ERROR = 'EB-REDO.DATE.RANGE'
            RETURN
        END

        IF Y.DATE.VAL.TO GT TODAY OR Y.DATE.VAL.FROM GT TODAY OR Y.DATE.VAL.FROM GT Y.DATE.VAL.TO THEN
            ENQ.ERROR = 'EB-REDO.GT.TODAY'
            RETURN
        END
    END
RETURN

*--------------------------------------------------------------------------------------------------------
SEL.CMD:
*--------------------------------------------------------------------------------------------------------
    IF Y.DEP.VAL THEN
        SEL.CMD.1 = 'SELECT ':FN.REDO.PIGGY.STOCK.BY.DATE: ' WITH @ID LIKE ...':Y.DEP.VAL
    END ELSE
        SEL.CMD.1 = 'SELECT ':FN.REDO.PIGGY.STOCK.BY.DATE
    END

    LOC.REF.APPLICATION="USER"
    LOC.REF.FIELDS= 'L.US.IDC.BR':@VM:'L.US.IDC.CODE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.BR.VAL =LOC.REF.POS<1,1>
    POS.DETP.VAL = LOC.REF.POS<1,2>

    Y.CODE.DEPT = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>

    IF Y.ITEM.VAL THEN
        SEL.CMD.1 := ' AND WITH ITEM.CODE EQ ':Y.ITEM.VAL

    END
    IF Y.STATUS.VAL THEN
        SEL.CMD.1 := ' AND WITH STATUS EQ ':Y.STATUS.VAL
    END
    IF Y.BR.VAL THEN
        SEL.CMD.1 := ' AND WITH BRANCH EQ ':Y.BR.VAL
    END

    IF NOT(Y.SEL.FLAG) THEN
        IF Y.CODE.DEPT THEN
            Y.BR.VAL1 = ID.COMPANY:"-":Y.CODE.DEPT
            SEL.CMD.1 := ' AND WITH @ID LIKE ':Y.BR.VAL1:'...'
        END ELSE
            SEL.CMD.1 := ' AND WITH @ID LIKE ':ID.COMPANY:'...'
        END
    END
RETURN

*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------

    CALL EB.READLIST(SEL.CMD.1,SEL.LIST,'',NO.OF.REC,SEL.ERR)
    LOOP
        REMOVE Y.ID FROM SEL.LIST SETTING Y.POS
    WHILE Y.ID:Y.POS
        CALL F.READ(FN.REDO.PIGGY.STOCK.BY.DATE,Y.ID,R.REDO.PIGGY.STOCK.BY.DATE,F.REDO.PIGGY.STOCK.BY.DATE,Y.ERR)
        Y.ITEM.VAL.LIST = ''
        Y.DATA.LIST = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.DATE>
        GOSUB DATE.BASED.GROUP
    REPEAT
RETURN
*--------------------------------------------------------------------------------------------------------
DATE.BASED.GROUP:
*--------------------------------------------------------------------------------------------------------
    Y.COUNT = DCOUNT(Y.DATA.LIST,@VM)
    Y.CNT = 1
    LOOP

    WHILE Y.CNT LE Y.COUNT
        Y.FLAG.DATE = '' ; Y.FLAG.DATE1 = ''
        Y.DATA = Y.DATA.LIST<1,Y.CNT>
        GOSUB DATE.CHECK.VAL
        IF NOT(Y.FLAG.DATE) AND NOT(Y.FLAG.DATE1) THEN
            GOSUB VALUE.ASSIGN
            GOSUB ASSIGN.PROCESS
        END
        Y.CNT += 1
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
VALUE.ASSIGN:
*--------------------------------------------------------------------------------------------------------
    Y.BRANCH.DES = ''
    Y.DATA = Y.DATA.LIST<1,Y.CNT>
    Y.BRANCH.CODE = FIELD(Y.ID,"-",2)
    Y.BRANCH = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.BRANCH,Y.CNT>

    CALL F.READ(FN.REDO.H.MAIN.COMPANY,Y.BRANCH,R.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY,Y.ERR.MAIN)
    Y.DESCRIPTION.MAIN = R.REDO.H.MAIN.COMPANY<REDO.COM.DESCRIPTION>
    Y.CODE.LIS.MAIN = R.REDO.H.MAIN.COMPANY<REDO.COM.CODE>
    LOCATE Y.BRANCH.CODE IN Y.CODE.LIS.MAIN<1,1> SETTING POS.CODE THEN
        Y.BRANCH.DES = Y.DESCRIPTION.MAIN<1,POS.CODE>
    END
    Y.ITEM = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.ITEM.CODE,Y.CNT>
    LOCATE Y.ITEM IN Y.ITEM.LIST.PARA<1,1> SETTING POS.ITEM THEN
        Y.STATUS =   Y.DES.LIST.PARA<1,POS.ITEM>
    END
    Y.AMOUNT = ''   ; Y.FALD = ''
    Y.TXN.ID = ''
    Y.STATUS = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.STATUS,Y.CNT>
    Y.ACCOUNT =R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.ACCOUNT,Y.CNT>
    Y.PAYMENT = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.PAYMENT,Y.CNT>
    Y.AMOUNT = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.AMT,Y.CNT>
    Y.TXN.ID = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.TRANS.REF,Y.CNT>
    GOSUB GET.QNTY.FROM.TXN
    Y.AMOUNT.VAL = Y.AMOUNT
    Y.FALD =   R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.TRANS.REF,Y.CNT>
    Y.QNTY = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.QNTY,Y.CNT>
    Y.INPUT = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.INPUT,Y.CNT>
    Y.AUTH = R.REDO.PIGGY.STOCK.BY.DATE<PIGGY.RPT.AUTH,Y.CNT>
    CHANGE '.' TO '' IN Y.AMOUNT
    CHANGE '0' TO '' IN Y.AMOUNT
    IF NOT(Y.AMOUNT) AND Y.FALD THEN
        Y.PAYMENT = 'WAIVED'
    END
RETURN
*--------------------------------------------------------------------------------------------------------
GET.QNTY.FROM.TXN:
*--------------------------------------------------------------------------------------------------------
    Y.QUANTITY.VAL = ''
    CALL F.READ(FN.REDO.TELLER.PROCESS,Y.TXN.ID,R.REDO.TELLER.PROCESS,F.REDO.TELLER.PROCESS,Y.ERR.TXN)
    IF R.REDO.TELLER.PROCESS THEN
        Y.QUANTITY.VAL = R.REDO.TELLER.PROCESS<TEL.PRO.QUANTITY>
    END
RETURN
*--------------------------------------------------------------------------------------------------------
DATE.CHECK.VAL:
*--------------------------------------------------------------------------------------------------------
    IF Y.DATE.VAL.FROM AND Y.DATE.VAL.FROM GT Y.DATA THEN
        Y.FLAG.DATE ='1'
    END
    IF Y.DATE.VAL.TO AND Y.DATE.VAL.TO LT Y.DATA THEN
        Y.FLAG.DATE1  = '1'
    END
RETURN
*--------------------------------------------------------------------------------------------------------
ASSIGN.PROCESS:
*--------------------------------------------------------------------------------------------------------
    Y.ERR.FLAG = ''
    GOSUB NULLIFY.VARAIBLES
    IF Y.DATE.VAL AND Y.DATE.VAL NE Y.DATA THEN
        Y.ERR.FLAG = '1'
    END
    IF Y.STATUS.VAL AND Y.STATUS.VAL NE Y.STATUS THEN
        Y.ERR.FLAG = '1'
    END

*                           1           2           3             4             5            6          7           8            9              10                   11
    IF NOT(Y.ERR.FLAG) THEN
        Y.OUT.ARRAY<-1> = Y.DATA:"*":Y.BRANCH:"*":Y.STATUS:"*":Y.ACCOUNT:"*":Y.PAYMENT:"*":Y.QNTY:"*":Y.INPUT:"*":Y.AUTH:"*":Y.BRANCH.DES:"*":Y.AMOUNT.VAL:"*":Y.QUANTITY.VAL
    END
    Y.SERIES.FROM = ''
    Y.SERIES.FROM1 = ''
    Y.SERIES.LIST = ''
    Y.BRANCH.DES = ''
    Y.ERR.FLAG = ''

RETURN
*--------------------------------------------------------------------------------------------------------
NULLIFY.VARAIBLES:
*--------------------------------------------------------------------------------------------------------
    IF NOT(Y.QNTY) THEN
        Y.QNTY = 0
    END
RETURN
*--------------------------------------------------------------------------------------------------------
END
