* @ValidationCode : MjotNjAwMjY2NzE5OkNwMTI1MjoxNjgxMzAyNzQ3MDczOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:02:27
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
SUBROUTINE REDO.V.AUTH.DEPOSIT(Y.AC.OGM.ID,Y.AC.OGM.ID1)
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : REDO.V.AUTH.DEPOSIT
*--------------------------------------------------------------------------------
* Description:
*--------------------------------------------------------------------------------
*       This authorisation routine should be attached to the REDO.H.AZ.REINV.DEPOSIT
* template. This routine is used to create primary base account, reinvested
* interest account and az.account
*---------------------------------------------------------------------------------
* Modification History:
*---------------------------------------------------------------------------------
*
*  DATE             WHO         REFERENCE         DESCRIPTION
* 11-06-2010      SUJITHA.S   ODR-2009-10-0332  INITIAL CREATION
* 03-08-2010      RASHMITHA M    ODR-2009-10-0346  B.21 Changes incorporated
* 24-02-2011      H GANESH    PACS00033293       Change made as per issue
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,++ TO +=1
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* --------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.AZ.REINV.DEPOSIT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_GTS.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.TFS.PROCESS

    GOSUB INIT
    GOSUB REINVACCT
    GOSUB ACCT

RETURN

*-----------------------------------------------------------------------------------
INIT:
*-----------------------------------------------------------------------------------

    LOC.APPL='AZ.ACCOUNT':@FM:'ACCOUNT'
    LOC.FIELD='L.AZ.METHOD.PAY':@VM:'L.AZ.AMOUNT':@VM:'L.AZ.SRC.FUND':@VM:'L.AZ.DEBIT.ACC':@VM:'L.AZ.ORG.DP.AMT':@VM:'L.AZ.IN.TRANSIT':@VM:'L.VAL.MAT.DATE':@VM:'L.MG.ACT.NO':@VM:'L.FHA.POL.NO':@VM:'L.FHA.CASE.NO':@FM:'L.AC.REINVESTED'
    LOC.POS=''
    CALL MULTI.GET.LOC.REF(LOC.APPL,LOC.FIELD,LOC.POS)
    Y.METHOD.POS=LOC.POS<1,1>
    Y.AMOUNT.POS=LOC.POS<1,2>
    Y.SOURCE.POS=LOC.POS<1,3>
    Y.DEBIT.POS=LOC.POS<1,4>
    Y.ORIG.AMT.POS=LOC.POS<1,5>
    Y.INTRANSIT.POS=LOC.POS<1,6>
    Y.VAL.MAT.DATE.POS=LOC.POS<1,7>
    Y.MG.ACT.NO.POS=LOC.POS<1,8>
    Y.FHA.POL.NO.POS=LOC.POS<1,9>
    Y.FHA.CASE.NO.POS=LOC.POS<1,10>
    Y.REINV.POS=LOC.POS<2,1>

RETURN

*-----------------------------------------------------------------------------------
REINVACCT:
*-----------------------------------------------------------------------------------

    Y.CUSTOMER=R.NEW(REDO.AZ.REINV.CUSTOMER)
    Y.CATEGORY=R.NEW(REDO.AZ.REINV.REINVINT.CATEG)
    Y.CURRENCY=R.NEW(REDO.AZ.REINV.CURRENCY)
    Y.ACCOUNTNAME=R.NEW(REDO.AZ.REINV.ACCOUNT.NAME)
*Y.MNEMONIC=R.NEW(REDO.AZ.REINV.MNEMONIC)
    Y.MNEMONIC=''
    Y.ACCT.OFF=R.NEW(REDO.AZ.REINV.ACCOUNT.OFFICER)
    Y.JOINT.HOLDER=R.NEW(REDO.AZ.REINV.JOINT.HOLDER)
    Y.JOINT.REL=R.NEW(REDO.AZ.REINV.JOINT.RELCODE)

    R.AC.DETAIL=''

    R.AC.DETAIL<AC.CUSTOMER> = Y.CUSTOMER
    R.AC.DETAIL<AC.CATEGORY> = Y.CATEGORY
    R.AC.DETAIL<AC.CURRENCY> = Y.CURRENCY
    R.AC.DETAIL<AC.SHORT.TITLE> = Y.ACCOUNTNAME
    R.AC.DETAIL<AC.MNEMONIC> = Y.MNEMONIC
    R.AC.DETAIL<AC.ACCOUNT.OFFICER> = Y.ACCT.OFF

    Y.JOINT.DETAILS=DCOUNT(Y.JOINT.HOLDER,@VM)
    Y.JOINT.INIT=1
    LOOP
    WHILE Y.JOINT.INIT LE Y.JOINT.DETAILS
        R.AC.DETAIL<AC.JOINT.HOLDER,Y.JOINT.INIT> = R.NEW(REDO.AZ.REINV.JOINT.HOLDER)<1,Y.JOINT.INIT>
        R.AC.DETAIL<AC.RELATION.CODE,Y.JOINT.INIT> = R.NEW(REDO.AZ.REINV.JOINT.RELCODE)<1,Y.JOINT.INIT>
        Y.JOINT.INIT += 1
    REPEAT

    ACTUAL.APP.NAME = 'ACCOUNT'
    OFS.FUNCTION = 'I'
    PROCESS = 'PROCESS'
    OFS.VERSION = ''
    GTSMODE = ''
    NO.OF.AUTH = ''
    TRANSACTION.ID = Y.AC.OGM.ID
    OFS.RECORD = ''
    VERSION = 'ACCOUNT,RE'
    MSG.ID = ''
    OFS.SRC.ID = 'REINV.DEPOSIT'
    OPTION = ''

    CALL OFS.BUILD.RECORD(ACTUAL.APP.NAME,OFS.FUNCTION,PROCESS,OFS.VERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.AC.DETAIL,OFS.RECORD)
    OFS.MSG = VERSION:OFS.RECORD
    MSG.ID = ''
    ERR.OFS = ''

RETURN

*-------------------------------------------------------------------------------------------
ACCT:
*-------------------------------------------------------------------------------------------

    Y.CUSTOMER1=R.NEW(REDO.AZ.REINV.CUSTOMER)
    Y.CATEGORY1=R.NEW(REDO.AZ.REINV.PRODUCT.CODE)
    Y.CURRENCY1=R.NEW(REDO.AZ.REINV.CURRENCY)
    Y.SHORT.TITLE='REINVESTED.ACCOUNT-':Y.AC.OGM.ID
*Y.MNEMONIC1='RE-':Y.MNEMONIC
    Y.MNEMONIC1=''
    Y.ACCT.OFF1=R.NEW(REDO.AZ.REINV.ACCOUNT.OFFICER)
    Y.REINV.FLAG='YES'

    R.AC.DETAIL1=''

    VERSION1 = 'ACCOUNT,RE'
    OFS.HEADER1=VERSION1:'/I/PROCESS///,//,':Y.AC.OGM.ID1
    OFS.BODY1=',CUSTOMER:1:1=':Y.CUSTOMER1:',CATEGORY:1:1=':Y.CATEGORY1:',CURRENCY:1:1=':Y.CURRENCY1:',SHORT.TITLE:1:1=':Y.SHORT.TITLE:',MNEMONIC:1:1=':Y.MNEMONIC1:',ACCOUNT.OFFICER:1:1=':Y.ACCT.OFF1:',INTEREST.LIQU.ACCT:1:1=':Y.AC.OGM.ID:',LOCAL.REF:':Y.REINV.POS:':1=':Y.REINV.FLAG
    Y.JNT.INIT=1
    JOINT.MULTI=''
    LOOP
    WHILE Y.JNT.INIT LE Y.JOINT.DETAILS
        JOINT.MULTI:=',JOINT.HOLDER:':Y.JNT.INIT:':1=':Y.JOINT.HOLDER<1,Y.JNT.INIT>:',RELATION.CODE:':Y.JNT.INIT:':1=':Y.JOINT.REL<1,Y.JNT.INIT>
        Y.JNT.INIT += 1
    REPEAT
    OFS.MSG1=OFS.HEADER1:OFS.BODY1:JOINT.MULTI

    Y.DB.ACCT=R.NEW(REDO.AZ.REINV.DEBIT.ACCOUNT)
    IF Y.DB.ACCT EQ "" THEN
        GOSUB REDO.V.INP.TFS.PROCESS
    END ELSE
        GOSUB AZACC.PROCESS
    END

RETURN

*--------------------------------------------------------------------------------------------
AZACC.PROCESS:
*--------------------------------------------------------------------------------------------

    Y.CURRENCY=R.NEW(REDO.AZ.REINV.CURRENCY)
    Y.ALL.IN.ONE.PRODUCT=R.NEW(REDO.AZ.REINV.DEPOSIT.PRODUCT)
    Y.PRINCIPAL=R.NEW(REDO.AZ.REINV.DEPOSIT.AMOUNT)
    Y.VAL.DATE=R.NEW(REDO.AZ.REINV.START.DATE)
    Y.MAT.DATE=R.NEW(REDO.AZ.REINV.END.DATE)
    Y.INT.RATE=R.NEW(REDO.AZ.REINV.INTEREST.RATE)
    Y.SCHEDULES=R.NEW(REDO.AZ.REINV.SCHEDULES)
    Y.CHG.CODE=R.NEW(REDO.AZ.REINV.CHARGE.CODE)
    Y.CHG.ACCT=R.NEW(REDO.AZ.REINV.CHG.LIQ.ACCT)
    Y.REP.TYPE=R.NEW(REDO.AZ.REINV.REPAYMENT.TYPE)
    Y.CAL.BASE=R.NEW(REDO.AZ.REINV.CALCULATION.BASE)
    Y.TYPE.SCH=R.NEW(REDO.AZ.REINV.TYPE.OF.SCHDLE)
    Y.FREQ=R.NEW(REDO.AZ.REINV.FREQUENCY)
    Y.MAT.INST=R.NEW(REDO.AZ.REINV.MATURITY.INSTRN)
    Y.NOM.ACC=R.NEW(REDO.AZ.REINV.NOMINATED.ACCOUNT)
    Y.IN.TRANSIT=R.NEW(REDO.AZ.REINV.IN.TRANSIT)
    Y.L.AZ.ORG.DP.AMT=R.NEW(REDO.AZ.REINV.DEPOSIT.AMOUNT)
    Y.AZ.METHOD=R.NEW(REDO.AZ.REINV.AZ.METHOD.PAY)
    Y.AZ.AMOUNT=R.NEW(REDO.AZ.REINV.AZ.AMOUNT)
    Y.AZ.SOURCE=R.NEW(REDO.AZ.REINV.AZ.SOURCE.FUND)
    Y.AZ.DEB.ACCT=R.NEW(REDO.AZ.REINV.AZ.DEBIT.ACC)

*--------------- B.21--------------------------------
    Y.AZ.VAL.MAT.DATE=R.NEW(REDO.AZ.REINV.VAL.MAT.DATE)
    Y.AZ.MG.ACT.NO=R.NEW(REDO.AZ.REINV.MG.ACT.NO)
    Y.AZ.FHA.POL.NO=R.NEW(REDO.AZ.REINV.FHA.POL.NO)
    Y.AZ.FHA.CASE.NO=R.NEW(REDO.AZ.REINV.FHA.CASE.NO)
*-----------------------------------------------------
    Y.MULTI=DCOUNT(R.NEW(REDO.AZ.REINV.AZ.METHOD.PAY),@VM)

    VERSION.NAME='AZ.ACCOUNT,RE'
    OFS.AZ.MSG1=VERSION.NAME:'/I/PROCESS///,//,':Y.AC.OGM.ID1
    OFS.BODY=',ALL.IN.ONE.PRODUCT:1:1=':Y.ALL.IN.ONE.PRODUCT:',PRINCIPAL:1:1=':Y.PRINCIPAL:',VALUE.DATE:1:1=':Y.VAL.DATE:',MATURITY.DATE:1:1=':Y.MAT.DATE:',NOMINATED.ACCOUNT:1:1=':Y.NOM.ACC:',SCHEDULES:1:1=':Y.SCHEDULES:',LOCAL.REF:':Y.ORIG.AMT.POS:':1=':Y.L.AZ.ORG.DP.AMT:',LOCAL.REF:':Y.INTRANSIT.POS:':1=':Y.IN.TRANSIT:',MATURITY.INSTR:1:1=':Y.MAT.INST
    MULTI=1
    OFS.MULTI=''
    LOOP
    WHILE MULTI LE Y.MULTI
        OFS.MULTI:=',LOCAL.REF:':Y.METHOD.POS:':':MULTI:'=':Y.AZ.METHOD<1,MULTI>:',LOCAL.REF:':Y.AMOUNT.POS:':':MULTI:'=':Y.AZ.AMOUNT<1,MULTI>:',LOCAL.REF:':Y.SOURCE.POS:':':MULTI:'=':Y.AZ.SOURCE<1,MULTI>:',LOCAL.REF:':Y.DEBIT.POS:':':MULTI:'=':Y.AZ.DEB.ACCT<1,MULTI>
        MULTI += 1
    REPEAT
*------------------- B.21--------------------------------
    Y.MG.COUNT=DCOUNT(R.NEW(REDO.AZ.REINV.MG.ACT.NO),@VM)
    MG.COUNT=1
    OFS.MG.MULTI=''
    LOOP
    WHILE MG.COUNT LE Y.MG.COUNT
        OFS.MG.MULTI:=',LOCAL.REF:':Y.MG.ACT.NO.POS:':':MULTI:'=':Y.AZ.MG.ACT.NO<1,MG.COUNT>:',LOCAL.REF:':Y.FHA.POL.NO.POS:':':MULTI:'=':Y.AZ.FHA.POL.NO<1,MG.COUNT>:',LOCAL.REF:':Y.FHA.CASE.NO.POS:':':MULTI:'=':Y.AZ.FHA.CASE.NO<A,MG.COUNT>
        MG.COUNT += 1
    REPEAT
*-------------------------------------------------------

*---------------------------PACS00033293------------------
    R.FT=''
    R.FT<FT.DEBIT.ACCT.NO>=R.NEW(REDO.AZ.REINV.DEBIT.ACCOUNT)
    R.FT<FT.CREDIT.ACCT.NO>=Y.AC.OGM.ID1
    R.FT<FT.CREDIT.AMOUNT>=R.NEW(REDO.AZ.REINV.DEPOSIT.AMOUNT)
    R.FT<FT.CREDIT.CURRENCY>=R.NEW(REDO.AZ.REINV.CURRENCY)
    R.FT<FT.CREDIT.VALUE.DATE>=R.NEW(REDO.AZ.REINV.START.DATE)
    CALL OFS.BUILD.RECORD('FUNDS.TRANSFER','I','','FUNDS.TRANSFER,REINV','',0,'',R.FT,OFS.FT)

*---------------------------PACS00033293------------------

    OFS.MSG2=OFS.AZ.MSG1:OFS.BODY:OFS.MULTI:OFS.MG.MULTI
    OFS.SRC.ID2 = 'REINV.DEPOSIT'
    MSG.ID2 = ''
    ERR.OFS2 = ''
    OFS.MAIN.MSG=OFS.MSG:@FM:OFS.MSG1:@FM:OFS.MSG2:@FM:OFS.FT
    CALL OFS.POST.MESSAGE(OFS.MAIN.MSG,MSG.ID2,OFS.SRC.ID2,ERR.OFS2)


RETURN

*----------------------------------------------------------------------------------------
REDO.V.INP.TFS.PROCESS:
*----------------------------------------------------------------------------------------

    R.REDO.TFS.PROCESS=''

    R.REDO.TFS.PROCESS<TFS.PRO.PRIMARY.ACCT>=Y.AC.OGM.ID1
    R.REDO.TFS.PROCESS<TFS.PRO.ACCOUNT.NAME>=R.NEW(REDO.AZ.REINV.ACCOUNT.NAME)

    Y.AZ.METHOS.PAY=R.NEW(REDO.AZ.REINV.AZ.METHOD.PAY)
    Y.TFS.COUNT=DCOUNT(Y.AZ.METHOS.PAY,@VM)
    VAR1=1
    LOOP
    WHILE VAR1 LE Y.TFS.COUNT
        R.REDO.TFS.PROCESS<TFS.PRO.CURRENCY,VAR1>=R.NEW(REDO.AZ.REINV.CURRENCY)
        R.REDO.TFS.PROCESS<TFS.PRO.TRANSACTION,VAR1>=R.NEW(REDO.AZ.REINV.AZ.METHOD.PAY)<1,VAR1>
        R.REDO.TFS.PROCESS<TFS.PRO.ACCOUNT,VAR1>=R.NEW(REDO.AZ.REINV.AZ.DEBIT.ACC)<1,VAR1>
        R.REDO.TFS.PROCESS<TFS.PRO.AMOUNT,VAR1>=R.NEW(REDO.AZ.REINV.AZ.AMOUNT)<1,VAR1>
        VAR1 += 1
    REPEAT
    GOSUB OFS
RETURN

*------------------------------------------------------------------------------------------
OFS:
*------------------------------------------------------------------------------------------

    OFS.TFS.SOURCE.ID = 'REDO.OFS.AZ.UPDATE'
    APPLICATION.NAME = 'REDO.TFS.PROCESS'
    TRANS.FUNC.VAL = 'I'
    TRANS.OPER.VAL = 'PROCESS'
    APPLICATION.NAME.VERSION = 'REDO.TFS.PROCESS,OFS.PROCESS'
    NO.AUT = '0'
    OFS.MSG.ID = ''
    APPLICATION.ID= ''
    CALL OFS.BUILD.RECORD(APPLICATION.NAME,TRANS.FUNC.VAL,TRANS.OPER.VAL,APPLICATION.NAME.VERSION,"",NO.AUT,APPLICATION.ID,R.REDO.TFS.PROCESS,OFS.REQ.MSG)
    GOSUB AZACC.PROCESS
    CALL OFS.POST.MESSAGE(OFS.REQ.MSG,OFS.MSG.ID,OFS.TFS.SOURCE.ID,OFS.ERR)
RETURN
END
