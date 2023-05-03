* @ValidationCode : MjoxMjA5MTA1NjU1OkNwMTI1MjoxNjgxNzM1NjgzMjk4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 18:18:03
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
SUBROUTINE REDO.V.INP.SERIES.CHECK
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
* 07-JAN-2012  JEEVA T          pACS00172842     changes
*Modification history
*Date                Who               Reference                  Description
*17-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,FM TO @FM,VM TO @VM
*17-04-2023      Mohanraj R          R22 Manual code conversion   CALL method format modified
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.ORDER.DETAILS
    $INSERT I_F.REDO.H.BANK.DRAFTS
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.H.PASSBOOK.INVENTORY
    $INSERT I_F.REDO.H.INVENTORY.PARAMETER
    $INSERT I_F.REDO.H.DEPOSIT.RECEIPTS
*-----------------------------------------------------------------------------------------
MAIN:
*-----------------------------------------------------------------------------------------

    Y.REJ.ORDER = ''
    Y.REJ.ORDER = R.NEW(RE.ORD.REJECTED.ORDER)
    IF (Y.REJ.ORDER EQ 'NO' OR Y.REJ.ORDER EQ '') THEN
        GOSUB INIT
        GOSUB OPENFILES
        GOSUB PROCESS
        GOSUB PROGRAM.END
    END ELSE
        R.NEW(RE.ORD.REJECT.DATE) = TODAY

    END
RETURN
*-----------------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------------
    Y.TOTAL.VAL = 0
    Y.DIFF = 0

RETURN
*-----------------------------------------------------------------------------------------
OPENFILES:
*-----------------------------------------------------------------------------------------

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
    FN.REDO.ITEM.SERIES = 'F.REDO.ITEM.SERIES'
    F.REDO.ITEM.SERIES =''
    CALL OPF(FN.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES)

    FN.REDO.H.INVENTORY.PARAMETER = 'F.REDO.H.INVENTORY.PARAMETER'
    F.REDO.H.INVENTORY.PARAMETER =''
    CALL OPF(FN.REDO.H.INVENTORY.PARAMETER,F.REDO.H.INVENTORY.PARAMETER)


RETURN
*-----------------------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------------------

    Y.INV.MNT.ID = R.NEW(RE.ORD.ITEM.CODE)
    CALL CACHE.READ(FN.REDO.H.INVENTORY.PARAMETER,'SYSTEM',R.REDO.H.INVENTORY.PARAMETER,Y.ERR.INV)
    Y.ITEM.DECS = R.REDO.H.INVENTORY.PARAMETER<IN.PR.ITEM.DESC>
    Y.ITEM.CODE.LIST.PARA = R.REDO.H.INVENTORY.PARAMETER<IN.PR.ITEM.CODE>
    CHANGE @VM TO @FM IN Y.ITEM.DECS
    CHANGE @SM TO @FM IN Y.ITEM.DECS
    CHANGE @VM TO @FM IN Y.ITEM.CODE.LIST.PARA
    CHANGE @SM TO @FM IN Y.ITEM.CODE.LIST.PARA
    LOCATE Y.INV.MNT.ID IN Y.ITEM.CODE.LIST.PARA SETTING POS.ITEM THEN
        Y.PIGGY.CHK = Y.ITEM.DECS<POS.ITEM>
        FINDSTR "PIGGY" IN Y.PIGGY.CHK SETTING POS.AP THEN
            R.NEW(RE.ORD.SERIES.FROM) = ''
            R.NEW(RE.ORD.SERIES.TO) = ''
            RETURN
        END
        FINDSTR "ALCANCIAS" IN Y.PIGGY.CHK SETTING POS.AP THEN
            R.NEW(RE.ORD.SERIES.FROM) = ''
            R.NEW(RE.ORD.SERIES.TO) = ''
            RETURN
        END
        FINDSTR "iggy" IN Y.PIGGY.CHK SETTING POS.AP THEN
            R.NEW(RE.ORD.SERIES.FROM) = ''
            R.NEW(RE.ORD.SERIES.TO) = ''
            RETURN
        END

    END
    Y.SEQ.FROM = R.NEW(RE.ORD.SERIES.FROM)
    Y.SEQ.TO = R.NEW(RE.ORD.SERIES.TO)
    Y.REQ.COMP = R.NEW(RE.ORD.REQUEST.COMPANY)
    Y.DEL.QUL =  R.NEW(RE.ORD.DELEVIRY.QUANTITY)

    Y.COMPANY = ID.COMPANY
    Y.CODE =    R.NEW(RE.ORD.BRANCH.CODE)
    Y.ITEM =    Y.INV.MNT.ID
    IF Y.CODE THEN
        Y.ID = Y.COMPANY:'-':Y.CODE:'.':Y.ITEM
    END ELSE
        Y.ID = Y.COMPANY:'.':Y.ITEM
    END

    CALL F.READ(FN.REDO.ITEM.SERIES,Y.ID,R.REDO.ITEM.SERIES,F.REDO.ITEM.SERIES,Y.ERR)
    Y.CNT.TOT = DCOUNT(R.REDO.ITEM.SERIES,@FM)
    Y.SERIES.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',1,1)
    Y.STATUS.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',2,1)
    Y.BATCH.LIST.DUP = FIELDS(R.REDO.ITEM.SERIES,'*',3,1)

    CALL APAP.TAM.REDO.CHECK.APPLICATION(Y.INV.MNT.ID,APPL.NAME,APPL.PATH) ;* R22 Manual Conversion - CALL method format modified
    CALL OPF(APPL.NAME,APPL.PATH)
    SEQ.COUNT = DCOUNT(R.NEW(RE.ORD.SERIES.FROM),@VM)
    Y.CNT = 1
    LOOP
    WHILE Y.CNT LE SEQ.COUNT DO
        Y.SEQ.FROM = R.NEW(RE.ORD.SERIES.FROM)<1,Y.CNT>
        Y.SEQ.TO = R.NEW(RE.ORD.SERIES.TO)<1,Y.CNT>

        Y.DIFF = Y.SEQ.TO - Y.SEQ.FROM
        GOSUB QUANTITY.CHECK
        LOOP
        WHILE Y.SEQ.FROM LE Y.SEQ.TO DO
            GOSUB CASE.FILE.SEL
            Y.SEQ.FROM += 1

            Y.TOTAL.VAL += 1 ;*R22 Auto Code Conversion
        REPEAT
        Y.CNT += 1
    REPEAT

    IF Y.DEL.QUL NE Y.TOTAL.VAL THEN
        AF=RE.ORD.DELEVIRY.QUANTITY
        ETEXT = "EB-DEL.QUANTITY.NOT.EQ"
        CALL STORE.END.ERROR
    END
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
    Y.BATCH = ''
    LOCATE Y.SEQ.FROM IN Y.SERIES.LIST.DUP SETTING POS.SE THEN
        Y.BATCH = Y.BATCH.LIST.DUP<POS.SE>
    END
    IF Y.BATCH THEN
        CALL F.READ(APPL.NAME,Y.BATCH,R.REC,APPL.PATH,Y.ERR)
    END
    IF R.REC THEN
        AF =  RE.ORD.SERIES.FROM
        ETEXT = 'EB-INVENTORY.ALREADY.EXISTS'
        CALL STORE.END.ERROR
        GOSUB PROGRAM.END
    END
RETURN
*-----------------------------------------------------------------------------------------
PROGRAM.END:
*-----------------------------------------------------------------------------------------
END
