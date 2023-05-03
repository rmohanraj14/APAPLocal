* @ValidationCode : Mjo5NTk5NjY3MjE6Q3AxMjUyOjE2ODIwNjk4OTY0NzA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:08:16
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
*21-04-2023      conversion tool     R22 Auto code conversion     > TO GT,< TO LT
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE LAPAP.CALC.AGE.RT(START.DATE,END.DATE, OUT.AGE)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DATES

    REMAIN.CAL.DAYS = "C"

    IF START.DATE LT END.DATE THEN
        CALL CDD('',START.DATE, END.DATE, REMAIN.CAL.DAYS)

    END ELSE
        OUT.AGE = 0
        RETURN
    END
    Y.TOTAL.DAYS = 0
    IF REMAIN.CAL.DAYS GE 1 THEN
*CRT "Dias: " : REMAIN.CAL.DAYS
        Y.TOTAL.DAYS = REMAIN.CAL.DAYS
        Y.DIVIDED = Y.TOTAL.DAYS / 365
        Y.DIVIDED = INT(Y.DIVIDED)
    END
    Y.HYPOTETICAL.BIRTHDAY = END.DATE[1,4] : START.DATE[5,4]

    IF Y.HYPOTETICAL.BIRTHDAY GT END.DATE THEN

*Si cumple año un dia despues de la asamblea y la edad que cumple es 18, entonces tiene 17 años...
        REMAIN.CAL.DAYS = "C"
        CALL CDD('',END.DATE, Y.HYPOTETICAL.BIRTHDAY, REMAIN.CAL.DAYS)

        IF REMAIN.CAL.DAYS GE 1 AND REMAIN.CAL.DAYS LE 4 THEN
            IF Y.DIVIDED EQ 18 THEN
                Y.DIVIDED -= 1 ;*R22 Auto code conversion
            END
        END

    END
    IF Y.DIVIDED NE 0 THEN
        OUT.AGE = Y.DIVIDED
    END ELSE

        ENDOUT.AGE = 0
    END
