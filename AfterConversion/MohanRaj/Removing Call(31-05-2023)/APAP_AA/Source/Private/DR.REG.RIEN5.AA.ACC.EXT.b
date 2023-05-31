* @ValidationCode : MjotMzA1Nzc3MjkyOkNwMTI1MjoxNjgzNjk4NDE5MDgyOklUU1M6LTE6LTE6NzI1OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:19
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 725
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE DR.REG.RIEN5.AA.ACC.EXT(REC.ID)
*----------------------------------------------------------------------------
* Company Name   : APAP
* Developed By   : gangadhar@temenos.com
* Program Name   : DR.REG.RIEN4.AZ.EXT
* Date           : 27-May-2013
*----------------------------------------------------------------------------
* Description:
*------------
* This multi-thread job is meant for to extact the AZ.ACCOUNT/ACCOUNT Details Product wise.
*----------------------------------------------------------------------------
*
* Modification History :

*

* ----------------------
*   Date       Author              Modification Description
* 05/10/2014  Ashokkumar.V.P        PACS00309203 - Added credit lines loan
* 26/02/2015  Ashokkumar.V.P        PACS00309203 - Just for compilation
* 18/03/2015  Ashokkumar.V.P        PACS00309203 - Removed the NAB child account. Added check for multi-principal
*                                   in single bill.
* 27/03/2015  Ashokkumar.V.P        PACS00309203 - Performance change
* 16/04/2015  Ashokkumar.V.P        PACS00309203 - Performance change
*
* Date                    Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar             R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023        Conversion Tool                          R22 Auto Code Conversion        I to I.VAR,FM to @FM,J to J.VAR

*----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------


*-----------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_BATCH.FILES
    $INSERT I_TSA.COMMON
*
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.EB.CONTRACT.BALANCES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.OVERDUE
*   $INSERT I_F.ACCOUNT
*
    $INSERT I_DR.REG.RIEN5.AA.ACC.EXT.COMMON
    $INSERT I_F.DR.REG.RIEN5.REP1
    $INSERT I_F.DR.REG.RIEN5.REP2
    $INSERT I_F.DR.REG.RIEN5.REP3
*
    IF CONTROL.LIST<1,1> EQ 'REP1' THEN
        GOSUB PROCESS
    END
RETURN
*----------------------------------------------------------------------------
PROCESS:
*------*
    R.AA.ARRANGEMENT = ''; AA.ARRANGEMENT.ERR = ''; TOT.AMT.INDET = ''; YACC.NABBAL = ''
    CALL F.READ(FN.AA.ARRANGEMENT,REC.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARRANGEMENT.ERR)
    IF R.AA.ARRANGEMENT THEN
        YAA.PROD = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>
        YAA.PROD.GRP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
        YACCOUNT.ID = R.AA.ARRANGEMENT<AA.ARR.LINKED.APPL.ID>
        YSTART.DTE = R.AA.ARRANGEMENT<AA.ARR.START.DATE>
        YARR.STATUS = R.AA.ARRANGEMENT<AA.ARR.ARR.STATUS>
        GOSUB GET.LOAN.STATUS
        IF YSTART.DTE GT LAST.WORK.DAY THEN
            RETURN
        END
        IF YARR.STATUS NE 'CURRENT' AND YARR.STATUS NE 'EXPIRED' THEN
            RETURN
        END
        IF LOAN.STATUS NE 'Write-off' THEN
            GOSUB GET.CASE.CAT
        END
    END
RETURN
*----------------------------------------------------------------------------
GET.CASE.CAT:
*************
*
    BEGIN CASE
        CASE YAA.PROD.GRP EQ 'CONSUMO'
            GOSUB PROCESS.GRP1
        CASE YAA.PROD.GRP EQ 'COMERCIAL'
            GOSUB PROCESS.GRP2
        CASE YAA.PROD.GRP EQ 'HIPOTECARIO'
            GOSUB PROCESS.GRP3
        CASE YAA.PROD.GRP EQ 'LINEAS.DE.CREDITO'
            PFM = '';PVM = ''; PSM = ''
            FINDSTR 'COM' IN YAA.PROD SETTING PFM,PVM,PSM THEN
                GOSUB PROCESS.GRP2
            END
            PFM = '';PVM = ''; PSM = ''
            FINDSTR 'CONS' IN YAA.PROD SETTING PFM,PVM,PSM THEN
                GOSUB PROCESS.GRP1
            END
    END CASE
RETURN

GET.LOAN.STATUS:
*--------------*
    ArrangementID = REC.ID
    effectiveDate = ''
    idPropertyClass = 'OVERDUE'
    idProperty = ''
    returnIds = ''
    returnConditions = ''
    returnError = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
    R.AA.OVERDUE = RAISE(returnConditions)
    LOAN.STATUS = R.AA.OVERDUE<AA.OD.LOCAL.REF,L.LOAN.STATUS.POS>
RETURN

SUB.PROCESS.GRP1:
*****************
*
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RATE> = INT.RATE
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.0.15> = RANGE1.AMT + TOTAL.DUE.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.16.30> = RANGE2.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.31.60> = RANGE3.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.61.90> = RANGE4.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.91.180> = RANGE5.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.181.360> = RANGE6.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.361.720> = RANGE7.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.721.1080> = RANGE8.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.1081.1440> = RANGE9.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.1441.1800> = RANGE10.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.RANGE.1881> = RANGE11.AMT
    R.DR.REG.RIEN5.REP1<DR.RIEN5.REP1.INDETERMINATE> = RANGE.AMT.INDET  ;* PACS00309203 - Indeterminado field
*
RETURN
*----------------------------------------------------------------------------
PROCESS.GRP1:
*----------*
*
    R.DR.REG.RIEN5.REP1 = ''
    GOSUB GET.INT.RATE
    GOSUB GET.SCHEDULES
    GOSUB ABS.AMT
    GOSUB SUB.PROCESS.GRP1
    CALL F.WRITE(FN.DR.REG.RIEN5.REP1,YACCOUNT.ID,R.DR.REG.RIEN5.REP1)
RETURN

ABS.AMT:
*------*
*
    RANGE1.AMT = ABS(RANGE1.AMT)
    RANGE2.AMT = ABS(RANGE2.AMT)
    RANGE3.AMT = ABS(RANGE3.AMT)
    RANGE4.AMT = ABS(RANGE4.AMT)
    RANGE5.AMT = ABS(RANGE5.AMT)
    RANGE6.AMT = ABS(RANGE6.AMT)
    RANGE7.AMT = ABS(RANGE7.AMT)
    RANGE8.AMT = ABS(RANGE8.AMT)
    RANGE9.AMT = ABS(RANGE9.AMT)
    RANGE10.AMT = ABS(RANGE10.AMT)
    RANGE11.AMT = ABS(RANGE11.AMT)
    RANGE.AMT.INDET = ABS(TOT.AMT.INDET)  ;* PACS00309203 - Indeterminado field
*
RETURN
*----------------------------------------------------------------------------
GET.INT.RATE:
*---------*
*
    GOSUB INT.RATE.INIT
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ArrangementID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
    INT.REC = RAISE(returnConditions)
    INT.RATE = INT.REC<AA.INT.EFFECTIVE.RATE>
*
RETURN
*----------------------------------------------------------------------------
INT.RATE.INIT:
**************
*
    ArrangementID = REC.ID
    idPropertyClass = 'INTEREST'
    idProperty = ''
    effectiveDate = ''
    returnIds = ''
    returnConditions = ''
    returnError = ''
*
RETURN
*----------------------------------------------------------------------------
GET.SCHEDULES1:
***************
    I.VAR = 1 ;*R22 Auto Code Conversion
    LOOP
    WHILE I.VAR LE TOT.BALANCES ;*R22 Auto Code Conversion
        BALANCE.TO.CHECK=BALANCES.TO.CHECK<I.VAR>
        REQUEST.TYPE<4>='ECB'
        REQUEST.TYPE<4,2>='END'
        CALL AA.GET.PERIOD.BALANCES(YACCOUNT.ID, BALANCE.TO.CHECK,REQUEST.TYPE, START.DATE, END.DATE, '',BAL.DETAILS, ERROR.MESSAGE)
        BAL.DATES=BAL.DETAILS<1>
        DAT.BALANCES=BAL.DETAILS<4>
        TOTAL.DUE.AMT+=DAT.BALANCES
        I.VAR += 1 ;*R22 Auto Code Conversion
    REPEAT
RETURN

GET.SCHEDULES:
**************
* PACS00309203 - Indeterminado field
*
    GOSUB SCHEDULES.INIT
    ARRANGEMENT.ID = REC.ID
    idPropertyClass = 'TERM.AMOUNT'
*
    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARRANGEMENT.ID, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)
    R.AA.TERM.AMOUNT = RAISE(returnConditions)
    MAT.DATE = R.AA.TERM.AMOUNT<AA.AMT.MATURITY.DATE>
* PACS00309203 - Indeterminado field
    R.REDO.AA.SCHEDULE = ''; REDO.AA.SCHEDULE.ERR = ''; DUE.DATES = ''; DUE.TYPES = ''; DUE.TYPE.AMTS = ''
    DUE.PROPS = ''; DUE.PROP.AMTS = ''
    CALL F.READ(FN.REDO.AA.SCHEDULE,ARRANGEMENT.ID,R.REDO.AA.SCHEDULE,F.REDO.AA.SCHEDULE,REDO.AA.SCHEDULE.ERR)
    IF R.REDO.AA.SCHEDULE THEN
        DUE.DATES = RAISE(R.REDO.AA.SCHEDULE<2>)
        DUE.TYPES = RAISE(R.REDO.AA.SCHEDULE<3>)
        DUE.TYPE.AMTS = RAISE(R.REDO.AA.SCHEDULE<5>)
        DUE.PROPS = RAISE(R.REDO.AA.SCHEDULE<6>)
        DUE.PROP.AMTS = RAISE(R.REDO.AA.SCHEDULE<7>)
    END
*    CALL AA.SCHEDULE.PROJECTOR(ARRANGEMENT.ID, SIMULATION.REF, NO.RESET, DATE.RANGE, TOT.PAYMENT, DUE.DATES, DUE.DEFER.DATES, DUE.TYPES, DUE.METHODS,DUE.TYPE.AMTS, DUE.PROPS, DUE.PROP.AMTS, DUE.OUTS)
*
    IF MAT.DATE NE '' THEN      ;* PACS00309203
        BALANCES.TO.CHECK='DE1ACCOUNT':@FM:'DE2ACCOUNT':@FM:'DE3ACCOUNT':@FM:'DELACCOUNT':@FM:'NABACCOUNT':@FM:'DUEACCOUNT'
        TOT.BALANCES = DCOUNT(BALANCES.TO.CHECK,@FM) ;*R22 Auto Code Conversion
        GOSUB GET.SCHEDULES1
    END ELSE          ;* PACS00309203 - Option to get also CURACCOUNT balance for Indeterminado field
        BALANCES.TO.CHECK='DE1ACCOUNT':@FM:'DE2ACCOUNT':@FM:'DE3ACCOUNT':@FM:'DELACCOUNT':@FM:'NABACCOUNT':@FM:'CURACCOUNT':@FM:'DUEACCOUNT' ;*R22 Auto Code Conversio
        TOT.BALANCES = DCOUNT(BALANCES.TO.CHECK,@FM);*R22 Auto Code Conversio
        GOSUB GET.SCHEDULES2
    END
    TOTAL.DUE.AMT = ABS(TOTAL.DUE.AMT)
    GOSUB GET.RANGE.WISE.SUM
RETURN

GET.SCHEDULES2:
***************
*
    I.VAR = 1 ;*R22 Auto Code Conversion
    LOOP
    WHILE I.VAR LE TOT.BALANCES ;*R22 Auto Code Conversion
        BALANCE.TO.CHECK=BALANCES.TO.CHECK<I.VAR>
        REQUEST.TYPE<4>='ECB'
        REQUEST.TYPE<4,2>='END'
        CALL AA.GET.PERIOD.BALANCES(YACCOUNT.ID, BALANCE.TO.CHECK,REQUEST.TYPE, START.DATE, END.DATE, '',BAL.DETAILS, ERROR.MESSAGE)
        IF BALANCE.TO.CHECK NE 'CURACCOUNT' THEN
            BAL.DATES=BAL.DETAILS<1>
            DAT.BALANCES=BAL.DETAILS<4>
            TOTAL.DUE.AMT+=DAT.BALANCES
        END ELSE
            TOT.AMT.INDET += BAL.DETAILS<4>
        END
        I.VAR += 1 ;*R22 Auto Code Conversion
    REPEAT
RETURN
*----------------------------------------------------------------------------
SCHEDULES.INIT:
***************
*
    START.DATE = LAST.WORK.DAY
    END.DATE=LAST.WORK.DAY
    TOTAL.DUE.AMT=''
    NO.RESET=''
    REQUEST.TYPE = ''
    GOSUB SCH.INIT1
    GOSUB SCH.INIT
RETURN

SCH.INIT1:
**********
*
    effectiveDate = ''
    idPropertyClass = ''
    idProperty = ''
    returnIds = ''
    returnConditions = ''
    returnError = ''
*
RETURN
*----------------------------------------------------------------------------
SCH.INIT:
*********
*
    SIMULATION.REF = ''
    NO.RESET<2> = 1
    DATE.RANGE = ''
    TOT.PAYMENT = ''
    DUE.DATES = ''
    DUE.TYPES = ''
    DUE.METHODS = ''
    DUE.TYPE.AMTS = ''
    DUE.PROPS = ''
    DUE.PROP.AMTS = ''
    DUE.OUTS = ''
    BALANCES.TO.CHECK = ''
    TOT.BALANCES = ''
*
RETURN
*----------------------------------------------------------------------------
GET.RANGE.WISE.SUM1:

    CALL CDT(Y.REGION,RANGE1,'+15C')
    CALL CDT(Y.REGION,RANGE2,'+30C')
    CALL CDT(Y.REGION,RANGE3,'+60C')
    CALL CDT(Y.REGION,RANGE4,'+90C')
    CALL CDT(Y.REGION,RANGE5,'+180C')
    CALL CDT(Y.REGION,RANGE6,'+360C')
    CALL CDT(Y.REGION,RANGE7,'+720C')
    CALL CDT(Y.REGION,RANGE8,'+1080C')
    CALL CDT(Y.REGION,RANGE9,'+1440C')
    CALL CDT(Y.REGION,RANGE10,'+1800C')
RETURN
*----------------------------------------------------------------------------
GET.RANGE.WISE.SUM:
*-----------------*
    PERIOD.START = LAST.WORK.DAY
    SCHEDULE.DATES=DUE.DATES
    GOSUB WISE.SUM.INIT
    GOSUB GET.RANGE.WISE.SUM1
*
    TOT.DUE.DATE=DCOUNT(DUE.DATES,@FM) ;*R22 Auto Code Conversion
    J.VAR = 1 ;*R22 Auto Code Conversion
    LOOP
    WHILE J.VAR LE TOT.DUE.DATE ;*R22 Auto Code Conversion
        PERIOD.START = LAST.WORK.DAY
        PERIOD.END.DATE=DUE.DATES
        SCHEDULE.DATE = DUE.DATES<J.VAR> ;*R22 Auto Code Conversion
        IF SCHEDULE.DATE GE Y.TODAY THEN
            GOSUB GET.RANGE.WISE.SUM2
        END
        J.VAR += 1 ;*R22 Auto Code Conversion
    REPEAT
RETURN
*----------------------------------------------------------------------------
GET.RANGE.WISE.SUM2:
********************
    YRANGE.AMT = ''; YACCT.RANGE.AMT = 0; YSC.RANGE.AMT = 0; YCAP.RANGE.AMT = 0
    FMPOS = ''; VMPOS = ''; SMPOS = ''; FMS.POS = ''; VMS.POS = ''; SMS.POS = ''
    FMSPOS = ''; VMSPOS = ''; SMSPOS = ''
    FINDSTR 'ACCOUNT' IN DUE.PROPS<J.VAR> SETTING FMPOS,VMPOS,SMPOS THEN
        YACCT.RANGE.AMT = DUE.PROP.AMTS<J.VAR,VMPOS,SMPOS> ;*R22 Auto Code Conversion
    END

    FINDSTR 'SOLO.CAPITAL' IN DUE.TYPES<J.VAR> SETTING FMS.POS,VMS.POS,SMS.POS THEN
        YSC.RANGE.AMT = DUE.PROP.AMTS<J.VAR,VMS.POS,SMS.POS> ;*R22 Auto Code Conversion
    END

    FINDSTR 'CAPPROG' IN DUE.TYPES<J.VAR> SETTING FMSPOS,VMSPOS,SMSPOS THEN
        YCAP.RANGE.AMT = DUE.PROP.AMTS<J.VAR,VMSPOS,SMSPOS>
    END

    IF YSC.RANGE.AMT OR YCAP.RANGE.AMT THEN
        YRANGE.AMT = YSC.RANGE.AMT + YCAP.RANGE.AMT + YRANGE.AMT
    END ELSE
        YRANGE.AMT = YACCT.RANGE.AMT
    END

    BEGIN CASE
        CASE SCHEDULE.DATE LE RANGE1
            RANGE1.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE1 AND SCHEDULE.DATE LE RANGE2
            RANGE2.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE2 AND SCHEDULE.DATE LE RANGE3
            RANGE3.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE3 AND SCHEDULE.DATE LE RANGE4
            RANGE4.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE4 AND SCHEDULE.DATE LE RANGE5
            RANGE5.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE5 AND SCHEDULE.DATE LE RANGE6
            RANGE6.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE6 AND SCHEDULE.DATE LE RANGE7
            RANGE7.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE7 AND SCHEDULE.DATE LE RANGE8
            RANGE8.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE8 AND SCHEDULE.DATE LE RANGE9
            RANGE9.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE9 AND SCHEDULE.DATE LE RANGE10
            RANGE10.AMT+=YRANGE.AMT
        CASE SCHEDULE.DATE GT RANGE10
            RANGE11.AMT+=YRANGE.AMT
    END CASE
RETURN
*----------------------------------------------------------------------------
WISE.SUM.INIT:
**************
*
    RANGE1=LAST.WORK.DAY
    RANGE2=LAST.WORK.DAY
    RANGE3=LAST.WORK.DAY
    RANGE4=LAST.WORK.DAY
    RANGE5=LAST.WORK.DAY
    RANGE6=LAST.WORK.DAY
    RANGE7=LAST.WORK.DAY
    RANGE8=LAST.WORK.DAY
    RANGE9 =LAST.WORK.DAY
    RANGE10 = LAST.WORK.DAY
****
    RANGE1.AMT= 0
    RANGE2.AMT= 0
    RANGE3.AMT= 0
    RANGE4.AMT= 0
    RANGE5.AMT= 0
    RANGE6.AMT= 0
    RANGE7.AMT= 0
    RANGE8.AMT= 0
    RANGE9.AMT= 0
    RANGE10.AMT= 0
    RANGE11.AMT= 0
****
    Y.REGION = ''
*
RETURN
*----------------------------------------------------------------------------
PROCESS.GRP2:
*----------*
*
    R.DR.REG.RIEN5.REP2 = ''
    GOSUB GET.INT.RATE
    GOSUB GET.SCHEDULES
    GOSUB ABS.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RATE> = INT.RATE
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.0.15> = RANGE1.AMT + TOTAL.DUE.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.16.30> = RANGE2.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.31.60> = RANGE3.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.61.90> = RANGE4.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.91.180> = RANGE5.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.181.360> = RANGE6.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.361.720> = RANGE7.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.721.1080> = RANGE8.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.1081.1440> = RANGE9.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.1441.1800> = RANGE10.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.RANGE.1881> = RANGE11.AMT
    R.DR.REG.RIEN5.REP2<DR.RIEN5.REP2.INDETERMINATE> = RANGE.AMT.INDET  ;* PACS00309203 - Indeterminado field
    CALL F.WRITE(FN.DR.REG.RIEN5.REP2,YACCOUNT.ID,R.DR.REG.RIEN5.REP2)
RETURN
*----------------------------------------------------------------------------
PROCESS.GRP3:
*-----------*
*
    R.DR.REG.RIEN5.REP3 = ''
    GOSUB GET.INT.RATE
    GOSUB GET.SCHEDULES
    GOSUB ABS.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RATE> = INT.RATE
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.0.15> = RANGE1.AMT + TOTAL.DUE.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.16.30> = RANGE2.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.31.60> = RANGE3.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.61.90> = RANGE4.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.91.180> = RANGE5.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.181.360> = RANGE6.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.361.720> = RANGE7.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.721.1080> = RANGE8.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.1081.1440> = RANGE9.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.1441.1800> = RANGE10.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.RANGE.1881> = RANGE11.AMT
    R.DR.REG.RIEN5.REP3<DR.RIEN5.REP3.INDETERMINATE> = RANGE.AMT.INDET  ;* PACS00309203 - Indeterminado field
    CALL F.WRITE(FN.DR.REG.RIEN5.REP3,YACCOUNT.ID,R.DR.REG.RIEN5.REP3)
RETURN
*----------------------------------------------------------------------------
END
