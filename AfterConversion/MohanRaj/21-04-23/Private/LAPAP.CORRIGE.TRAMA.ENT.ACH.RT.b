* @ValidationCode : MjoyMDkwOTI4NDEwOkNwMTI1MjoxNjgyMDcyMDg1OTIwOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:44:45
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
*21-04-2023      conversion tool     R22 Auto code conversion     >TO GT,= TO EQ
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CORRIGE.TRAMA.ENT.ACH.RT(Y.IN.ROW, Y.DELIMITER)

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB METHOD_INIT
    GOSUB METHOD_PROCESS

RETURN

*---------------
METHOD_INIT:
*---------------
    Y.INW.LINE = Y.IN.ROW
    Y.CAMPO1 = ''; Y.CAMPO2 = ''; Y.CAMPO4 = ''; Y.CAMPO5 = ''; Y.CAMPO6 = ''; Y.CAMPO7 = ''; Y.CAMPO8 = ''; Y.CAMPO9 = '';
    Y.CAMPO10 = ''; Y.CAMPO11 = ''; Y.CAMPO12 = ''; Y.CAMPO13 = ''; Y.CUENTA = ''; Y.FINAL = ''

RETURN
*------------------
METHOD_PROCESS:
*------------------
    Y.CAMPO1 = FIELD(Y.INW.LINE,Y.DELIMITER, 1)
    Y.CAMPO2 = FIELD(Y.INW.LINE,Y.DELIMITER, 2)
    Y.CUENTA = FIELD(Y.INW.LINE,Y.DELIMITER, 3)
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
    Y.CAMPO13 = FIELD(Y.INW.LINE,Y.DELIMITER, 13)

    GOSUB METHOD_VALIDA_CUENTA_ACH

    Y.FINAL:= Y.CAMPO1 : Y.DELIMITER : Y.CAMPO2 : Y.DELIMITER : Y.CUENTA : Y.DELIMITER : Y.CAMPO4 : Y.DELIMITER : Y.CAMPO5 : Y.DELIMITER : Y.CAMPO6 : Y.DELIMITER : Y.CAMPO7 : Y.DELIMITER : Y.CAMPO8 : Y.DELIMITER : Y.CAMPO9 : Y.DELIMITER : Y.CAMPO10 : Y.DELIMITER : Y.CAMPO11 : Y.DELIMITER : Y.CAMPO12 : Y.DELIMITER : Y.CAMPO13

    Y.IN.ROW = Y.FINAL

RETURN

*----------------------------
METHOD_VALIDA_CUENTA_ACH:
*----------------------------
    IF Y.CAMPO1 EQ '32' OR Y.CAMPO1 EQ '22' THEN
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

END
