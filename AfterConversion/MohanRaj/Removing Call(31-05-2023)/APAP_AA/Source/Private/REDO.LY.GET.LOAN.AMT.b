* @ValidationCode : Mjo0NzgwNjk0MjpDcDEyNTI6MTY4NTUzMTA2OTEyNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:34:29
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
SUBROUTINE REDO.LY.GET.LOAN.AMT
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: S SUDHARSANAN
* PROGRAM NAME: REDO.LY.GET.LOAN.AMT
* ODR NO      : ODR-2010-09-0012
*----------------------------------------------------------------------
*DESCRIPTION: To generate the points based on the parameter setup is done in REDO.LY.MODALITY and REDO.LY.PROGRAM for each repayment for Loan product
*IN PARAMETER: N/A
*OUT PARAMETER: N/A
*LINKED WITH: Post routine is attached to the ACTIVITY.CLASS of LENDING-APPLYPAYMENT-PAYMENT.RULES, LENDING-SETTLE-PAYMENT.RULES & LENDING-CREDIT-ARRANGEMENT
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*23.10.2010  S SUDHARSANAN    ODR-2010-09-0012  INITIAL CREATION
*31.05.2013  RMONDRAGON    ODR-2011-06-0243 UPDATE
*29-03-2023      CONVERSION TOOL         AUTO R22 CODE CONVERSION     FM TO @FM,VM TO @VM,SM TO @SM,++ TO =1
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.DATES
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.LY.MODALITY
    $INSERT I_F.REDO.LY.PROGRAM
    $INSERT I_F.REDO.LY.POINTS
    $INSERT I_F.REDO.LY.POINTS.TOT
    $INSERT I_F.REDO.LY.CUSGROUP
    $INSERT I_F.REDO.LY.PDT.TYPE
    $INSERT I_F.REDO.LY.MASTERPRGDR
    $USING APAP.TAM
    GOSUB INIT
    GOSUB OPENFILES
    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB GET.PROPERTY
*        GOSUB CHECK.MOD
        GOSUB CHECK.PROD.GRP
    END
RETURN
*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------
    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    FN.REDO.LY.MODALITY = 'F.REDO.LY.MODALITY'
    F.REDO.LY.MODALITY =''
    FN.REDO.LY.PROGRAM = 'F.REDO.LY.PROGRAM'
    F.REDO.LY.PROGRAM = ''
    FN.REDO.LY.POINTS = 'F.REDO.LY.POINTS'
    F.REDO.LY.POINTS =''
    FN.REDO.LY.POINTS.TOT = 'F.REDO.LY.POINTS.TOT'
    F.REDO.LY.POINTS.TOT =''
    FN.REDO.LY.CUSGROUP = 'F.REDO.LY.CUSGROUP'
    F.REDO.LY.CUSGROUP =''
    FN.ACCT.ACTIVITY = 'F.ACCT.ACTIVITY'
    F.ACCT.ACTIVITY = ''
    FN.CUSTOMER = 'F.CUSTOMER'
    F.CUSTOMER = ''
    FN.REDO.LY.PDT.TYPE = 'F.REDO.LY.PDT.TYPE'
    F.REDO.LY.PDT.TYPE = ''
    FN.REDO.LY.MASTERPRGDR = 'F.REDO.LY.MASTERPRGDR'
    F.REDO.LY.MASTERPRGDR = ''
    IN.ACC.ID = ''
    Y.ARR.ID = ''
    OUT.ID = ''
    G.DATE = ''
    I.DATE = DATE()
    CALL DIETER.DATE(G.DATE,I.DATE,'')
    LOC.REF.POS = ''
*    CALL GET.LOC.REF('CUSTOMER','L.CU.G.LEALTAD',LOC.REF.POS)
    LOC.REF.APP = 'CUSTOMER':@FM:'AA.PRD.DES.OVERDUE' ;*AUTO R22 CODE CONVERSION
    LOC.REF.FIELD = 'L.CU.G.LEALTAD':@FM:'L.LOAN.STATUS.1':@VM:'L.LOAN.COND' ;*AUTO R22 CODE CONVERSION
    CALL MULTI.GET.LOC.REF(LOC.REF.APP,LOC.REF.FIELD,LOC.REF.POS)
    POS.CU.G.LEALTAD = LOC.REF.POS<1,1>
    POS.L.LOAN.STATUS = LOC.REF.POS<2,1>
    POS.L.LOAN.COND = LOC.REF.POS<2,2>
    CUR.DAY   = TODAY[7,2]
    CUR.MONTH = TODAY[5,2]
    CUR.YEAR  = TODAY[1,4]
RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)
    CALL OPF(FN.REDO.LY.MODALITY,F.REDO.LY.MODALITY)
    CALL OPF(FN.REDO.LY.PROGRAM,F.REDO.LY.PROGRAM)
    CALL OPF(FN.REDO.LY.POINTS,F.REDO.LY.POINTS)
    CALL OPF(FN.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT)
    CALL OPF(FN.REDO.LY.CUSGROUP,F.REDO.LY.CUSGROUP)
    CALL OPF(FN.ACCT.ACTIVITY,F.ACCT.ACTIVITY)
    CALL OPF(FN.CUSTOMER,F.CUSTOMER)
    CALL OPF(FN.REDO.LY.PDT.TYPE,F.REDO.LY.PDT.TYPE)
    CALL OPF(FN.REDO.LY.MASTERPRGDR,F.REDO.LY.MASTERPRGDR)
RETURN
*----------------------------------------------------------------------
GET.PROPERTY:
*-----------------------------------------------------------------------
    VAR.ARR.ID =  c_aalocArrId
    IN.PROPERTY.CLASS='ACCOUNT'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.ACC.PROPERTY,OUT.ERR);* R22 Manual conversion
    IN.PROPERTY.CLASS='INTEREST'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.INT.PROPERTY,OUT.ERR);* R22 Manual conversion
    IN.PROPERTY.CLASS='TERM.AMOUNT'
    APAP.TAM.redoGetPropertyName(VAR.ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,Y.TERM.PROPERTY,OUT.ERR);* R22 Manual conversion
RETURN
*----------------------------------------------------------------------
CHECK.PROD.GRP:
*----------------------------------------------------------------------
    SEL.PG = 'SELECT ':FN.REDO.LY.PDT.TYPE:' WITH PRODUCT.TYPE EQ "Prestamo"'
    CALL EB.READLIST(SEL.PG,SEL.PG.LIST,'',NOR.PG,PG.ERR)
    PG.CNT = 1
    LOOP
    WHILE PG.CNT LE NOR.PG
        Y.PG = FIELD(SEL.PG.LIST,@FM,PG.CNT) ;*AUTO R22 CODE CONVERSION
        CALL F.READ(FN.REDO.LY.PDT.TYPE,Y.PG,R.REDO.LY.PDT.TYPE,F.REDO.LY.PDT.TYPE,PG.ERR)
        IF R.REDO.LY.PDT.TYPE THEN
            Y.CAT.LIST = R.REDO.LY.PDT.TYPE<REDO.PDT.PRODUCT>
            Y.CAT.LIST = CHANGE(Y.CAT.LIST,@VM,@FM) ;*AUTO R22 CODE CONVERSION
            GOSUB GET.ACCOUNT
            LOCATE Y.CATEGORY IN Y.CAT.LIST SETTING CAT.POS THEN
                GOSUB CHECK.MOD
            END
        END
        PG.CNT += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------------------
CHECK.MOD:
*----------------------------------------------------------------------
*    SEL.MOD = 'SELECT ':FN.REDO.LY.MODALITY:' WITH PRODUCT.GROUP EQ 2 OR PRODUCT.GROUP EQ 3'
    SEL.MOD = 'SSELECT ':FN.REDO.LY.MODALITY:' WITH PRODUCT.GROUP EQ ':Y.PG
    CALL EB.READLIST(SEL.MOD,SEL.MOD.LIST,'',NOR.MOD,MOD.ERR)
    MOD.CNT = 1
    LOOP
    WHILE MOD.CNT LE NOR.MOD
        PT.QTY = 0; PT.VAL = 0
        GOSUB GET.MOD.VALUE
        IF Y.MOD.TYPE EQ 1 THEN
            SEL.PRG = 'SELECT ':FN.REDO.LY.PROGRAM:' WITH MODALITY EQ ':MOD.ID
            CALL EB.READLIST(SEL.PRG,SEL.PRG.LIST,'',NOR.PRG,PRG.ERR)
            GOSUB CHECK.PRG
        END
        MOD.CNT += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------------------------------------
GET.MOD.VALUE:
*----------------------------------------------------------------------------------------
    MOD.ID = SEL.MOD.LIST<MOD.CNT>
    R.MODALITY = '' ; Y.FORM.GEN =''; Y.PRODUCT.GROUP = ''; Y.DISBURSE.AMT = ''; Y.GEN.AMT = ''; Y.GEN.POINTS =''
    Y.LOW.LIM.AMT = ''; Y.UP.LIM.AMT = ''; Y.INT.GEN.POINTS = ''; Y.INT.LOW.LIM.AMT = ''; Y.INT.UP.LIM.AMT ='' ;
    Y.GEN.FACTOR = ''; Y.MIN.GEN ='' ; Y.MAX.GEN = '' ;  Y.INT.GEN.FACTOR = '' ; Y.INT.MIN.GEN = '' ; Y.INT.MAX.GEN = '' ;
    CALL F.READ(FN.REDO.LY.MODALITY,MOD.ID,R.MODALITY,F.REDO.LY.MODALITY,ERR.MOD)
    Y.MOD.TYPE = R.MODALITY<REDO.MOD.TYPE>
    Y.FORM.GEN = R.MODALITY<REDO.MOD.FORM.GENERATION>
    Y.PRODUCT.GROUP = R.MODALITY<REDO.MOD.PRODUCT.GROUP>
    Y.GEN.AMT = R.MODALITY<REDO.MOD.GEN.AMT>
    Y.DISBURSE.AMT = R.MODALITY<REDO.MOD.MIN.DISBURSE.AMT>
    Y.GEN.POINTS = R.MODALITY<REDO.MOD.GEN.POINTS>
    Y.LOW.LIM.AMT = R.MODALITY<REDO.MOD.LOW.LIM.AMT>
    Y.UP.LIM.AMT = R.MODALITY<REDO.MOD.UP.LIM.AMT>
    Y.INT.GEN.POINTS = R.MODALITY<REDO.MOD.INT.GEN.POINTS>
    Y.INT.LOW.LIM.AMT = R.MODALITY<REDO.MOD.INT.LOW.LIM.AMT>
    Y.INT.UP.LIM.AMT = R.MODALITY<REDO.MOD.INT.UP.LIM.AMT>
    Y.GEN.FACTOR = R.MODALITY<REDO.MOD.GEN.FACTOR>
    Y.MIN.GEN = R.MODALITY<REDO.MOD.MIN.GEN>
    Y.MAX.GEN = R.MODALITY<REDO.MOD.MAX.GEN>
    Y.INT.GEN.FACTOR = R.MODALITY<REDO.MOD.INT.GEN.FACTOR>
    Y.INT.MIN.GEN = R.MODALITY<REDO.MOD.INT.MIN.GEN>
    Y.INT.MAX.GEN = R.MODALITY<REDO.MOD.INT.MAX.GEN>
RETURN
*----------------------------------------------------------------------------------------
CHECK.PRG:
*----------------------------------------------------------------------------------------
    PRG.CNT = 1
    LOOP
    WHILE PRG.CNT LE NOR.PRG
        GOSUB GET.PRG.VALUE
        GOSUB UPD.CUS.GRP
        IF TODAY GE PRG.ST.DATE AND Y.OUT EQ 'N' THEN
            IF PRG.END.DATE THEN
                IF TODAY LE PRG.END.DATE THEN
*                    GOSUB GET.ACCOUNT
                    GOSUB GET.CUS.GROUP
                    IF GEN EQ 'NG' THEN
                        PRG.CNT += 1 ;*AUTO R22 CODE CONVERSION
                        CONTINUE
                    END
                    FILE.UPD.STOP = ''
                    GOSUB CHECK.EXC.INC.COND
                    IF FILE.UPD.STOP EQ 1 THEN
                        PRG.CNT += 1 ;*AUTO R22 CODE CONVERSION
                        CONTINUE
                    END
                    GOSUB CHK.PRODUCT
                END
            END ELSE
*                GOSUB GET.ACCOUNT
                GOSUB GET.CUS.GROUP
                IF GEN EQ 'NG' THEN
                    PRG.CNT += 1 ;*AUTO R22 CODE CONVERSION
                    CONTINUE
                END
                FILE.UPD.STOP = ''
                GOSUB CHECK.EXC.INC.COND
                IF FILE.UPD.STOP EQ 1 THEN
                    PRG.CNT += 1 ;*AUTO R22 CODE CONVERSION
                    CONTINUE
                END
                GOSUB CHK.PRODUCT
            END
        END
        PRG.CNT += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*-------------------------------------------------------------------------------------------
GET.PRG.VALUE:
*-------------------------------------------------------------------------------------------
    PRG.ID  =  SEL.PRG.LIST<PRG.CNT>
    R.PROGRAM = '' ;
    PRG.ST.DATE = ''  ; PRG.END.DATE = ''
    PRG.PT.VALUE = ''
    PRG.DAYS.EXP = '' ; PRG.EXP.DATE = ''
    PRG.MOD = ''      ; PRG.PRO = ''
    PRG.CUS.GRP = ''; Y.OUT = 'N'
    CALL F.READ(FN.REDO.LY.PROGRAM,PRG.ID,R.REDO.LY.PROGRAM,F.REDO.LY.PROGRAM,ERR.PRG)
    PRG.STA = R.REDO.LY.PROGRAM<REDO.PROG.STATUS>
    IF PRG.STA EQ 'No Activo' THEN
        Y.OUT = 'Y'
        RETURN
    END
    PRG.MOD = R.REDO.LY.PROGRAM<REDO.PROG.MODALITY>
    PRG.ST.DATE = R.REDO.LY.PROGRAM<REDO.PROG.START.DATE>
    PRG.END.DATE = R.REDO.LY.PROGRAM<REDO.PROG.END.DATE>
    PRG.PT.VALUE = R.REDO.LY.PROGRAM<REDO.PROG.POINT.VALUE>
    PRG.DAYS.EXP = R.REDO.LY.PROGRAM<REDO.PROG.DAYS.EXP>
    PRG.EXP.DATE = R.REDO.LY.PROGRAM<REDO.PROG.EXP.DATE>
    PRG.CUS.GRP = R.REDO.LY.PROGRAM<REDO.PROG.GROUP.CUS>
    PRG.AVAIL.IF.DELAY = R.REDO.LY.PROGRAM<REDO.PROG.AVAIL.IF.DELAY>
    PRG.PER.IF.DELAY = R.REDO.LY.PROGRAM<REDO.PROG.PER.IF.DELAY>
    PRG.PT.USE = R.REDO.LY.PROGRAM<REDO.PROG.POINT.USE>
    PRG.PRO = R.REDO.LY.PROGRAM<REDO.PROG.PRODUCT>
    COND.TYPE = R.REDO.LY.PROGRAM<REDO.PROG.COND.TYPE.EXINC>
    IF R.REDO.LY.PROGRAM<REDO.PROG.APP.EXC.COND> EQ 'ESPECIFICA' THEN
        BEGIN CASE
            CASE COND.TYPE EQ 'ESTADO.PRESTAMO'
                PROGRAM.COND = R.REDO.LY.PROGRAM<REDO.PROG.EXC.EST.LOAN>
            CASE COND.TYPE EQ 'CONDICION.PRESTAMO'
                PROGRAM.COND = R.REDO.LY.PROGRAM<REDO.PROG.EXC.COND.LOAN>
        END CASE
        EXCOTYES.MOD = COND.TYPE
        EXCOTYPE.MOD = PROGRAM.COND
    END
    IF R.REDO.LY.PROGRAM<REDO.PROG.APP.INC.COND> EQ 'ESPECIFICA' THEN
        BEGIN CASE
            CASE COND.TYPE EQ 'ESTADO.PRESTAMO'
                PROGRAM.COND = R.REDO.LY.PROGRAM<REDO.PROG.INC.EST.LOAN>
            CASE COND.TYPE EQ 'CONDICION.PRESTAMO'
                PROGRAM.COND = R.REDO.LY.PROGRAM<REDO.PROG.INC.COND.LOAN>
        END CASE
        INCOTYES.MOD = COND.TYPE
        INCOTYPE.MOD = PROGRAM.COND
    END
    IF PRG.EXP.DATE EQ '' THEN
        DAYS.EXP = PRG.DAYS.EXP
        EXP.DATE = TODAY
        TEMP.DAYS.EXP = '+':DAYS.EXP:'C'
        CALL CDT('',EXP.DATE,TEMP.DAYS.EXP)
    END
RETURN
*------------
UPD.CUS.GRP:
*------------
*-------------------------------------------------
* This section updates the local variable CG
*-------------------------------------------------
    IF PRG.CUS.GRP EQ '' THEN
        CG = ''
        GEN = 'G'
    END ELSE
        CG = PRG.CUS.GRP
    END
RETURN
*--------------------------------------------------------------------------------------------------
GET.ACCOUNT:
*----------------------------------------------------------------------------------------------------
    Y.ARR.ID = c_aalocArrId
    APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.ARR.ID,Y.ACCOUNT.ID,ERR.TEXT);* R22 Manual conversion
    CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    CU  = R.ACCOUNT<AC.CUSTOMER>
    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
RETURN
*-----------------
GET.CUS.GROUP:
*----------------
*-------------------------------------------------------------------------------------------------
* This section assigns the value to GEN variable based on customer group value
*--------------------------------------------------------------------------------------------------
    IF CG THEN
        CALL F.READ(FN.CUSTOMER,CU,R.CUSTOMER,F.CUSTOMER,CUS.ERR)
        VAR.LEALTAD = R.CUSTOMER<EB.CUS.LOCAL.REF,POS.CU.G.LEALTAD>
        CHANGE @SM TO @FM IN VAR.LEALTAD ;*AUTO R22 CODE CONVERSION
        LOCATE CG IN VAR.LEALTAD SETTING POS.CUS THEN
            GEN = 'G'
        END ELSE
            IF CG EQ 'ALLGC' THEN
                GEN = 'G'
            END ELSE
                GEN = 'NG'
            END
        END
    END
RETURN
*-------------------------------------------------------------------------------------------------
CHECK.EXC.INC.COND:
*-------------------------------------------------------------------------------------------------
    BEGIN CASE
        CASE EXCOTYES.MOD EQ "ESTADO.PRESTAMO"
            GOSUB COMP.LOANS.EX
        CASE EXCOTYES.MOD EQ "CONDICION.PRESTAMO"
            GOSUB COMP.LOANC.EX
    END CASE
    BEGIN CASE
        CASE INCOTYES.MOD EQ "ESTADO.PRESTAMO"
            GOSUB COMP.LOANS.IN
        CASE INCOTYES.MOD EQ "CONDICION.PRESTAMO"
            GOSUB COMP.LOANC.IN
    END CASE
RETURN
*---------------------------------------------------------------------------------------------------
COMP.LOANS.EX:
*---------------------------------------------------------------------------------------------------
    CHANGE @VM TO @FM IN EXCOTYPE.MOD ;*AUTO R22 CODE CONVERSION
    LOCATE "ESTADO.PRESTAMO" IN EXCOTYES.MOD SETTING Y.EXCT.POS THEN
        Y.CNT.CONDT = '' ; CNT.EXC = ''
        Y.CNT.CONDT = DCOUNT(EXCOTYPE.MOD,@FM) ;*AUTO R22 CODE CONVERSION
* FOR I=1 TO Y.CNT.CONDT
        FOR I.VAR=1 TO Y.CNT.CONDT ;*AUTO R22 CODE CONVERSION
            Y.LOAN.STATUS = ''
            Y.LOAN.STATUS = EXCOTYPE.MOD<I.VAR> ;*AUTO R22 CODE CONVERSION
            GOSUB GET.LOAN.COND.STATUS
            IF Y.AC.LOAN.STATUS NE "" AND Y.LOAN.STATUS EQ Y.AC.LOAN.STATUS THEN
                CNT.EXC += 1 ;*AUTO R22 CODE CONVERSION
            END
*NEXT I
        NEXT I.VAR ;*AUTO R22 CODE CONVERSION
        IF CNT.EXC GT 0 THEN
            FILE.UPD.STOP = 1
        END
    END
RETURN
*-----------------------------------------------------------------------------------------------------
COMP.LOANC.EX:
*-----------------------------------------------------------------------------------------------------
    CHANGE @VM TO @FM IN EXCOTYPE.MOD ;*AUTO R22 CODE CONVERSION
    LOCATE "CONDICION.PRESTAMO" IN EXCOTYES.MOD SETTING Y.EXCT.POS THEN
        Y.CNT.CONDT = '' ; CNT.EXC = ''
        Y.CNT.CONDT = DCOUNT(EXCOTYPE.MOD,@FM) ;*AUTO R22 CODE CONVERSION
*FOR I=1 TO Y.CNT.CONDT
        FOR I.VAR=1 TO Y.CNT.CONDT ;*AUTO R22 CODE CONVERSION
            Y.LOAN.COND = ''
*Y.LOAN.COND = EXCOTYPE.MOD<I>
            Y.LOAN.COND = EXCOTYPE.MOD<I.VAR> ;*AUTO R22 CODE CONVERSION
            GOSUB GET.LOAN.COND.STATUS
            IF Y.LOAN.COND.IN.AA NE "" AND Y.LOAN.COND EQ Y.LOAN.COND.IN.AA THEN
                CNT.EXC += 1 ;*AUTO R22 CODE CONVERSION
            END
* NEXT I
        NEXT I.VAR ;*AUTO R22 CODE CONVERSION
        IF CNT.EXC GT 0 THEN
            FILE.UPD.STOP = 1
        END
    END
RETURN
*-----------------------------------------------------------------------------------------------------
COMP.LOANS.IN:
*-----------------------------------------------------------------------------------------------------
    CHANGE @VM TO @FM IN INCOTYPE.MOD ;*AUTO R22 CODE CONVERSION
    LOCATE "ESTADO.PRESTAMO" IN INCOTYPE.MOD SETTING Y.INCT.POS THEN
        Y.CNT.CONDT = '' ; CNT.INC = ''
        Y.CNT.CONDT = DCOUNT(INCOTYPE.MOD,@FM) ;*AUTO R22 CODE CONVERSION
*FOR I=1 TO Y.CNT.CONDT
        FOR I.VAR=1 TO Y.CNT.CONDT ;*AUTO R22 CODE CONVERSION
            Y.LOAN.STATUS = ''
* Y.LOAN.STATUS = INCOTYPE.MOD<I>
            Y.LOAN.STATUS = INCOTYPE.MOD<I.VAR> ;*AUTO R22 CODE CONVERSION
            GOSUB GET.LOAN.COND.STATUS
            IF Y.AC.LOAN.STATUS NE "" AND Y.LOAN.STATUS EQ Y.AC.LOAN.STATUS THEN
                CNT.INC += 1 ;*AUTO R22 CODE CONVERSION
            END
*NEXT I
        NEXT I.VAR ;*AUTO R22 CODE CONVERSION
        IF CNT.INC LT 1 AND Y.AC.LOAN.STATUS NE "" THEN
            FILE.UPD.STOP = 1
        END ELSE
            FILE.UPD.STOP = ''
        END
    END
RETURN
*-----------------------------------------------------------------------------------------------------
COMP.LOANC.IN:
*-----------------------------------------------------------------------------------------------------
    CHANGE @VM TO @FM IN INCOTYPE.MOD ;*AUTO R22 CODE CONVERSION
    LOCATE "CONDICION.PRESTAMO" IN INCOTYPE.MOD SETTING Y.INCT.POS THEN
        Y.CNT.CONDT = '' ; CNT.INC = ''
        Y.CNT.CONDT = DCOUNT(INCOTYPE.MOD,@FM) ;*AUTO R22 CODE CONVERSION
*FOR I=1 TO Y.CNT.CONDT
        FOR I.VAR=1 TO Y.CNT.CONDT ;*AUTO R22 CODE CONVERSION
            Y.LOAN.COND = ''
*Y.LOAN.COND = INCOTYPE.MOD<I>
            Y.LOAN.COND = INCOTYPE.MOD<I.VAR> ;*AUTO R22 CODE CONVERSION
            GOSUB GET.LOAN.COND.STATUS
            IF Y.LOAN.COND.IN.AA NE "" AND Y.LOAN.COND EQ Y.LOAN.COND.IN.AA THEN
                CNT.INC += 1 ;*AUTO R22 CODE CONVERSION
            END
* NEXT I
        NEXT I.VAR ;*AUTO R22 CODE CONVERSION
        IF CNT.INC LT 1 AND Y.LOAN.COND.IN.AA NE "" THEN
            FILE.UPD.STOP = 1
        END ELSE
            FILE.UPD.STOP = ''
        END
    END
RETURN
*-----------------------------------------------------------------------------------------------------
GET.LOAN.COND.STATUS:
*-----------------------------------------------------------------------------------------------------
    ARR.ID = c_aalocArrId
    PROP.CLASS = 'OVERDUE'
    PROPERTY = ''
    R.Condition = ''
    ERR.MSG = ''
    EFF.DATE = ''
    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.Condition,ERR.MSG);* R22 Manual conversion
    Y.AC.LOAN.STATUS = R.Condition<AA.OD.LOCAL.REF,POS.L.LOAN.STATUS>
    Y.LOAN.COND.IN.AA = R.Condition<AA.OD.LOCAL.REF,POS.L.LOAN.COND>
    Y.NO.OF.DAYS = R.Condition<AA.OD.AGEING,1,1>
RETURN
*-----------------------------------------------------------------------------------------------------
CHK.PRODUCT:
*-----------------------------------------------------------------------------------------------------
*    Y.CATEGORY = R.ACCOUNT<AC.CATEGORY>
*    CHANGE VM  TO FM IN PRG.PRO
*    LOCATE Y.CATEGORY IN PRG.PRO SETTING CAT.POS THEN
    Y.TOT = 'TOT':Y.TERM.PROPERTY
    Y.CUR = 'CUR':Y.TERM.PROPERTY
    DATE.OPTIONS = ''
    EFFECTIVE.DATE = TODAY
    DATE.OPTIONS<4>  = 'ECB'
    BALANCE.AMOUNT = ""
    CALL AA.GET.PERIOD.BALANCES(Y.ACCOUNT.ID, Y.TOT, DATE.OPTIONS, EFFECTIVE.DATE, "", "", TOT.BAL.DETAILS, "")
    TOT.BAL.CNT = DCOUNT(TOT.BAL.DETAILS<IC.ACT.BALANCE>,@VM) ;*AUTO R22 CODE CONVERSION
    TOT.BAL = ABS(TOT.BAL.DETAILS<IC.ACT.BALANCE,TOT.BAL.CNT>)
    CALL AA.GET.PERIOD.BALANCES(Y.ACCOUNT.ID, Y.CUR, DATE.OPTIONS, EFFECTIVE.DATE, "", "", CUR.BAL.DETAILS, "")
    CUR.BAL.CNT = DCOUNT(CUR.BAL.DETAILS<IC.ACT.BALANCE>,@VM) ;*AUTO R22 CODE CONVERSION
    CUR.BAL = ABS(CUR.BAL.DETAILS<IC.ACT.BALANCE,CUR.BAL.CNT>)
    VAR.DISP.AMT = TOT.BAL - CUR.BAL
    IF VAR.DISP.AMT GE Y.DISBURSE.AMT THEN
        GOSUB PROCESS
*        MOD.CNT = NOR.MOD
*        PRG.CNT = NOR.PRG
    END
*   END
RETURN
*-------------------------------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    R.ACCOUNT.DETAILS = c_aalocAccountDetails
    Y.REPAY.REF=R.ACCOUNT.DETAILS<AA.AD.REPAY.REFERENCE>
    Y.REPAY.CNT=DCOUNT(Y.REPAY.REF,@VM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1=1 ; DELAYP = ''
    LOOP
    WHILE Y.VAR1 LE Y.REPAY.CNT
        Y.REPAY.REF.ID=FIELD(Y.REPAY.REF<1,Y.VAR1>,'-',1)
        Y.REPAY.DATE = FIELD(Y.REPAY.REF<1,Y.VAR1>,'-',2)
        IF Y.REPAY.REF.ID EQ c_aalocArrActivityId AND Y.REPAY.DATE EQ TODAY THEN
            Y.BILL.ID = R.ACCOUNT.DETAILS<AA.AD.RPY.BILL.ID,Y.VAR1>
            CHANGE @SM TO @FM IN Y.BILL.ID ;*AUTO R22 CODE CONVERSION
            CHANGE @VM TO @FM IN Y.BILL.ID ;*AUTO R22 CODE CONVERSION
            GOSUB BILL.DETAILS
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
    R.REDO.LY.POINTS = '' ; PTS.CHG = 0
    CALL F.READU(FN.REDO.LY.POINTS,CU,R.REDO.LY.POINTS,F.REDO.LY.POINTS,RLP.ERR,'')
    GOSUB ASSIGN.AUDIT
    PRO.LST = R.REDO.LY.POINTS<REDO.PT.PRODUCT>
    GOSUB CHK.FORM.GEN
    IF PT.QTY NE 0 AND PT.VAL NE 0 THEN
        GOSUB CHK.AVAIL.DELAY
        R.AA.ACTIVITY  = c_aalocArrActivityRec
        TXN.ID = R.AA.ACTIVITY<AA.ARR.ACT.TXN.CONTRACT.ID>
        GOSUB ASSIGN.LY.PTS
        IF PTS.CHG THEN
            CALL F.WRITE(FN.REDO.LY.POINTS,CU,R.REDO.LY.POINTS)
        END
        GOSUB ASSIGN.LY.PTS.TOT
    END
RETURN
*----------------------------------------------------------------------
BILL.DETAILS:
*----------------------------------------------------------------------
    Y.BILL.COUNT=DCOUNT(Y.BILL.ID,@FM) ;*AUTO R22 CODE CONVERSION
    TOTAL.ACC.AMT = 0; TOTAL.INT.AMT = 0
    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.BILL.COUNT
        Y.BILL.DUE = ''
        BILL.ID=Y.BILL.ID<Y.VAR2>
        CALL F.READ(FN.AA.BILL.DETAILS,BILL.ID,R.BILL.DETAIL,F.AA.BILL.DETAILS,BILL.ERR)
        VAR.PROP = R.BILL.DETAIL<AA.BD.PROPERTY>
        VAR.BILL.DATE = R.BILL.DETAIL<AA.BD.BILL.DATE>
        VAR.PAY.DATE = R.BILL.DETAIL<AA.BD.PAYMENT.DATE>
        VAR.BILL.AMT = R.BILL.DETAIL<AA.BD.OR.TOTAL.AMOUNT>
        CHANGE @VM TO @FM IN VAR.PROP ;*AUTO R22 CODE CONVERSION
        CHANGE @VM TO @FM IN VAR.BILL.DATE;*AUTO R22 CODE CONVERSION
*        IF DELAYP NE 'E' THEN
        GOSUB CHK.DELAY
*        END
        IF Y.GEN.AMT EQ 'Total' AND Y.BILL.DUE EQ 'Y' THEN
            Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
        END ELSE
            GOSUB GET.INT.AMT
            GOSUB GET.ACC.AMT
            Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
        END
    REPEAT
RETURN
*---------------------------------------------------
CHK.DELAY:
*---------------------------------------------------
    Y.BILL.DATE = VAR.BILL.DATE<1>
    GOSUB CHECK.GRACE.PERIOD
    IF Y.BILL.DATE LT TODAY AND YDATE LT TODAY THEN
        DELAYP = 'E'
        Y.BILL.DUE = 'Y'
    END ELSE
*        DELAYP = 'N'
        Y.BILL.DUE = 'N'
    END
RETURN
*----------------------------------------------------------------------------------------
GET.ACC.AMT:
*----------------------------------------------------------------------------------------
    Y.ACC.PROPERTY.COUNT = DCOUNT(Y.ACC.PROPERTY,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR4=1
    LOOP
    WHILE Y.VAR4 LE Y.ACC.PROPERTY.COUNT
        Y.PROP = Y.ACC.PROPERTY<Y.VAR4>
        LOCATE Y.PROP IN VAR.PROP SETTING PROPERTY.POS THEN
            VAR.REPAY.REF = R.BILL.DETAIL<AA.BD.REPAY.REF,PROPERTY.POS>
            VAR.REPAY.CNT = DCOUNT(VAR.REPAY.REF,@SM) ;*AUTO R22 CODE CONVERSION
            Y.VAR5=1
            LOOP
            WHILE Y.VAR5 LE VAR.REPAY.CNT
                VAR.REPAY.REF.ID=FIELD(VAR.REPAY.REF<1,Y.VAR5>,'-',1)
                IF VAR.REPAY.REF.ID EQ c_aalocArrActivityId THEN
                    TOT.ACC.AMT = R.BILL.DETAIL<AA.BD.REPAY.AMOUNT,PROPERTY.POS,Y.VAR5>
                    TOTAL.ACC.AMT+=TOT.ACC.AMT
                    BREAK
                END
                Y.VAR5 += 1 ;*AUTO R22 CODE CONVERSION
            REPEAT
        END
        Y.VAR4 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*----------------------------------------------------------------------------------------
GET.INT.AMT:
*----------------------------------------------------------------------------------------
    Y.INT.PROPERTY.COUNT= DCOUNT(Y.INT.PROPERTY,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR3=1
    LOOP
    WHILE Y.VAR3 LE Y.INT.PROPERTY.COUNT
        Y.PROPERTY = Y.INT.PROPERTY<Y.VAR3>
        IF Y.PROPERTY EQ 'PRINCIPALINT' THEN
            LOCATE Y.PROPERTY IN VAR.PROP SETTING PROP.POS THEN
                VAR.REPAY.REF = R.BILL.DETAIL<AA.BD.REPAY.REF,PROP.POS>
                VAR.REPAY.CNT = DCOUNT(VAR.REPAY.REF,@SM) ;*AUTO R22 CODE CONVERSION
                Y.VAR6=1
                LOOP
                WHILE Y.VAR6 LE VAR.REPAY.CNT
                    VAR.REPAY.REF.ID=FIELD(VAR.REPAY.REF<1,Y.VAR6>,'-',1)
                    IF VAR.REPAY.REF.ID EQ c_aalocArrActivityId THEN
                        TOT.INT.AMT = R.BILL.DETAIL<AA.BD.REPAY.AMOUNT,PROP.POS,Y.VAR6>
                        TOTAL.INT.AMT+=TOT.INT.AMT
                        BREAK
                    END
                    Y.VAR6 += 1 ;*AUTO R22 CODE CONVERSION
                REPEAT
            END
        END
        Y.VAR3 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*-------------------------------------------------------------------------------------------
CHK.FORM.GEN:
*-------------------------------------------------------------------------------------------------
    IF Y.FORM.GEN EQ '2' THEN
        GOSUB CHK.GEN.FACTOR
    END ELSE
        GOSUB CHK.WHOLE.PTS
    END
RETURN
*----------------------------------------------------------------------------------------------------
CHK.GEN.FACTOR:
*---------------------------------------------------------------------------------------------------
*    IF Y.PRODUCT.GROUP EQ 2 THEN
    IF Y.GEN.AMT EQ 'Total' AND TOTAL.ACC.AMT NE 0 AND TOTAL.INT.AMT NE 0 THEN
*TOTAL.ACC.AMT = TOTAL.ACC.AMT + TOTAL.INT.AMT
        TOTAL.ACC.AMT += TOTAL.INT.AMT ;*AUTO R22 CODE CONVERSION
        TOTAL.ACC.AMT *= Y.GEN.FACTOR
        TOTAL.ACC.AMT = FMT(TOTAL.ACC.AMT,0)
        IF TOTAL.ACC.AMT LT Y.MIN.GEN THEN
            TOTAL.ACC.AMT = 0
        END ELSE
            IF Y.MAX.GEN AND TOTAL.ACC.AMT GT Y.MAX.GEN THEN
                TOTAL.ACC.AMT = Y.MAX.GEN
            END
        END
        PT.QTY = TOTAL.ACC.AMT
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
*    IF Y.PRODUCT.GROUP EQ 3 THEN
    IF Y.GEN.AMT EQ 'Interes' THEN
        TOTAL.INT.AMT *= Y.INT.GEN.FACTOR
        TOTAL.INT.AMT = FMT(TOTAL.INT.AMT,0)
        IF TOTAL.INT.AMT LT Y.INT.MIN.GEN THEN
            TOTAL.INT.AMT = 0
        END ELSE
            IF Y.INT.MAX.GEN AND TOTAL.INT.AMT GT Y.INT.MAX.GEN THEN
                TOTAL.INT.AMT = Y.INT.MAX.GEN
            END
        END
        PT.QTY = TOTAL.INT.AMT
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
    IF Y.GEN.AMT EQ 'Capital' THEN
        TOTAL.ACC.AMT *= Y.GEN.FACTOR
        TOTAL.ACC.AMT = FMT(TOTAL.ACC.AMT,0)
        IF TOTAL.ACC.AMT LT Y.MIN.GEN THEN
            TOTAL.ACC.AMT = 0
        END ELSE
            IF Y.MAX.GEN AND TOTAL.ACC.AMT GT Y.MAX.GEN THEN
                TOTAL.ACC.AMT = Y.MAX.GEN
            END
        END
        PT.QTY = TOTAL.ACC.AMT
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
RETURN
*---------------------------------------------------------------------------------------------------------
CHECK.GRACE.PERIOD:
*---------------------------------------------------------------------------------------------------------
    IF Y.NO.OF.DAYS AND VAR.PAY.DATE THEN
        YREGION = ''
        YDATE = VAR.PAY.DATE
        YDAYS.ORIG = '+':Y.NO.OF.DAYS:'C'
        CALL CDT(YREGION,YDATE,YDAYS.ORIG)
    END
RETURN
*---------------------------------------------------------------------------------------------------------
CHK.WHOLE.PTS:
*---------------------------------------------------------------------------------------------------------
*    IF Y.PRODUCT.GROUP EQ 2 THEN
    IF Y.GEN.AMT EQ 'Total' THEN
        GEN.PTS.CNT = DCOUNT(Y.GEN.POINTS,@VM) ;*AUTO R22 CODE CONVERSION
        FOR GEN.PTS.POS = 1 TO GEN.PTS.CNT
*TOTAL.ACC.AMT = TOTAL.ACC.AMT + TOTAL.INT.AMT
            TOTAL.ACC.AMT += TOTAL.INT.AMT ;*AUTO R22 CODE CONVERSION
            IF TOTAL.ACC.AMT GE Y.LOW.LIM.AMT<1,GEN.PTS.POS> AND TOTAL.ACC.AMT LE Y.UP.LIM.AMT<1,GEN.PTS.POS> THEN
                PT.QTY = Y.GEN.POINTS<1,GEN.PTS.POS>
                GEN.PTS.POS = GEN.PTS.CNT
            END
        NEXT GEN.PTS.POS
        PT.QTY+=0
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
*    IF Y.PRODUCT.GROUP EQ 3 THEN
    IF Y.GEN.AMT EQ 'Interes' THEN
        GEN.PTS.CNT = DCOUNT(Y.INT.GEN.POINTS,@VM) ;*AUTO R22 CODE CONVERSION
        FOR GEN.PTS.POS = 1 TO GEN.PTS.CNT
            IF TOTAL.INT.AMT GE Y.INT.LOW.LIM.AMT<1,GEN.PTS.POS> AND TOTAL.INT.AMT LE Y.INT.UP.LIM.AMT<1,GEN.PTS.POS> THEN
                PT.QTY = Y.INT.GEN.POINTS<1,GEN.PTS.POS>
                GEN.PTS.POS = GEN.PTS.CNT
            END
        NEXT GEN.PTS.POS
        PT.QTY+=0
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
RETURN
*---------------------------------------------------------------------------------------------------------
CHK.AVAIL.DELAY:
*---------------------------------------------------------------------------------------------------------
    IF DELAYP EQ 'E' AND PRG.PER.IF.DELAY NE '' THEN
        Y.CAL.A = PRG.PER.IF.DELAY/100
        Y.TOTAL = PT.QTY*Y.CAL.A
        Y.TOTPOINT = PT.QTY-Y.TOTAL
        Y.TOTPOINT = FMT(Y.TOTPOINT,0)
        PT.QTY = Y.TOTPOINT
        PT.VAL = PT.QTY * PRG.PT.VALUE
    END
RETURN
*------------
ASSIGN.AUDIT:
*------------
*----------------------------------------------------------
* This section updates audit fields of REDO.LY.POINTS table
*----------------------------------------------------------
    CURR.NO = ''
    CUR.TIME = OCONV(TIME(), "MT")
*CONVERT ':' TO '' IN CUR.TIME
    CHANGE ':' TO '' IN CUR.TIME ;*AUTO R22 CODE CONVERSION
    CURR.NO = R.REDO.LY.POINTS<REDO.PT.CURR.NO>
    IF CURR.NO EQ '' THEN
        CURR.NO = 1
    END ELSE
        CURR.NO += 1 ;*AUTO R22 CODE CONVERSION
    END
    R.REDO.LY.POINTS<REDO.PT.RECORD.STATUS> = ''
    R.REDO.LY.POINTS<REDO.PT.CURR.NO> = CURR.NO
*R.REDO.LY.POINTS<REDO.PT.INPUTTER> = TNO:'_':OPERATOR
    R.REDO.LY.POINTS<REDO.PT.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.POINTS<REDO.PT.DATE.TIME> = G.DATE[3,6]:CUR.TIME
*R.REDO.LY.POINTS<REDO.PT.AUTHORISER> = TNO:'_':OPERATOR
    R.REDO.LY.POINTS<REDO.PT.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.POINTS<REDO.PT.CO.CODE> = ID.COMPANY
    R.REDO.LY.POINTS<REDO.PT.DEPT.CODE> = 1
RETURN
*-------------
ASSIGN.LY.PTS:
*-------------
*--------------------------------------------------------------------------------------------
* This section assigns value in the variable that needs to be updated in REDO.LY.POINTS table
*--------------------------------------------------------------------------------------------
    PTS.CHG = 1
    CHANGE @VM TO @FM IN PRO.LST ;*AUTO R22 CODE CONVERSION
    LOCATE Y.CATEGORY IN PRO.LST SETTING PRO.INS.POS ELSE
        R.REDO.LY.POINTS<REDO.PT.PRODUCT,PRO.INS.POS> = Y.CATEGORY
    END
    R.REDO.LY.POINTS<REDO.PT.PROGRAM,PRO.INS.POS,-1> = PRG.ID
    R.REDO.LY.POINTS<REDO.PT.TXN.ID,PRO.INS.POS,-1> = TXN.ID
    R.REDO.LY.POINTS<REDO.PT.QUANTITY,PRO.INS.POS,-1> = PT.QTY
    R.REDO.LY.POINTS<REDO.PT.QTY.VALUE,PRO.INS.POS,-1> = PT.VAL
*    IF PRG.AVAIL.IF.DELAY NE 'SI' AND DELAYP EQ 'E' THEN
*        R.REDO.LY.POINTS<REDO.PT.STATUS,PRO.INS.POS,-1> = 'No Liberada'
*        VAR.STATUS = 'NA'
*    END ELSE
    R.REDO.LY.POINTS<REDO.PT.STATUS,PRO.INS.POS,-1> = 'Liberada'
    VAR.STATUS = 'A'
*    END
    R.REDO.LY.POINTS<REDO.PT.GEN.DATE,PRO.INS.POS,-1> = TODAY
    R.REDO.LY.POINTS<REDO.PT.AVAIL.DATE,PRO.INS.POS,-1> = TODAY
    R.REDO.LY.POINTS<REDO.PT.EXP.DATE,PRO.INS.POS,-1> = EXP.DATE
    R.REDO.LY.POINTS<REDO.PT.MAN.DATE,PRO.INS.POS,-1> = ''
    R.REDO.LY.POINTS<REDO.PT.MAN.QTY,PRO.INS.POS,-1> = ''
    R.REDO.LY.POINTS<REDO.PT.MAN.DESC,PRO.INS.POS,-1> = ''
    R.REDO.LY.POINTS<REDO.PT.MAN.USER,PRO.INS.POS,-1> = ''
RETURN
*-------------------------------------------------------------------------------------------------------------------------------
ASSIGN.LY.PTS.TOT:
*-------------------------------------------------------------------------------------------------------------------------------
* To accumulate the points in REDO.LY.POINTS.TOT local table
    GOSUB UPD.PTS.MMYY
    GOSUB UPD.PTS.PGM.YY
    GOSUB UPD.PTS.YYYY
    IF PRG.PT.USE EQ 4 THEN
        GOSUB UPD.PTS.CUS
    END
    IF PRG.PT.USE EQ 3 THEN
        GOSUB UPD.PTS.BUS
    END
    Y.UPD.ONLINE = 0
    GOSUB CHECK.MASTER.PRG
    GOSUB UPD.PTS.FOR.ACCT
    IF Y.UPD.ONLINE EQ 1  THEN
        GOSUB UPD.PTS.FOR.DEB
        PRG.ID = PRG.ID.OLD
    END
RETURN
*-------------------------------------------------------------------------------------------------------------------------------
CHECK.MASTER.PRG:
*-------------------------------------------------------------------------------------------------------------------------------
    R.REDO.LY.MASTERPRGDR = '' ; MAS.ERR = ''

*  CALL F.READ(FN.REDO.LY.MASTERPRGDR,'SYSTEM',R.REDO.LY.MASTERPRGDR,F.REDO.LY.MASTERPRGDR,MAS.ERR) ;*Tus Start
    CALL CACHE.READ(FN.REDO.LY.MASTERPRGDR,'SYSTEM',R.REDO.LY.MASTERPRGDR,MAS.ERR) ; * Tus End
    IF R.REDO.LY.MASTERPRGDR THEN
        Y.MASTER.PRG = R.REDO.LY.MASTERPRGDR<REDO.MASPRG.MASTER.PRG>
        Y.SLAVES.PRG = R.REDO.LY.MASTERPRGDR<REDO.MASPRG.SLAVE.PRG>
    END
    Y.SLAVES.PRG.CNT = DCOUNT(Y.SLAVES.PRG,@VM) ;*AUTO R22 CODE CONVERSION
    Y.SLAVE.CNT = 1
    LOOP
    WHILE Y.SLAVE.CNT LE Y.SLAVES.PRG.CNT
        Y.SLAVE.PRG = FIELD(Y.SLAVES.PRG,@VM,Y.SLAVE.CNT) ;*AUTO R22 CODE CONVERSION
        IF PRG.ID EQ Y.MASTER.PRG OR PRG.ID EQ Y.SLAVE.PRG THEN
            PRG.ID.OLD = PRG.ID
            PRG.ID = Y.MASTER.PRG
            Y.UPD.ONLINE = 1
            Y.SLAVE.CNT = Y.SLAVES.PRG.CNT
        END
        Y.SLAVE.CNT += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*---------------------------------------------------------------------------
UPD.PTS.MMYY:
*----------------------------------------------------------------------------
    TOT.POINTS.ID = CU:PRG.ID:TODAY[5,2]:TODAY[1,4]
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*--------------------------------------------------------------------------------
UPD.PTS.PGM.YY:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = CU:PRG.ID:'ALL':TODAY[1,4]
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PTS.YYYY:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = CU:'ALL':TODAY[1,4]
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PTS.CUS:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = CU:'C'
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PTS.BUS:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = CU:'B'
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PTS.FOR.ACCT:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = 'ALL':PRG.ID:CUR.DAY:CUR.MONTH:CUR.YEAR
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PTS.FOR.DEB:
*----------------------------------------------------------------------------------
    TOT.POINTS.ID = CU:'ONLINEDEB'
    R.REDO.LY.POINTS.TOT =''
    CALL F.READ(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT,F.REDO.LY.POINTS.TOT,TOT.ERR)
    GOSUB UPD.PROCESS.DEB
    GOSUB ASSIGN.AUDIT.TOT
    CALL F.WRITE(FN.REDO.LY.POINTS.TOT,TOT.POINTS.ID,R.REDO.LY.POINTS.TOT)
RETURN
*----------------------------------------------------------------------------------
UPD.PROCESS:
*---------------------------------------------------------------------------------
    VAR.AVAIL = 0 ; VAR.AVAIL.VALUE = 0 ; VAR.NAVAIL = 0 ; VAR.NAVAIL.VALUE = 0
    VAR.TOT.GEN = 0 ; VAR.TOT.GEN.VALUE = 0
    IF R.REDO.LY.POINTS.TOT EQ '' THEN
        VAR.NAVAIL = 0
        VAR.NAVAIL.VALUE = 0
        VAR.TOT.GEN = 0
        VAR.TOT.GEN.VALUE = 0
        VAR.AVAIL = 0
        VAR.AVAIL.VALUE = 0
    END ELSE
        VAR.TOT.GEN = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.GEN.POINTS>
        VAR.TOT.GEN.VALUE = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.GEN.VALUE>
        VAR.AVAIL   =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS>
        VAR.AVAIL.VALUE =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE>
        VAR.NAVAIL   =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.NAVAIL.POINTS>
        VAR.NAVAIL.VALUE =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.NAVAIL.VALUE>
    END
    IF PT.QTY GT 0 AND VAR.STATUS EQ 'A' THEN
        VAR.TOT.GEN += PT.QTY
        VAR.TOT.GEN.VALUE += PT.VAL
    END
    IF VAR.STATUS EQ 'A' THEN
        VAR.AVAIL += PT.QTY
        VAR.AVAIL.VALUE += PT.VAL
    END ELSE
        VAR.AVAIL -= PT.QTY
        VAR.AVAIL.VALUE -= PT.VAL
    END
    IF VAR.STATUS EQ 'NA' THEN
* VAR.NAVAIL = VAR.NAVAIL + PT.QTY
        VAR.NAVAIL += PT.QTY ;*AUTO R22 CODE CONVERSION
* VAR.NAVAIL.VALUE = VAR.NAVAIL.VALUE + PT.VAL
        VAR.NAVAIL.VALUE += PT.VAL ;*AUTO R22 CODE CONVERSION
    END
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS> = VAR.AVAIL
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE> = VAR.AVAIL.VALUE
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.GEN.POINTS> = VAR.TOT.GEN
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.GEN.VALUE> = VAR.TOT.GEN.VALUE
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.NAVAIL.POINTS> = VAR.NAVAIL
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.NAVAIL.VALUE> = VAR.NAVAIL.VALUE
RETURN
*--------------------------------------------------------------------------------
UPD.PROCESS.DEB:
*--------------------------------------------------------------------------------
    VAR.AVAIL = 0 ; VAR.AVAIL.VALUE = 0
    IF R.REDO.LY.POINTS.TOT EQ '' THEN
        VAR.AVAL = 0
        VAR.AVAIL.VALUE = 0
    END ELSE
        VAR.AVAIL = R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS>
        VAR.AVAIL.VALUE =  R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE>
    END
    VAR.AVAIL += PT.QTY
    VAR.AVAIL.VALUE += PT.VAL
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.POINTS> = VAR.AVAIL
    R.REDO.LY.POINTS.TOT<REDO.PT.T.TOT.AVAIL.VALUE> = VAR.AVAIL.VALUE
RETURN
*--------------------------------------------------------------------------------
ASSIGN.AUDIT.TOT:
*-------------------------------------------------------------------------------
* This section updates audit fields of REDO.LY.POINTS.TOT table
*----------------------------------------------------------
    CURR.NO = ''
    CUR.TIME = OCONV(TIME(), "MT")
*CONVERT ':' TO '' IN CUR.TIME
    CHANGE ':' TO '' IN CUR.TIME ;*AUTO R22 CODE CONVERSION
    CURR.NO = R.REDO.LY.POINTS.TOT<REDO.PT.T.CURR.NO>
    IF CURR.NO EQ '' THEN
        CURR.NO = 1
    END ELSE
        CURR.NO += 1 ;*AUTO R22 CODE CONVERSION
    END
    R.REDO.LY.POINTS.TOT<REDO.PT.T.RECORD.STATUS> = ''
    R.REDO.LY.POINTS.TOT<REDO.PT.T.CURR.NO> = CURR.NO
*.POINTS.TOT<REDO.PT.T.INPUTTER> = TNO:'_':OPERATOR
    R.REDO.LY.POINTS.TOT<REDO.PT.T.INPUTTER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.POINTS.TOT<REDO.PT.T.DATE.TIME> = G.DATE[3,6]:CUR.TIME
*R.REDO.LY.POINTS.TOT<REDO.PT.T.AUTHORISER> = TNO:'_':OPERATOR
    R.REDO.LY.POINTS.TOT<REDO.PT.T.AUTHORISER> = C$T24.SESSION.NO:'_':OPERATOR ;*AUTO R22 CODE CONVERSION
    R.REDO.LY.POINTS.TOT<REDO.PT.T.CO.CODE> = ID.COMPANY
    R.REDO.LY.POINTS.TOT<REDO.PT.T.DEPT.CODE> = 1
RETURN
*----------------------------------------------------------------------------------
END
