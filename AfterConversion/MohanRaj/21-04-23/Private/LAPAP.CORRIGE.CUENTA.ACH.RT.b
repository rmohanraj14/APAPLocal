* @ValidationCode : Mjo2MTU3MDY0MjA6Q3AxMjUyOjE2ODIwNzE5OTIwODQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:43:12
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
*21-04-2023      conversion tool     R22 Auto code conversion     > TO GT,FM TO @FM,= TO EQ
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CORRIGE.CUENTA.ACH.RT

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.PARAM
    $INSERT I_F.REDO.ACH.PARAM

    GOSUB INITIALICE
    GOSUB GET.FILE.NAME
    GOSUB READ.FILE.ACH
    GOSUB ESCRIBIR.ARCHIVO.FINAL

RETURN
***********
INITIALICE:
***********
    IN.DIR.PATH = ''
    IN.DIR.PATH.CONV = '../interface/ACH/Inward/CONVERT'
    HIST.PATH = ''
    Y.FILE.NAME = ''
    Y.FILE.NAME.CONV = ''
    Y.DELIMITER = ''
    Y.FINAL = ''

    FN.REDO.INTERFACE.PARAM = 'F.REDO.INTERFACE.PARAM'
    F.REDO.INTERFACE.PARAM = ''
    CALL OPF(FN.REDO.INTERFACE.PARAM,F.REDO.INTERFACE.PARAM)

    FN.REDO.ACH.PARAM = 'F.REDO.ACH.PARAM'
    F.REDO.ACH.PARAM = ''
    CALL OPF(FN.REDO.ACH.PARAM,F.REDO.ACH.PARAM)

    Y.INTERF.ID = 'ACH003'
    CALL CACHE.READ(FN.REDO.INTERFACE.PARAM,Y.INTERF.ID,R.REDO.INTERFACE.PARAM,Y.ERR.INT.PARAM)
    CALL CACHE.READ(FN.REDO.ACH.PARAM,"SYSTEM",R.REDO.ACH.PARAM,Y.ERR.ACH.PAR)

    IN.DIR.PATH = R.REDO.INTERFACE.PARAM<REDO.INT.PARAM.DIR.PATH>
    HIST.PATH = R.REDO.ACH.PARAM<REDO.ACH.PARAM.INW.HIST.PATH>
    Y.DELIMITER =  R.REDO.ACH.PARAM<REDO.ACH.PARAM.INW.DELIMITER>

RETURN
**************
GET.FILE.NAME:
**************

    OPEN IN.DIR.PATH.CONV TO F.FILE.PATH ELSE
        RETURN
    END

    SEL.CMD.INW = "SELECT ":IN.DIR.PATH.CONV
    CALL EB.READLIST(SEL.CMD.INW,SEL.LIST.INW,'',NO.OF.INW.REC,SEL.ERR.INW)

    LOOP
        REMOVE Y.INW.ID FROM SEL.LIST.INW SETTING INW.POS
    WHILE Y.INW.ID : INW.POS
        Y.FILE.NAME = Y.INW.ID
        Y.FILE.NAME.CONV = Y.INW.ID:'.CONV'

*SOLO DEBE EXISTIR UN ARCHIVO PARA ESTE PROCESO EN LA RUTA ORIGEN
        RETURN
    REPEAT

RETURN

**************
READ.FILE.ACH:
**************
    READ Y.FILE.MSG FROM F.FILE.PATH,Y.FILE.NAME THEN

        LOOP
            REMOVE Y.INW.LINE FROM Y.FILE.MSG SETTING Y.REC.POS
        WHILE Y.INW.LINE : Y.REC.POS

            Y.CAMPO1 = ''; Y.CAMPO2 = ''; Y.CAMPO4 = ''; Y.CAMPO5 = ''; Y.CAMPO6 = ''; Y.CAMPO7 = ''; Y.CAMPO8 = ''; Y.CAMPO9 = '';
            Y.CAMPO10 = ''; Y.CAMPO11 = ''; Y.CAMPO12 = ''; Y.CUENTA = '';

            Y.CAMPO1 = FIELD(Y.INW.LINE,Y.DELIMITER, 1)
            Y.CAMPO2 = FIELD(Y.INW.LINE,Y.DELIMITER, 2)
            Y.CAMPO4 = FIELD(Y.INW.LINE,Y.DELIMITER, 4)
            Y.CAMPO4 = EREPLACE(Y.CAMPO4, "ñ", "n")
            Y.CAMPO4 = EREPLACE(Y.CAMPO4, "Ñ", "N")
            Y.CAMPO5 = FIELD(Y.INW.LINE,Y.DELIMITER, 5)
            Y.CAMPO6 = FIELD(Y.INW.LINE,Y.DELIMITER, 6)
            Y.CAMPO7 = FIELD(Y.INW.LINE,Y.DELIMITER, 7)
*Algunos bancos envian el valor del codigo de transaccion rellenado con ceros a la derecha. Solo nos interesan los dos digitos que identifican la txn.
            Y.CAMPO7 = SUBSTRINGS(Y.CAMPO7, 1, 2)
            Y.CAMPO8 = FIELD(Y.INW.LINE,Y.DELIMITER, 8)
            Y.CAMPO8 = EREPLACE(Y.CAMPO8, "ñ", "n")
            Y.CAMPO8 = EREPLACE(Y.CAMPO8, "Ñ", "N")
            Y.CAMPO9 = FIELD(Y.INW.LINE,Y.DELIMITER, 9)
            Y.CAMPO9 = EREPLACE(Y.CAMPO9, "ñ", "n")
            Y.CAMPO9 = EREPLACE(Y.CAMPO9, "Ñ", "N")
            Y.CAMPO10 = FIELD(Y.INW.LINE,Y.DELIMITER, 10)
            Y.CAMPO11 = FIELD(Y.INW.LINE,Y.DELIMITER, 11)
            Y.CAMPO12 = FIELD(Y.INW.LINE,Y.DELIMITER, 12)
            Y.CUENTA = FIELD(Y.INW.LINE,Y.DELIMITER, 3)

            GOSUB VALIDA.CUENTA.ACH

            Y.FINAL:= Y.CAMPO1 : Y.DELIMITER : Y.CAMPO2 : Y.DELIMITER : Y.CUENTA : Y.DELIMITER : Y.CAMPO4 : Y.DELIMITER : Y.CAMPO5 : Y.DELIMITER : Y.CAMPO6 : Y.DELIMITER : Y.CAMPO7 : Y.DELIMITER : Y.CAMPO8 : Y.DELIMITER : Y.CAMPO9 : Y.DELIMITER : Y.CAMPO10 : Y.DELIMITER : Y.CAMPO11 : Y.DELIMITER : Y.CAMPO12 : Y.DELIMITER : @FM

        REPEAT

    END

RETURN

******************
VALIDA.CUENTA.ACH:
******************
    IF Y.CAMPO1 EQ '32' THEN
        IF NOT(NUM(Y.CUENTA)) THEN
            Y.CUENTA = EREPLACE(Y.CUENTA, ",", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "-", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "|", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "_", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "&", "")

        END

        IF LEN(Y.CUENTA) GT 12 AND SUBSTRINGS(Y.CUENTA, 1, 4) EQ '0000' THEN
            Y.CUENTA = SUBSTRINGS(Y.CUENTA,5,12)
        END

        IF SUBSTRINGS(Y.CUENTA,1,3) EQ '001' THEN
            Y.CUENTA = ICONV(Y.CUENTA,"MD")
        END

        RETURN
    END

    IF Y.CAMPO1 EQ '52' AND Y.CAMPO7 EQ '04' THEN
        IF NOT(NUM(Y.CUENTA)) THEN
            Y.CUENTA = EREPLACE(Y.CUENTA, ",", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "-", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "|", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "_", "")
            Y.CUENTA = EREPLACE(Y.CUENTA, "&", "")

        END

        IF LEN(Y.CUENTA) EQ 13 THEN
            IF SUBSTRINGS(Y.CUENTA, 1, 3) EQ '000' THEN
                Y.CUENTA = ICONV(Y.CUENTA,"MD")
            END ELSE
                Y.EXTRAE1 = ICONV(SUBSTRINGS(Y.CUENTA, 1, 3),"MD")
                Y.EXTRAE2 = ICONV(SUBSTRINGS(Y.CUENTA, 4, 3),"MD")
                Y.EXTRAE3 = ICONV(SUBSTRINGS(Y.CUENTA, 7, 7),"MD")

                Y.CUENTA = Y.EXTRAE1 : Y.EXTRAE2 : Y.EXTRAE3
            END
        END ELSE
            Y.CUENTA = ICONV(Y.CUENTA,"MD")
        END

        RETURN
    END

RETURN

******************
ESCRIBIR.ARCHIVO.FINAL:
******************
    Y.TOTAL = DCOUNT(Y.FINAL,@FM)

    IF Y.TOTAL GT 0 THEN

        Y.COMMAND = 'COPY FROM ':IN.DIR.PATH.CONV: ' TO ':HIST.PATH:' ':Y.FILE.NAME
        EXECUTE Y.COMMAND

        DEL.CMD = "DELETE ":IN.DIR.PATH.CONV:" ":Y.FILE.NAME
        EXECUTE DEL.CMD

        OPENSEQ IN.DIR.PATH,Y.FILE.NAME.CONV TO FV.PTR ELSE
            CREATE FV.PTR ELSE
                CRT "CANNOT OPEN DIR ": F.FILE.PATH
                STOP
            END

        END

        FOR A = 1 TO Y.TOTAL STEP 1

            IF Y.FINAL<A> NE '' THEN
                WRITESEQ Y.FINAL<A> TO FV.PTR ELSE
                    CRT "UNABLE TO WRITE TO FILE"
                END
            END
        NEXT A

        CLOSESEQ FV.PTR

        Y.COMMAND = 'COPY FROM ':IN.DIR.PATH.CONV: ' TO ':IN.DIR.PATH:' ':Y.FILE.NAME.CONV
        EXECUTE Y.COMMAND

        DEL.CMD = "DELETE ":IN.DIR.PATH.CONV:" ":Y.FILE.NAME.CONV
        EXECUTE DEL.CMD

    END

RETURN

END
