* @ValidationCode : MjoxMzg0NTk0MDE2OkNwMTI1MjoxNjg1NTI5MTA2NTk3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:01:46
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
SUBROUTINE REDO.B.AA.LEN.DET.DEB(Y.AA.ARR.ID)
*-----------------------------------------------------------------------------
*
* Developed By            : Vijayarani G
*
* Developed On            : 12-NOV-2013
*
* Development Reference   : 786844(FS-207-DE21)
*
* Development Description : A report Contains antecedents of each credit that belongs to the Debtors of the Bank,
*                           indicating both the current amount and the past due  amount of 31-90 days, and for more
*                           than 90 days past due, of the natural and legal persons indebted to the bank,
*                           detailing by account credits each, plus interest receivable detail.
*
* Attached To             : BATCH>BNK/REDO.B.AA.LEN.DET.DEB
*
* Attached As             : COB Routine
*
*-----------------------------------------------------------------------------------------------------------------
*  M O D I F I C A T I O N S
*-----------------------------------------------------------------------------------------------------------------
* Defect Reference       Modified By                    Date of Change        Change Details
* NA                     NA                             NA                    NA
*-----------------------------------------------------------------------------------------------------------------
* XXXX                   Vijayarani G                   06-DEC-2013           Code changes done for issue fixing
*                        Vijayarani G                   10-DEC-2013           Code changes done for issue fixing
* PACS00361224           Amaravathi Krithika B          24-May-2014           Getting Negative Value for the Date Comparision So changed that as
*                                                                             today date can be set as last day of previous month
* PACS00361224           Ashokkumar.V.P                 30/10/2014            New mapping changes - Rewritten the whole source.
* PACS00464363           Ashokkumar.V.P                 22/06/2015            Changed to avoid ageing problem and mapping changes.
* R22 Auto conversion    Conversion Tool                29-MAR-2023           ++ to +=, FM TO @FM, VM to @VM, SM to @SM
* Manual R22 conversion  Harishvikram C                 29-MAR-2023           Modified CALL routine format
*-----------------------------------------------------------------------------------------------------------------
* Include files
*-----------------------------------------------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.COMPANY
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_F.RE.STAT.REP.LINE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_REDO.B.AA.LEN.DET.DEB.COMMON
    $INSERT I_F.REDO.H.REPORTS.PARAM
    $USING APAP.TAM
    $USING APAP.REDOCHNLS


* </region>
*-----------------------------------------------------------------------------
*
    GOSUB PROCESS.INIT
    GOSUB CHK.AA.ARR.ID
RETURN
*
CHK.AA.ARR.ID:
*-------------
    ARR.ERR = ""; R.AA.ARRANGEMENT = ""
    CALL F.READ(FN.AA.ARR,Y.AA.ARR.ID,R.AA.ARRANGEMENT,F.AA.ARR,AA.ARRANGEMENT.ERR)
    Y.PROD.LINE = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.LINE>
    Y.PROD.GRP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    PRODUCT.ID = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
    Y.ARR.STATUS = R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>
    CURRENCY = R.AA.ARRANGEMENT<AA.ARR.CURRENCY>
    EFFECTIVE.DATE = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE>
    STAR.DATE.VAL = R.AA.ARRANGEMENT<AA.ARR.START.DATE>

    IF (Y.ARR.STATUS EQ "CURRENT" OR Y.ARR.STATUS EQ "EXPIRED") ELSE
        RETURN
    END
    YLST.TODAY1 = YLST.TODAY
    IF STAR.DATE.VAL GT YLST.TODAY1 THEN
        RETURN
    END

    CONS.POS = ''
    IF Y.PROD.GRP EQ 'LINEAS.DE.CREDITO' THEN
        FINDSTR "COM" IN PRODUCT.ID SETTING CONS.POS THEN
        END ELSE
            RETURN
        END
    END

    ARRAY.VAL = ''; Y.LOAN.STATUS = ''; Y.CLOSE.LN.FLG = 0
    APAP.TAM.redoRptClseWriteLoans(Y.AA.ARR.ID,R.AA.ARRANGEMENT,ARRAY.VAL);* R22 Manual conversion
    Y.LOAN.STATUS = ARRAY.VAL<1>
    Y.CLOSE.LN.FLG = ARRAY.VAL<2>
    IF Y.LOAN.STATUS EQ "Write-off" THEN
        RETURN
    END
    IF Y.CLOSE.LN.FLG NE 1 THEN
        GOSUB READ.ACCT.DETAILS
        GOSUB GET.COMMON.FIELDS
        GOSUB GET.ACC.ACCOUNT
        GOSUB ACC.NAB.PROCESS
        GOSUB RUN.PROCESS
    END
RETURN

GET.COMMON.FIELDS:
*-----------------
    Y.LINKED.APPL    = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL>
    Y.LINKED.APPL.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>

    LOCATE "ACCOUNT" IN Y.LINKED.APPL<1,1> SETTING Y.LINKED.POS THEN
        Y.FINAL.MSG = ""; Y.FINAL.AMT = ""; Y.FINAL.DAYS = ""
        CHANGE @VM TO @FM IN Y.LINKED.APPL.ID
        Y.NROPRESTAMO  = Y.LINKED.APPL.ID<Y.LINKED.POS>
    END

    Y.ACCT.ID = Y.NROPRESTAMO
    GOSUB READ.ACCOUNT
    IF ERR.ACCOUNT THEN
        RETURN
    END
    Y.ARRAY.VAL = ''; Y.PREV.ACCOUNT = ''
    YACCT.GRP = R.ACCOUNT:"###":R.AA.ARRANGEMENT
    APAP.TAM.redoRptAcctAltLoans(YACCT.GRP,Y.PREV.ACCOUNT);* R22 Manual conversion
    IF NOT(Y.PREV.ACCOUNT) THEN
        Y.PREV.ACCOUNT = Y.NROPRESTAMO
    END
    C$SPARE(452) = Y.PREV.ACCOUNT

    Y.LCY = LCCY
    AR.CCY = CURRENCY
    IF AR.CCY EQ Y.LCY THEN
        VAL.CCCY = "N"
    END ELSE
        VAL.CCCY = "E"
    END
    C$SPARE(457) = VAL.CCCY
RETURN

GET.ACC.ACCOUNT:
****************
    IF Y.NROPRESTAMO NE '' THEN
        CALL F.READ(FN.EB.CONT.BAL,Y.NROPRESTAMO,R.EB.CONTRACT.BALANCES,F.EB.CONT.BAL,EB.CONTRACT.BALANCES.ERR)
        IF R.EB.CONTRACT.BALANCES THEN
            Y.CONSOL.KEY = R.EB.CONTRACT.BALANCES<ECB.CONSOL.KEY>
            Y.CONSOL.PART = FIELD(Y.CONSOL.KEY,'.',1,16)
            Y.ASSET.TYPE = R.EB.CONTRACT.BALANCES<ECB.CURR.ASSET.TYPE>
            CTR.BAL.TYPE = 1
            CNT.BAL.TYPE = DCOUNT(Y.ASSET.TYPE,@VM)
            LOOP
                C$SPARE(456) = ''; C$SPARE(455) = ''
                C$SPARE(453) = ''; C$SPARE(454) = ''
            WHILE CTR.BAL.TYPE LE CNT.BAL.TYPE
                ACC.POS = '';  RET.FLG = 0; Y.ASSET.TYPE.TP = ''
                BAL.TYPE1 = Y.ASSET.TYPE<1,CTR.BAL.TYPE>
                Y.ASSET.TYPE.TP = R.EB.CONTRACT.BALANCES<ECB.CURR.ASSET.TYPE,CTR.BAL.TYPE>
                LEN.TYPE = LEN(BAL.TYPE1)
                REQ.LEN = BAL.TYPE1[((LEN.TYPE-AC.LEN)+1),AC.LEN]
                REQ.INT.LEN = BAL.TYPE1[((LEN.TYPE-PRIN.INT.LEN)+1),PRIN.INT.LEN]
                IF (REQ.LEN EQ 'ACCOUNT') OR (REQ.INT.LEN EQ 'PRINCIPALINT') THEN
                    Y.IN.CONSOL.KEY = Y.CONSOL.PART:'.':BAL.TYPE1     ;*alter the consol key with current balance type in analysis
                    Y.VARIABLE = ''; YACC.STAT = ''
                    CALL RE.CALCUL.REP.AL.LINE(Y.IN.CONSOL.KEY,Y.RPRTS,Y.LINES,Y.VARIABLE)
                    Y.LINE = Y.RPRTS:'.':Y.LINES
                    CALL F.READ(FN.RE.STAT.REP.LINE,Y.LINE,R.LINE,F.RE.STAT.REP.LINE,REP.ERR)
                    GOSUB REG.ACCOUNT.NO
                END
                CTR.BAL.TYPE += 1
            REPEAT
        END
    END
RETURN

REG.ACCOUNT.NO:
***************
    IF R.LINE THEN
        Y.REGULATORY.ACC.NO = R.LINE<RE.SRL.DESC,1>         ;* get accounting account for the current balance type in analysis
        IF Y.REGULATORY.ACC.NO[1,1] EQ '8' THEN
            RETURN
        END
        LOCATE Y.REGULATORY.ACC.NO IN SAVE.ACC.AC<1> SETTING ACC.POS THEN
            GOSUB CHECK.ASSET.TYPE
            RET.FLG = 1
        END ELSE
            GOSUB SAVE.UNIQUE.AC.ACC
        END
        YACC.STAT = BAL.TYPE1[1,3]
        GOSUB BILL.VALUE.CHK
        RET.FLG = 0
    END
RETURN

SAVE.UNIQUE.AC.ACC:
*******************
    YGRP.ACCT.NO<-1> = Y.NROPRESTAMO
    SAVE.ACC.AC<-1> = Y.REGULATORY.ACC.NO
    CALL AA.GET.PERIOD.BALANCES(Y.NROPRESTAMO, BAL.TYPE1,REQUEST.TYPE, START.DATE, END.DATE, '',BAL.DETAILS, ERROR.MESSAGE)
    ASSET.TYPE.ARRAY<-1> = BAL.TYPE1
    DAT.BALANCES = BAL.DETAILS<4>
    BAL.AMT<-1> = DAT.BALANCES
RETURN

SAVE.EXISTING.AC.ACC:
*********************
    CALL AA.GET.PERIOD.BALANCES(Y.NROPRESTAMO, BAL.TYPE1,REQUEST.TYPE, START.DATE, END.DATE, '',BAL.DETAILS, ERROR.MESSAGE)
    DAT.BALANCES = BAL.DETAILS<4>
    NEW.AMT = DAT.BALANCES + BAL.AMT<ACC.POS>
    BAL.AMT<ACC.POS> = NEW.AMT
RETURN

CHECK.ASSET.TYPE:
*****************
    LOCATE BAL.TYPE1 IN ASSET.TYPE.ARRAY<1> SETTING ASSET.POS THEN
        ASSET.POS = ''
    END ELSE
        ASSET.TYPE.ARRAY<-1> = BAL.TYPE1
        GOSUB SAVE.EXISTING.AC.ACC
    END
RETURN

RUN.PROCESS:
*----------*
    CTR.LINE = 1
    CNT.LINE = DCOUNT(SAVE.ACC.AC,@FM)
    LOOP
    WHILE CTR.LINE LE CNT.LINE
        ACC.NO.LINE = SAVE.ACC.AC<CTR.LINE>
        BAL.AMT.LINE = BAL.AMT<CTR.LINE>
        IF BAL.AMT.LINE LT '0' AND BAL.AMT.LINE NE '' THEN
            AC.ACCOUNT.PRINT = ACC.NO.LINE
            AC.BAL.PRINT = ABS(BAL.AMT.LINE)
            C$SPARE(453) = SAVE.ACC.AC<CTR.LINE>
            C$SPARE(455) = Y.ARR.AGE.DAYS<CTR.LINE>
            C$SPARE(456) = Y.ARR.INST.NUM<CTR.LINE>
            C$SPARE(454) = AC.BAL.PRINT
            GOSUB MAP.RCL.VALUES
        END
        CTR.LINE += 1
    REPEAT
RETURN

READ.ACCOUNT:
*************
    ERR.ACCOUNT = ''; R.ACCOUNT = ''
    CALL F.READ(FN.ACCOUNT,Y.ACCT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
RETURN

ACC.NAB.PROCESS:
****************
    R.REDO.CONCAT.ACC.NAB = ''; NAB.ERR = ''; YACC.NABBAL = ''; YNAB.STATUS = ''; YOPEN.DATE = ''
    CALL F.READ(FN.REDO.CONCAT.ACC.NAB,Y.NROPRESTAMO,R.REDO.CONCAT.ACC.NAB,F.REDO.CONCAT.ACC.NAB,NAB.ERR)
    IF NOT(R.REDO.CONCAT.ACC.NAB) THEN
        RETURN
    END
    Y.ACCT.ID = R.REDO.CONCAT.ACC.NAB
    GOSUB READ.ACCOUNT
    YACC.NABBAL = R.ACCOUNT<AC.WORKING.BALANCE>
    YNAB.STATUS = R.ACCOUNT<AC.LOCAL.REF,L.OD.STATUS.POS>
    YOPEN.DATE = R.ACCOUNT<AC.OPENING.DATE>
    IF YOPEN.DATE EQ Y.TODAY THEN
        RETURN
    END
    YCRF.TYPE = 'OFFDB'
    Y.REGULATORY.ACC.NO = ''; R.EB.CONTRACT.BALANCES = ''; Y.IN.CONSOL.KEY = ''
    CALL F.READ(FN.EB.CONT.BAL,R.REDO.CONCAT.ACC.NAB,R.EB.CONTRACT.BALANCES,F.EB.CONT.BAL,EB.CONTRACT.BALANCES.ERR)
    IF R.EB.CONTRACT.BALANCES AND YNAB.STATUS EQ 'NAB' THEN
        Y.CONSOL.KEY = R.EB.CONTRACT.BALANCES<ECB.CONSOL.KEY>
        Y.CONSOL.PART = FIELD(Y.CONSOL.KEY,'.',1,16)
        Y.IN.CONSOL.KEY = Y.CONSOL.PART:'.':YCRF.TYPE
        Y.VARIABLE = ''; Y.RPRTS = ''; Y.LINES = ''
        CALL RE.CALCUL.REP.AL.LINE(Y.IN.CONSOL.KEY,Y.RPRTS,Y.LINES,Y.VARIABLE)
        Y.LINE = Y.RPRTS:'.':Y.LINES
        CALL F.READ(FN.RE.STAT.REP.LINE,Y.LINE,R.LINE,F.RE.STAT.REP.LINE,REP.ERR)
        Y.REGULATORY.ACC.NO = R.LINE<RE.SRL.DESC,1>
        YGRP.ACCT.NO<-1> = R.REDO.CONCAT.ACC.NAB
        SAVE.ACC.AC<-1> = Y.REGULATORY.ACC.NO
        BAL.AMT<-1> = YACC.NABBAL
        YACC.STAT = 'NAB'
        Y.ARR.YACC.STAT = ''
        GOSUB BILL.VALUE.CHK
    END
RETURN

BILL.VALUE.CHK:
***************
    YAGING.STAT = ''; YSET.STAT = ''; Y.BIL.DATE = ''; FM.AGS = ''; SM.AGS = ''
    VM.AGS = ''; SET.STAT = 0; YINSTALL.CNT = 0; YBILL.STAT = ''; Y.SET.STAT = ''
    YCURR.ASS.VAL = ''; YFM.POSN = ''; Y.FM.POSN = ''
    LOCATE YACC.STAT IN Y.ARR.YACC.STAT<1> SETTING YFM.POSN THEN
        LOCATE Y.ASSET.TYPE.TP IN Y.ASSET.TYPE.ARR<1> SETTING Y.FM.POSN THEN
            RETURN
        END
    END

    IF YACC.STAT EQ 'DUE' THEN
        YTEM.SET.STAT = 0; YTEM.INST.NUM = 0
        YTEM.SET.STAT = Y.ARR.AGE.DAYS<ACC.POS>
        YTEM.INST.NUM = Y.ARR.INST.NUM<ACC.POS>
        Y.ARR.AGE.DAYS<ACC.POS> = YTEM.SET.STAT
        Y.ARR.INST.NUM<ACC.POS> = YTEM.INST.NUM
        RETURN
    END
    YSET.STAT = R.AA.ACCT.DET<AA.AD.SET.STATUS>
    YAGING.STAT = R.AA.ACCT.DET<AA.AD.AGING.STATUS>
    YBILL.STAT = R.AA.ACCT.DET<AA.AD.BILL.STATUS>

    FINDSTR YACC.STAT IN YAGING.STAT<1> SETTING FM.AGU,SM.AGU,VM.AGU THEN
        Y.SET.STAT = R.AA.ACCT.DET<AA.AD.SET.STATUS,SM.AGU,VM.AGU>
        IF Y.SET.STAT EQ 'UNPAID' THEN
            Y.BIL.DATE = R.AA.ACCT.DET<AA.AD.BILL.DATE,SM.AGU,VM.AGU>
            GOSUB LOOP.INSTAL.DET
        END
    END

    IF (Y.BIL.DATE LT Y.TODAY) AND (LEN(Y.BIL.DATE) EQ 8 AND LEN(Y.TODAY) EQ 8) THEN
        YDAYS = 'C'
        CALL CDD('',Y.BIL.DATE,YLST.TODAY,YDAYS)
        SET.STAT = YDAYS + 1
    END

    IF RET.FLG EQ 1 THEN
        YTEM.SET.STAT = ''
        YTEM.SET.STAT = Y.ARR.AGE.DAYS<ACC.POS>
        IF SET.STAT GT YTEM.SET.STAT THEN
            Y.ARR.AGE.DAYS<ACC.POS> = SET.STAT
        END
        Y.ARR.INST.NUM<ACC.POS> += YINSTALL.CNT
    END ELSE
        Y.ARR.AGE.DAYS<-1> = SET.STAT
        Y.ARR.INST.NUM<-1> = YINSTALL.CNT
    END
    Y.ARR.YACC.STAT<-1> = YACC.STAT
    Y.ASSET.TYPE.ARR<-1> = Y.ASSET.TYPE.TP
RETURN

LOOP.INSTAL.DET:
****************
    YAGING.STAT.CNT = ''; YPROCESS.CNT = 0; YGP.AGING.STAT = ''; YGP.SET.STAT = ''
    YAGING.STAT.CNT = DCOUNT(YAGING.STAT,@VM)
    LOOP
    UNTIL YPROCESS.CNT EQ YAGING.STAT.CNT
        YPROCESS.CNT += 1
        YGP.AGING.STAT = R.AA.ACCT.DET<AA.AD.AGING.STATUS,YPROCESS.CNT,1>
        YGP.SET.STAT = R.AA.ACCT.DET<AA.AD.SET.STATUS,YPROCESS.CNT,1>
        IF YACC.STAT EQ YGP.AGING.STAT AND YGP.SET.STAT EQ 'UNPAID' THEN
            YINSTALL.CNT += 1
        END
    REPEAT
RETURN

PROCESS.INIT:
*************
    REQUEST.TYPE = ''
    START.DATE = STAR.DATE.VAL
    END.DATE = YLST.TODAY1
    REQUEST.TYPE<4>='ECB'
    STRT.DATE.PRINT = ''
    AC.BAL.PRINT = ''
    AC.ACCOUNT.PRINT = ''
    AC.INTEREST.PRINT = ''
    LINK.POS = ''
    STRT.DATE = ''
    LEN.TERM = ''
    D.PART = ''
    TERM.PRINT = ''
    ASSET.TYPE.ARRAY = ''
    SAVE.ACC.AC = ''
    BAL.AMT = ''
    R.EB.CONTRACT.BALANCES = ''
    EB.CONTRACT.BALANCES.ERR = ''
    AC.LEN = 7      ;* This is length of word 'ACCOUNT'
    PRIN.INT.LEN = 12         ;* This is length of word 'PRINCIPALINT'
RETURN

READ.ACCT.DETAILS:
******************
    R.AA.ACCT.DET = ''; AA.ACCT.DET.ERR = ''
    CALL F.READ(FN.AA.ACCT.DET,Y.AA.ARR.ID,R.AA.ACCT.DET,F.AA.ACCT.DET,AA.ACCT.DET.ERR)
RETURN
*-------------------------------------------------
MAP.RCL.VALUES:
*------------------------------------------------
* Pass arguments to RCL and get the return message
*-------------------------------------------------
    R.RETURN.MSG = ""
    RCL.ID  = Y.RCL.ID
    MAP.FMT = "MAP"
    APP     = FN.AA.ARR
    R.APP   = R.AA.ARRANGEMENT
    CALL RAD.CONDUIT.LINEAR.TRANSLATION(MAP.FMT,RCL.ID,APP,Y.AA.ARR.ID,R.APP,R.RETURN.MSG,ERR.MSG)
    IF R.RETURN.MSG THEN
        WRK.FILE.ID = Y.AA.ARR.ID:'.':CTR.LINE
        CALL F.WRITE(FN.DR.REG.DE21.WORKFILE,WRK.FILE.ID,R.RETURN.MSG)
    END
RETURN
*-----------------------------------------------------------------------------------------------------------------
RAISE.ERR.C.22:
*-----------------------------------------------------------------------------------------------------------------
*Handling Fatal error to halt the process
*-----------------------------------------------------------------------------------------------------------------
    MON.TP    = "21"
    Y.ERR.MSG = "Record not found"
    REC.CON   = "DE21-":Y.AA.ARR.ID:Y.ERR.MSG
    DESC      = "DE21-":Y.AA.ARR.ID:Y.ERR.MSG
    INT.CODE  = 'REP001'
    INT.TYPE  = 'ONLINE'
    BAT.NO    = ''
    BAT.TOT   = ''
    INFO.OR   = ''
    INFO.DE   = ''
    ID.PROC   = ''
    EX.USER   = ''
    EX.PC     = ''
    APAP.REDOCHNLS.redoInterfaceRecAct(INT.CODE,INT.TYPE,BAT.NO,BAT.TOT,INFO.OR,INFO.DE,ID.PROC,MON.TP,DESC,REC.CON,EX.USER,EX.PC);* R22 Manual conversion - Modified CALL routine format
*
RETURN
*------------------------------------------------------------------Final End-------------------------------------------
END
