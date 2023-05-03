* @ValidationCode : MjoxMTYxMTUyMTMyOkNwMTI1MjoxNjgxODEyNjEzMTE5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 15:40:13
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
SUBROUTINE REDO.V.NEXT.AVL.SERIES
*-----------------------------------------------------------------------------
* Description:
* This routine will be attached to the versions as
* a validation routine
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : JEEVA T
* PROGRAM NAME : REDO.V.NEXT.AVL.SERIES
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 11-10-2011  JEEVA T         ODR-2009-11-0200    PACS00156712
* 31-05-2012  Ganesh R        PACS00194269          New section included
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.USER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.REDO.H.REASSIGNMENT
    $INSERT I_F.REDO.H.REORDER.LEVEL
    $INSERT I_F.REDO.H.INVENTORY.PARAMETER
    $INSERT I_REDO.INV.REASSIGN.COMMON

    Y.CURR.NO = ''
    Y.CURR.NO = R.OLD(RE.ORD.CURR.NO)
    GOSUB OPENFILES
    GOSUB PROCESS.FILE
    GOSUB MIN.LEVEL.CHECK       ;* PACS00194269 - S/E

RETURN
*-----------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------

    FN.REDO.H.ITEM.SERIES = 'F.REDO.ITEM.SERIES'
    F.REDO.H.ITEM.SERIES  = ''
    CALL OPF(FN.REDO.H.ITEM.SERIES,F.REDO.H.ITEM.SERIES)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.REDO.H.REORDER.LEVEL = 'F.REDO.H.REORDER.LEVEL'
    F.REDO.H.REORDER.LEVEL  = ''
    CALL OPF(FN.REDO.H.REORDER.LEVEL,F.REDO.H.REORDER.LEVEL)

    FN.REDO.H.INVENTORY.PARAMETER = 'F.REDO.H.INVENTORY.PARAMETER'
    F.REDO.H.INVENTORY.PARAMETER = ''
    CALL OPF(FN.REDO.H.INVENTORY.PARAMETER,F.REDO.H.INVENTORY.PARAMETER)

RETURN
*-----------------------------------------------------------------------------
PROCESS.FILE:
*------------------------------------------------------------------------------
    LOC.REF.APPLICATION="USER"
    LOC.REF.FIELDS='L.US.IDC.BR':@VM:'L.US.IDC.CODE'
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)

    POS.BR.VAL =LOC.REF.POS<1,1>
    POS.DETP.VAL = LOC.REF.POS<1,2>

    Y.CODE.DEPT = ''
    Y.BRANCH.LIST = R.USER<EB.USE.LOCAL.REF,POS.BR.VAL>
    Y.DEPT.LIST = R.USER<EB.USE.LOCAL.REF,POS.DETP.VAL>

    LOCATE ID.COMPANY IN Y.BRANCH.LIST<1,1,1> SETTING POS.BR THEN
        Y.CODE.DEPT = Y.DEPT.LIST<1,1,POS.BR>
    END

    Y.ACCOUNT = R.NEW(RE.ASS.ACCOUNT.NUMBER)
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT,R.ACCOUNT,F.ACCOUNT,Y.ACCT.ERR)

    Y.CATEG.ID = R.ACCOUNT<AC.CATEGORY>
    CALL CACHE.READ(FN.REDO.H.INVENTORY.PARAMETER,'SYSTEM',R.INV.PARAM,PARM.ERR)

    Y.INV.MAINT = R.INV.PARAM<IN.PR.INV.MAINT.TYPE>
    Y.INV.MAINT = CHANGE(Y.INV.MAINT,@VM,@FM)
    Y.INV.MAINT = CHANGE(Y.INV.MAINT,@SM,@FM)
    POS=1
    Y.TOT.POS=DCOUNT(Y.INV.MAINT,@FM)
    IF R.INV.PARAM THEN
        LOOP
        WHILE POS LE Y.TOT.POS
            Y.CATG.LIST = R.INV.PARAM<IN.PR.PROD.CATEG,POS>
            IF Y.INV.MAINT<POS> EQ 'PASSBOOKS' THEN
                LOCATE Y.CATEG.ID IN R.INV.PARAM<IN.PR.PROD.CATEG,POS,1> SETTING POS.1.VA THEN
                    ITEM.CODE = R.INV.PARAM<IN.PR.ITEM.CODE,POS>
                    DESCRIPTION = R.INV.PARAM<IN.PR.ITEM.DESC,POS>
                    REORDER.LEVEL = R.INV.PARAM<IN.PR.REORDER.LEVEL,POS>
                    QTY.TO.ORDER = R.INV.PARAM<IN.PR.QTY.TO.REQ,POS>
                    POS += Y.TOT.POS ;*R22 Auto code conversion
                END
            END
            POS += 1
        REPEAT
        Y.CODE = ''
        Y.ITEM = ''
        Y.COMPANY = ''
        Y.FINAL.VAL.CH = ''
        R.NEW(RE.ASS.DEPT) = ID.COMPANY
        Y.COMPANY = ID.COMPANY
        R.NEW(RE.ASS.CODE) = Y.CODE.DEPT
        Y.CODE    = Y.CODE.DEPT
        Y.NEWSER.ITEM.CODE = ITEM.CODE      ;* THIS VARIABLE IS SET AS COMMON VARIABLE TO USE IN AUTH ROUTINE
        Y.ITEM    = ITEM.CODE
        IF Y.CODE THEN
            Y.ID = Y.COMPANY:'-':Y.CODE:'.':Y.ITEM
        END ELSE
            Y.ID = Y.COMPANY:'.':Y.ITEM
        END
        CALL F.READ(FN.REDO.H.ITEM.SERIES,Y.ID,R.REDO.H.ITEM.SERIES,F.REDO.H.ITEM.SERIES,Y.ERR)
        Y.SERIES.LIST = FIELDS(R.REDO.H.ITEM.SERIES,'*',1,1)
        Y.DATE.UPD.LIST = FIELDS(R.REDO.H.ITEM.SERIES,'*',4,1)
        GOSUB GET.NEW.SERIES
        Y.SORT.VAL = SORT(Y.DATE.VAL.NEW.LIST)
        Y.FINAL.VAL.CH = Y.SORT.VAL<1>
        Y.LEN.FN.VAL = LEN(Y.FINAL.VAL.CH)
        Y.FINAL.VAL.CH = Y.FINAL.VAL.CH[9,Y.LEN.FN.VAL]
        R.NEW(RE.ASS.NEW.SERIES) = Y.FINAL.VAL.CH
    END
    IF NOT(Y.FINAL.VAL.CH) THEN
        AF = RE.ASS.NEW.SERIES
        ETEXT = 'AC-INP.FLD.MAND'
        CALL STORE.END.ERROR
        RETURN
    END
RETURN
*------------------------------------------------------------------------------
GET.NEW.SERIES:
*------------------------------------------------------------------------------
    Y.VAL.CK = ''
    Y.MAX = MAXIMUM(Y.SERIES.LIST)
    Y.LEN = LEN(Y.MAX)
    Y.FMT = 'R%':Y.LEN
    Y.CNT.FMT = 1
    Y.COUNT.FMT = DCOUNT(Y.SERIES.LIST,@FM)
    LOOP
    WHILE Y.CNT.FMT LE Y.COUNT.FMT
        Y.VAL.CK = Y.SERIES.LIST<Y.CNT.FMT>
        IF Y.VAL.CK THEN
*            Y.FMT.CHCK.VAL = FMT(Y.SERIES.LIST<Y.CNT.FMT>,Y.FMT)
            Y.FMT.CHCK.VAL = Y.SERIES.LIST<Y.CNT.FMT>
            Y.SERIES.NEW.LIST<-1> = Y.FMT.CHCK.VAL
            Y.DATE.VAL.NEW.LIST<-1> = Y.DATE.UPD.LIST<Y.CNT.FMT>:Y.FMT.CHCK.VAL
        END
        Y.CNT.FMT += 1 ;*R22 Auto code conversion
    REPEAT
RETURN
*-------------------------------------------------------------------------
*-------------------------------------------------------------------------------------
MIN.LEVEL.CHECK:
*-------------------------------------------------------------------------------------
    CALL F.READ(FN.REDO.H.REORDER.LEVEL,ID.COMPANY,R.REDO.H.REORDER,F.REDO.H.REORDER.LEVEL,REORDER.ERR)
    Y.CODE.LIST = R.REDO.H.REORDER<RE.ORD.CODE>
    Y.INIT = 1
    Y.COUNT = DCOUNT(Y.CODE.LIST,@VM)
    LOOP
        REMOVE Y.CODE.ID FROM Y.CODE.LIST SETTING Y.COD.POS
    WHILE Y.INIT LE Y.COUNT
        IF Y.CODE.ID EQ Y.CODE THEN
            Y.ITEM.LIST = R.REDO.H.REORDER<RE.ORD.ITEM.VALUE>
            Y.ITEM.LIST = R.REDO.H.REORDER<RE.ORD.ITEM.VALUE,Y.INIT>
            LOCATE Y.ITEM IN Y.ITEM.LIST<1,1,1>  SETTING Y.IT.POS THEN
                Y.REORDER.LEVEL = R.REDO.H.REORDER<RE.ORD.REORDER.LEVEL,Y.INIT,Y.IT.POS>
            END
        END
        Y.INIT += 1
    REPEAT

    R.REC = DCOUNT(Y.DATE.VAL.NEW.LIST,@FM)
    IF R.REC LE Y.REORDER.LEVEL THEN
        TEXT = 'REDO.MIN.INVENT.LEVEL'
        Y.CUR.CNT = DCOUNT(R.NEW(RE.ORD.OVERRIDE),@VM)
        CALL STORE.OVERRIDE(Y.CUR.CNT+1)
    END
RETURN
END
