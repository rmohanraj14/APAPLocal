* @ValidationCode : MjotMzM3NTgwMTU1OkNwMTI1MjoxNjgxMzgyNzg4NjI1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:16:28
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
SUBROUTINE REDO.V.CANT.CK
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.V.CANT.CK
* ODR NO      : ODR-2009-12-0275
*----------------------------------------------------------------------
*DESCRIPTION: It is neccessary to create a routine REDO.V.MONTO.CK as
* a validation routine to default fields in REDO.H.SOLICITUD.CK
*IN PARAMETER:  NA
*OUT PARAMETER: NA
*LINKED WITH: REDO.H.SOLICITUD.CK
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*19.02.2010  H GANESH     ODR-2009-12-0275  INITIAL CREATION
*27.01.2012  SHANKAR RAJU   PACS00176990    Tax Calculation part changes[*0.15/100], CANT.CK is assigned to COMI in case of browser
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,++ TO +=1,F.READ TO CACHE.READ
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.CANT.CK
    $INSERT I_F.REDO.H.SOLICITUD.CK
    $INSERT I_F.FT.COMMISSION.TYPE
    $INSERT I_F.TAX
    $INSERT I_EB.EXTERNAL.COMMON
    $INSERT I_F.STOCK.ENTRY
    $INSERT I_DAS.TAX

    IF  EB.EXTERNAL$CHANNEL EQ 'INTERNET' THEN

        GOSUB INIT
        GOSUB OPENFILES
        GOSUB PROCESS
    END

    IF MESSAGE EQ 'VAL' THEN
        RETURN

    END
    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------
INIT:
*----------------------------------------------------------------------
    FN.REDO.H.CANT.CK='F.REDO.H.CANT.CK'
    F.REDO.H.CANT.CK=''
    FN.FT.COMMISSION.TYPE='F.FT.COMMISSION.TYPE'
    F.FT.COMMISSION.TYPE=''
    FN.TAX='F.TAX'
    F.TAX=''
    FN.STK.DETAILS = 'F.REDO.SAVE.STOCK.DETAILS'
    F.STK.DETAILS = ''
    FN.STK.ENTRY = 'F.STOCK.ENTRY'
    F.STK.ENTRY = ''
    STK.APP = 'STOCK.ENTRY'
    STK.FLD = 'L.STE.COMMTAL'
    CALL MULTI.GET.LOC.REF(STK.APP,STK.FLD,STK.POS)
    STK.VAL.POS = STK.POS<1,1>

    TOTAL.TAX.AMT=0
    TOTAL.FLAT.AMT=0
    Y.DEFAULT.CCY = ''
    Y.AI.COSTO.CK = ''

RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    CALL OPF(FN.REDO.H.CANT.CK,F.REDO.H.CANT.CK)
    CALL OPF(FN.FT.COMMISSION.TYPE,F.FT.COMMISSION.TYPE)
    CALL OPF(FN.TAX,F.TAX)
    CALL OPF(FN.STK.DETAILS,F.STK.DETAILS)
    CALL OPF(FN.STK.ENTRY,F.STK.ENTRY)
RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    GOSUB SELECT.TAX
    SOL.AGENCIA  =    R.NEW(REDO.H.SOL.SUC.SOL)
    R.NEW(REDO.H.SOL.SUC.ENTREGA) = SOL.AGENCIA

    IF  EB.EXTERNAL$CHANNEL EQ 'INTERNET' THEN
        Y.CANT.CK = R.NEW(REDO.H.SOL.CANT.CK)
    END ELSE
        Y.CANT.CK = COMI
    END

    CALL F.READ(FN.REDO.H.CANT.CK,Y.CANT.CK,R.REDO.H.CANT.CK,F.REDO.H.CANT.CK,ERR.CANT.CK)
    Y.CHEQUE.TYPE=R.NEW(REDO.H.SOL.CHEQUE.TYPE)
    IF  EB.EXTERNAL$CHANNEL EQ 'INTERNET' THEN
        Y.CHEQUE.TYPE = R.REDO.H.CANT.CK<REDO.H.CA.CK.TYPE>
        ACCT.ID = R.NEW(REDO.H.SOL.ACCOUNT)
        CALL F.READ(FN.STK.DETAILS,ACCT.ID,R.STK.DETAILS,F.STK.DETAILS,STK.ERR)
        IF NOT(STK.ERR) THEN
            R.NEW(REDO.H.SOL.FICHA.IMPR)= R.STK.DETAILS<1>
            CALL F.READ(FN.STK.ENTRY,R.STK.DETAILS,R.STK.ENTRY,F.STK.ENTRY,STK.ENT.ERR)
            IF NOT(STK.ENT.ERR) THEN

                STK.FT.COMM.TYPE = R.STK.ENTRY<STO.ENT.LOCAL.REF><1,STK.VAL.POS>
                R.NEW(REDO.H.SOL.COSTO.CK) = STK.FT.COMM.TYPE
                Y.AI.COSTO.CK =  R.NEW(REDO.H.SOL.COSTO.CK)<1,1>
                CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.AI.COSTO.CK, R.FT.COMMISSION.TYPE, FT.COMMI.ERR) ;*R22 Auto Code Conversion
                Y.DEFAULT.CCY = R.FT.COMMISSION.TYPE<FT4.DEFAULT.CCY>
                R.NEW(REDO.H.SOL.MONEDA.CK) = Y.DEFAULT.CCY
            END
        END
    END

    LOCATE Y.CHEQUE.TYPE IN R.REDO.H.CANT.CK<REDO.H.CA.CK.TYPE,1> SETTING POS THEN
        Y.CANT.TAL=R.REDO.H.CANT.CK<REDO.H.CA.CANT.TAL,POS>
    END
    R.NEW(REDO.H.SOL.CANT.TAL)=Y.CANT.TAL
    Y.COSTO.CK.CNT=DCOUNT(R.NEW(REDO.H.SOL.COSTO.CK),@VM)
    VAR1=1
    LOOP
    WHILE VAR1 LE Y.COSTO.CK.CNT
        Y.COSTO.CK = R.NEW(REDO.H.SOL.COSTO.CK)<1,VAR1>
        CALL CACHE.READ(FN.FT.COMMISSION.TYPE, Y.COSTO.CK, R.FT.COMMISSION.TYPE, FT.COMMI.ERR) ;*R22 Auto Code Conversion
        Y.TAX.TYPE=R.FT.COMMISSION.TYPE<FT4.TAX.CODE>


        R.NEW(REDO.H.SOL.TAX)=SEL.LIST<NOR>
        FLAT.AMT.CNT= DCOUNT(R.FT.COMMISSION.TYPE<FT4.FLAT.AMT>,@VM)
        TOTAL.FLAT.AMT=''
        TOT.MONTO.CK=''
        VAR2=1
        LOOP
        WHILE VAR2 LE FLAT.AMT.CNT
            TOTAL.FLAT.AMT=R.FT.COMMISSION.TYPE<FT4.FLAT.AMT,VAR2>+TOTAL.FLAT.AMT
            VAR2 += 1
        REPEAT
        Y.CANT.TAL=R.NEW(REDO.H.SOL.CANT.TAL)
        TOT.MONTO.CK = TOTAL.FLAT.AMT*Y.CANT.TAL
        R.NEW(REDO.H.SOL.MONTO.CK)<1,VAR1>=TOT.MONTO.CK
        TOTAL.TAX.AMT += TOT.MONTO.CK ;*R22 Auto Code Conversion
        VAR1 += 1
    REPEAT
*** PACS00176990 - Tax Calculation part changes[*0.15/100]
*** S ->
    Y.TAX.AMT = (TOTAL.TAX.AMT*0.15)/100
    Y.CURRENCY = LCCY
    CALL EB.ROUND.AMOUNT(Y.CURRENCY,Y.TAX.AMT,"","")

    R.NEW(REDO.H.SOL.TAX.AMOUNT) = Y.TAX.AMT
*** -> R
RETURN
*----------------------------------------------------------------------------

*----------*
SELECT.TAX:
*-----------*

    SEL.CMD = 'SSELECT ':FN.TAX

    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NOR,SEL.ERR)

*    TOT.TAX.CNT = DCOUNT(SEL.REC,FM)

RETURN

END
