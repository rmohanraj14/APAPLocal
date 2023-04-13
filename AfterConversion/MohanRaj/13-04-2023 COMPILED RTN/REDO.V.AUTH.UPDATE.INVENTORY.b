* @ValidationCode : MjotMTg3NzIzMTkwODpDcDEyNTI6MTY4MTM4MjE2MTQ3ODo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:06:01
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
SUBROUTINE REDO.V.AUTH.UPDATE.INVENTORY
*-----------------------------------------------------------------------------
* Description:
* This routine will be attached to the VERSION.CONTROL of ACCOUNT Application as
* a auth routine
*----------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*----------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.AUTH.UPDATE.INVENTORY
*----------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 17.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
*20-05-2011   Prabhu N        CR13              Loop added for PASSBOOKS
*26-SEP-2011  JEEVAT          PACS00134603
*11-NOV-2011  JEEVAT          PACS00153539     Select command has been removed
*25-JAN-2012  JEEVAT          PACS00177114     Sort has been changed
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    TNO:'_':OPERATOR TO C$T24.SESSION.NO:'_':OPERATOR,VM TO @VM,FM TO @FM,++ TO +=1
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ---------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.USER
    $INSERT I_F.REDO.H.INVENTORY.PARAMETER
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_REDO.PASS.ID.COMMON
    $INSERT I_F.REDO.H.PASSBOOK.INVENTORY
    $INSERT I_F.REDO.ITEM.STOCK.BY.DATE
    $INSERT I_F.REDO.ITEM.STOCK
    $INSERT I_F.AI.REDO.ARCIB.PARAMETER
    $INSERT I_F.REDO.H.REORDER.LEVEL
    $INSERT I_F.ACCOUNT
    $INSERT I_F.COMPANY
*---------------------------------------------------------------------------------------
MAIN:
*---------------------------------------------------------------------------------------
    Y.LOC.FLAG = ''
    Y.CURR.NO = ''
    Y.CURR.NO = R.OLD(AC.CURR.NO)
    IF R.NEW(AC.ARRANGEMENT.ID) OR Y.CURR.NO THEN
        RETURN
    END

    ITEM.CODE         = ''
    Y.SERIES.NEW.LIST = ''
    Y.SORT.VALUE.NEW  = ''
    Y.REORDER.VAL     = ''

    IF V$FUNCTION EQ 'I' THEN
        AUTHORISER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        GOSUB OPENFILES
        GOSUB PROCESS
        GOSUB MIN.LEVEL.CHECK
        GOSUB CHECK.FOR.ERROR
        GOSUB PROGRAM.END
    END ELSE
        FN.REDO.ITEM.SERIES = 'F.REDO.ITEM.SERIES'
        F.REDO.ITEM.SERIES = ''
        CALL OPF(FN.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES)
*PACS00260041 - S
        Y.ACCOUNT.ID = ID.NEW
        CALL F.READ(FN.REDO.ITEM.SERIES,Y.ACCOUNT.ID,R.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES,Y.ERR)
        COUNT.LIST = DCOUNT(R.REDO.ITEM.SERIES,@FM)
        Y.ACCOUNT.LIST = FIELDS(R.REDO.ITEM.SERIES,'-',1,1)
        Y.PASS.LIST =    FIELDS(R.REDO.ITEM.SERIES,'-',2,1)
        Y.PASS.ID = Y.PASS.LIST<COUNT.LIST>
        FN.REDO.H.PASSBOOK.INVENTORY = 'F.REDO.H.PASSBOOK.INVENTORY'
        F.REDO.H.PASSBOOK.INVENTORY = ''
        CALL OPF(FN.REDO.H.PASSBOOK.INVENTORY,F.REDO.H.PASSBOOK.INVENTORY)

        CALL F.READ(FN.REDO.H.PASSBOOK.INVENTORY,Y.PASS.ID,R.PASS.INV,F.REDO.H.PASSBOOK.INVENTORY,Y.ERR.INV)
        AUTHORISER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        R.PASS.INV<REDO.PASS.AUTHORISER> = AUTHORISER
        R.PASS.INV<REDO.PASS.DATE.UPDATED> = TODAY
        R.PASS.INV<REDO.PASS.USER> = OPERATOR
        IF Y.PASS.ID THEN
            CALL F.WRITE(FN.REDO.H.PASSBOOK.INVENTORY,Y.PASS.ID,R.PASS.INV)
        END
*PACS00260041 - E
    END
RETURN
*---------------------------------------------------------------------------------------
OPENFILES:
*---------------------------------------------------------------------------------------
    FN.REDO.H.INVENTORY.PARAMETER = 'F.REDO.H.INVENTORY.PARAMETER'
    F.REDO.H.INVENTORY.PARAMETER = ''
    CALL OPF(FN.REDO.H.INVENTORY.PARAMETER,F.REDO.H.INVENTORY.PARAMETER)

    FN.REDO.ITEM.STOCK.BY.DATE = 'F.REDO.ITEM.STOCK.BY.DATE'
    F.REDO.ITEM.STOCK.BY.DATE = ''
    CALL OPF(FN.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE)

    FN.REDO.H.PASSBOOK.INVENTORY = 'F.REDO.H.PASSBOOK.INVENTORY'
    F.REDO.H.PASSBOOK.INVENTORY = ''
    CALL OPF(FN.REDO.H.PASSBOOK.INVENTORY,F.REDO.H.PASSBOOK.INVENTORY)

    FN.REDO.ITEM.SERIES = 'F.REDO.ITEM.SERIES'
    F.REDO.ITEM.SERIES = ''
    CALL OPF(FN.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.ITEM.STOCK = 'F.REDO.ITEM.STOCK'
    F.REDO.ITEM.STOCK = ''
    CALL OPF(FN.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK)

    FN.AI.REDO.ARC.PARAM = 'F.AI.REDO.ARCIB.PARAMETER'
    F.AI.REDO.ARC.PARAM  = ''
    CALL OPF(FN.AI.REDO.ARC.PARAM,F.AI.REDO.ARC.PARAM)

    FN.REDO.H.REORDER.LEVEL = 'F.REDO.H.REORDER.LEVEL'
    F.REDO.H.REORDER.LEVEL =''
    CALL OPF(FN.REDO.H.REORDER.LEVEL,F.REDO.H.REORDER.LEVEL)

RETURN
*---------------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------------

    Y.COUNT.FMT = ''
    Y.VALU = V$FUNCTION
    R.PASS.INV = ''
    LOC.REF.APPLICATION="ACCOUNT":@FM:"USER"
    LOC.REF.FIELDS='L.AC.UPD.INVTRY':@VM:'L.SERIES.ID':@FM:'L.US.IDC.BR':@VM:'L.US.IDC.CODE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.AC = LOC.REF.POS<1,1>
    POS.AC.1 =LOC.REF.POS<1,2>
    POS.BR.VAL =LOC.REF.POS<2,1>
    POS.DETP.VAL = LOC.REF.POS<2,2>
    Y.CODE.DEPT = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>

    LOCATE ID.COMPANY IN Y.BRANCH.LIST<1,1,1> SETTING POS.BR THEN
        Y.CODE.DEPT = Y.DEPT.LIST<1,1,POS.BR>
    END

    TOTAL.DIGIT=''

    IF R.NEW(AC.LOCAL.REF)<1,POS.AC> NE 'NO' OR R.NEW(AC.LOCAL.REF)<1,POS.AC> NE ' ' THEN
        Y.CATEG.ID = R.NEW(AC.CATEGORY)
        CALL CACHE.READ(FN.REDO.H.INVENTORY.PARAMETER,'SYSTEM',R.INV.PARAM,PARM.ERR)

        Y.INV.MAINT = R.INV.PARAM<IN.PR.INV.MAINT.TYPE>
        Y.INV.MAINT = CHANGE(Y.INV.MAINT,@VM,@FM)
        Y.INV.MAINT = CHANGE(Y.INV.MAINT,@SM,@FM)
        POS=1
        Y.TOT.POS=DCOUNT(Y.INV.MAINT,@FM)
        IF R.INV.PARAM THEN
*---------------Start of modification-CR13-----------------------------------------------------------------
            LOOP
            WHILE POS LE Y.TOT.POS
                Y.CATG.LIST = R.INV.PARAM<IN.PR.PROD.CATEG,POS>
                IF Y.INV.MAINT<POS> EQ 'PASSBOOKS' THEN
                    LOCATE Y.CATEG.ID IN R.INV.PARAM<IN.PR.PROD.CATEG,POS,1> SETTING POS.1.VA THEN
                        Y.LOC.FLAG = 1
                        ITEM.CODE = R.INV.PARAM<IN.PR.ITEM.CODE,POS>
                        DESCRIPTION = R.INV.PARAM<IN.PR.ITEM.DESC,POS>
                        REORDER.LEVEL = R.INV.PARAM<IN.PR.REORDER.LEVEL,POS>
                        QTY.TO.ORDER = R.INV.PARAM<IN.PR.QTY.TO.REQ,POS>
                        POS += Y.TOT.POS ;*R22 Auto Code conversion
                    END
                END
                POS += 1
            REPEAT
        END
*-------------End of modification------------------------------------------------------------------------------
*PACS00260041 - S
        R.REDO.ACCT.ITEM = ''
        Y.ACCOUNT.ID = ID.NEW
        CALL F.READ(FN.REDO.ITEM.SERIES,Y.ACCOUNT.ID,R.REDO.ACCT.ITEM,F.REDO.ITEM.SERIES,Y.ACC.ERR.)
        IF NOT(R.REDO.ACCT.ITEM) THEN
            GOSUB INV.UPD
        END
*PACS00260041 - E
    END ELSE
        GOSUB PROGRAM.END
    END
RETURN
*-------------------------------------------------------------------------------------
GET.ALL.SERIES:
*-------------------------------------------------------------------------------------
    Y.VAL.CK = ''
    Y.MAX = MAXIMUM(Y.SERIES.LIST)
    Y.LEN = LEN(Y.MAX)
    Y.FMT = 'R%':Y.LEN
    Y.CNT.FMT = 1
    Y.COUNT.FMT = DCOUNT(Y.SERIES.LIST,@FM)
    LOOP
    WHILE Y.CNT.FMT LE Y.COUNT.FMT
        Y.VAL.CK = Y.SERIES.LIST<Y.CNT.FMT>
        Y.SERIES.NEW.LIST<-1> = Y.DATE.UPD.LIST<Y.CNT.FMT>:FMT(Y.SERIES.LIST<Y.CNT.FMT>,Y.FMT)
        IF Y.VAL.CK THEN
            Y.FMT.CHCK.VAL = FMT(Y.SERIES.LIST<Y.CNT.FMT>,Y.FMT)
            Y.DATE.VAL.NEW.LIST<-1> = Y.DATE.UPD.LIST<Y.CNT.FMT>:Y.FMT.CHCK.VAL
        END
        Y.CNT.FMT += 1 ;*R22 Auto code conversion
    REPEAT
    Y.SORT.VALUE.NEW  = Y.DATE.VAL.NEW.LIST
RETURN
*-------------------------------------------------------------------------------------
CHECK.FOR.NEXT.AVALIABLE:
*-------------------------------------------------------------------------------------
    CALL F.READU(FN.REDO.ITEM.SERIES,Y.ITEM.STOCK.ID1,R.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES,Y.ERR,'')
    IF R.REDO.ITEM.SERIES THEN
        Y.SERIES.LIST = FIELDS(R.REDO.ITEM.SERIES,'*',1,1)
        Y.DATE.UPD.LIST = FIELDS(R.REDO.ITEM.SERIES,'*',4,1)

        GOSUB GET.ALL.SERIES
        Y.SORT.VAL = SORT(Y.DATE.VAL.NEW.LIST)

        Y.FINAL.VAL.CH = Y.SORT.VAL<1>

        LOCATE Y.FINAL.VAL.CH IN Y.SERIES.NEW.LIST SETTING POS.SORT THEN
            Y.SEL.LIST = FIELDS(R.REDO.ITEM.SERIES,'*',3,1)
            Y.PASS.ID1 = Y.SEL.LIST<POS.SORT>
            DEL R.REDO.ITEM.SERIES<POS.SORT>
        END
        R.PASS.INV = ''

        GOSUB UPDATE.PASSBOOK.TABLE
    END
RETURN
*-------------------------------------------------------------------------------------
UPDATE.PASSBOOK.TABLE:
*-------------------------------------------------------------------------------------
    IF Y.PASS.ID1 THEN
        CALL F.READ(FN.REDO.H.PASSBOOK.INVENTORY,Y.PASS.ID1,R.PASS.INV,F.REDO.H.PASSBOOK.INVENTORY,INV.ERR)
        R.PASS.INV<REDO.PASS.ACCOUNT> = ID.NEW
        R.PASS.INV<REDO.PASS.DATE.UPDATED> = TODAY
        R.PASS.INV<REDO.PASS.STATUS> = 'Asignada'
        R.PASS.INV<REDO.PASS.CATEGORY> = R.NEW(AC.CATEGORY)
        R.PASS.INV<REDO.PASS.STATUS.CHG, 1> = 'Asignada'
        R.PASS.INV<REDO.PASS.STATUS.DATE,1> = TODAY
        R.PASS.INV<REDO.PASS.USER.MOD,1> = OPERATOR
        R.PASS.INV<REDO.PASS.USER.AUTH,1> = OPERATOR
        R.PASS.INV<REDO.PASS.NEW.CREATED> = 'YES'
        CURR.NO.VALUE = R.PASS.INV<REDO.PASS.CURR.NO>
        R.PASS.INV<REDO.PASS.CURR.NO>  = CURR.NO.VALUE + 1
        INPUTTER = C$T24.SESSION.NO:'_':OPERATOR ;*R22 Auto code conversion
        TEMPTIME = OCONV(TIME(),"MTS")
        TEMPTIME = TEMPTIME[1,5]
        CHANGE ':' TO '' IN TEMPTIME
        CHECK.DATE = DATE()
        DATE.TIME = OCONV(CHECK.DATE,"DY2"):OCONV(CHECK.DATE,"DM"):OCONV(CHECK.DATE,"DD"):TEMPTIME
        R.PASS.INV<REDO.PASS.INPUTTER> = INPUTTER
        R.PASS.INV<REDO.PASS.DATE.TIME> = DATE.TIME
        R.PASS.INV<REDO.PASS.AUTHORISER> = AUTHORISER
        R.PASS.INV<REDO.PASS.CO.CODE> = ID.COMPANY
        IF NOT(R.NEW(AC.LOCAL.REF)<1,POS.AC.1>) OR ( R.REDO.ITEM.STOCK.BK EQ R.REDO.ITEM.STOCK ) THEN
            GOSUB INV.STOCK.UPDT
            GOSUB INV.STOCK.UPDT.VAL
        END
        R.NEW(AC.LOCAL.REF)<1,POS.AC.1> = R.PASS.INV<REDO.PASS.SERIAL.NO>
        Y.SERIAL.CHK = ''
        Y.SERIAL.CHK = R.NEW(AC.LOCAL.REF)<1,POS.AC.1>
        CALL F.WRITE(FN.REDO.H.PASSBOOK.INVENTORY,Y.PASS.ID1,R.PASS.INV)
        CALL F.WRITE(FN.REDO.ITEM.SERIES,Y.ITEM.STOCK.ID1,R.REDO.ITEM.SERIES)
        R.REDO.ACCT.ITEM = ID.NEW:'-':Y.PASS.ID1
        CALL F.WRITE(FN.REDO.ITEM.SERIES,Y.ACCOUNT.ID,R.REDO.ACCT.ITEM)
    END
RETURN
*-------------------------------------------------------------------------------------
INV.UPD:
*-------------------------------------------------------------------------------------
    Y.CODE.DEPT = ''
    SEL.LIST = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>

    LOCATE ID.COMPANY IN Y.BRANCH.LIST<1,1,1> SETTING POS.BR THEN
        Y.CODE.DEPT = Y.DEPT.LIST<1,1,POS.BR>
    END

    IF Y.CODE.DEPT THEN
        Y.ITEM.STOCK.ID = ID.COMPANY:"-":Y.CODE.DEPT
        Y.ITEM.STOCK.ID1 = ID.COMPANY:"-":Y.CODE.DEPT:".":ITEM.CODE
    END ELSE
        Y.ITEM.STOCK.ID = ID.COMPANY
        Y.ITEM.STOCK.ID1 = ID.COMPANY:".":ITEM.CODE
    END
    Y.OFS.VAL = OFS$OPERATION
    Y.LOCK.VAL = 1
    IF Y.OFS.VAL EQ 'PROCESS' THEN
        GOSUB CHECK.FOR.NEXT.AVALIABLE
    END
RETURN
*-------------------------------------------------------------------------------------
INV.STOCK.UPDT:
*-------------------------------------------------------------------------------------
    R.REDO.ITEM.STOCK = ''
    CALL F.READ(FN.REDO.ITEM.STOCK,Y.ITEM.STOCK.ID,R.REDO.ITEM.STOCK,F.REDO.ITEM.STOCK,Y.ERR)

    R.REDO.ITEM.STOCK.BK = R.REDO.ITEM.STOCK

    Y.LIST.ITM = R.REDO.ITEM.STOCK<ITEM.REG.ITEM.CODE>

    LOCATE ITEM.CODE IN Y.LIST.ITM<1,1> SETTING POS THEN
        R.REDO.ITEM.STOCK<ITEM.REG.BAL,POS> = R.REDO.ITEM.STOCK<ITEM.REG.BAL,POS> - 1
    END
    IF R.REDO.ITEM.STOCK THEN
        CALL F.WRITE(FN.REDO.ITEM.STOCK,Y.ITEM.STOCK.ID,R.REDO.ITEM.STOCK)
    END

RETURN
*-------------------------------------------------------------------------------------
INV.STOCK.UPDT.VAL:
*-------------------------------------------------------------------------------------
    Y.DATE.RPT = TODAY
    CALL F.READ(FN.REDO.ITEM.STOCK.BY.DATE,Y.ITEM.STOCK.ID1,R.REDO.ITEM.STOCK.BY.DATE,F.REDO.ITEM.STOCK.BY.DATE,Y.ERR.FLA)
    IF R.REDO.ITEM.STOCK.BY.DATE THEN
        LOCATE Y.DATE.RPT IN R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE,1> SETTING POS.RPT THEN
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED,POS.RPT>            =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED,POS.RPT> + 1
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,POS.RPT>           =   R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,POS.RPT> - 1
        END ELSE
            Y.DATE.COUNT1 = DCOUNT(R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE>,@VM)
            Y.DATE.COUNT = Y.DATE.COUNT1 + 1
            Y.QNTY = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED,Y.DATE.COUNT>
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.DATE,Y.DATE.COUNT>                = Y.DATE.RPT
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ITEM.CODE,Y.DATE.COUNT>           = ITEM.CODE
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.INITIAL.STOCK,Y.DATE.COUNT>       = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT1>
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED,Y.DATE.COUNT>            = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.ASSIGNED,Y.DATE.COUNT> + 1
            R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT>           = R.REDO.ITEM.STOCK.BY.DATE<ITEM.RPT.AVALIABLE,Y.DATE.COUNT1> - 1
        END
        CALL F.WRITE(FN.REDO.ITEM.STOCK.BY.DATE,Y.ITEM.STOCK.ID1,R.REDO.ITEM.STOCK.BY.DATE)
    END
RETURN
*-------------------------------------------------------------------------------------
MIN.LEVEL.CHECK:
*-------------------------------------------------------------------------------------
    CALL F.READ(FN.REDO.H.REORDER.LEVEL,ID.COMPANY,R.REDO.H.REORDER.LEVEL,F.REDO.H.REORDER.LEVEL,Y.INV.ERR)
    Y.REORDER.LEVEL = R.REDO.H.REORDER.LEVEL<RE.ORD.REORDER.LEVEL>
    Y.ITEM.LIST = R.REDO.H.REORDER.LEVEL<RE.ORD.ITEM.VALUE>
    Y.ORD.CODE  = R.REDO.H.REORDER.LEVEL<RE.ORD.CODE>
    Y.CODE.CNT  = DCOUNT(Y.ORD.CODE,@VM)
    Y.GOT.FLAG = ''
    Y.CODE.INIT = 1
    LOOP
        REMOVE Y.CODE.ID FROM Y.ORD.CODE SETTING Y.COD.POS
    WHILE Y.CODE.INIT LE Y.CODE.CNT
        IF Y.CODE.ID EQ Y.CODE.DEPT AND NOT(Y.GOT.FLAG) THEN
            LOCATE ITEM.CODE IN Y.ITEM.LIST<1,Y.CODE.INIT,1> SETTING Y.ITEM.POS THEN
                Y.REORDER.VAL = Y.REORDER.LEVEL<1,Y.CODE.INIT,Y.ITEM.POS>
                Y.GOT.FLAG = 1
            END
        END
        Y.CODE.INIT += 1
    REPEAT
    R.REC = DCOUNT(Y.SERIES.NEW.LIST,@FM)
    IF DCOUNT(Y.SORT.VALUE.NEW,@FM) LE Y.REORDER.VAL AND NOT(Y.CURR.NO) THEN
        TEXT = 'REDO.MIN.INVENT.LEVEL'
        Y.CUR.CNT = DCOUNT(R.NEW(AC.LOCAL.REF),@VM)
        CALL STORE.OVERRIDE(Y.CUR.CNT+1)
    END

RETURN
*---------------------------------------------------------------------------------------
CHECK.FOR.ERROR:
    IF NOT(Y.SERIAL.CHK) AND Y.LOC.FLAG AND NOT(Y.CURR.NO) AND OFS$OPERATION EQ 'PROCESS' THEN
        AF = AC.LOCAL.REF
        AV = POS.AC.1
        AS = 1
        ETEXT = "EB-REDO.NO.SERIAL"
        CALL STORE.END.ERROR
    END
RETURN
PROGRAM.END:
*---------------------------------------------------------------------------------------
END
