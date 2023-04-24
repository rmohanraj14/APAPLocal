* @ValidationCode : MjotODI5NzUyNjA0OkNwMTI1MjoxNjgyMzIwNzU4NzExOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 24 Apr 2023 12:49:18
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
SUBROUTINE LAPAP.FASEII.CUOTA.PROG
*----------------------------------------------------------------------------------------------------------------------------
*Descripcion: proceso automático donde utilizando un archivo que contiene el número de préstamos y el valor, realice el cambio de la cuota mensual para cada préstamo.
*Ticket: ET-5337
*Autor: Oliver Fermin
*Fecha: 03/07/2020
*Modification history
*Date                Who               Reference                  Description
*24-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM
*24-04-2023      Mohanraj R          R22 Manual code conversion   Call Method Format Modified
*----------------------------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_TSA.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.DATES

    GOSUB OPEN.FILES
    GOSUB MAIN.PROCESS

RETURN

OPEN.FILES:
**********

    FN.AA.BILL = 'F.AA.BILL.DETAILS'
    F.AA.BILL = ''
    CALL OPF(FN.AA.BILL,F.AA.BILL)

    FN.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.ARRANGEMENT = ''
    CALL OPF(FN.ARRANGEMENT,F.ARRANGEMENT)

    FN.ARR.PS = "F.AA.ARR.PAYMENT.SCHEDULE"
    F.ARR.PS = ""
    CALL OPF(FN.ARR.PS, F.ARR.PS)

    FN.CHK.DIR1 = "DMFILES"
    F.CHK.DIR1 = ""
    CALL OPF(FN.CHK.DIR1,F.CHK.DIR1)

    Y.FILE.NAME = "CARGA.FASEII.CUOTA.PROG.txt";
    Y.FILE.NAME.EXIT = "APAP.LIST.FASEII.CUOTA.PROG.txt";
    Y.ARREGLO.PROPIEDADES = "";

RETURN

MAIN.PROCESS:
************
    Y.CONTEO = 0;

    R.CHK.DIR.1 = '' ; CHK.DIR.ERROR = '';
    CALL F.READ(FN.CHK.DIR1,Y.FILE.NAME,R.CHK.DIR.1,F.CHK.DIR1,CHK.DIR.ERROR)
    IF NOT(R.CHK.DIR.1) THEN
        RETURN
    END

    LOOP
        REMOVE Y.AA.ID FROM R.CHK.DIR.1 SETTING PROCESO.POS
    WHILE Y.AA.ID DO

        Y.AA.ID.POS = CHANGE(Y.AA.ID,',',@FM);
        Y.ARRANGEMENT.ID  = Y.AA.ID.POS<1>
        Y.VALOR.CUOTA.PROG = Y.AA.ID.POS<2>

        R.ARRANGEMENT = ''; ERR.ARRAGEMENT = ''; CLIENTE.ID = ''
        CALL AA.GET.ARRANGEMENT(Y.ARRANGEMENT.ID,R.ARRANGEMENT,ERR.ARRAGEMENT)

        Y.COMPANY          = R.ARRANGEMENT<AA.ARR.CO.CODE>
        Y.ARR.STATUS       = R.ARRANGEMENT<AA.ARR.ARR.STATUS>
        Y.PRODUCT.GROUP    = R.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
        Y.NUMERO.PRESTAMO  = R.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
        Y.START.DATE = R.ARRANGEMENT<AA.ARR.START.DATE>

        IF Y.ARR.STATUS EQ 'CLOSE' THEN
            RETURN
        END

        GOSUB CHECK.REPAYMENT.SCHEDULE
        GOSUB VERIFICAR.PROPIEDADES.PRESTAMO

        Y.CONTEO += 1;
        CRT Y.CONTEO:".":Y.ARRANGEMENT.ID:"|PROCESADO|";

    REPEAT

    GOSUB CHECK.ARCHIVO.FILES

RETURN

CHECK.REPAYMENT.SCHEDULE:
***********************

    CALL APAP.AA.REDO.B.CON.LNS.BY.DEBTOR.AA.RECS(Y.ARRANGEMENT.ID,OUT.RECORD) ;*R22 Manual Code Conversion-Call Method Format Modified
    R.AA.PAYMENT.SCHEDULE.APP = FIELD(OUT.RECORD,"*",3)

    Y.PAYMENT.TYPE =  R.AA.PAYMENT.SCHEDULE.APP<AA.PS.PAYMENT.TYPE>
    Y.PAYMENT.TYPE = CHANGE(Y.PAYMENT.TYPE,@SM,@FM)
    Y.PAYMENT.TYPE = CHANGE(Y.PAYMENT.TYPE,@VM,@FM)

    Y.PAYMENT.METHOD = R.AA.PAYMENT.SCHEDULE.APP<AA.PS.PAYMENT.METHOD>
    Y.PAYMENT.METHOD = CHANGE(Y.PAYMENT.METHOD,@SM,@FM)
    Y.PAYMENT.METHOD = CHANGE(Y.PAYMENT.METHOD,@VM,@FM)

    Y.START.DATE.PAY = R.AA.PAYMENT.SCHEDULE.APP<AA.PS.START.DATE>
    Y.START.DATE.PAY = CHANGE(Y.START.DATE.PAY,@SM,@FM)
    Y.START.DATE.PAY = CHANGE(Y.START.DATE.PAY,@VM,@FM)

    Y.END.DATE.PAY = R.AA.PAYMENT.SCHEDULE.APP<AA.PS.END.DATE>
    Y.END.DATE.PAY = CHANGE(Y.END.DATE.PAY,@SM,@FM)
    Y.END.DATE.PAY = CHANGE(Y.END.DATE.PAY,@VM,@FM)

    Y.PROPERTY = R.AA.PAYMENT.SCHEDULE.APP<AA.PS.PROPERTY>

RETURN

VERIFICAR.PROPIEDADES.PRESTAMO:
******************************

    Y.FIELD.NAME = ""
    Y.FIELD.NAME ="||":Y.ARRANGEMENT.ID:"||LENDING-CHANGE-REPAYMENT.SCHEDULE||":Y.COMPANY:"||REPAYMENT.SCHEDULE||";
    Y.FIELD.VALUE ='';

    FINDSTR 'CONSTANTE' IN Y.PAYMENT.TYPE SETTING V.FLD, V.VAL THEN

        Y.PROPERTY.POS = Y.PROPERTY<1,V.FLD,1>;
        Y.PROPERTY.POS.2 = Y.PROPERTY<1,V.FLD,2>;

        IF Y.PROPERTY.POS EQ 'ACCOUNT' THEN
            Y.FIELD.NAME := "PAYMENT.TYPE:":V.FLD:":1::PROPERTY:":V.FLD:":1::ACTUAL.AMT||"
            Y.FIELD.VALUE := Y.PAYMENT.TYPE<V.FLD>:"::":Y.PROPERTY.POS:"::":Y.VALOR.CUOTA.PROG:"||"
        END ELSE
            Y.FIELD.NAME := "PAYMENT.TYPE:":V.FLD:":1::PROPERTY:":V.FLD:":2::ACTUAL.AMT||"
            Y.FIELD.VALUE := Y.PAYMENT.TYPE<V.FLD>:"::":Y.PROPERTY.POS.2:"::":Y.VALOR.CUOTA.PROG:"||"
        END

        Y.ARREGLO.PROPIEDADES<-1> = Y.FIELD.NAME:Y.FIELD.VALUE

    END

RETURN

CHECK.ARCHIVO.FILES:
********************

    R.CHK.DIR.1 = '' ; CHK.DIR.ERROR = '';
    CALL F.READ(FN.CHK.DIR1,Y.FILE.NAME.EXIT,R.CHK.DIR.1,F.CHK.DIR1,CHK.DIR.ERROR)

    IF R.CHK.DIR.1 THEN
        DELETE F.CHK.DIR1,Y.FILE.NAME.EXIT
    END

    WRITE Y.ARREGLO.PROPIEDADES ON F.CHK.DIR1, Y.FILE.NAME.EXIT ON ERROR
        CALL OCOMO("Error en la escritura del archivo en el directorio":F.CHK.DIR1)
    END

RETURN

END
