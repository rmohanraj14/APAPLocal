* @ValidationCode : MjozNDA1MTc1MDA6Q3AxMjUyOjE2ODE3MzM2ODc1NzY6SVRTUzotMTotMTo0NzE6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 17 Apr 2023 17:44:47
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 471
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.CANALAFILF360(R.DATA)
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This is an Nofile routine to get some data for enquiry REDO.CH.CANALAFILF360
* related to C.24 Channel Administration.
*
* Input/Output:
*--------------
* IN : CUSTOMER.ID
* OUT : R.DATA (ALL DATA)
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who                   Reference               Description
* 15-JUN-2011    RMONDRAGON            ODR-2010-06-0155           FIRST VERSION
* 06-OCT-2011    RMONDRAGON            ODR-2010-06-0155        UPDATE TO GET THE
*                                                              PROFILE AND PERM.
*                                                              FOR CHANNEL USER.
* 25-JAN-2012    RMONDRAGON            ODR-2010-06-0155        UPDATE TO GET THE
*                                                              PROFILE AND PRODUCT.
* 04-JUN-2013    RMONDRAGON            ODR-2010-06-0155        UPDATE
*
* 12-APR-2023     Conversion tool    R22 Auto conversion       F.READ to CACHE.READ
* 12-APR-2023     Conversion tool    R22 Auto conversion       No changes
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.AA.ARRANGEMENT

    $INSERT I_F.REDO.CH.PROFILE
* </region>
*-----------------------------------------------------------------------------

    GOSUB INIT
    GOSUB OPENFILES
    GOSUB PROCESS

RETURN

*****
INIT:
*****

    Y.DATE = ''
    Y.SEL.EXTU = ''
    Y.SEL.EXTU.LIST = ''
    Y.SEL.EXTU.LIST.NO = ''
    EXTU.ERR = ''
    CNT.REC = 1
    Y.REC.ID = ''
    Y.EXTU.REC = ''
    Y.CHANNEL = ''
    Y.AFFILIATED = ''
    Y.STATUS = ''
    Y.START.DATE = ''
    CONFIG.ID = ''
    R.CON = ''
    CONFIG.ERR = ''
    Y.PROFILE1 = ''
    Y.PROFILE2 = ''
    Y.PROF = ''
    Y.REC.ID.AA.ARR = ''
    Y.REC.AA.ARR = ''
    AA.ARR.ERR = ''
    Y.PROD = ''
    Y.ROLL.TYPE = ''
    Y.ACCESS.TYPE = ''

RETURN

*********
OPENFILES:
*********

    FN.EB.EXTERNAL.USER = 'F.EB.EXTERNAL.USER'
    F.EB.EXTERNAL.USER = ''
    CALL OPF(FN.EB.EXTERNAL.USER,F.EB.EXTERNAL.USER)

    FN.REDO.CH.PROFILE = 'F.REDO.CH.PROFILE'
    F.REDO.CH.PROFILE = ''
    CALL OPF(FN.REDO.CH.PROFILE,F.REDO.CH.PROFILE)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    IF LNGG EQ 1 THEN
        Y.AFFILIATED = 'YES'
        Y.PROFILE1 = 'CONSULTS'
        Y.PROFILE2 = 'TRANSACTIONS'
        Y.CUST1 = 'INDIVIDUAL CUSTOMER'
        Y.CUST2 = 'CORPORATE CUSTOMER (Inputter)'
        Y.CUST3 = 'CORPORATE CUSTOMER (Authoriser)'
        Y.CUST4 = 'CORPORATE CUSTOMER (Administrator)'
    END ELSE
        Y.AFFILIATED = 'SI'
        Y.PROFILE1 = 'CONSULTAS'
        Y.PROFILE2 = 'TRANSACCIONES'
        Y.CUST1 = 'PERSONA FISICA'
        Y.CUST2 = 'PERSONA JURIDICA (Ingresador)'
        Y.CUST3 = 'PERSONA JURIDICA (Autorizador)'
        Y.CUST4 = 'PERSONA JURIDICA (Administrador)'
    END

RETURN

********
PROCESS:
********

    LOCATE 'CUSTOMER.ID' IN D.FIELDS<1> SETTING CUSTOMER.ID.POS THEN
        Y.CUSTOMER.ID = D.RANGE.AND.VALUE<CUSTOMER.ID.POS>
    END

    Y.SEL.EXTU = 'SELECT ':FN.EB.EXTERNAL.USER:' WITH CUSTOMER EQ ':Y.CUSTOMER.ID
    CALL EB.READLIST(Y.SEL.EXTU,Y.SEL.EXTU.LIST,'',Y.SEL.EXTU.LIST.NO,EXTU.ERR)

    LOOP
    WHILE CNT.REC LE Y.SEL.EXTU.LIST.NO DO
        Y.REC.ID = Y.SEL.EXTU.LIST<CNT.REC>
        CALL CACHE.READ(FN.EB.EXTERNAL.USER, Y.REC.ID, Y.EXTU.REC, EXTU.ERR) ;*R22 Auto conversion
        Y.CHANNEL = Y.EXTU.REC<EB.XU.CHANNEL>
        Y.ARR = Y.EXTU.REC<EB.XU.ARRANGEMENT>
        IF Y.CHANNEL EQ 'INTERNET' THEN
            Y.CHANNEL = 'APAPENLINEA'
        END ELSE
            Y.CHANNEL = 'TELEAPAP'
        END
        Y.STATUS = Y.EXTU.REC<EB.XU.STATUS>
        Y.START.DATE = Y.EXTU.REC<EB.XU.START.DATE>
        Y.START.DATE = Y.START.DATE[5,2]:'-':Y.START.DATE[7,2]:'-':Y.START.DATE[1,4]
        Y.START.DATE = ICONV(Y.START.DATE,'D')
        Y.START.DATE = OCONV(Y.START.DATE,'D4')
        GOSUB GET.PROFILE.AND.PERM
        R.DATA<-1> := Y.CHANNEL:'*':Y.AFFILIATED:'*':Y.STATUS:'*':Y.REC.ID:'*':Y.START.DATE:'*':Y.ROLL.TYPE:'*':Y.ACCESS.TYPE
        CNT.REC +=1
    REPEAT

RETURN

*********************
GET.PROFILE.AND.PERM:
*********************

    Y.PROF = ''
    R.REDO.CH.PROFILE = ''; PROF.ERR = ''
    CALL F.READ(FN.REDO.CH.PROFILE,Y.REC.ID,R.REDO.CH.PROFILE,F.REDO.CH.PROFILE,PROF.ERR)
    IF R.REDO.CH.PROFILE THEN
        Y.PROF = R.REDO.CH.PROFILE<REDO.CH.PROF.PROFILE>
    END

    IF Y.PROF EQ 'Teleapap.Consultas' OR Y.PROF EQ 'Apapenlinea.Consultas' THEN
        Y.ROLL.TYPE = Y.PROFILE1
    END

    IF Y.PROF EQ 'Teleapap.Txns' OR Y.PROF EQ 'Apapenlinea.Txns' THEN
        Y.ROLL.TYPE = Y.PROFILE2
    END

    CALL F.READ(FN.AA.ARRANGEMENT,Y.ARR,Y.REC.AA.ARR,F.AA.ARRANGEMENT,AA.ARR.ERR)
    IF Y.REC.AA.ARR THEN
        Y.PROD = Y.REC.AA.ARR<AA.ARR.PRODUCT>
    END

    BEGIN CASE
        CASE Y.PROD EQ 'PERSONAL'
            Y.ACCESS.TYPE = Y.CUST1
            RETURN
        CASE Y.PROD EQ 'PERSONAL.TEL'
            Y.ACCESS.TYPE = Y.CUST1
            RETURN
        CASE Y.PROD EQ 'CORPADMIN'
            Y.ACCESS.TYPE = Y.CUST4
            RETURN
        CASE Y.PROD EQ 'CORPAUTH'
            Y.ACCESS.TYPE = Y.CUST3
            RETURN
        CASE Y.PROD EQ 'CORPINPUT'
            Y.ACCESS.TYPE = Y.CUST2
            RETURN
    END CASE

RETURN

END
