* @ValidationCode : Mjo5NTE1NTk1NDpDcDEyNTI6MTY4MjA3MTg4NzQwMDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:41:27
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
*========================================================================
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
SUBROUTINE LAPAP.COBROS.SEG.UNAU
*========================================================================
* Technical report:
* =================
* Company Name   : APAP
* Program Name   : LAPAP.COBROS.SEG.UNAU
* Date           :
* Item ID        : 9202
*========================================================================
* Brief description :
* -------------------
* this routine is part of a service that create in REG.REPORT some report
*========================================================================
* Modification History :
* ======================
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2018/07/02     RichardHC         Initial development
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     ++ TO +=1
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*========================================================================
* Content summary :
* =================
* Table name     : FUNDS.TRANSFER$NAU
* Auto Increment : N/A
* Views/versions : ENQ LAPAP.ENQ.COBROS.SEG.UNAU
* EB record      : N/A
* Routine        : LAPAP.COBROS.SEG.UNAU
*========================================================================


    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.FUNDS.TRANSFER

    FN.FUND = 'F.FUNDS.TRANSFER$NAU'
    F.FUND = ''

    QUERY = "SELECT FBNK.FUNDS.TRANSFER$NAU WITH ORDERING.BANK EQ 'COBRO SEGUROS'"
    CALL EB.READLIST(QUERY,SEL.LIST,'',NO.OF.REC,RET.CODE)

    PP = 1
    LOOP
        REMOVE Y.FUND.ID FROM SEL.LIST SETTING TEMP.POS
    WHILE Y.FUND.ID DO
        COD.TRANSACTION = "";DEBIT.ACCOUNT = "";CREDIT.ACCOUNT= "";AMOUNT= "";COMMENT= "";BRANCH= "";CURRENCY= "";WARNING= "";ARR= "";
        CALL F.READ(FN.FUND,Y.FUND.ID,R.FUND,F.FUND,ERR)
        COD.TRANSACTION = R.FUND<FT.TRANSACTION.TYPE>
        DEBIT.ACCOUNT = R.FUND<FT.DEBIT.ACCT.NO>
        CREDIT.ACCOUNT = R.FUND<FT.CREDIT.ACCT.NO>
        AMOUNT = R.FUND<FT.DEBIT.AMOUNT>
        CALL GET.LOC.REF("FUNDS.TRANSFER","L.COMMENTS",POS)
        COMMENT = R.FUND<FT.LOCAL.REF,POS>
        BRANCH = R.FUND<FT.CO.CODE>
        CURRENCY = R.FUND<FT.DEBIT.CURRENCY>
        WARNING = R.FUND<FT.OVERRIDE>
        ARR = Y.FUND.ID:"|":COD.TRANSACTION:"|":DEBIT.ACCOUNT:"|":CREDIT.ACCOUNT:"|":AMOUNT:"|":COMMENT:"|":BRANCH:"|":CURRENCY:"|":WARNING[1,70]:"|":

        CHANGE "|" TO "," IN ARR

        NARR = PP:".":ARR

        CALL OCOMO(NARR)

        V.DIR.OUT = "../interface/T24SEGUROS"
        V.FILE.OUT = "L.APAP.COBROS.REVER.TODO.csv"

        IF PP EQ 1 THEN

            HDR = "TRANSACCIONID,COD TRANSACCION,CUENTA DEBITO,CUENTA CREDITO,MONTO,COMENTARIO,SUCURSAL,MONEDA,ALERTAS"
            OPENSEQ V.DIR.OUT, V.FILE.OUT TO F.FILE.OUT THEN NULL
            WRITESEQ HDR APPEND TO F.FILE.OUT ELSE
                CRT 'error writing header'
                STOP
            END

        END

        OPENSEQ V.DIR.OUT, V.FILE.OUT TO F.FILE.OUT THEN NULL
        WRITESEQ ARR APPEND TO F.FILE.OUT ELSE
            CRT 'error in the body of report'
            STOP
        END

        PP += 1

    REPEAT

RETURN

END
