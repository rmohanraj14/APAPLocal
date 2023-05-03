* @ValidationCode : Mjo2ODg5NTE2NTY6Q3AxMjUyOjE2ODIwNjkzNDgzMzY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 14:59:08
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
$PACKAGE APAP.LAPAP
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM, I TO I.VAR
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.BALANCE.DES.SIMU
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.EB.CONTRACT.BALANCES
*Rutina para retornar el monto en el que fue desembolsado el prestamo
*-----------------------------------------------------------------------------
    GOSUB MAIN.PROCESS
RETURN
*-----------------------------------------------------------------------------
MAIN.PROCESS:
*------------
    Y.AA.ARR.ID = COMI
    GOSUB GET.TABLE.RECORD
    GOSUB GET.ARRANGEMENT.ACCOUNT
    GOSUB GET.BALANCE.EN.EB
RETURN
*-------------------
GET.TABLE.RECORD:
    FN.AA = "F.AA.ARRANGEMENT"
    FV.AA = ""
    CALL OPF (FN.AA, FV.AA)
    FN.CB = "F.EB.CONTRACT.BALANCES"
    FV.CB = ""
    CALL OPF (FN.CB, FV.CB)
RETURN
GET.ARRANGEMENT.ACCOUNT:
**------------------
    AA.ERROR = ''; R.AA = ''; Y.LINKED.APPL = ''; Y.LINKED.APPL.ID = ''
    L.APA.CUENTA = ''
    CALL F.READ(FN.AA,Y.AA.ARR.ID,R.AA,FV.AA, AA.ERROR)
    Y.LINKED.APPL    = R.AA<AA.ARR.LINKED.APPL>
    Y.LINKED.APPL.ID = R.AA<AA.ARR.LINKED.APPL.ID>
    LOCATE "ACCOUNT" IN Y.LINKED.APPL<1,1> SETTING Y.LINKED.POS THEN
        CHANGE @VM TO @FM IN Y.LINKED.APPL.ID
        L.APA.CUENTA = Y.LINKED.APPL.ID<Y.LINKED.POS>
    END
RETURN
*-----------------------
GET.BALANCE.EN.EB:
*----------------------
    CB.ERROR = '' ; R.CB = '' ; Y.CREDIT.AMT = 0 ; Y.DEBIT.AMT = 0
    Y.SUMA.AMT = 0 ; Y.TOTAL.AMT = 0
    CALL F.READ(FN.CB, L.APA.CUENTA, R.CB, FV.CB, CB.ERROR)
    Y.TYPE.CB =  R.CB<ECB.TYPE.SYSDATE>
    Y.CNT = DCOUNT(Y.TYPE.CB,@VM)
    Y.CB.ACCOUN.TYPE = ""
    FOR I.VAR = 1 TO Y.CNT ;*R22 Auto code conversion
        Y.CB.ACCOUN.TYPE = R.CB<ECB.TYPE.SYSDATE,I.VAR>
        FINDSTR "TOTCOMMITMENT" IN Y.CB.ACCOUN.TYPE SETTING Ap, Vp THEN
            FINDSTR "TOTCOMMITMENTBL" IN Y.CB.ACCOUN.TYPE SETTING Ap, Vp THEN
                CONTINUE
            END
            Y.TO.OPEN = R.CB<ECB.OPEN.BALANCE,I.VAR,1>
            Y.CREDIT.AMT = R.CB<ECB.CREDIT.MVMT,I.VAR,1>
            Y.DEBIT.AMT = R.CB<ECB.DEBIT.MVMT,I.VAR,1>
            Y.SUMA.AMT = Y.TO.OPEN + Y.CREDIT.AMT + Y.DEBIT.AMT
            Y.TOTAL.AMT += Y.SUMA.AMT ;*R22 Auto code conversion
            Y.MONTO.EB = Y.TOTAL.AMT
        END
    NEXT I.VAR
    COMI = ABS(Y.MONTO.EB)
RETURN
END
