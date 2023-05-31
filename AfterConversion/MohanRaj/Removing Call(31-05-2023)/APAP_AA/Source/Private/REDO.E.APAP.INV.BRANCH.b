* @ValidationCode : MjoxNzEwNzQyNjpDcDEyNTI6MTY4NTUyOTk2OTEwNTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:16:09
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
$PACKAGE APAP.AA
SUBROUTINE REDO.E.APAP.INV.BRANCH(Y.OUT.ARRAY)
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
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION         CALL method format changed
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
    $INSERT I_F.REDO.ITEM.STOCK.BY.DATE
    $INSERT I_F.REDO.H.ITEM.DETAILS
    $INSERT I_F.REDO.H.MAIN.COMPANY
    $USING APAP.TAM

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

    FN.REDO.H.ORDER.DETAILS = 'F.REDO.H.ORDER.DETAILS'
    F.REDO.H.ORDER.DETAILS = ''
    CALL OPF(FN.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS)

    FN.REDO.H.MAIN.COMPANY = 'F.REDO.H.MAIN.COMPANY'
    F.REDO.H.MAIN.COMPANY = ''
    CALL OPF(FN.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY)

    FN.REDO.ITEM.STOCK.BY.DATE = 'F.REDO.ITEM.STOCK.BY.DATE'
    F.REDO.ITEM.STOCK.BY.DATE = ''
    CALL OPF(FN.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE)

    FN.REDO.H.ITEM.DETAILS = 'F.REDO.H.ITEM.DETAILS'
    F.REDO.H.ITEM.DETAILS = ''
*  CALL OPF(FN.REDO.H.ITEM.DETAILS,F.REDO.H.ITEM.DETAILS);*TUS (S/E)
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
    Y.DES.QNTY = 0     ; Y.PREV.QNTY = 0   ; Y.RETURN.QNTY = 0

    LOCATE "ITEM" IN D.FIELDS<1> SETTING Y.ITEM.POS  THEN
        Y.ITEM.VAL= D.RANGE.AND.VALUE<Y.ITEM.POS>
        Y.SEL.FLAG = '1'
    END

    LOCATE "BRANCH" IN D.FIELDS<1> SETTING Y.BRANCH.POS THEN
        Y.BRANCH.VAL= D.RANGE.AND.VALUE<Y.BRANCH.POS>
        Y.SEL.FLAG = '1'
    END

    LOCATE "DATE" IN D.FIELDS<1> SETTING Y.DATE.POS THEN
        Y.DATE.VAL = D.RANGE.AND.VALUE<Y.DATE.POS>
        Y.DATE.FLAG = '1'

    END

    LOCATE "CODE" IN D.FIELDS<1> SETTING Y.CODE.POS THEN
        Y.CODE.SEL = D.RANGE.AND.VALUE<Y.CODE.POS>
        Y.SEL.FLAG = '1'

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

    SEL.CMD.1 = 'SELECT ':FN.REDO.ITEM.STOCK.BY.DATE

    LOC.REF.APPLICATION="USER"
    LOC.REF.FIELDS= 'L.US.IDC.BR':@VM:'L.US.IDC.CODE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.BR.VAL =LOC.REF.POS<1,1>
    POS.DETP.VAL = LOC.REF.POS<1,2>

    Y.CODE.DEPT = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>

    IF Y.BRANCH.VAL THEN
        LOCATE Y.BRANCH.VAL IN Y.BRANCH.LIST<1,1,1> SETTING POS.BR THEN
            Y.CODE.DEPT = Y.DEPT.LIST<1,1,POS.BR>
        END
    END ELSE
        LOCATE ID.COMPANY IN Y.BRANCH.LIST<1,1,1> SETTING POS.BR THEN
            Y.CODE.DEPT = Y.DEPT.LIST<1,1,POS.BR>
        END
    END

    Y.BR.VAL = Y.BRANCH.VAL:"-":Y.CODE.DEPT
    IF Y.BRANCH.VAL AND Y.CODE.SEL THEN
        Y.BRANCH.VAL = Y.BRANCH.VAL:"-":Y.CODE.SEL
        SEL.CMD.1 := ' AND WITH @ID LIKE ':Y.BRANCH.VAL:"..."
    END
    IF Y.BRANCH.VAL AND NOT(Y.CODE.SEL) THEN
        SEL.CMD.1 := ' AND WITH @ID LIKE ':Y.BRANCH.VAL:"..."
    END
    IF NOT(Y.BRANCH.VAL) AND Y.CODE.SEL THEN
        SEL.CMD.1 := ' AND WITH @ID LIKE ...':Y.CODE.SEL:"..."
    END

    IF Y.ITEM.VAL THEN
        SEL.CMD.1 := ' AND WITH ITEM.CODE EQ ':Y.ITEM.VAL

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

        CALL F.READ(FN.REDO.ITEM.STOCK.BY.DATE,Y.ID,R.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE,Y.ERR)
        Y.ITEM = ''
        Y.ITEM.VAL.LIST = ''
        Y.DATA.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE>
        Y.BRANCH = FIELD(Y.ID,"-",1)
        CALL F.READ(FN.REDO.H.MAIN.COMPANY,Y.BRANCH,R.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY,Y.ERR.MAIN)
        Y.DESCRIPTION.MAIN = R.REDO.H.MAIN.COMPANY<REDO.COM.DESCRIPTION>
        Y.CODE.LIS.MAIN = R.REDO.H.MAIN.COMPANY<REDO.COM.CODE>
        Y.BRANCH.CODE =  FIELD(Y.ID,"-",2)
        Y.BRANCH.CODE = FIELD(Y.BRANCH.CODE,".",1)
        LOCATE Y.BRANCH.CODE IN Y.CODE.LIS.MAIN<1,1> SETTING POS.CODE THEN
            Y.BRANCH.DES = Y.DESCRIPTION.MAIN<1,POS.CODE>
        END
        Y.ITEM = FIELD(Y.ID,".",2)
        Y.ITEM.DESC = ''
        Y.REV.QTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.RECEIVED>
        Y.PREV.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.INITIAL.STOCK>
        Y.ASSIGN.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED>
        Y.RETURN.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.RETURN>
        Y.CANCEL.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.CANCELLED>
        Y.DES.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DESTORY>
        Y.AVABL.QNTY.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE>
        Y.AVABL.TRAN.LIST = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.TRANSFER>
        Y.ITEM.VAL.LIST = ''
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
            GOSUB SEL.AVB.SERIES
            IF Y.ITEM THEN
                GOSUB ASSIGN.PROCESS
            END
        END
        Y.CNT += 1 ;* R22 Auto Conversion
    REPEAT

RETURN
*--------------------------------------------------------------------------------------------------------
VALUE.ASSIGN:
*--------------------------------------------------------------------------------------------------------
    Y.BRANCH = FIELD(Y.ID,"-",1)
    Y.REV.QTY = Y.REV.QTY.LIST<1,Y.CNT>
    Y.PREV.QNTY = Y.PREV.QNTY.LIST<1,Y.CNT>
    Y.ASSIGN.QNTY = Y.ASSIGN.QNTY.LIST<1,Y.CNT>
    Y.CANCEL.QNTY = Y.CANCEL.QNTY.LIST<1,Y.CNT>
    Y.DES.QNTY = Y.DES.QNTY.LIST<1,Y.CNT>
    Y.AVABL.QNTY = Y.AVABL.QNTY.LIST<1,Y.CNT>
    Y.RETURN.QNTY = Y.RETURN.QNTY.LIST<1,Y.CNT>
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
SEL.AVB.SERIES:
*--------------------------------------------------------------------------------------------------------

    APAP.TAM.redoCheckApplication(Y.ITEM,APPL.NAME,APPL.PATH);* R22 Manual conversion
    DUP.APPL.NAME = APPL.NAME
    DUP.APPL.PATH = APPL.PATH
    IF DUP.APPL.NAME THEN
        CALL OPF(APPL.NAME,APPL.PATH)
    END

    GOSUB SELECT.PROCESS

RETURN
*--------------------------------------------------------------------------------------------------------
ASSIGN.PROCESS:
*--------------------------------------------------------------------------------------------------------

    GOSUB NULLIFY.VARAIBLES

    Y.ITEM.VAL.LIST = Y.ITEM
    Y.ITEM.VAL.LIST1 = Y.ITEM
    LOCATE Y.ITEM.VAL.LIST1 IN Y.ITEM.LIST.PARA<1,1> SETTING POS.PARA.LIST THEN
        Y.ITEM.DESC = Y.DES.LIST.PARA<1,POS.PARA.LIST>
    END
    IF Y.SERIES.LIST EQ '-' THEN
        Y.SERIES.LIST = ''
    END
    Y.FIN.QNTY = Y.AVABL.QNTY
    CHANGE @VM TO @FM IN Y.FIN.QNTY
    CHANGE @SM TO @FM IN Y.FIN.QNTY
    Y.LEN.FINAL = DCOUNT(Y.FIN.QNTY,@FM)
    Y.NUM.FIANL.QNTY = Y.FIN.QNTY<Y.LEN.FINAL>
    Y.NUM.FIANL.QNTY = Y.AVABL.QNTY

*                       1           2                 3             4             5               6                7                 8               9              10                 11                   12             13                 14                     15

    Y.OUT.ARRAY<-1> = Y.DATA:"*":Y.BRANCH:"*":Y.ITEM.VAL.LIST:"*":Y.ITEM.DESC:"*":Y.PREV.QNTY:"*":Y.REV.QTY:"*":Y.ASSIGN.QNTY:"*":Y.CANCEL.QNTY:"*":Y.DES.QNTY:"*":Y.AVABL.QNTY:"*":Y.SERIES.LIST:"*":Y.BRANCH.DES:'*':Y.RETURN.QNTY:"*":Y.AVABL.TRAN.LIST:"*":Y.NUM.FIANL.QNTY
    Y.SERIES.FROM = '' ; Y.PREV.QNTY = '' ; Y.REV.QTY = '' ;  Y.ASSIGN.QNTY = '' ; Y.CANCEL.QNTY = '' ; Y.DES.QNTY = '' ; Y.AVABL.QNTY = '' ; Y.RETURN.QNTY = '' ; Y.AVABL.TRAN.LIST = ''
    Y.SERIES.FROM1 = ''
    Y.SERIES.LIST = ''
    Y.SER1 = ''
    Y.SER = ''

RETURN
*--------------------------------------------------------------------------------------------------------
NULLIFY.VARAIBLES:
*--------------------------------------------------------------------------------------------------------
    IF NOT(Y.PREV.QNTY) THEN
        Y.PREV.QNTY = 0
    END
    IF NOT(Y.REV.QTY) THEN
        Y.REV.QTY = 0
    END
    IF NOT(Y.ASSIGN.QNTY) THEN
        Y.ASSIGN.QNTY = 0
    END
    IF NOT(Y.CANCEL.QNTY) THEN
        Y.CANCEL.QNTY = 0
    END
    IF NOT(Y.DES.QNTY) THEN
        Y.DES.QNTY = 0
    END
    IF NOT(Y.AVABL.QNTY) THEN
        Y.AVABL.QNTY = 0
    END
    IF NOT(Y.RETURN.QNTY) THEN
        Y.RETURN.QNTY = 0
    END
    IF NOT(Y.AVABL.TRAN.LIST) THEN
        Y.AVABL.TRAN.LIST = 0
    END
RETURN

*-------------------------------------------------------------------------
SELECT.PROCESS:
*-------------------------------------------------------------------------

    Y.BRANCH = FIELD(Y.ID,"-",1)
    Y.DEPT.WHOLE = FIELD(Y.ID,"-",2)
    Y.DEPT = FIELD(Y.DEPT.WHOLE,".",1)
    Y.ITEM.VALUE = FIELD(Y.ID,".",2)
    Y.BRANCH = FIELD(Y.BRANCH,".",1)
    SEL.LIST.1 = '' ; Y.DEPOSIT.FLAG = '' ; Y.DRAFT.FLAG = '' ; Y.CHEQU.FLAG = '' ; Y.PASSBOOK.FLAG = ''
    BEGIN CASE
        CASE DUP.APPL.NAME EQ 'F.REDO.H.DEPOSIT.RECEIPTS'
            IF Y.DEPT THEN
                SEL.CMD.1 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ': ' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH CATEGORY EQ ":Y.DEPT:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END ELSE
                SEL.CMD.1 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ': ' AND WITH BRANCH.DEPT EQ ':Y.BRANCH: " AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END
            CALL EB.READLIST(SEL.CMD.1,SEL.LIST.1,'',NO.OF.RECS,DEP.ERR)
            GOSUB DEPOSIT.RECEIPTS

        CASE DUP.APPL.NAME EQ 'F.REDO.H.BANK.DRAFTS'
            IF Y.DEPT THEN
                SEL.CMD.2 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ':' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH CODE EQ ":Y.DEPT:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END ELSE
                SEL.CMD.2 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ': ' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END
            CALL EB.READLIST(SEL.CMD.2,SEL.LIST.1,'',NO.OF.RECS,DEP.ERR)
            Y.DRAFT.FLAG = '1'
            GOSUB BANK.DRAFTS

        CASE DUP.APPL.NAME EQ 'F.REDO.H.ADMIN.CHEQUES'
            IF Y.DEPT THEN
                SEL.CMD.3 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ':' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH CODE EQ ":Y.DEPT:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END ELSE
                SEL.CMD.3 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ': ' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END
            CALL EB.READLIST(SEL.CMD.3,SEL.LIST.1,'',NO.OF.RECS,DEP.ERR)
            Y.CHEQU.FLAG ='1'
            GOSUB ADMIN.CHEQUES

        CASE DUP.APPL.NAME EQ 'F.REDO.H.PASSBOOK.INVENTORY'
            IF Y.DEPT THEN
                SEL.CMD.4 = 'SSELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ':' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH CODE EQ ":Y.DEPT:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END ELSE
                SEL.CMD.4 = 'SELECT ':APPL.NAME:' WITH ITEM.CODE EQ ':Y.ITEM.VALUE: ' AND STATUS EQ AVAILABLE ': ' AND WITH BRANCH.DEPT EQ ':Y.BRANCH:" AND WITH DATE.UPDATED EQ ":Y.DATA:" BY SERIAL.NO "
            END
            CALL EB.READLIST(SEL.CMD.4,SEL.LIST.1,'',NO.OF.RECS,DEP.ERR)
            Y.PASSBOOK.FLAG = '1'
            GOSUB PASSBOOK.INVENTORY

    END CASE
RETURN
*-------------------------------------------------------------------------
PASSBOOK.INVENTORY:
*-------------------------------------------------------------------------

    LOOP
        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.SER = R.REC<REDO.PASS.SERIAL.NO>
        Y.SER = FMT(Y.SER,'R#10')
        Y.SER1<-1> = Y.SER:"*":Y.INV.ID
    REPEAT

    SEL.LIST.1 = SORT(Y.SER1)
    LOOP
        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        Y.INV.ID = FIELD(Y.INV.ID,'*',2)
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)

        Y.DATE.INV = R.REC<REDO.PASS.DATE.UPDATED>
        Y.SER.VAL = R.REC<REDO.PASS.SERIAL.NO>
        Y.SER.CNT = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.PREV = Y.SERIES.FROM1<Y.SER.CNT>
        Y.PREV1 = Y.PREV + 1
        IF Y.PREV AND Y.SER.VAL NE Y.PREV1 THEN

            Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.PREV
            Y.SERIES.FROM1 = ''
        END
        Y.SERIES.FROM1<-1> = R.REC<REDO.PASS.SERIAL.NO>
        Y.SERIES.FROM<-1> = R.REC<REDO.PASS.SERIAL.NO>

    REPEAT

    IF NOT(Y.SERIES.LIST) THEN
        Y.COUNT.SER.VAL = DCOUNT(Y.SERIES.FROM,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM<1>:"-":Y.SERIES.FROM<Y.COUNT.SER.VAL>
    END ELSE
        Y.COUNT.SER.VAL1 = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.SERIES.FROM1<Y.COUNT.SER.VAL1>
    END
RETURN
*-------------------------------------------------------------------------
ADMIN.CHEQUES:
*-------------------------------------------------------------------------
    LOOP

        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.SER = R.REC<REDO.ADMIN.SERIAL.NO>
        Y.SER = FMT(Y.SER,'R#10')
        Y.SER1<-1> = Y.SER:"*":Y.INV.ID
    REPEAT

    SEL.LIST.1 = SORT(Y.SER1)
    LOOP
        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        Y.INV.ID = FIELD(Y.INV.ID,'*',2)
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.DATE.INV = R.REC<REDO.ADMIN.DATE.UPDATED>
        Y.SER.VAL = R.REC<REDO.ADMIN.SERIAL.NO>
        Y.SER.CNT = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.PREV = Y.SERIES.FROM1<Y.SER.CNT>
        Y.PREV1 = Y.PREV + 1
        IF Y.PREV AND Y.SER.VAL NE Y.PREV1 THEN

            Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.PREV
            Y.SERIES.FROM1 = ''
        END
        Y.SERIES.FROM1<-1> = R.REC<REDO.ADMIN.SERIAL.NO>
        Y.SERIES.FROM<-1> = R.REC<REDO.ADMIN.SERIAL.NO>

    REPEAT

    IF NOT(Y.SERIES.LIST) THEN
        Y.COUNT.SER.VAL = DCOUNT(Y.SERIES.FROM,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM<1>:"-":Y.SERIES.FROM<Y.COUNT.SER.VAL>
    END ELSE
        Y.COUNT.SER.VAL1 = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.SERIES.FROM1<Y.COUNT.SER.VAL1>
    END
RETURN

*-------------------------------------------------------------------------
BANK.DRAFTS:
*-------------------------------------------------------------------------
    LOOP

        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.SER = R.REC<REDO.BANK.SERIAL.NO>
        Y.SER = FMT(Y.SER,'R#10')
        Y.SER1<-1> = Y.SER:"*":Y.INV.ID
    REPEAT

    SEL.LIST.1 = SORT(Y.SER1)
    LOOP
        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        Y.INV.ID = FIELD(Y.INV.ID,'*',2)
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.DATE.INV = R.REC<REDO.BANK.DATE.UPDATED>
        Y.SER.VAL = R.REC<REDO.BANK.SERIAL.NO>
        Y.SER.CNT = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.PREV = Y.SERIES.FROM1<Y.SER.CNT>
        Y.PREV1 = Y.PREV + 1
        IF Y.PREV AND Y.SER.VAL NE Y.PREV1 THEN

            Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.PREV
            Y.SERIES.FROM1 = ''
        END
        Y.SERIES.FROM1<-1> = R.REC<REDO.BANK.SERIAL.NO>
        Y.SERIES.FROM<-1> = R.REC<REDO.BANK.SERIAL.NO>
    REPEAT
    IF NOT(Y.SERIES.LIST) THEN
        Y.COUNT.SER.VAL = DCOUNT(Y.SERIES.FROM,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM<1>:"-":Y.SERIES.FROM<Y.COUNT.SER.VAL>
    END ELSE
        Y.COUNT.SER.VAL1 = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.SERIES.FROM1<Y.COUNT.SER.VAL1>
    END
RETURN

*-------------------------------------------------------------------------
DEPOSIT.RECEIPTS:
*-------------------------------------------------------------------------
    LOOP

        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.SER = R.REC<REDO.DEP.SERIAL.NO>
        Y.SER = FMT(Y.SER,'R#10')
        Y.SER1<-1> = Y.SER:"*":Y.INV.ID
    REPEAT

    SEL.LIST.1 = SORT(Y.SER1)
    LOOP
        REMOVE Y.INV.ID FROM SEL.LIST.1 SETTING POS.INV
    WHILE Y.INV.ID:POS.INV
        Y.INV.ID = FIELD(Y.INV.ID,'*',2)
        CALL F.READ(APPL.NAME,Y.INV.ID,R.REC,APPL.PATH,Y.ERR.FILE)
        Y.DATE.INV = R.REC<REDO.DEP.DATE.UPDATED>
        Y.SER.VAL = R.REC<REDO.DEP.SERIAL.NO>
        Y.SER.CNT = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.PREV = Y.SERIES.FROM1<Y.SER.CNT>
        Y.PREV1 = Y.PREV + 1
        IF Y.PREV AND Y.SER.VAL NE Y.PREV1 THEN

            Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.PREV
            Y.SERIES.FROM1 = ''
        END
        Y.SERIES.FROM1<-1> = R.REC<REDO.DEP.SERIAL.NO>
        Y.SERIES.FROM<-1> = R.REC<REDO.DEP.SERIAL.NO>
    REPEAT

    IF NOT(Y.SERIES.LIST) THEN
        Y.COUNT.SER.VAL = DCOUNT(Y.SERIES.FROM,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM<1>:"-":Y.SERIES.FROM<Y.COUNT.SER.VAL>
    END ELSE
        Y.COUNT.SER.VAL1 = DCOUNT(Y.SERIES.FROM1,@FM)
        Y.SERIES.LIST<1,-1> = Y.SERIES.FROM1<1>:"-":Y.SERIES.FROM1<Y.COUNT.SER.VAL1>
    END
RETURN

END
