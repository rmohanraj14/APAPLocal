* @ValidationCode : MjotMjAxNTkyNzEzNzpDcDEyNTI6MTY4MjMxOTM1NDU2MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Apr 2023 12:25:54
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
*24-04-2023      conversion tool     R22 Auto code conversion     FM TO @FM
*24-04-2023      Mohanraj R          R22 Manual code conversion   SE L.ERR TO SELL.ERR
SUBROUTINE LAPAP.FASEII.COVID.POST

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_TSA.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
    $INSERT I_F.DATES

    GOSUB MAIN.PROCESS

RETURN

MAIN.PROCESS:
*************

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN

OPEN.FILES:
**********

    FN.LAPAP.FASEII.COVID19 = "F.LAPAP.FASEII.COVID19"
    F.LAPAP.FASEII.COVID19 = ""
    CALL OPF (FN.LAPAP.FASEII.COVID19,F.LAPAP.FASEII.COVID19)

    Y.GRUPO1 = ""
    Y.GRUPO2 = ""
    Y.GRUPO3 = ""
    Y.GRUPO4 = ""
    Y.GRUPO5 = ""
    Y.EXCLUIDOS = "";

***directorio de salidad
    FN.CHK.DIR1 = "DMFILES"
    F.CHK.DIR1 = ""
    CALL OPF(FN.CHK.DIR1,F.CHK.DIR1)

RETURN

PROCESS:
********

    SEL.CMD  = ''; NO.OF.RECS = ''; F.CHK.DIR = "" ; SEL.LIST= ''
    SEL.CMD = " SELECT " : FN.LAPAP.FASEII.COVID19
    CALL EB.READLIST(SEL.CMD, SEL.LIST, '',NO.OF.RECS,SEL.ERR) ;*R22 Manual Code Conversion-SE L.ERR TO SEL.ERR

    LOOP
        REMOVE Y.ID.RECORD FROM SEL.LIST SETTING REGISTRO.POS
    WHILE Y.ID.RECORD  DO
        CALL F.READ(FN.LAPAP.FASEII.COVID19,Y.ID.RECORD,R.LAPAP.FASEII.COVID19,F.LAPAP.FASEII.COVID19,ERROR.MIGR)
        Y.ID = Y.ID.RECORD
        Y.ID = CHANGE(Y.ID,'*',@FM)
        BEGIN CASE
            CASE Y.ID<2> EQ 'GRUPO1'
                Y.GRUPO1<-1> = R.LAPAP.FASEII.COVID19
            CASE Y.ID<2> EQ 'GRUPO2'
                Y.GRUPO2<-1> = R.LAPAP.FASEII.COVID19
            CASE Y.ID<2> EQ 'GRUPO3'
                Y.GRUPO3<-1> = R.LAPAP.FASEII.COVID19
            CASE Y.ID<2> EQ 'GRUPO4'
                Y.GRUPO4<-1> = R.LAPAP.FASEII.COVID19
            CASE Y.ID<2> EQ 'GRUPO5'
                Y.GRUPO5<-1> = R.LAPAP.FASEII.COVID19
            CASE Y.ID<2> EQ 'EXCLUIDO'
                Y.EXCLUIDOS<-1> = R.LAPAP.FASEII.COVID19
            CASE 1
                Y.VALOR = "NO REGISTRO"
        END CASE
    REPEAT

    IF Y.EXCLUIDOS NE '' THEN
        Y.FILE.NAME = 'CARGA0.PRESTAMOS.EXCLUIDOS.txt'
        Y.ARREGLO = Y.EXCLUIDOS
        GOSUB CHECK.ARCHIVO.FILES
    END

    Y.FILE.NAME = 'CARGA1.FASEII.TASA.FIJA.CERO.txt'
    Y.ARREGLO = Y.GRUPO1
    GOSUB CHECK.ARCHIVO.FILES

    Y.FILE.NAME = 'CARGA2.FASEII.INCREM.CAPITAL.txt'
    Y.ARREGLO = Y.GRUPO2
    GOSUB CHECK.ARCHIVO.FILES

    Y.FILE.NAME = 'CARGA3.FASEII.EXT.PLAZO.PREST.txt'
    Y.ARREGLO =  Y.GRUPO3
    GOSUB CHECK.ARCHIVO.FILES

    Y.FILE.NAME = 'CARGA4.FASEII.PROG.FUTURO.TASA.txt'
    Y.ARREGLO = Y.GRUPO4
    GOSUB CHECK.ARCHIVO.FILES

*Y.FILE.NAME = 'CARGA5.FASEII.ACTUALIZAR.POLIZA.txt'
*Y.ARREGLO = Y.GRUPO5
*GOSUB CHECK.ARCHIVO.FILES

RETURN

CHECK.ARCHIVO.FILES:
    R.FIL = ''; READ.FIL.ERR = ''
    CALL F.READ(FN.CHK.DIR1,Y.FILE.NAME,R.FIL,F.CHK.DIR1,READ.FIL.ERR)
    IF R.FIL THEN
        DELETE F.CHK.DIR1,Y.FILE.NAME
    END
    WRITE Y.ARREGLO ON F.CHK.DIR1, Y.FILE.NAME ON ERROR
        CALL OCOMO("Error en la escritura del archivo en el directorio":F.CHK.DIR1)
    END
RETURN

END
