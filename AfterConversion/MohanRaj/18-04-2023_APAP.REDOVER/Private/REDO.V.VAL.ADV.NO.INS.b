* @ValidationCode : MjotMjQ3MTk5ODQ2OkNwMTI1MjoxNjgxODIyMzc4ODQzOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 18:22:58
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,SM TO @SM
*18-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
SUBROUTINE REDO.V.VAL.ADV.NO.INS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used as validation routine for the the local field L.ADV.INS.CNT
*-------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 10-08-2011        S.MARIMUTHU     PACS00074323         Initial Creation
* 14-10-2011        S.MARIMUTHU     PACS00142802
* 12-11-2011        S.MARIMUTHU     PACS00146864
*-------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_System
    $INSERT I_F.VERSION
MAIN:

    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PGM.END

OPENFILES:

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    APPLS = 'FUNDS.TRANSFER':@FM:'AA.PRD.DES.TERM.AMOUNT'
    F.FIELDS = 'L.NO.OF.INSTAL':@VM:'L.ADV.INS.CNT':@VM:'L.AA.PART.ALLOW':@FM:'L.AA.PART.PCNT':@VM:'L.AA.PART.ALLOW'
    POS.VAL = ''
    CALL MULTI.GET.LOC.REF(APPLS,F.FIELDS,POS.VAL)
    Y.POS.INS = POS.VAL<1,1>
    Y.POS.ADV = POS.VAL<1,2>
    Y.POS.PART = POS.VAL<1,3>
    POS.PART.PERC = POS.VAL<2,1>
    POS.FT.PART = POS.VAL<2,2>

RETURN

PROCESS:


    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END
    Y.INS.CNT = COMI

    VAR.AA.ID = R.NEW(FT.CREDIT.ACCT.NO)
    Y.ADV.CNT = R.NEW(FT.LOCAL.REF)<1,Y.POS.ADV>
    Y.PART.CON = R.NEW(FT.LOCAL.REF)<1,Y.POS.PART>

    IF VAR.AA.ID[1,2] NE 'AA' THEN
        CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        Y.CUS = R.ACCOUNT<AC.CUSTOMER>
    END ELSE
        CALL F.READ(FN.AA.ARRANGEMENT,VAR.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARR.ERR)
        Y.CUS = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    END

    Y.DUP.NO.OF.INS = Y.INS.CNT

    GOSUB GET.BILL.DET

    GOSUB PR.NO.DUE
* PACS00142802 -S
    GOSUB PROCESS1
    GOSUB PROCESS2
RETURN

PR.NO.DUE:

    Y.BILLS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.BILLS = CHANGE(Y.BILLS,@SM,@VM)
    Y.BILLS = CHANGE(Y.BILLS,@VM,@FM)
    Y.CNT = DCOUNT(Y.BILLS,@FM)
    Y.FLG = '' ; Y.UNPAID.CNT = 0; YFIRST.BILLDTE = ''
    YFIRST.BILLDTE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE,1>
    IF NOT(YFIRST.BILLDTE) THEN
        YFIRST.BILLDTE = TODAY
    END

    LOOP
    WHILE Y.CNT GT 0 DO
        Y.FLG += 1
        Y.BL = Y.BILLS<Y.FLG>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BL,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ER)
        Y.ST = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>
        IF Y.ST EQ 'UNPAID' THEN
            Y.UNPAID.CNT += 1
        END
        Y.CNT -= 1
    REPEAT

    Y.ADV.BL = R.NEW(FT.LOCAL.REF)<1,Y.POS.ADV>

    IF Y.UNPAID.CNT EQ 0 AND COMI THEN
        AF = FT.LOCAL.REF
        AV = Y.POS.INS
        ETEXT = 'EB-NO.BILS.DUE'
        CALL STORE.END.ERROR
        GOSUB PGM.END
    END
    IF COMI GT Y.UNPAID.CNT  THEN
        AF = FT.LOCAL.REF
        AV = Y.POS.INS
        ETEXT = 'EB-NO.BILS.DUE.EX':@FM:Y.UNPAID.CNT
        CALL STORE.END.ERROR
        GOSUB PGM.END
    END

RETURN
************
PROCESS1:
************
    YMAT.DATE = ''
    IF Y.ADV.CNT EQ '' AND (Y.PART.CON EQ 'YES' OR Y.PART.CON EQ 'SI') THEN
        PROP.CLASS='TERM.AMOUNT'
        CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(VAR.AA.ID,EFF.DATE,PROP.CLASS, PROPERTY,R.CONDITION,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
        Y.PARTIAL = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART.PERC>
        Y.PART.VAL = R.CONDITION<AA.AMT.LOCAL.REF,POS.FT.PART>
* FIX R15 20170802
        YMAT.DATE = R.CONDITION<AA.AMT.MATURITY.DATE>
        IF (FLG EQ 1 OR COMI EQ FLG) THEN
            IF (Y.PART.VAL EQ 'YES' OR Y.PART.VAL EQ 'SI') THEN
                Y.LAST.PART.AMT = SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)* (Y.PARTIAL/100)
                Y.FIN.AMT = Y.FIN.AMT - SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)+ Y.LAST.PART.AMT
            END ELSE
                AF = FT.LOCAL.REF
                AV = Y.POS.PART
                ETEXT = 'EB-PART.NOT.ALLOW'
                CALL STORE.END.ERROR
                R.NEW(FT.CREDIT.AMOUNT) = ''
            END
        END ELSE
            AF = FT.LOCAL.REF
            AV = Y.POS.INS
            ETEXT = 'EB-NO.INS.LT.PARTIAL'
            CALL STORE.END.ERROR
            R.NEW(FT.CREDIT.AMOUNT) = ''
        END
    END


RETURN

************
PROCESS2:
************

    IF Y.ADV.CNT NE '' THEN
        IF FLG EQ Y.INS.CNT THEN
            ARRANGEMENT.ID = VAR.AA.ID
* FIX R15 20170802
            DATE.RANGE = YFIRST.BILLDTE:@FM:YMAT.DATE
            CALL AA.SCHEDULE.PROJECTOR(ARRANGEMENT.ID, SIMULATION.REF, NO.RESET, DATE.RANGE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS,DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)

            IF Y.PART.CON EQ 'YES' OR Y.PART.CON EQ 'SI' THEN
                FLG.DUP = 0
                GOSUB CALC.SCH.AMT
            END ELSE
                FLG.DUP = 1 ; Y.ADV.CNT += 1 ;*R22 Auto Code conversion
                GOSUB CALC.SCH.AMT
            END
            Y.FIN.AMT += VAR.INSTALL.AMOUNT
            Y.FIN.AMT = FMT(Y.FIN.AMT,'R2')
        END ELSE
            AF = FT.LOCAL.REF
            AV = Y.POS.ADV
            ETEXT = 'EB-DUES.ARE.THERE'
            CALL STORE.END.ERROR
            GOSUB PGM.END
        END
    END
* PACS00142802 -E

    R.NEW(FT.CREDIT.AMOUNT) = Y.FIN.AMT
    CALL System.setVariable("CURRENT.CRED.AMT",Y.FIN.AMT)

    IF Y.INS.CNT GT FLG THEN
        AF = FT.LOCAL.REF
        AV = Y.POS.INS
        ETEXT = 'EB-INS.CNT.GT.INS'
        CALL STORE.END.ERROR
        R.NEW(FT.CREDIT.AMOUNT) = ''
    END

*------ Group 12 ---
    IF R.VERSION(EB.VER.VERSION.TYPE) EQ 'NV' THEN
        Y.COMI = COMI
        Y.AF   = AF
        Y.AV   = AV
        Y.AS   = AS
        COMI = R.NEW(FT.CREDIT.AMOUNT)
        CALL APAP.TAM.REDO.VAL.MTS.AMOUNT.FT ;* R22 Manual Conversion - CALL method format modified
        COMI  =     Y.COMI
        AF    =     Y.AF
        AV    =     Y.AV
        AS    =     Y.AS
    END
*------ Group 12 ---

RETURN
GET.BILL.DET:

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,VAR.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.AC.ERR)
    Y.TOT.BILS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.TOT.BILS = CHANGE(Y.TOT.BILS,@SM,@VM)
    Y.CN.VM = DCOUNT(Y.TOT.BILS,@VM)
    Y.CNT = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>,@VM)
    FLG = '' ; FIN.CNT = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        FLG.VAL += 1
        Y.TYPE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL>
        Y.CNT.TYPE = DCOUNT(Y.TYPE,@SM)
        IF Y.CNT.TYPE EQ 1 THEN
            IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'PAYMENT' THEN
                Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,1>
                CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
                Y.SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>
                GOSUB CHECK.UNPAID
            END
            IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'ACT.CHARGE' THEN
                FIN.CNT += 1
            END
        END ELSE
            GOSUB PROCESS.MANY.BILS
        END
        Y.CNT -= 1
    REPEAT

RETURN

PROCESS.MANY.BILS:

    FG.LG = ''
    LOOP
    WHILE Y.CNT.TYPE GT 0 DO
        FG.LG += 1

        IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,FG.LG> EQ 'PAYMENT' THEN
            Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,FG.LG>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
            Y.SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>
            GOSUB CHECK.UNPAID1
        END
        IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,FG.LG> EQ 'ACT.CHARGE' THEN
            Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,FG.LG>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)

            Y.PAY.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>
            IF Y.PAY.DATE NE Y.DUP.DATE THEN
                Y.DUP.DATE = Y.PAY.DATE
                FIN.CNT += 1
            END
        END
        Y.CNT.TYPE -= 1
    REPEAT

RETURN

CALC.SCH.AMT:

    FLG.PR = ''
    FLG.FIN = FLG + FIN.CNT
    LOOP
    WHILE Y.ADV.CNT GT FLG.DUP DO
        FLG.FIN += 1
        Y.PROP = DUE.PROPS<FLG.FIN>
        Y.PROP = CHANGE(Y.PROP,@SM,@VM)
        IF 'ACCOUNT' MATCHES Y.PROP OR 'PRINCIPALINT' MATCHES Y.PROP OR 'PENALTYINT' MATCHES Y.PROP THEN
            IF Y.ADV.CNT NE 1 THEN
                VAR.INSTALL.AMOUNT += TOT.PAYMENT<FLG.FIN>
            END ELSE
                VAR.INSTALL.AMOUNT += (TOT.PAYMENT<FLG.FIN> * (Y.PARTIAL/100))
            END
        END ELSE
            Y.ADV.CNT += 1
        END
        Y.ADV.CNT -= 1
    REPEAT

RETURN

*****************
CHECK.UNPAID:
******************
    IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
        Y.DUP.NO.OF.INS -= 1
        IF Y.DUP.NO.OF.INS GE 0 THEN
            Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
        END
        FLG += 1
    END ELSE
        FIN.CNT += 1
    END

RETURN
*****************************
CHECK.UNPAID1:
****************************
    IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
        Y.DUP.NO.OF.INS -= 1
        IF Y.DUP.NO.OF.INS GE 0 THEN
            Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
        END
        FLG += 1
    END ELSE
        Y.PAY.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>
        IF Y.PAY.DATE NE Y.DUP.DATE THEN
            Y.DUP.DATE = Y.PAY.DATE
            FIN.CNT += 1
        END
    END
RETURN
****************************************
PGM.END:

END
