* @ValidationCode : MjotMjgwOTgwMTQ3OkNwMTI1MjoxNjgxODIyMjYyMzIwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 18:21:02
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
SUBROUTINE REDO.V.VAL.ADV.IVR.PART.CHECK
*-------------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used as validation routine for the the local field L.AA.PART.ALLOW
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
* 05-03-2012        RMONDRAGON     PACS00146447         Initial Creation for IVR
*                                                       based on original routine
*                                                       REDO.V.VAL.ADV.AA.PART.CHECK
*                                                       developed by S.MARIMUTHU
*-------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
*   $INCLUDE GLOBUS.BP I_F.AA.ARRANGEMENT ; * Unwanted, Not Used in the routine --14th Mar 2013 TSH
    $INSERT I_F.ACCOUNT
    $INSERT I_System

MAIN:

    IF VAL.TEXT THEN
        RETURN
    END

    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PGM.END

OPENFILES:

**Unwanted OPF as no READ/WRITE on AA.ARRANGEMENT --14th Mar 2013 TSH
*FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
*F.AA.ARRANGEMENT = ''
*CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    APPLS = 'AA.PRD.DES.TERM.AMOUNT'
    F.FIELDS = 'L.AA.PART.ALLOW':@VM:'L.AA.PART.PCNT'
    POS.VAL=''
    CALL MULTI.GET.LOC.REF(APPLS,F.FIELDS,POS.VAL)
    POS.PART = POS.VAL<1,1>
    POS.PART.PERC = POS.VAL<1,2>

RETURN

PROCESS:

    VAR.AA.ID = R.NEW(FT.CREDIT.ACCT.NO)
    Y.CREDIT.AMT = COMI

    IF VAR.AA.ID[1,2] NE 'AA' THEN
        CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    END

    GOSUB GET.IF.PARTIAL
    GOSUB GET.PAY.DETAILS

    IF Y.CREDIT.AMT NE '' AND (Y.FIN.AMT EQ 0 OR Y.FIN.AMT EQ '') THEN
        AF = FT.CREDIT.AMOUNT
        ETEXT = 'EB-REDO.IVR.AMT.NOT.ALLW': @FM : Y.FIN.AMT
        CALL STORE.END.ERROR
        R.NEW(FT.CREDIT.AMOUNT) = COMI
        RETURN
    END

    IF Y.PART EQ 'YES' OR Y.PART EQ 'SI' THEN
        IF FLG EQ 1 THEN
            GOSUB CALC.PARTIAL.LIM.FOR.AMT
        END ELSE
            GOSUB VAL.COMPL.PAY
        END
    END ELSE
        GOSUB VAL.COMPL.PAY
    END

RETURN

CALC.PARTIAL.LIM.FOR.AMT:

    Y.DUP.FIN.AMT = (R.AA.BILL.DETAILS<AA.BD.OR.TOTAL.AMOUNT>*Y.PARTIAL/100)
    IF Y.DUP.FIN.AMT LT SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>) THEN
        Y.FIN.AMT.MIN = Y.FIN.AMT - SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>) + Y.DUP.FIN.AMT
        Y.FIN.AMT.MAX = Y.FIN.AMT
        Y.TWO.LIMIT = 'Y'
        GOSUB VAL.AMT.TO.PAY
    END ELSE
        Y.TWO.LIMIT = 'N'
        GOSUB VAL.AMT.TO.PAY
        IF Y.NO.VAL EQ '' THEN
            Y.PAR.COME = 1
            GOSUB IF.AMT.NOT.VALID
        END
    END

RETURN

VAL.COMPL.PAY:

    Y.TWO.LIMIT = 'N'
    FLG.VAL = 1
    Y.NO.VAL = ''
    LOOP
    WHILE FLG.VAL LE FLG DO
        Y.FIN.AMT = FIELD(Y.COMPL.AMT,' / ',FLG.VAL)
        GOSUB VAL.AMT.TO.PAY
        FLG.VAL += 1
    REPEAT

    IF Y.NO.VAL EQ '' THEN
        Y.PAR.COME = ''
        GOSUB IF.AMT.NOT.VALID
    END

RETURN

IF.AMT.NOT.VALID:

    IF Y.PAR.COME EQ 1 THEN
        ETEXT = 'EB-REDO.IVR.CR.AMT2': @FM : FLG : @VM : ' ' : Y.FIN.AMT
    END ELSE
        ETEXT = 'EB-REDO.IVR.CR.AMT2': @FM : FLG : @VM : Y.COMPL.AMT
    END

    AF = FT.CREDIT.AMOUNT
    CALL STORE.END.ERROR
    R.NEW(FT.CREDIT.AMOUNT) = COMI

RETURN

VAL.AMT.TO.PAY:

    IF Y.TWO.LIMIT EQ 'Y' THEN
        IF Y.CREDIT.AMT LT Y.FIN.AMT.MIN OR Y.CREDIT.AMT GT Y.FIN.AMT.MAX THEN
            Y.FIN.AMT.MIN = FMT(Y.FIN.AMT.MIN,'R2')
            Y.FIN.AMT.MAX = FMT(Y.FIN.AMT.MAX,'R2')
            AF = FT.CREDIT.AMOUNT
            ETEXT = 'EB-REDO.IVR.CR.AMT': @FM : Y.FIN.AMT.MIN : @VM : Y.FIN.AMT.MAX
            CALL STORE.END.ERROR
            R.NEW(FT.CREDIT.AMOUNT) = COMI
        END
    END ELSE
        IF Y.CREDIT.AMT EQ Y.FIN.AMT THEN
            Y.NO.VAL = 'Y'
        END
    END

RETURN

GET.PAY.DETAILS:

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,VAR.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.AC.ERR)
    Y.TOT.BILS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.TOT.BILS = CHANGE(Y.TOT.BILS,@SM,@VM)
    Y.CN.VM = DCOUNT(Y.TOT.BILS,@VM)

    Y.CNT = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>,@VM)
    FLG.VAL = ''
    IF Y.PART EQ 'YES' OR Y.PART EQ 'SI' THEN
        LOOP
        WHILE Y.CNT GT 0 DO
            FLG.VAL += 1
            Y.TYPE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL>
            Y.CNT.TYPE = DCOUNT(Y.TYPE,@SM)
            GOSUB SUB.PROCESS.EACH.BIL
            Y.CNT -= 1
        REPEAT
    END ELSE
        GOSUB GET.SUB.PROCESS.DET
    END

RETURN

GET.IF.PARTIAL:

    PROP.CLASS='TERM.AMOUNT'
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(VAR.AA.ID,EFF.DATE,PROP.CLASS, PROPERTY,R.CONDITION,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    Y.PARTIAL = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART.PERC>
    Y.PART = R.CONDITION<AA.AMT.LOCAL.REF,POS.PART>

RETURN

SUB.PROCESS.EACH.BIL:

    IF Y.CNT.TYPE EQ 1 THEN
        IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'PAYMENT' THEN
            Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,1>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
            Y.SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>
            IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
                Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
                FLG += 1
                GOSUB GET.SOME.AMT.VALID
            END ELSE
                FIN.CNT += 1
            END
        END ELSE
            IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'ACT.CHARGE' THEN
                FIN.CNT += 1
            END
        END
    END ELSE
        GOSUB PROCESS.MANY.BILS
    END

RETURN

GET.SUB.PROCESS.DET:

    LOOP
    WHILE Y.CNT GT 0 DO
        FLG.VAL += 1
        Y.TYPE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL>
        Y.CNT.TYPE = DCOUNT(Y.TYPE,@SM)
        IF Y.CNT.TYPE EQ 1 THEN
            GOSUB SET.ST.UNP
        END ELSE
            GOSUB PROCESS.MANY.BILS
        END
        Y.CNT -= 1
    REPEAT

RETURN

*-----------
SET.ST.UNP:
*-----------

    IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'PAYMENT' THEN
        Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,1>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
        Y.SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>

        IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
            Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
            FLG += 1
            GOSUB GET.SOME.AMT.VALID
        END ELSE
            FIN.CNT += 1
        END
    END ELSE
        IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'ACT.CHARGE' THEN
            FIN.CNT += 1
        END
    END
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
            GOSUB PR.SET.ST.UNP
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
*--------------
PR.SET.ST.UNP:
*--------------

    IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
        Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
        FLG += 1
        GOSUB GET.SOME.AMT.VALID
    END ELSE
        Y.PAY.DATE = R.AA.BILL.DETAILS<AA.BD.PAYMENT.DATE>
        IF Y.PAY.DATE NE Y.DUP.DATE THEN
            Y.DUP.DATE = Y.PAY.DATE
            FIN.CNT += 1
        END
    END
RETURN

GET.SOME.AMT.VALID:

    Y.COMPL.ACUM += FMT(SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>),'R2')

    IF FLG EQ 1 THEN
        Y.COMPL.AMT := ' ' : Y.COMPL.ACUM
    END ELSE
        Y.COMPL.AMT := ' / ' : Y.COMPL.ACUM
    END

RETURN

PGM.END:

END
