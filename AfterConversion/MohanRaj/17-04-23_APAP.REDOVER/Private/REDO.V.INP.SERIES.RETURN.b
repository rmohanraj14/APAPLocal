* @ValidationCode : MjotMTQwMzk2MDAwNTpDcDEyNTI6MTY4MTczNTkxNDY1NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 17 Apr 2023 18:21:54
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
SUBROUTINE REDO.V.INP.SERIES.RETURN
*----------------------------------------------------------------------------
* Description:
* This routine will be attached to the version REDO.ORDER.DETAIL,ORDER.DELEVIRY as
* a input routine
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.INP.SERIES.CHECK
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 12.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion    TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR,SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.COMPANY
    $INSERT I_F.USER
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_F.REDO.H.BANK.DRAFTS
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.ITEM.STOCK.BY.DATE
    $INSERT I_F.REDO.H.PASSBOOK.INVENTORY
    $INSERT I_F.REDO.H.DEPOSIT.RECEIPTS
    $INSERT I_F.REDO.ITEM.STOCK
    $INSERT I_F.REDO.H.PIGGY.BANKS
    $INSERT I_F.REDO.H.MAIN.COMPANY
*-----------------------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES

    GOSUB PROCESS
    IF NOT(Y.ERROR.CMP.FLAG) THEN
        AF = RE.ORD.BRANCH.DES
        ETEXT = 'AC-INVALID.DEPARTMENT.CODE'
        CALL STORE.END.ERROR
        RETURN
    END


    GOSUB PROGRAM.END
*-----------------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------------
    Y.TOTAL.VAL = 0
    Y.DIFF = 0

RETURN
*-----------------------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------------------
    Y.OFS.VAL = OFS$OPERATION
    FN.REDO.H.ORDER.DETAILS = 'F.REDO.H.ORDER.DETAILS'
    F.REDO.H.ORDER.DETAILS = ''
    CALL OPF(FN.REDO.H.ORDER.DETAILS,F.REDO.H.ORDER.DETAILS)
    FN.REDO.H.DEPOSIT.RECEIPTS = 'F.REDO.H.DEPOSIT.RECEIPTS'
    F.REDO.H.DEPOSIT.RECEIPTS = ''
    FN.REDO.H.ADMIN.CHEQUES = 'F.REDO.H.ADMIN.CHEQUES'
    F.REDO.H.ADMIN.CHEQUES = ''
    FN.REDO.H.BANK.DRAFTS = 'F.REDO.H.BANK.DRAFTS'
    F.REDO.H.BANK.DRAFTS = ''
    FN.REDO.H.PASSBOOK.INVENTORY = 'F.REDO.H.PASSBOOK.INVENTORY'
    F.REDO.H.PASSBOOK.INVENTORY = ''
    FN.REDO.ITEM.STOCK = 'F.REDO.ITEM.STOCK'
    F.REDO.ITEM.STOCK = ''
    FN.REDO.ITEM.STOCK.BY.DATE = 'F.REDO.ITEM.STOCK.BY.DATE'
    F.REDO.ITEM.STOCK.BY.DATE = ''
    FN.REDO.H.PIGGY.BANKS = 'F.REDO.H.PIGGY.BANKS'
    F.REDO.H.PIGGY.BANKS = ''
    CALL OPF(FN.REDO.H.PIGGY.BANKS,F.REDO.H.PIGGY.BANKS)

    FN.REDO.H.MAIN.COMPANY = 'F.REDO.H.MAIN.COMPANY'
    F.REDO.H.MAIN.COMPANY = ''
    CALL OPF(FN.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY)

    CALL OPF(FN.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK)
    CALL OPF(FN.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE)

    Y.INV.MNT.ID = R.NEW(RE.ORD.ITEM.CODE)
    Y.SEQ.FROM = R.NEW(RE.ORD.SERIES.FROM)
    Y.SEQ.TO = R.NEW(RE.ORD.SERIES.TO)
    Y.REQ.COMP = R.NEW(RE.ORD.REQUEST.COMPANY)
    Y.DEL.QUL =  R.NEW(RE.ORD.RETURN.QUANTITY)
    INPUTTER = R.NEW(RE.ORD.INPUTTER)
    IF NOT(INPUTTER) THEN
        INPUTTER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    END
    AUTHORISER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    R.NEW(RE.ORD.ORDER.STATUS) = 'Orden Devuelta'

    FN.REDO.ITEM.SERIES = 'F.REDO.ITEM.SERIES'
    F.REDO.ITEM.SERIES  = ''
    CALL OPF(FN.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES)
    CALL APAP.TAM.REDO.CHECK.APPLICATION(Y.INV.MNT.ID,APPL.NAME,APPL.PATH) ;* R22 Manual Conversion - CALL method format modified
    DUP.APPL.NAME = APPL.NAME
    DUP.APPL.PATH = APPL.PATH

    CALL OPF(APPL.NAME,APPL.PATH)
    LOC.REF.APPLICATION="USER"
    LOC.REF.FIELDS='L.US.IDC.BR':@VM:'L.US.IDC.CODE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.BR.VAL =LOC.REF.POS<1,1>
    POS.DETP.VAL = LOC.REF.POS<1,2>
    Y.CODE.DEPT = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>
    CHANGE @SM TO @FM IN Y.BRANCH.LIST
    CHANGE @VM TO @FM IN Y.BRANCH.LIST
    CHANGE @SM TO @FM IN Y.DEPT.LIST
    CHANGE @VM TO @FM IN Y.DEPT.LIST

    Y.FLAG.ERROR = ''
    Y.ERROR.CMP.FLAG = ''
    Y.CODE.VAL = R.NEW(RE.ORD.BRANCH.CODE)
    Y.CNT = 1
    Y.COUNT = DCOUNT(Y.BRANCH.LIST,@FM)

    LOCATE ID.COMPANY IN Y.BRANCH.LIST SETTING POS.BR ELSE
        Y.ERROR.CMP.FLAG = ''
        RETURN
    END

    LOOP
    WHILE Y.CNT LE Y.COUNT
        IF ID.COMPANY EQ Y.BRANCH.LIST<Y.CNT> AND Y.CODE.VAL EQ Y.DEPT.LIST<Y.CNT> THEN
            Y.ERROR.CMP.FLAG = '1'
        END
        Y.CNT += 1 ;*R22 Auto code conversion
    REPEAT

RETURN
*-----------------------------------------------------------------------------------------
PIGGY.INV.STOCK:
*-----------------------------------------------------------------------------------------
    IF R.NEW(RE.ORD.BRANCH.CODE) THEN
        Y.ITEM.STOCK.ID = ID.COMPANY:'-':R.NEW(RE.ORD.BRANCH.CODE)
    END ELSE
        Y.ITEM.STOCK.ID = ID.COMPANY
    END
    CALL F.READ(FN.REDO.ITEM.STOCK,Y.ITEM.STOCK.ID,R.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK,Y.ER.ST)
    Y.ITEM.LIST = R.REDO.ITEM.STOCK<ITEM.REG.ITEM.CODE>
    LOCATE R.NEW(RE.ORD.ITEM.CODE) IN Y.ITEM.LIST<1,1> SETTING POS THEN
        Y.BAL = R.REDO.ITEM.STOCK<ITEM.REG.BAL,POS>
        IF R.NEW(RE.ORD.RETURN.QUANTITY) GT Y.BAL THEN
            AF = RE.ORD.RETURN.QUANTITY
            ETEXT = 'EB-INVENTORY.NOT.EXISTS'
            CALL STORE.END.ERROR
            RETURN
        END
    END ELSE
        ETEXT = 'EB-INVENTORY.NOT.EXISTS'
        CALL STORE.END.ERROR
        RETURN
    END
    GOSUB REC.PIGGY
RETURN
*-------------------------------
REC.PIGGY:
*-------------------------------

    Y.UPD.FLAG = ''
    Y.SYSTEM = 'SYSTEM'
    Y.DES.DEPT = R.NEW(RE.ORD.BRANCH.CODE)
    IF Y.DES.DEPT THEN
        Y.BRANCH = ID.COMPANY:"-":Y.DES.DEPT
    END ELSE
        Y.BRANCH = ID.COMPANY
    END
    CALL CACHE.READ(FN.REDO.H.PIGGY.BANKS,Y.SYSTEM,R.REDO.H.PIGGY.BANKS,Y.ERRR)
    IF R.REDO.H.PIGGY.BANKS THEN
        Y.BRANCH = R.REDO.H.PIGGY.BANKS<REDO.PIG.BRANCH.DEPT>
        Y.COUNT.BRAN = DCOUNT(Y.BRANCH,@VM)
        Y.CNT.BR = 1
        LOOP
        WHILE Y.CNT.BR LE Y.COUNT.BRAN
            IF ID.COMPANY EQ R.REDO.H.PIGGY.BANKS<REDO.PIG.BRANCH.DEPT,Y.CNT.BR> THEN
                Y.CODE.VAL.1 = R.REDO.H.PIGGY.BANKS<REDO.PIG.BRANCH.DEPT,Y.CNT.BR>
                IF Y.DES.DEPT AND Y.DES.DEPT EQ R.REDO.H.PIGGY.BANKS<REDO.PIG.DEPT,Y.CNT.BR> THEN
                    R.REDO.H.PIGGY.BANKS<REDO.PIG.NO.AVBL,Y.CNT.BR> = R.REDO.H.PIGGY.BANKS<REDO.PIG.NO.AVBL,Y.CNT.BR> - R.NEW(RE.ORD.RETURN.QUANTITY)
                    Y.UPD.FLAG = '1'
                END
            END
            Y.CNT.BR += 1 ;*R22 Auto code conversion
        REPEAT
    END

    CURR.NO.VALUE = R.REDO.H.PIGGY.BANKS<REDO.PIG.CURR.NO>
    R.REDO.H.PIGGY.BANKS<REDO.PIG.CURR.NO> = CURR.NO.VALUE + 1
    INPUTTER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    AUTHORISER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
    TEMPTIME = OCONV(TIME(),"MTS")
    TEMPTIME = TEMPTIME[1,5]
    CHANGE ':' TO '' IN TEMPTIME
    CHECK.DATE = DATE()
    DATE.TIME = OCONV(CHECK.DATE,"DY2"):OCONV(CHECK.DATE,"DM"):OCONV(CHECK.DATE,"DD"):TEMPTIME
    R.REDO.H.PIGGY.BANKS<REDO.PIG.INPUTTER> = INPUTTER
    R.REDO.H.PIGGY.BANKS<REDO.PIG.DATE.TIME> = DATE.TIME
    R.REDO.H.PIGGY.BANKS<REDO.PIG.AUTHORISER> = AUTHORISER

    CALL F.WRITE(FN.REDO.H.PIGGY.BANKS,Y.SYSTEM,R.REDO.H.PIGGY.BANKS)

RETURN
RETURN
*-----------------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------------

    Y.ID.COMPANY = ID.COMPANY
    CALL F.READ(FN.REDO.H.MAIN.COMPANY,Y.ID.COMPANY,R.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY,Y.ERR)
    R.REDO.H.MAIN.COMPANY = ''
    IF R.REDO.H.MAIN.COMPANY AND NOT(R.NEW(RE.ORD.BRANCH.DES)) THEN
        ETEXT = 'AZ-INP.MISS'
        AF = RE.ORD.BRANCH.CODE
        CALL STORE.END.ERROR
        RETURN
    END ELSE
        Y.GROUP = R.NEW(RE.ORD.REQUEST.COMPANY)
        CALL F.READ(FN.REDO.H.MAIN.COMPANY,Y.GROUP,R.REDO.H.MAIN.COMPANY,F.REDO.H.MAIN.COMPANY,Y.ERR)
        Y.DES = R.NEW(RE.ORD.BRANCH.DES)
        LOCATE Y.DES IN R.REDO.H.MAIN.COMPANY<REDO.COM.DESCRIPTION,1> SETTING POS.1.1 THEN
            R.NEW(RE.ORD.BRANCH.CODE) = R.REDO.H.MAIN.COMPANY<REDO.COM.CODE,POS.1.1>
            Y.CODE = R.NEW(RE.ORD.BRANCH.CODE)
        END
    END

    R.NEW(RE.ORD.ORDER.STATUS) = 'Orden Devuelta'

    IF R.NEW(RE.ORD.BRANCH.CODE) THEN
        Y.ITEM.STOCK.RPT.ID = ID.COMPANY:'-':R.NEW(RE.ORD.BRANCH.CODE):".":R.NEW(RE.ORD.ITEM.CODE)
        Y.ITEM.STOCK.ID = ID.COMPANY:'-':R.NEW(RE.ORD.BRANCH.CODE)
    END ELSE
        Y.ITEM.STOCK.RPT.ID = ID.COMPANY:".":R.NEW(RE.ORD.ITEM.CODE)
        Y.ITEM.STOCK.ID = ID.COMPANY
    END
    CALL F.READ(FN.REDO.ITEM.STOCK,Y.ITEM.STOCK.ID,R.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK,Y.ERR.READ)
    CALL F.READ(FN.REDO.ITEM.STOCK.BY.DATE,Y.ITEM.STOCK.RPT.ID,R.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE,Y.ERR.DATE)
    CALL F.READ(FN.REDO.ITEM.SERIES,Y.ITEM.STOCK.RPT.ID,R.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES,Y.ERR.R)
    Y.CNT.TOT = DCOUNT(R.REDO.ITEM.SERIES,@FM)
    Y.SERIES.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',1,1)
    Y.STATUS.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',2,1)
    Y.BATCH.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',3,1)

    SEQ.COUNT = DCOUNT(R.NEW(RE.ORD.SERIES.FROM),@VM)

    IF DUP.APPL.NAME EQ 'F.REDO.H.PIGGY.BANKS' THEN
        GOSUB PIGGY.INV.STOCK
        RETURN
    END
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE SEQ.COUNT DO

        GOSUB LOOP.PROCESS.RETURN

    REPEAT
    IF Y.DEL.QUL NE Y.TOTAL.VAL THEN
        AF= RE.ORD.RETURN.QUANTITY
        ETEXT = "EB-DEL.QUANTITY.NOT.EQ"
        CALL STORE.END.ERROR
        RETURN
    END

    IF Y.OFS.VAL EQ 'PROCESS' THEN
        GOSUB UP.ITEM.STOCK.SER
        GOSUB UPD.ITEM.STOCK.RPT
    END

RETURN
*-----------------------------------------------------------------------------------------
UP.ITEM.STOCK.SER:
*-----------------------------------------------------------------------------------------
    Y.ITEM.LIST = R.REDO.ITEM.STOCK<ITEM.REG.ITEM.CODE>
    LOCATE Y.INV.MNT.ID IN Y.ITEM.LIST<1,1> SETTING POS THEN
        Y.BAL = R.REDO.ITEM.STOCK<ITEM.REG.BAL,POS>
        Y.BAL.NEW = Y.BAL - Y.DEL.QUL
        R.REDO.ITEM.STOCK<ITEM.REG.BAL,POS> = Y.BAL.NEW
    END
    CALL F.WRITE(FN.REDO.ITEM.STOCK,Y.ITEM.STOCK.ID,R.REDO.ITEM.STOCK)
    R.REDO.ITEM.SERIES.BK = ''
    R.REDO.ITEM.SERIES.BK = R.REDO.ITEM.SERIES
    Y.SER.LIST.VAL =  R.NEW(RE.ORD.RESERVED.5)
    Y.CNT.VM = 1
    LOOP
    WHILE Y.CNT.VM LE DCOUNT(Y.SER.LIST.VAL,@VM)
        LOCATE Y.SER.LIST.VAL<1,Y.CNT.VM> IN Y.BATCH.LIST.DUP SETTING POS.VM THEN
            R.REDO.ITEM.SERIES.BK<POS.VM> = '':"*":'':"*":Y.SER.LIST.VAL<1,Y.CNT.VM>
        END
        Y.CNT.VM += 1 ;*R22 Auto code conversion
    REPEAT
    CALL F.WRITE(FN.REDO.ITEM.SERIES,Y.ITEM.STOCK.RPT.ID,R.REDO.ITEM.SERIES.BK)

RETURN

*-----------------------------------------------------------------------------------------
LOOP.PROCESS.RETURN:
*-----------------------------------------------------------------------------------------
    Y.SEQ.FROM = R.NEW(RE.ORD.SERIES.FROM)<1,Y.CNT>
    Y.SEQ.TO = R.NEW(RE.ORD.SERIES.TO)<1,Y.CNT>

    Y.DIFF = Y.SEQ.TO - Y.SEQ.FROM
    GOSUB QUANTITY.CHECK
    LOOP
    WHILE Y.SEQ.FROM LE Y.SEQ.TO DO
        GOSUB CASE.FILE.SEL
        Y.SEQ.FROM += 1

        Y.TOTAL.VAL += 1 ;*R22 Auto code conversion
    REPEAT
    Y.CNT += 1
RETURN
*-----------------------------------------------------------------------------------------
QUANTITY.CHECK:
*-----------------------------------------------------------------------------------------

    IF Y.SEQ.TO AND Y.SEQ.FROM GT Y.SEQ.TO THEN
        AV = Y.CNT
        AF=RE.ORD.SERIES.FROM
        ETEXT = "EB-SEQ.FROM.GT.TO"
        CALL STORE.END.ERROR
    END
RETURN
*-----------------------------------------------------------------------------------------
CASE.FILE.SEL:
*-----------------------------------------------------------------------------------------

    R.REC = ''
    LOCATE Y.SEQ.FROM IN Y.SERIES.LIST.DUP SETTING POS.SER THEN
        Y.BATCH = Y.BATCH.LIST.DUP<POS.SER>
        SEL.LIST.1 = Y.BATCH
    END
    IF Y.BATCH THEN
        CALL F.READ(APPL.NAME,Y.BATCH,R.REC,APPL.PATH,Y.ERR)
    END

    BEGIN CASE
        CASE DUP.APPL.NAME EQ 'F.REDO.H.DEPOSIT.RECEIPTS'

            GOSUB DEPOSIT.RECEIPTS

        CASE DUP.APPL.NAME EQ 'F.REDO.H.BANK.DRAFTS'

            GOSUB BANK.DRAFTS

        CASE DUP.APPL.NAME EQ 'F.REDO.H.ADMIN.CHEQUES'

            GOSUB ADMIN.CHEQUES

        CASE DUP.APPL.NAME EQ 'F.REDO.H.PASSBOOK.INVENTORY'

            GOSUB PASSBOOK.INVENTORY

    END CASE

*-------------------to avoid select in reception receive id is stored in the reserverd field----------------------
    IF R.NEW(RE.ORD.RESERVED.5) THEN
        R.NEW(RE.ORD.RESERVED.5) := @VM:SEL.LIST.1
    END ELSE
        R.NEW(RE.ORD.RESERVED.5) = SEL.LIST.1
    END

*-----------------------------------------
RETURN
*-----------------------------------------------------------------------------------------
ERROR.THROW:
*-----------------------------------------------------------------------------------------
    AF =  RE.ORD.SERIES.FROM
    ETEXT = 'EB-INVENTORY.NOT.EXISTS'
    CALL STORE.END.ERROR
    GOSUB PROGRAM.END
RETURN
*-------------------------------
UPD.ITEM.STOCK.RPT:
*-------------------------------

    Y.DATE.RPT = R.NEW(RE.ORD.DATE)
    IF R.REDO.ITEM.STOCK.BY.DATE THEN
        LOCATE Y.DATE.RPT IN R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE,1> SETTING POS.RPT THEN
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.RETURN,POS.RPT>              =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.RETURN,POS.RPT> + R.NEW(RE.ORD.RETURN.QUANTITY)
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,POS.RPT>           =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,POS.RPT> - R.NEW(RE.ORD.RETURN.QUANTITY)
        END ELSE
            Y.DATE.COUNT1 = DCOUNT(R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE>,@VM)
            Y.DATE.COUNT = Y.DATE.COUNT1 + 1

            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE,Y.DATE.COUNT>                =   Y.DATE.RPT
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ITEM.CODE,Y.DATE.COUNT>           =   R.NEW(RE.ORD.ITEM.CODE)
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.INITIAL.STOCK,Y.DATE.COUNT>       =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT1>
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.RETURN,Y.DATE.COUNT>              =   R.NEW(RE.ORD.RETURN.QUANTITY)
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT>           =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT1> - R.NEW(RE.ORD.RETURN.QUANTITY)
        END
    END
    CALL F.WRITE(FN.REDO.ITEM.STOCK.BY.DATE,Y.ITEM.STOCK.RPT.ID,R.REDO.ITEM.STOCK.BY.DATE)

RETURN
*-------------------------------
DEPOSIT.RECEIPTS:
*-------------------------------

    IF R.REC THEN
        R.REC<REDO.DEP.STATUS> = 'ORDEN DEVUELTA'
        R.REC<REDO.DEP.INPUTTER> = INPUTTER
        R.REC<REDO.DEP.AUTHORISER> = AUTHORISER
        R.REC<REDO.DEP.DATE.UPDATED> = TODAY
        CALL F.WRITE(FN.REDO.H.DEPOSIT.RECEIPTS,SEL.LIST.1,R.REC)
    END ELSE
        GOSUB ERROR.THROW
    END

RETURN
*-------------------------------
ADMIN.CHEQUES:
*-------------------------------

    IF R.REC THEN
        R.REC<REDO.ADMIN.STATUS> = 'ORDEN DEVUELTA'
        R.REC<REDO.ADMIN.INPUTTER> = INPUTTER
        R.REC<REDO.ADMIN.AUTHORISER> = AUTHORISER
        R.REC<REDO.ADMIN.DATE.UPDATED> = TODAY
        CALL F.WRITE(FN.REDO.H.ADMIN.CHEQUES,SEL.LIST.1,R.REC)
    END ELSE
        GOSUB ERROR.THROW
    END
RETURN
*-------------------------------
PASSBOOK.INVENTORY:
*-------------------------------
    IF R.REC THEN
        R.REC<REDO.PASS.STATUS> = 'ORDEN DEVUELTA'
        R.REC<REDO.PASS.INPUTTER> = INPUTTER
        R.REC<REDO.PASS.AUTHORISER> = AUTHORISER
        R.REC<REDO.PASS.DATE.UPDATED> = TODAY
        CALL F.WRITE(FN.REDO.H.PASSBOOK.INVENTORY,SEL.LIST.1,R.REC)
    END ELSE
        GOSUB ERROR.THROW
    END

RETURN
*-------------------------------
BANK.DRAFTS:
*-------------------------------
    IF R.REC THEN
        R.REC<REDO.BANK.STATUS> = 'ORDEN DEVUELTA'
        R.REC<REDO.BANK.INPUTTER> = INPUTTER
        R.REC<REDO.BANK.AUTHORISER> = AUTHORISER
        R.REC<REDO.BANK.DATE.UPDATED> = TODAY
        CALL F.WRITE(FN.REDO.H.BANK.DRAFTS,SEL.LIST.1,R.REC)
    END ELSE
        GOSUB ERROR.THROW
    END
RETURN
*-----------------------------------------------------------------------------------------
PROGRAM.END:
*-----------------------------------------------------------------------------------------
END
