* @ValidationCode : MjotNjE0NDAxNTU4OkNwMTI1MjoxNjgwMTg3NzU1MTQwOklUU1M6LTE6LTE6MzcyOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:15
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 372
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

* ------------------------------------------------------------------
* Modification History:
*    DATE            WHO            REFERENCE                DESCRIPTION
* 30-MAR-2023    Conversion Tool   R22 Auto conversion    Variable name changed I to I.VAR & K to K.VAR, FM TO @FM, VM to @VM, SM to @SM, ++ to +=
* 29-MAR-2023    Harishvikram C    Manual R22 conversion    No changes
* ------------------------------------------------------------------

$PACKAGE APAP.AA
PROGRAM REDO.AA.UNC.SETTLE.NCF

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.REDO.L.NCF.STOCK
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    GOSUB OPEN.FILES
    GOSUB PROCESS
    GOSUB WRITE.PROCESS
RETURN

OPEN.FILES:

    CRLF = CHARX(13):CHARX(10)
    Y.FILE.NAME= "AA.NCF.csv"
    Y.FILE.PATH="../bnk.run"

    FN.AA.ACTIVITY.BALANCES = 'F.AA.ACTIVITY.BALANCES'
    F.AA.ACTIVITY.BALANCES = ''
    CALL OPF(FN.AA.ACTIVITY.BALANCES, F.AA.ACTIVITY.BALANCES)

    FN.REDO.L.NCF.STOCK = 'F.REDO.L.NCF.STOCK'
    F.REDO.L.NCF.STOCK = ''
    CALL OPF(FN.REDO.L.NCF.STOCK, F.REDO.L.NCF.STOCK)

RETURN

PROCESS:
    CALL CACHE.READ(FN.REDO.L.NCF.STOCK,'SYSTEM',R.NCF.STOCK,ST.ERR)
    Y.AA.IC.TYPE = R.NCF.STOCK<ST.AA.IC.TYPE>

    OPENSEQ Y.FILE.PATH,Y.FILE.NAME TO Y.FILE.LOG.POINTER ELSE
        CREATE Y.FILE.LOG.POINTER ELSE
            NULL
        END
    END

    SEL.CMD = 'SELECT ':FN.AA.ACTIVITY.BALANCES:' WITH ACTIVITY EQ "LENDING-SETTLE-RP.PAGO.ANTICIPADO"'
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '', NOR, ERR)

    I.VAR = 1
    LOOP
    WHILE I.VAR LE NOR
        Y.ARR.ID = SEL.LIST<I.VAR>
        CRT "Processing...":Y.ARR.ID
        Y.AMT.RET = '0'
        Y.LOAN.NO = ''
        Y.PAY.DATE = ''
        TRANSACTION.CODE = ''
        Y.FT.ID = ''
        Y.NCF.AMT = '0'
        CALL F.READ(FN.AA.ACTIVITY.BALANCES, Y.ARR.ID, R.AA.ACTIVITY.BALANCES, F.AA.ACTIVITY.BALANCES, Y.ACT.ERR)
        K.VAR = 1
        Y.TOT.ACT = DCOUNT(R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.REF>,@VM)
        LOOP
        WHILE K.VAR LE Y.TOT.ACT
            Y.AMT.RET = '0'
            Y.LOAN.NO = ''
            Y.PAY.DATE = ''
            TRANSACTION.CODE = ''
            Y.FT.ID = ''
            Y.NCF.AMT = '0'
            Y.VM.ACTIVITY = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY,K.VAR>
            Y.ACT.REF = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.REF,K.VAR>
            Y.ACT.ID = 'LENDING-SETTLE-RP.PAGO.ANTICIPADO'
            IF Y.ACT.ID EQ Y.VM.ACTIVITY THEN
                Y.FT.ID = Y.ACT.REF
                Y.PAY.DATE = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.DATE,K.VAR>
                Y.PROPERTY     = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,K.VAR>
                Y.PROPERTY.BAL.TYPE = FIELDS(Y.PROPERTY,'.',2)
                Y.PROPERTY.AMT = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY.AMT,K.VAR>
                GOSUB CALC.AMT
                GOSUB WRITE.FILE
            END

            K.VAR += 1
        REPEAT

        I.VAR += 1
    REPEAT
RETURN

CALC.AMT:
*-------
    Y.AA.IC.TYPE.CNT = DCOUNT(Y.PROPERTY.BAL.TYPE,@SM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.AA.IC.TYPE.CNT
        Y.PARAM.BAL.TYPE = Y.PROPERTY.BAL.TYPE<1,1,Y.VAR1>
        LOCATE Y.PARAM.BAL.TYPE IN Y.AA.IC.TYPE<1,1> SETTING POS3 THEN
            Y.AMT.RET += Y.PROPERTY.AMT<1,1,Y.VAR1>
        END
        Y.VAR1 += 1
    REPEAT
RETURN

WRITE.FILE:
*-----------
    Y.LOAN.NO = Y.ARR.ID
    TRANSACTION.CODE = "N/A"
    Y.NCF.AMT = Y.AMT.RET
    IF Y.NCF.AMT GT 0 THEN
        Y.ARRAY<-1> = Y.LOAN.NO:',':Y.PAY.DATE:',':TRANSACTION.CODE:',':Y.FT.ID:',':Y.NCF.AMT
    END
RETURN

WRITE.PROCESS:
*-------------
    Y.WRT.ARR = CHANGE(Y.ARRAY,@FM,CRLF)
    WRITESEQ Y.WRT.ARR TO Y.FILE.LOG.POINTER ELSE
        NULL
    END
    CALL JOURNAL.UPDATE('')
RETURN
END
