* @ValidationCode : MjotMTU2ODA2Njc5NjpDcDEyNTI6MTY4MjA3NDI3OTA2MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Apr 2023 16:21:19
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
*21-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,I TO I.VAR,CHAR TO CHARX
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.DIFERENCIA.TASA.IN

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.INTEREST.ACCRUALS
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.INTEREST

* *DEBUG
    GOSUB LOAD.TABLE
    GOSUB MAIN.PROCESS

*------------
MAIN.PROCESS:
*------------

**DEBUG
*COMANDO DE SELECION - PRINCIPAL
    SEL.CMD = ""
    SEL.LIST = ""
    NO.OF.RECS = ""
    SEL.ERR = ""
    Y.AA.ARR.ID = ""

*SEL.CMD = " SELECT " : FN.AA : " WITH @ID EQ 'AA1512040108' AND  ARR.STATUS EQ 'CURRENT' 'EXPIRED' "
    SEL.CMD = " SELECT " : FN.AA : " WITH ARR.STATUS EQ 'CURRENT' 'EXPIRED' "
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '',NO.OF.RECS,SEL.ERR)

*VARIABLE GLOBALES
    Y.FINAL = ""
    Y.IN.ID = ""
    Y.CS.ID = ""
    Y.AR.ID = ""
    Y.AP.ID = ""

*------------------
*-----ARCHIVO DE SALIDA
*------------------
    Y.DIR.NAME = "../interface/T24TASAPR"
    Y.YYYYMMDD = OCONV(DATE(),"DY4") : FMT(OCONV(DATE(),"DM"),"L%2") : FMT(OCONV(DATE(),"DD"),"L%2")
    Y.FILE.NAME = "Reporte de diferencia tasa " : Y.YYYYMMDD : ".CSV"

    DELETESEQ Y.DIR.NAME, Y.FILE.NAME ELSE NULL

    OPENSEQ Y.DIR.NAME,Y.FILE.NAME TO FV.PTR ELSE
        CREATE FV.PTR ELSE
            CRT "NO SE PUEDE ABRIR ARCHIVO: " : Y.FILE.NAME : " DEL DIRECTORIO: " : Y.DIR.NAME
            STOP
        END
    END
*---------------
*-----header----
*---------------
    Y.FINAL = "NUMERO_DE_AA,NUMERO_CUENTA,TASA_INTERES_CORRIENTE,TASA_CAPITAL_VENCIDO "

    WRITESEQ Y.FINAL TO FV.PTR ELSE
        CRT "NO SE PRUEDE ESCRIBIR EN EL ARCHIVO: " : Y.FILE.NAME
    END
    Y.FINAL  = ""
    LOOP
        REMOVE Y.IN.ID FROM SEL.LIST SETTING FI.POS
    WHILE Y.IN.ID DO

**DEBUG

        Y.AA.ARR.ID = Y.IN.ID
        Y.AA.TASA = '' ; Y.CUENTA.PRESTAMO = '' ; Y.AA.RATE.IN = '' ; Y.AA.RATE = ''
        GOSUB GET.ARRAGEMENT.CUENTA
*GOSUB AA.INTEREST.ACCRUALS.READ
*GOSUB AA.INTEREST.ACCRUALS.READ
*GOSUB READ.EB.CONTRAC.BALANCE
        GOSUB AA.INTEREST.READ
        GOSUB AA.INTEREST.READ.1
**DEBUG
        Y.DIFERENCIA.TASA = Y.AA.RATE.IN - Y.AA.RATE
        IF Y.DIFERENCIA.TASA NE 0 THEN
            GOSUB GET.LECTURA.REGISTRO
            WRITESEQ Y.FINAL TO FV.PTR ELSE
                CRT "NO SE PRUEDE ESCRIBIR EL ARCHIVO: " : Y.FILE.NAME
            END
        END
    REPEAT
    CLOSESEQ FV.PTR
RETURN
GET.ARRAGEMENT.CUENTA:

***DEBUG
    AA.ERROR = ''
    R.AA = ''
    CALL F.READ(FN.AA,Y.AA.ARR.ID,R.AA,FV.AA, AA.ERROR)
    Y.LINKED.APPL = R.AA<AA.ARR.LINKED.APPL>
    Y.LINKED.APPL.ID = R.AA<AA.ARR.LINKED.APPL.ID>
    LOCATE "ACCOUNT" IN Y.LINKED.APPL<1,1> SETTING Y.LINKED.POS THEN
        CHANGE @VM TO @FM IN Y.LINKED.APPL.ID
        Y.CUENTA.PRESTAMO  = Y.LINKED.APPL.ID<Y.LINKED.POS>
    END
RETURN
READ.EB.CONTRAC.BALANCE:
***********************
    CB.ERROR = ''; R.CB = ''
    CALL F.READ(FN.EB,Y.CUENTA.PRESTAMO,R.CB,FV.EB,CB.ERROR)
    GOSUB GET.EB.CONTRAC.BALANCE
RETURN
GET.EB.CONTRAC.BALANCE:
***DEBUG
    Y.PRINCIPAL = "PRINCIPALINT";Y.PRINCIPALINTSP = "PRINCIPALINTSP"; Y.PENALIDAD = "PENALTINT"
    Y.TYPE.CB = '';Y.CB.ACCOUN.TYPE = ''; Y.CNT = 0 ; I.VAR=''; J.VAR='' ; Y.DIFERENCIA.EB = 0 ;*R22 Auto code conversion
    IF R.CB THEN
        Y.TYPE.CB =  R.CB<ECB.TYPE.SYSDATE>
        Y.CNT = DCOUNT(Y.TYPE.CB,@VM)
        Y.CB.ACCOUN.TYPE = ""

        FOR I.VAR = 1 TO Y.CNT ;*R22 Auto code conversion
            Y.CB.ACCOUN.TYPE = R.CB<ECB.TYPE.SYSDATE,I.VAR>
            FINDSTR Y.PRINCIPAL IN Y.CB.ACCOUN.TYPE SETTING Ap, Vp THEN
                FINDSTR Y.PRINCIPALINTSP IN Y.CB.ACCOUN.TYPE SETTING Ap, Vp THEN
                    CONTINUE
                END
                Y.TO.OPEN = R.CB<ECB.OPEN.BALANCE,I.VAR,1> ;*R22 Auto code conversion
                Y.CREDIT.AMT = R.CB<ECB.CREDIT.MVMT,I.VAR,1>
                Y.DEBIT.AMT = R.CB<ECB.DEBIT.MVMT,I.VAR,1>
                Y.SUMA.AMT = Y.TO.OPEN + Y.CREDIT.AMT + Y.DEBIT.AMT
                Y.TOTAL.AMT += Y.SUMA.AMT
                Y.MONTO.PRIN = Y.TOTAL.AMT
            END
        NEXT I.VAR


        GOSUB RET.VARIABLE.GET
        FOR J.VAR = 1 TO Y.CNT
            Y.CB.ACCOUN.TYPE = R.CB<ECB.TYPE.SYSDATE,J.VAR> ;*R22 Auto code conversion
            FINDSTR Y.PENALIDAD IN Y.CB.ACCOUN.TYPE SETTING Ap, Vp THEN
                Y.TO.OPEN = R.CB<ECB.OPEN.BALANCE,J.VAR,1>
                Y.CREDIT.AMT = R.CB<ECB.CREDIT.MVMT,J.VAR,1>
                Y.DEBIT.AMT = R.CB<ECB.DEBIT.MVMT,J.VAR,1>
                Y.SUMA.AMT = Y.TO.OPEN + Y.CREDIT.AMT + Y.DEBIT.AMT
                Y.TOTAL.AMT += Y.SUMA.AMT ;*R22 Auto code conversion
                Y.MONTO.PENALTINT = Y.TOTAL.AMT
            END
        NEXT J.VAR

        IF Y.MONTO.PENALTINT NE Y.MONTO.PRIN THEN
            Y.DIFERENCIA.EB = 1
        END
    END
RETURN

RET.VARIABLE.GET:
    Y.CREDIT.AMT = 0
    Y.DEBIT.AMT = 0
    Y.SUMA.AMT = 0
    Y.TOTAL.AMT = 0
    Y.TO.OPEN = 0
    Y.CB.ACCOUN.TYPE = ""
RETURN

GET.LECTURA.REGISTRO:
    Y.FINAL = ""
    Y.FINAL = Y.AA.ARR.ID : ","
    Y.FINAL = Y.FINAL : Y.CUENTA.PRESTAMO : ","
    Y.FINAL = Y.FINAL : Y.AA.RATE.IN : ","
    Y.FINAL = Y.FINAL : Y.AA.RATE : CHARX(13) ;*R22 Auto code conversion

RETURN

LOAD.TABLE:
    FN.AA = "F.AA.ARRANGEMENT"
    FV.AA = ""
    CALL OPF(FN.AA, FV.AA)
*FN.INC = "F.AA.INTEREST.ACCRUALS"
*FV.INC = ""
*CALL OPF(FN.INC, FN.INC)
    FN.EB = "F.EB.CONTRACT.BALANCES"
    FV.EB = ""
    CALL OPF(FN.EB,FV.EB)
RETURN
*----------------
AA.INTEREST.ACCRUALS.READ:
**------------------------
***DEBUG
    FN.ACU = "F.AA.INTEREST.ACCRUALS"
    FV.ACU = ""
    FN.ERROR = ""
    R.ACU = ""
    Y.VALUE = "-PRINCIPALINT"
    Y.AA.ARR.IDS = Y.AA.ARR.ID :"-PRINCIPALINT"
    CALL OPF(FN.ACU,FV.ACU)
    CALL F.READ(FN.ACU, Y.AA.ARR.IDS, R.ACU, FV.ACU, FN.ERROR)
    Y.AA.TASA  = R.ACU<AA.INT.ACC.RATE,1,1>
RETURN

*----------------
AA.INTEREST.READ:
**---------------
***DEBUG
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.INTEREST  = ''
    PROP.CLASS     = ''
    PROP.NAME      = 'PRINCIPALINT'
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.INTEREST = RAISE(returnConditions)
*INTEREST = R.AA.INTEREST
    Y.AA.RATE.IN =  R.AA.INTEREST<AA.INT.FIXED.RATE,1>
RETURN
AA.INTEREST.READ.1:
**---------------
***DEBUG
    ARRANGEMENT.ID = Y.AA.ARR.ID
    R.AA.INTEREST  = ''
    PROP.CLASS     = ''
    PROP.NAME      = 'PENALTINT'
    RET.ERR        = ''
    returnConditions = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID,PROP.CLASS,PROP.NAME,'','',returnConditions,RET.ERR)
    R.AA.INTEREST = RAISE(returnConditions)
*INTEREST = R.AA.INTEREST
    Y.AA.RATE =  R.AA.INTEREST<AA.INT.FIXED.RATE,1>
RETURN
END
