* @ValidationCode : MjoxNjUxNzgzODI3OkNwMTI1MjoxNjgyMzIwODk2MDg2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Apr 2023 12:51:36
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
*24-04-2023      conversion tool     R22 Auto code conversion     = TO EQ
*24-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
SUBROUTINE LAPAP.GET.DEALTICKET.INFO.BUY.RT
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.FT.COMMISSION.TYPE

    GOSUB LOCREF
    GOSUB OPEN.FILES
    GOSUB INI
*---------------------------------------------------------------------------------------------------------
*Check wheter data has been fetched from ms-fim-dealticket-nc or not.
    IF C$SPARE(0) NE COMI THEN
*MSG<-1> = 'Hago llamada'
*CALL LAPAP.LOGGER('TESTLOG',ID.NEW,MSG)
        GOSUB DOCALL
    END ELSE
        GOSUB CHECK.PRELIM.CONDITIONS

        IF PROCESS.GOAHEAD THEN
            GOSUB PROCESS.2
        END
    END
*----------------------------------------------------------------------------------------------------------
LOCREF:
    APPL.NAME.ARR<1> = 'TELLER' ;
    FLD.NAME.ARR<1,1> = 'L.BOL.DIVISA' ;
    FLD.NAME.ARR<1,2> = 'L.NOM.DIVISA' ;
    FLD.NAME.ARR<1,3> = 'L.TT.BASE.AMT' ;
    FLD.NAME.ARR<1,4> = 'L.DEBIT.AMOUNT' ;
    FLD.NAME.ARR<1,5> = 'L.CREDIT.AMOUNT' ;

    CALL MULTI.GET.LOC.REF(APPL.NAME.ARR,FLD.NAME.ARR,FLD.POS.ARR)
    L.BOL.DIVISA.POS = FLD.POS.ARR<1,1>
    L.NOM.DIVISA.POS = FLD.POS.ARR<1,2>
    L.TT.BASE.AMT.POS = FLD.POS.ARR<1,3>
    L.DEBIT.AMOUNT.POS = FLD.POS.ARR<1,4>
    L.CREDIT.AMOUNT.POS = FLD.POS.ARR<1,5>
RETURN

*----------------------------------------------------------------------------------------------------------
OPEN.FILES:
*~~~~~~~~~~
*
    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    F.TELLER.TRANSACTION = ''

    FN.FT.COMMISSION.TYPE = 'F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT  = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT);
*
RETURN
*----------------------------------------------------------------------------------------------------------
INI:
    param = COMI    ;*R.NEW(TT.TE.LOCAL.REF)<1,L.BOL.DIVISA.POS>
    Y.EB.API.ID = 'LAPAP.FIM.DT.INFO.GET'

    PROCESS.GOAHEAD = "1"
    LOOP.CNT        = 1
    MAX.LOOPS       = 1


RETURN
*----------------------------------------------------------------------------------------------------------
DOCALL:
    CALL EB.CALL.JAVA.API(Y.EB.API.ID,param,Y.RESPONSE,Y.CALLJ.ERROR)

    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------------------------------------------
PROCESS:
    IF Y.CALLJ.ERROR THEN
        BEGIN CASE
            CASE Y.CALLJ.ERROR EQ 1
                MESSAGE = "Fatal error creating thread."
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 2
                MESSAGE = "Cannot create JVM."
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 3
                MESSAGE = "Cannot find JAVA class, please check EB.API Record " : Y.EB.API.ID
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 4
                MESSAGE = "Unicode conversion error"
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 5
                MESSAGE = "Cannot find method, please check EB.API Record  " : Y.EB.API.ID
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 6
                MESSAGE = "Cannot find object constructor"
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
            CASE Y.CALLJ.ERROR EQ 7
                MESSAGE = "Cannot instantiate object, check all dependencies registrered in CLASSPATH env."
                E = MESSAGE
                ETEXT = E
                CALL ERR
                RETURN
        END CASE
    END

    IF FIELD(Y.RESPONSE,'*',1) EQ '0' THEN

        GOSUB FORMARRAY
    END ELSE
        Y.EXTRACTO =FIELD(Y.RESPONSE,'*',2)
        MESSAGE = Y.EXTRACTO
        E = MESSAGE
        ETEXT = E
        CALL ERR

        GOSUB CHECK.PRELIM.CONDITIONS

        IF PROCESS.GOAHEAD THEN
            GOSUB PROCESS.2
        END

        RETURN
    END


RETURN
*----------------------------------------------------------------------------------------------------------
FORMARRAY:
**1: codigo, 2: Msg, 3: IdInstrumento, 4: Tipo Txn, 5: Identificacion, 6: Nombre contraparte, 7: Monto Origen, 8: Monto Destino, 9: Tasa cambio
**10: Moneda Origen, 11: Moneda Destino, 12: Moneda Origen ISO, 13: Moneda Destino ISO.
    IF FIELD(Y.RESPONSE,'*',12) EQ 'DOP' THEN
        MESSAGE = "DEAL TICKET:": param : ", especifica moneda DOP como moneda origen en compra de moneda extranjera."
        E = MESSAGE
        ETEXT = E
        CALL ERR
        RETURN
    END
    IF FIELD(Y.RESPONSE,'*',1) EQ '-2' THEN
        MESSAGE = "DEAL TICKET:": param : FIELD(Y.RESPONSE,'*',2)
        E = MESSAGE
        ETEXT = E
        CALL ERR
        RETURN
    END
    R.NEW(TT.TE.CURRENCY.1) = FIELD(Y.RESPONSE,'*',12)
    R.NEW(TT.TE.DEAL.RATE) = FIELD(Y.RESPONSE,'*',9)
    R.NEW(TT.TE.LOCAL.REF)<1,L.TT.BASE.AMT.POS> = FIELD(Y.RESPONSE,'*',7)
    R.NEW(TT.TE.LOCAL.REF)<1,L.NOM.DIVISA.POS> = FIELD(Y.RESPONSE,'*',6)
    R.NEW(TT.TE.NET.AMOUNT) = FIELD(Y.RESPONSE,'*',8)


*Y.TEST = FIELD(Y.RESPONSE,'*',8)
*DEBUG
**Implementacion de rutina: SUBROUTINE REDO.VVR.CALC.AMTS.FCYLCY
    Y.BASE.AMT = ''
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1> = ''
*
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = ''
* BASE AMT es valor 7 en MS.
    Y.BASE.AMT = FIELD(Y.RESPONSE,'*',7)          ;*2021-12-17 cambio el 7 por el 8

*---------------------------------------------------------------------------------------------------------
    C$SPARE(0) = COMI
    C$SPARE(1) = 'true'
*---------------------------------------------------------------------------------------------------------
    GOSUB CHECK.PRELIM.CONDITIONS

    IF PROCESS.GOAHEAD THEN
        GOSUB PROCESS.2
    END
RETURN
*----------------------------------------------------------------------------------------------------------
* ======================
CHECK.PRELIM.CONDITIONS:
* ======================
*
    LOOP
    WHILE LOOP.CNT LE MAX.LOOPS AND PROCESS.GOAHEAD DO
        BEGIN CASE

            CASE LOOP.CNT EQ 1
*
                IF MESSAGE EQ "VAL" THEN
                    PROCESS.GOAHEAD = ""
                END
*
        END CASE
        LOOP.CNT +=1
*
    REPEAT
*
RETURN
*----------------------------------------------------------------------------------------------------------
PROCESS.2:
*----------------------------------------------------------------------
*
    R.NEW(TT.TE.CHARGE.CUSTOMER)  = ""
    R.NEW(TT.TE.CHARGE.ACCOUNT)   = ""
    R.NEW(TT.TE.CHARGE.CATEGORY)  = ""
    R.NEW(TT.TE.CHRG.DR.TXN.CDE)  = ""
    R.NEW(TT.TE.CHRG.CR.TXN.CDE)  = ""
    R.NEW(TT.TE.CHRG.AMT.LOCAL)   = ""
    R.NEW(TT.TE.CHRG.AMT.FCCY)    = ""
    R.NEW(TT.TE.CHARGE.CODE)      = ""
    R.NEW(TT.TE.NET.AMOUNT)       = ""
    R.NEW(TT.TE.DEALER.DESK)      = "00"
*
    R.NEW(TT.TE.AMOUNT.FCY.1)<1,1>   = Y.BASE.AMT
*
    CALL TT.PERFORM.DEF.PROCESSING
    CALL TT.GENERAL.LIBRARY(CALL.CALCULATE.NET.AMOUNT)
*
* PACS00250002 - S

    Y.LCCY.AMT = R.NEW(TT.TE.AMOUNT.FCY.1)<1,1> * R.NEW(TT.TE.DEAL.RATE)
    CALL EB.ROUND.AMOUNT(LCCY,Y.LCCY.AMT,"2","")  ;* Fix for PACS00319443
*
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1> = Y.LCCY.AMT
*
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.LCCY.AMT
*
*PACS00250002 - E

    CALL APAP.TAM.REDO.HANDLE.COMM.TAX.FIELDS ;*R22 Manual Code Conversion-Call Method Format Modified
*
*
RETURN
*

END
