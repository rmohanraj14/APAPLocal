* @ValidationCode : MjozNjQzMjc4MTg6Q3AxMjUyOjE2ODExMjgwNDk3OTY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 Apr 2023 17:30:49
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.DENOMINATION(V.DR.DENOMINATIO)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :btorresalbornoz
*Program   Name    :REDO.DS.SEL.DST
*---------------------------------------------------------------------------------
*DESCRIPTION       :This program is used to get the SELL DESTINATION value from EB.LOOKUP TABLE
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM, ++ TO +=1, = TO EQ,F.READ TO CACHE.READ
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.TELLER.ID
    $INSERT I_F.USER
    $INSERT I_F.TELLER.DENOMINATION
    $INSERT I_F.CURRENCY
    $INSERT I_F.COMPANY

    GOSUB INITIALISE
    GOSUB DENOMINATION

    GOSUB PROCESS
RETURN

* =========
INITIALISE:
* =========
*

    FN.TELLER.ID = 'F.TELLER.ID'
    F.TELLER.ID = ''
    CALL OPF(FN.TELLER.ID,F.TELLER.ID)

    FN.CURRENCY = 'F.CURRENCY'
    F.CURRENCY = ''
    CALL OPF(FN.CURRENCY,F.CURRENCY)


    FN.TELLER.DENOM = 'F.TELLER.DENOMINATION'
    F.TELLER.DENOM = ''
    CALL OPF(FN.TELLER.DENOM,F.TELLER.DENOM)

    V.DR.DENOMINATIO=''
    Y.VAR2      = 1
    Y.DENOM.NUM = 0
    W.DENOM     = R.NEW(TT.TE.DENOMINATION)
    Y.DENOM.NUM = DCOUNT(W.DENOM,@VM)
    W.UNIT = R.NEW(TT.TE.DR.UNIT)
    Y.DENOM.UNIT = DCOUNT(W.UNIT,@VM)

    Y.VAR1      = 1
    Y.VAR.FIJA=1

RETURN

*********
PROCESS:
*********


    DATA.FIJA=12


    LOOP

    WHILE Y.VAR.FIJA LE DATA.FIJA
        IF Y.VAR.FIJA LE 7 THEN
            GOSUB ESTRUCTURA
        END
        IF Y.VAR.FIJA GE 8 THEN
            GOSUB SEGUNDA.ESTRUCTURA
        END

        Y.VAR.FIJA += 1
*    END

    REPEAT

RETURN

********************************************************************************
ESTRUCTURA:
********************************************************************************

    BEGIN  CASE

    CASE Y.VAR.FIJA EQ '1'
        PART1= "Referencia:":SPACE(24):ID.NEW
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART1:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



    CASE Y.VAR.FIJA EQ '2'
        GOSUB TELLER.ID.USER
        PART2= "De Cajero (Crédito):":SPACE(15):R.NEW(TT.TE.TELLER.ID.2):"/":Y.USER[1,7]
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART2:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



    CASE Y.VAR.FIJA EQ '3' ;*R22 Auto code conversion

        PART3="A Bóveda(Débito):":SPACE(26):R.NEW(TT.TE.TELLER.ID.1)
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART3:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



    CASE Y.VAR.FIJA EQ '4'
        GOSUB CURRENCY.NAME
        Y.CURRENCY=R.CURRENCY<EB.CUR.CCY.NAME>
        PART4="Moneda:":SPACE(18):"RD$(":Y.CURRENCY:")"
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART4:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



    CASE Y.VAR.FIJA EQ '5'

        Y.MONTO=R.NEW(TT.TE.AMOUNT.LOCAL.1)
        Y.MONTO=FMT(Y.MONTO,"R2,#16")
        PART5="Monto :":SPACE(24):Y.MONTO
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART5:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



    CASE Y.VAR.FIJA EQ '6' ;*R22 Auto code conversion
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=SPACE(53):V.DR.DENOMINATIO<1,Y.VAR.FIJA>




    CASE Y.VAR.FIJA EQ '7'
        GET.DATE.TIME = R.NEW(TT.TE.DATE.TIME)
        GOSUB GET.DATE.TIME.INFO
        PART7="Fecha - Hora:":SPACE(19):GET.DATE.TIME
        V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART7:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>



END CASE

RETURN

********************************************************************************
SEGUNDA.ESTRUCTURA:
********************************************************************************

    BEGIN CASE
        CASE Y.VAR.FIJA EQ '8'
            GET.CO.CODE ='APAP':" ":R.COMPANY(EB.COM.COMPANY.NAME):"-":R.NEW(TT.TE.TELLER.ID.2)
            GET.CO.CODE = FMT(GET.CO.CODE,"28R")
            PART8="Oficina - Cajero: ":SPACE(1):GET.CO.CODE
            V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART8:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>


        CASE Y.VAR.FIJA EQ '9'
            Y.COMENTARIO=R.NEW(TT.TE.NARRATIVE.2)[1,32]
            Y.COMENTARIO=FMT(Y.COMENTARIO,"R#32")

            PART9="Comentarios:":SPACE(3):Y.COMENTARIO
            V.DR.DENOMINATIO<1,Y.VAR.FIJA>=PART9:SPACE(6):V.DR.DENOMINATIO<1,Y.VAR.FIJA>


        CASE Y.VAR.FIJA EQ '10'
*        IF R.NEW(TT.TE.UNIT)<1,Y.VAR.FIJA> NE "0" AND V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN

            IF V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN
                V.DR.DENOMINATIO<1,Y.VAR.FIJA> = SPACE(53):V.DR.DENOMINATIO<1,Y.VAR.FIJA>
            END

        CASE Y.VAR.FIJA = '11'
*        IF R.NEW(TT.TE.UNIT)<1,Y.VAR.FIJA> NE "0" AND V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN

            IF V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN
                V.DR.DENOMINATIO<1,Y.VAR.FIJA> = SPACE(53):V.DR.DENOMINATIO<1,Y.VAR.FIJA>
            END

        CASE Y.VAR.FIJA = '12'
*        IF R.NEW(TT.TE.UNIT)<1,Y.VAR.FIJA> NE "0"  AND V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN

            IF V.DR.DENOMINATIO<1,Y.VAR.FIJA> NE '' THEN
                V.DR.DENOMINATIO<1,Y.VAR.FIJA> = SPACE(53):V.DR.DENOMINATIO<1,Y.VAR.FIJA>
            END

*    CASE Y.VAR.FIJA = '13'
*        IF R.NEW(TT.TE.UNIT)<1,Y.VAR.FIJA> NE "0" THEN
*            V.DR.DENOMINATIO<1,Y.VAR.FIJA>=SPACE(53):V.DR.DENOMINATIO<1,Y.VAR.FIJA>
*        END



    END CASE

RETURN

*
********************************************************
TELLER.ID.USER:
*******************************************************

    Y.TELLER.ID2=R.NEW(TT.TE.TELLER.ID.2)

    CALL F.READ(FN.TELLER.ID,Y.TELLER.ID2,R.TELLER.ID,F.TELLER.ID,I.ERR)

    Y.USER=R.TELLER.ID<TT.TID.USER>


RETURN
**********************************************************
CURRENCY.NAME:
*********************************************************
    Y.CURRENCY=R.NEW(TT.TE.CURRENCY.1)
    CALL CACHE.READ(FN.CURRENCY, Y.CURRENCY, R.CURRENCY, Y.ERR) ;*R22 Auto code conversion
    Y.CURRENCY=R.CURRENCY<EB.CUR.CCY.NAME>

RETURN

**********************************************************
DENOMINATION:
**********************************************************
    Y.DENOMINATION=R.NEW(TT.TE.DENOMINATION)<1,Y.VAR1>
    Y.UNIT=R.NEW(TT.TE.DR.UNIT)<1,Y.VAR1>

    LOOP
    WHILE Y.VAR1 LE Y.DENOM.NUM

        IF R.NEW(TT.TE.UNIT)<1,Y.VAR1> NE "0" THEN


            GOSUB GET.VALUE
            Y.DENOMINATION=R.NEW(TT.TE.DENOMINATION)<1,Y.VAR1>
            Y.DENOMINATION=FMT(Y.DENOMINATION,"11L")
            V.DR.DENOMINATIO<-1>=Y.DENOMINATION
            V.DR.DENOMINATIO= CHANGE(V.DR.DENOMINATIO,@FM,@VM)
            Y.UNIT=FMT(R.NEW(TT.TE.UNIT)<1,Y.VAR1>,"6R")
            V.DR.DENOMINATIO=V.DR.DENOMINATIO:SPACE(4):Y.UNIT:SPACE(3):V.DR.VALUE
        END

        Y.VAR1 += 1
    REPEAT



RETURN

*----------------------------------------------
GET.DATE.TIME.INFO:
*----------------------------------------------

    F1 = GET.DATE.TIME[1,2]
    F2 = GET.DATE.TIME[3,2]
    F3 = GET.DATE.TIME[5,2]
    F4 = GET.DATE.TIME[7,2]
    F5 = GET.DATE.TIME[9,2]

    Y.TIME = F3:'/':F2:'/':F1:'-':F4:':':F5
    GET.DATE.TIME= FMT(Y.TIME,"15R")

RETURN

*************************************************
GET.VALUE:
*************************************************
    Y.DENOM=R.NEW(TT.TE.DENOMINATION)<1,Y.VAR1>
    Y.UNIT=R.NEW(TT.TE.DR.UNIT)<1,Y.VAR1>
    CALL CACHE.READ(FN.TELLER.DENOM,Y.DENOM,R.TELLER.DENOM,DENOM.ERR)
    DEN.VALUE = R.TELLER.DENOM<TT.DEN.VALUE>
    Y.VALUE = Y.UNIT * DEN.VALUE
    V.DR.VALUE=FMT(Y.VALUE,"R2,#19")


RETURN



END
