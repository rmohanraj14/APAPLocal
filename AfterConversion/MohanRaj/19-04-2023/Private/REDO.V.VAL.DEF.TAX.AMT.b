* @ValidationCode : MjotMjkzMzUzNjYyOkNwMTI1MjoxNjgxODkwMDM3MTcyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:10:37
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
SUBROUTINE REDO.V.VAL.DEF.TAX.AMT
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: SHANKAR RAJU
* PROGRAM NAME: REDO.V.INP.RAISE.OVERRIDE
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
*21.02.2011  KAVITHA       HD1054080-S       CHANGES MADE FOR VERSION REFRESHING OF WAIVE TAX CHARGE FIELDS
*20.04.2001  Bharath G     PACS00032271      Base amount should not be modified.
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,++ TO +=1,F.READ TO CACHE.READ
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.ADMIN.CHQ.PARAM
    $INSERT I_F.REDO.MANAGER.CHQ.PARAM
    $INSERT I_F.TELLER.TRANSACTION
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.FT.CHARGE.TYPE
    $INSERT I_F.TAX
    $INSERT I_GTS.COMMON

    GOSUB INITIALISE
    GOSUB LOCAL.REF
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------
INITIALISE:
*----------------------------------------------------------------------
    TOT.WAIVE.AMT=''
    CHG.COMM.AMT.SAVE=''
    TAX.COMM.AMT=''
    Y.BASE.AMOUNT=''
    Y.BASE.AMT=''
    TAX.CHARGE.CODE=''
    COMM.CHARGE.CODE=''
    TOTAL.CHARGE=''
    Y.FINAL.AMT=''
    FINAL.AMOUNT=''
    TOT.COUNT.CHARGE=''
    LOC.REF.APPLICATION="TELLER"
    LOC.REF.FIELDS='WAIVE.TAX':@VM:'L.TT.WAI.CHARGE':@VM:'L.TT.BASE.AMT':@VM:'L.LETTER.ID':@VM:'L.TT.ADD.INFO':@VM:'L.TT.TAX.TYPE':@VM:'TAX.AMOUNT'
    LOC.REF.POS=''

RETURN
*----------------------------------------------------------------------------------------------------------
OPEN.FILES:
*~~~~~~~~~~
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

RETURN
*---------------------------------------------------------------------------------
LOCAL.REF:
*~~~~~~~~~
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LREF.POS)
    POS.WAIVE.TAX    = LREF.POS<1,1>
    POS.WAIVE.CHARGE = LREF.POS<1,2>
    POS.BASE.AMT     = LREF.POS<1,3>

    POS.STACK.TAX    = LREF.POS<1,4>
    POS.STACK.CHARGE = LREF.POS<1,5>
    TT.TAX.POS       = LREF.POS<1,6>
    POS.TAX.AMOUNT   = LREF.POS<1,7>

    IF PGM.VERSION[2,3] EQ 'CHQ' THEN

        FN.REDO.ADMIN.CHQ.PARAM = 'F.REDO.ADMIN.CHQ.PARAM'
        F.REDO.ADMIN.CHQ.PARAM = ''
        R.REDO.ADMIN.CHQ.PARAM = ''
        CALL OPF(FN.REDO.ADMIN.CHQ.PARAM,F.REDO.ADMIN.CHQ.PARAM)
        CALL CACHE.READ(FN.REDO.ADMIN.CHQ.PARAM,'SYSTEM',R.REDO.ADMIN.CHQ.PARAM,ERR.PAR)
        Y.ACCOUNT.2 = R.NEW(TT.TE.ACCOUNT.2)

        Y.ALL.AC.NOS = R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.ACCOUNT>
        Y.ALL.TAX.KEYS = R.REDO.ADMIN.CHQ.PARAM<ADMIN.CHQ.PARAM.TAX.KEY>

    END ELSE

        FN.REDO.MANAGER.CHQ.PARAM = 'F.REDO.MANAGER.CHQ.PARAM'
        F.REDO.MANAGER.CHQ.PARAM = ''
        R.REDO.MANAGER.CHQ.PARAM = ''
        CALL OPF(FN.REDO.MANAGER.CHQ.PARAM,F.REDO.MANAGER.CHQ.PARAM)
        CALL CACHE.READ(FN.REDO.MANAGER.CHQ.PARAM,'SYSTEM',R.REDO.MANAGER.CHQ.PARAM,ERR.PAR)
        Y.ACCOUNT.2 = R.NEW(TT.TE.ACCOUNT.2)
        Y.ALL.AC.NOS = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.ACCOUNT>
        Y.ALL.TAX.KEYS = R.REDO.MANAGER.CHQ.PARAM<MAN.CHQ.PRM.TAX.KEY>

    END

    LOCATE Y.ACCOUNT.2 IN Y.ALL.AC.NOS<1,1> SETTING POS1 THEN
        Y.TAX.KEY = Y.ALL.TAX.KEYS<1,POS1>
    END
RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

*TO CALCULATE THE CHARGE AMOUNT FOR THE BASE AMOUNT

    GOSUB CALCULATE.AMOUNT

    Y.WAIVE.CHARGE = R.NEW(TT.TE.LOCAL.REF)<1,POS.WAIVE.CHARGE>
    Y.WAIVE.TAX = COMI
    IF NOT(Y.WAIVE.TAX) THEN
        Y.WAIVE.TAX = R.NEW(TT.TE.LOCAL.REF)<1,POS.WAIVE.TAX>
    END

*ADDED TO CLASSIFY
    GOSUB PROCESS.WAIVE.CHARGE

RETURN
*----------------------------------------------------------------------------------------------------
CALCULATE.AMOUNT:
*~~~~~~~~~~~~~~~~

    Y.BASE.AMT =R.NEW(TT.TE.LOCAL.REF)<1,POS.BASE.AMT>
    TAXATION.CODE = R.NEW(TT.TE.LOCAL.REF)<1,TT.TAX.POS>
    IF TAXATION.CODE THEN
        SEL.CMD       = "SELECT ":FN.TAX:" WITH @ID LIKE ":TAXATION.CODE:"... BY-DSND @ID"
        CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.REC,RET.ERR)
        TAXATION.CODE = SEL.LIST<1>
        CALL CACHE.READ(FN.TAX, TAXATION.CODE, R.TAX, ERR.TAX) ;*R22 Auto code conversion
        Y.TAX.RATE    = R.TAX<EB.TAX.RATE>
        Y.TAX.AMT     = (Y.BASE.AMT*Y.TAX.RATE)/100
        Y.TAX.AMT.W.AMT = FIELD(Y.TAX.AMT,'.',1)
        Y.TAX.PREC.AMT = FIELD(Y.TAX.AMT,'.',2)
        Y.TAX.PREC.AMT = Y.TAX.PREC.AMT[1,2]
        Y.TAX.AMT = Y.TAX.AMT.W.AMT:'.':Y.TAX.PREC.AMT
    END ELSE
        Y.TAX.AMT = 0.00
    END
    Y.TELLER.TRANSACTION = R.NEW(TT.TE.TRANSACTION.CODE)

    CALL CACHE.READ(FN.TELLER.TRANSACTION, Y.TELLER.TRANSACTION, R.TELLER.TRANSACTION, ERR.TT) ;*R22 Auto code conversion
    Y.ALL.CHARGE.CODES = R.TELLER.TRANSACTION<TT.TR.CHARGE.CODE>

    Y.NO.CHARGE.CODES = DCOUNT(Y.ALL.CHARGE.CODES,@VM)

    START.COUNT = 1
    LOOP
    WHILE START.COUNT LE Y.NO.CHARGE.CODES
        GOSUB GET.VALUES
        START.COUNT += 1 ;*R22 Auto code conversion
    REPEAT
RETURN
*----------------------------------------------------------------------------------------------------
GET.VALUES:
*----------
*Calculation of Tax & Charge is done based on the FT.COMMISSION.TYPE

    IF Y.BASE.AMOUNT EQ '' THEN
        Y.BASE.AMOUNT=Y.BASE.AMT
    END

    Y.CHARGE.CODE = Y.ALL.CHARGE.CODES<1,START.COUNT>

    CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.CHARGE.CODE, R.FT.COMMISSION.TYPE, ERR.FTCT) ;*R22 Auto code conversion

    GOSUB CALC.TAX.COMMSN

RETURN
*----------------------------------------------------------------------------------------------------
CALC.TAX.COMMSN:
*---------------

    IF R.FT.COMMISSION.TYPE THEN

        IF R.FT.COMMISSION.TYPE<FT4.FLAT.AMT> NE '' THEN
            CHG.COMM.AMT = R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>
        END ELSE
* PACS00032271 - S
* DROUND Function added to round the amount.
            CHG.COMM.AMT = (R.FT.COMMISSION.TYPE<FT4.PERCENTAGE>*Y.BASE.AMOUNT)/100
            CHG.PREC.AMT = FIELD(CHG.COMM.AMT,'.',2)
            CHG.PREC.AMT = CHG.PREC.AMT[1,2]
            CHG.COMM.AMT = FIELD(CHG.COMM.AMT,'.',1)
            CHG.COMM.AMT = CHG.COMM.AMT:'.':CHG.PREC.AMT
* PACS00032271 - E
        END
        CHG.COMM.AMT.SAVE<-1>= CHG.COMM.AMT
        COMM.CHARGE.CODE<-1>= Y.CHARGE.CODE
    END
RETURN
*----------------------------------------------------------------------------------------------------
PROCESS.WAIVE.CHARGE:
*~~~~~~~~~~~~~~~~~~~~
*----------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ 'YES' AND Y.WAIVE.TAX EQ 'NO' THEN

        GOSUB WAIVE.ONLY.CHARGE
    END
*---------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ 'YES' AND Y.WAIVE.TAX EQ '' THEN

        GOSUB WAIVE.ONLY.CHARGE
    END
*---------------------------------------------------------------------------------------------------
    IF Y.WAIVE.TAX EQ 'YES' AND Y.WAIVE.CHARGE EQ 'NO' THEN
        GOSUB WAIVE.ONLY.TAX
    END
*---------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ 'NO' AND Y.WAIVE.TAX EQ 'NO' THEN

        GOSUB WAIVE.NO.CHARGE.TAX
    END

*---------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ '' AND Y.WAIVE.TAX EQ 'NO' THEN
        GOSUB WAIVE.NO.CHARGE.TAX
    END
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ 'NO' AND Y.WAIVE.TAX EQ '' THEN      ;*First Time when the screen Opens

        GOSUB WAIVE.NO.CHARGE.TAX
    END
*-----------------------------------------------------------------------------------------------------
    IF Y.WAIVE.CHARGE EQ 'YES' AND Y.WAIVE.TAX EQ 'YES' THEN

        GOSUB WAIVE.ALL.CHARGE.TAX

    END

RETURN
*-------------------------------------------------------------------------------------------------------
WAIVE.ONLY.CHARGE:
*~~~~~~~~~~~~~~~~~

    TOT.WAIVE.AMT = SUM(CHG.COMM.AMT.SAVE)
    FINAL.AMOUNT = R.NEW(TT.TE.LOCAL.REF)<1,POS.BASE.AMT>
    Y.BASE.AMT   = R.NEW(TT.TE.LOCAL.REF)<1,POS.BASE.AMT>
    Y.FINAL.AMT = FINAL.AMOUNT

    CHANGE @FM TO @VM IN CHG.COMM.AMT.SAVE
    TOTAL.CHARGE=CHG.COMM.AMT.SAVE
    TOT.COUNT.CHARGE= DCOUNT(TOTAL.CHARGE,@VM)

    FOR COUNT.CHG = 1 TO TOT.COUNT.CHARGE
        CHG.COMM.AMT.SAVE<COUNT.CHG>='0.00'
    NEXT COUNT.CHG

    Y.NULL.COUNT = 1
    TOTAL.CHARGE = ''
    LOOP
        REMOVE Y.VAL FROM CHG.COMM.AMT.SAVE SETTING Y.NULL.POS
    WHILE Y.NULL.COUNT LE TOT.COUNT.CHARGE
        IF Y.VAL NE '' THEN
            TOTAL.CHARGE<-1> = Y.VAL
            Y.NULL.COUNT += 1
        END
    REPEAT
    CHANGE @FM TO @VM IN TOTAL.CHARGE

    COMM.CHARGE.CODE=LOWER(COMM.CHARGE.CODE)
    R.NEW(TT.TE.CHARGE.CODE)   = COMM.CHARGE.CODE
    R.NEW(TT.TE.CHRG.AMT.LOCAL)= TOTAL.CHARGE
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.FINAL.AMT + Y.TAX.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1> = Y.FINAL.AMT + Y.TAX.AMT
    R.NEW(TT.TE.LOCAL.REF)<1,POS.TAX.AMOUNT> = Y.TAX.AMT


RETURN
*---------------------------------------------------------------------------------------------------
WAIVE.ONLY.TAX:
*~~~~~~~~~~~~~
    Y.TAX.AMT = 0
    TOT.WAIVE.AMT = SUM(CHG.COMM.AMT.SAVE)
    Y.FINAL.AMT   = Y.BASE.AMT + TOT.WAIVE.AMT
    CHANGE @FM TO @VM IN CHG.COMM.AMT.SAVE
    TOTAL.CHARGE = CHG.COMM.AMT.SAVE
    COMM.CHARGE.CODE=LOWER(COMM.CHARGE.CODE)
    R.NEW(TT.TE.CHARGE.CODE)=COMM.CHARGE.CODE
    R.NEW(TT.TE.CHRG.AMT.LOCAL) = TOTAL.CHARGE
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.FINAL.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1> = Y.FINAL.AMT
    R.NEW(TT.TE.LOCAL.REF)<1,POS.TAX.AMOUNT> = Y.TAX.AMT

RETURN
*--------------------------------------------------------------------------------------------------
WAIVE.NO.CHARGE.TAX:
*~~~~~~~~~~~~~~~~~~~
    CHANGE @FM TO @VM IN CHG.COMM.AMT.SAVE
    TOTAL.CHARGE=CHG.COMM.AMT.SAVE

    COMM.CHARGE.CODE=LOWER(COMM.CHARGE.CODE)
    R.NEW(TT.TE.CHARGE.CODE)=COMM.CHARGE.CODE
    TOT.COUNT.CHARGE= DCOUNT(TOTAL.CHARGE,@VM)
    Y.NULL.COUNT = 1
    TOTAL.CHARGE = ''
    LOOP
        REMOVE Y.VAL FROM CHG.COMM.AMT.SAVE SETTING Y.NULL.POS
    WHILE Y.NULL.COUNT LE TOT.COUNT.CHARGE
        IF Y.VAL NE '' THEN
            TOTAL.CHARGE<-1> = Y.VAL
            Y.NULL.COUNT += 1
        END
    REPEAT
    CHANGE @FM TO @VM IN TOTAL.CHARGE
    R.NEW(TT.TE.CHRG.AMT.LOCAL)=TOTAL.CHARGE
    R.NEW(TT.TE.AMOUNT.LOCAL.1) = Y.BASE.AMOUNT
    TOT.WAIVE.AMT = SUM(CHG.COMM.AMT.SAVE)
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1> = Y.BASE.AMT+TOT.WAIVE.AMT+Y.TAX.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1> = Y.BASE.AMT+TOT.WAIVE.AMT+Y.TAX.AMT
    R.NEW(TT.TE.LOCAL.REF)<1,POS.TAX.AMOUNT> = Y.TAX.AMT

RETURN

*----------------------------------------------------------------------------------------------------
WAIVE.ALL.CHARGE.TAX:
*~~~~~~~~~~~~~~~~~~~~
    Y.TAX.AMT = 0
    CHANGE @FM TO @VM IN CHG.COMM.AMT.SAVE
    TOT.COUNT.CHARGE= DCOUNT(CHG.COMM.AMT.SAVE,@VM)
    FOR COUNT.CHG = 1 TO TOT.COUNT.CHARGE
        CHG.COMM.AMT.SAVE<COUNT.CHG>='0.00'
    NEXT COUNT.CHG
    CHG.COMM.AMT.SAVE=LOWER(CHG.COMM.AMT.SAVE)
    TOTAL.CHARGE=CHG.COMM.AMT.SAVE
    R.NEW(TT.TE.CHRG.AMT.LOCAL)=TOTAL.CHARGE
    COMM.CHARGE.CODE=LOWER(COMM.CHARGE.CODE)
    R.NEW(TT.TE.CHARGE.CODE)=COMM.CHARGE.CODE
    R.NEW(TT.TE.AMOUNT.LOCAL.1)<1,1>=Y.BASE.AMT
    R.NEW(TT.TE.AMOUNT.LOCAL.2)<1,1>=Y.BASE.AMT
    R.NEW(TT.TE.LOCAL.REF)<1,POS.TAX.AMOUNT> = Y.TAX.AMT


RETURN
*------------------------------------------------------------------------------------------------------
END
