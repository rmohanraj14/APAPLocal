* @ValidationCode : MjoyMTIwOTkxODM5OkNwMTI1MjoxNjgxOTczOTY4MzE0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 12:29:28
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.RAISE.MGROVRIDE
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: SHANKAR RAJU
* PROGRAM NAME: REDO.V.VAL.RAISE.MGROVRIDE
* ODR NO      : ODR-2009-12-0285
*----------------------------------------------------------------------
*DESCRIPTION: This routine is an input routine attached to below versions,
* TELLER,CHQ.OTHERS
* TELLER,CHQ.TAX
* TELLER,CHQ.NO.TAX
* TELLER,MGR.CHQ.TAX
* TELLER,MGR.CHQ.NOTAX



*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: TELLER
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION

*05.07.2010  SHANKAR RAJU  ODR-2009-12-0285  ADDED NEW CHECKS
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion    F.READ TO CACHE.READ,VM TO @VM
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.MANAGER.CHQ.PARAM
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.FT.CHARGE.TYPE
    $INSERT I_F.TAX
    $INSERT I_GTS.COMMON
    IF ((OFS.VAL.ONLY EQ 1) AND (MESSAGE EQ '')) OR (PGM.VERSION EQ ',MGR.CHQ.NOTAX') THEN
        GOSUB LOCAL.REF
        GOSUB PROCESS
    END
RETURN
*----------------------------------------------------------------------
LOCAL.REF:
*----------------------------------------------------------------------

    LOC.REF.APPLICATION="TELLER"
    LOC.REF.FIELDS='WAIVE.TAX':@VM:'L.TT.WAI.CHARGE':@VM:'L.TT.BASE.AMT'
    LOC.REF.POS=''

    FN.TELLER.TRANSACTION = 'F.TELLER.TRANSACTION'
    F.TELLER.TRANSACTION = ''
    R.TELLER.TRANSACTION = ''
    CALL OPF(FN.TELLER.TRANSACTION,F.TELLER.TRANSACTION)

    FN.FT.COMMISSION.TYPE = 'F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE = ''
    R.FT.COMMISSION.TYPE = ''
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)

    FN.FT.CHARGE.TYPE = 'F.FT.CHARGE.TYPE'
    F.FT.CHARGE.TYPE = ''
    R.FT.CHARGE.TYPE = ''
    CALL OPF(FN.FT.CHARGE.TYPE,F.FT.CHARGE.TYPE)

    FN.TAX = 'F.TAX'
    F.TAX = ''
    R.TAX = ''
    CALL OPF(FN.TAX,F.TAX)

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LREF.POS)
    POS.WAIVE.TAX = LREF.POS<1,1>
    POS.WAIVE.CHARGE = LREF.POS<1,2>
    POS.BASE.AMT = LREF.POS<1,3>

    FN.REDO.MANAGER.CHQ.PARAM = 'F.REDO.MANAGER.CHQ.PARAM'
    F.REDO.MANAGER.CHQ.PARAM = ''
    R.REDO.MANAGER.CHQ.PARAM = ''
*CALL OPF(FN.REDO.MANAGER.CHQ.PARAM,F.REDO.MANAGER.CHQ.PARAM) ;*Tus S/E
    CALL CACHE.READ(FN.REDO.MANAGER.CHQ.PARAM,'SYSTEM',R.REDO.MANAGER.CHQ.PARAM,ERR.PAR)

RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

*TO CALCULATE THE CHARGE AMOUNT FOR THE BASE AMOUNT

    GOSUB CALCULATE.AMOUNT

    SAMPLE.VAR = COMI
*    Y.WAIVE.CHARGE = R.NEW(TT.TE.LOCAL.REF)<1,POS.WAIVE.CHARGE>
    Y.WAIVE.CHARGE = COMI
    Y.WAIVE.TAX = R.NEW(TT.TE.LOCAL.REF)<1,POS.WAIVE.TAX>
    Y.BASE.AMT = R.NEW(TT.TE.AMOUNT.LOCAL.1)

    Y.ACCOUNT.2 = R.NEW(TT.TE.ACCOUNT.2)

    Y.ALL.AC.NOS = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ACCOUNT>
    Y.ALL.TAX.KEYS = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.TAX.KEY>

    LOCATE Y.ACCOUNT.2 IN Y.ALL.AC.NOS<1,1> SETTING POS1 THEN

        Y.TAX.KEY = Y.ALL.TAX.KEYS<1,POS1>

    END

    Y.ALL.CHARGE.CODES = R.NEW(TT.TE.CHARGE.CODE)
    Y.ALL.LOC.CHGS = R.NEW(TT.TE.CHRG.AMT.LOCAL)
    Y.ALL.FOR.CHGS = R.NEW(TT.TE.CHRG.AMT.FCCY)

    TEMP.AMT = LCCY:' ':'0.00'

    IF Y.WAIVE.CHARGE EQ 'YES' AND Y.WAIVE.TAX NE 'YES' THEN

        GOSUB PROCESS.WAIVE.CHARGE

    END

    IF Y.WAIVE.CHARGE NE 'YES' AND Y.WAIVE.TAX EQ 'YES' THEN

        GOSUB PROCESS.WAIVE.TAX

    END

    IF Y.WAIVE.CHARGE EQ 'YES' AND Y.WAIVE.TAX EQ 'YES' THEN

        GOSUB PROCESS.WAIVE.ALL

    END

    IF Y.WAIVE.CHARGE NE 'YES' AND Y.WAIVE.TAX NE 'YES' THEN

        R.NEW(TT.TE.WAIVE.CHARGES) = 'NO'
        IF ((PGM.VERSION EQ ',MGR.CHQ.TAX') AND (OFS.VAL.ONLY EQ 1) AND (MESSAGE EQ '')) ELSE
            R.NEW(TT.TE.CHRG.AMT.LOCAL) = Y.AMOUNTS
        END
    END

RETURN
*----------------------------------------------------------------------------------------------------
CALCULATE.AMOUNT:
*~~~~~~~~~~~~~~~~
    Y.TELLER.TRANSACTION = R.NEW(TT.TE.TRANSACTION.CODE)
    Y.BASE.AMOUNT = R.NEW(TT.TE.LOCAL.REF)<1,POS.BASE.AMT>

    CALL CACHE.READ(FN.TELLER.TRANSACTION, Y.TELLER.TRANSACTION, R.TELLER.TRANSACTION, ERR.TT) ;*R22 Auto code conversion
    Y.ALL.CHARGE.CODES = R.TELLER.TRANSACTION<TT.TR.CHARGE.CODE>

    Y.NO.CHARGE.CODES = DCOUNT(Y.ALL.CHARGE.CODES,@VM)

    START.COUNT = 1
    LOOP
    WHILE START.COUNT LE Y.NO.CHARGE.CODES
        GOSUB GET.VALUES
        START.COUNT += 1 ;*R22 Auto code conversion
    REPEAT
    Y.AMOUNTS = LOWER(Y.AMOUNTS)
RETURN
*----------------------------------------------------------------------------------------------------
GET.VALUES:
*----------

    Y.CHARGE.CODE = Y.ALL.CHARGE.CODES<1,START.COUNT>

    CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.CHARGE.CODE, R.FT.COMMISSION.TYPE, ERR.FTCT) ;*R22 Auto code conversion

    IF R.FT.COMMISSION.TYPE THEN
        IF R.FT.COMMISSION.TYPE<FT4.FLAT.AMT> NE '' THEN
            Y.AMOUNTS<-1> = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>
        END ELSE
            Y.AMOUNTS<-1> = (R.FT.COMMISSION.TYPE<FT4.PERCENTAGE>*Y.BASE.AMOUNT)/100
        END

    END ELSE
        CALL CACHE.READ(FN.FT.CHARGE.TYPE, Y.CHARGE.CODE, R.FT.CHARGE.TYPE, ERR.FTCT) ;*R22 Auto code conversion
        IF R.FT.CHARGE.TYPE THEN
            Y.AMOUNTS<-1> = R.FT.CHARGE.TYPE<FT5.FLAT.AMT>
        END ELSE
            Y.AMOUNTS<-1> = R.FT.CHARGE.TYPE<FT5.CHARGE.AMT>
        END
    END

RETURN
*----------------------------------------------------------------------------------------------------
PROCESS.WAIVE.ALL:
*~~~~~~~~~~~~~~~~~

*    CURR.NO = DCOUNT(R.NEW(TT.TE.OVERRIDE),VM) + 1
*    TEXT = 'WAIVE.CHARGE.TAX'
*    CALL STORE.OVERRIDE(CURR.NO)

    LOCATE Y.TAX.KEY IN Y.ALL.CHARGE.CODES<1,1> SETTING POS2 THEN

        IF Y.ALL.LOC.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2> NE TEMP.AMT THEN

*            R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2>
*            R.NEW(TT.TE.NARRATIVE.2) = Y.AMOUNTS<1,POS2>
            IF APPLICATION EQ 'TELLER' AND (PGM.VERSION EQ ',CHQ.NO.TAX' OR PGM.VERSION EQ ',MGR.CHQ.NOTAX') THEN
                R.NEW(TT.TE.NARRATIVE.2) = Y.AMOUNTS<1,POS2>
            END ELSE
                R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2>
            END
        END ELSE

            IF Y.ALL.FOR.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2> NE TEMP.AMT THEN

*                R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2>
*                R.NEW(TT.TE.NARRATIVE.2) = Y.AMOUNTS<1,POS2>
                R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2>

            END

        END
    END

*    Y.BASE.AMT = Y.BASE.AMT - SUM(Y.AMOUNTS)
*    Y.BASE.AMT = Y.BASE.AMT - SUM(R.NEW(TT.TE.CHRG.AMT.LOCAL))

    IF PGM.VERSION EQ ',MGR.CHQ.NOTAX' AND MESSAGE EQ '' THEN
        Y.BASE.AMT = Y.BASE.AMT - SUM(Y.AMOUNTS) + Y.AMOUNTS<1,POS2>
    END ELSE
        Y.BASE.AMT = Y.BASE.AMT - SUM(R.NEW(TT.TE.CHRG.AMT.LOCAL))
    END

    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.BASE.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2) = Y.BASE.AMT

    R.NEW(TT.TE.WAIVE.CHARGES) = 'YES'
    R.NEW(TT.TE.CHRG.AMT.LOCAL) = ''
    R.NEW(TT.TE.CHRG.AMT.FCCY) = ''
    R.NEW(TT.TE.CHARGE.CODE) = ''
    R.NEW(TT.TE.CHARGE.CUSTOMER) = ''
    R.NEW(TT.TE.CHARGE.ACCOUNT) = ''
    R.NEW(TT.TE.CHARGE.CATEGORY) = ''

RETURN
*----------------------------------------------------------------------------------------------------
PROCESS.WAIVE.CHARGE:
*~~~~~~~~~~~~~~~~~~~~

    R.NEW(TT.TE.WAIVE.CHARGES) = 'NO'
    LOCATE Y.TAX.KEY IN Y.ALL.CHARGE.CODES<1,1> SETTING POS3 THEN

        TOT.CHARGES = DCOUNT(Y.ALL.CHARGE.CODES,@VM)

        START.LOOP = 1

        GOSUB LOOP.WAIVE.CHARGE

    END

    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.BASE.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2) = Y.BASE.AMT

RETURN
*----------------------------------------------------------------------------------------------------
LOOP.WAIVE.CHARGE:
*-----------------
    LOOP
    WHILE START.LOOP LE TOT.CHARGES

        IF START.LOOP NE POS3 THEN

            IF Y.ALL.LOC.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2> NE TEMP.AMT THEN

                Y.BASE.AMT = Y.BASE.AMT - Y.AMOUNTS<1,START.LOOP>
                R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,START.LOOP> = LCCY:' ':'0.00'

            END ELSE

                IF Y.ALL.FOR.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2> NE TEMP.AMT THEN
                    Y.BASE.AMT = Y.BASE.AMT - Y.AMOUNTS<1,START.LOOP>
                    R.NEW(TT.TE.CHRG.AMT.FCCY)<1,START.LOOP> = LCCY:' ':'0.00'
                END

            END

        END ELSE
            IF Y.ALL.LOC.CHGS NE '' THEN
                R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS3> = Y.AMOUNTS<1,POS3>
            END ELSE
                IF Y.ALL.FOR.CHGS NE '' THEN
                    R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS3> = Y.AMOUNTS<1,POS3>
                END
            END

        END

        START.LOOP += 1 ;*R22 Auto code conversion

    REPEAT
RETURN
*----------------------------------------------------------------------------------------------------
PROCESS.WAIVE.TAX:
*~~~~~~~~~~~~~~~~~

    R.NEW(TT.TE.WAIVE.CHARGES) = 'NO'

    LOCATE Y.TAX.KEY IN Y.ALL.CHARGE.CODES<1,1> SETTING POS2 THEN

        TOT.CHARGES = DCOUNT(Y.ALL.CHARGE.CODES,@VM)

        START.LOOP = 1

        GOSUB LOOP.WAIVE.TAX

    END

    IF APPLICATION EQ 'TELLER' AND (PGM.VERSION EQ ',CHQ.NO.TAX' OR PGM.VERSION EQ ',MGR.CHQ.NOTAX') ELSE
        R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.BASE.AMT
        R.NEW(TT.TE.AMOUNT.LOCAL.2) = Y.BASE.AMT
    END

RETURN
*---------------------------------------------------------------------------------------------------
LOOP.WAIVE.TAX:
*--------------
    LOOP
    WHILE START.LOOP LE TOT.CHARGES

        IF START.LOOP EQ POS2 THEN
            IF Y.ALL.LOC.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2> NE TEMP.AMT THEN

*            R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2>
                Y.BASE.AMT = Y.BASE.AMT - Y.AMOUNTS<1,START.LOOP>
                R.NEW(TT.TE.NARRATIVE.2) = Y.AMOUNTS<1,POS2>
                R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,POS2> = LCCY:' ':'0.00'

            END ELSE

                IF Y.ALL.FOR.CHGS NE '' AND R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2> NE TEMP.AMT THEN

*                R.NEW(TT.TE.NARRATIVE.2) = R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2>
                    Y.BASE.AMT = Y.BASE.AMT - Y.AMOUNTS<1,START.LOOP>
                    R.NEW(TT.TE.NARRATIVE.2) = Y.AMOUNTS<1,POS2>
                    R.NEW(TT.TE.CHRG.AMT.FCCY)<1,POS2> = LCCY:' ':'0.00'

                END

            END
        END ELSE

            IF Y.ALL.LOC.CHGS NE '' THEN

                R.NEW(TT.TE.CHRG.AMT.LOCAL)<1,START.LOOP> = Y.AMOUNTS<1,START.LOOP>

            END ELSE

                IF Y.ALL.FOR.CHGS NE '' THEN

                    R.NEW(TT.TE.CHRG.AMT.FCCY)<1,START.LOOP> = Y.AMOUNTS<1,START.LOOP>

                END

            END
        END

        START.LOOP += 1 ;*R22 Auto code conversion

    REPEAT
RETURN
*---------------------------------------------------------------------------------------------------
END
