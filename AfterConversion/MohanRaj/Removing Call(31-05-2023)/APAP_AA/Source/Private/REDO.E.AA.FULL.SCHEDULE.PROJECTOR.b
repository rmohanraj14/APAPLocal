* @ValidationCode : Mjo2MTczMDM3MDM6Q3AxMjUyOjE2ODU1Mjk4ODk4NTM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:14:49
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
$PACKAGE APAP.AA
SUBROUTINE  REDO.E.AA.FULL.SCHEDULE.PROJECTOR(SCHED.ARR)
*-----------------------------------------------------------------------------
* Description: This routine is to modify the output of Schedule projector enquiry in AA overview screen

*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : SCHED.ARR
* Deals With     : ENQUIRY -> REDO.AA.DETAILS.SCHEDULE.DETS
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 01-NOV-2011     H GANESH     ODR-2011-08-0106 CR-PENALTY CHARGE            Initial Draft...
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION           VM TO @VM ,FM TO @FM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED, CALL method format changed
*------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PROPERTY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_ENQUIRY.COMMON
    $USING APAP.TAM

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*--------------------------------------------------
OPEN.FILES:
*--------------------------------------------------
    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
*  CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM);*TUS (S/E)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.REDO.H.AA.DIS.CHG = 'F.REDO.H.AA.DIS.CHG'
    F.REDO.H.AA.DIS.CHG  = ''
*  CALL OPF(FN.REDO.H.AA.DIS.CHG,F.REDO.H.AA.DIS.CHG);*TUS (S/E)


RETURN
*--------------------------------------------------
PROCESS:
*--------------------------------------------------
* Here we will call the core routine E.AA.FULL.SCHEDULE.PROJECTOR to form the array
    LOCATE 'ARRANGEMENT.ID' IN ENQ.SELECTION<2,1> SETTING ARRPOS THEN
        ARR.ID = ENQ.SELECTION<4,ARRPOS>          ;* Pick the Arrangement Id
    END

    LOCATE 'DATE.DUE' IN ENQ.SELECTION<2,1> SETTING DTPOS THEN
        DATE.REQD = ENQ.SELECTION<4,DTPOS>        ;* Exact date on whih due Details are requested. This is for Drill down Enquiry
    END
    CALL E.AA.FULL.SCHEDULE.PROJECTOR(SCHED.ARR)
    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    IF R.REDO.APAP.PROPERTY.PARAM THEN
        Y.PENAL.PROPERTY        = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>
    END

    CALL CACHE.READ(FN.REDO.H.AA.DIS.CHG,'SYSTEM',R.REDO.H.AA.DIS.CHG,F.REDO.H.AA.DIS.CHG)
    Y.CHQ.RET.PROP = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.RET.CHQ.CHARGE>

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ACC.DET.ERR)
    Y.BILL.IDS = ''
    LOCATE DATE.REQD IN R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE,1> SETTING BILL.POS THEN
        Y.BILL.IDS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,BILL.POS>
        Y.BILL.TYPE =R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,BILL.POS>
    END
    IF Y.BILL.IDS THEN
        GOSUB FINAL.PROCESS
    END

RETURN
*--------------------------------------------
FINAL.PROCESS:
*--------------------------------------------
* Here we will add the charge amount in the Out array
    Y.TOTAL.AMT = 0
    Y.VAR1=1
    Y.BILLS.CNT = DCOUNT(Y.BILL.IDS,@SM)
    LOOP
    WHILE Y.VAR1 LE Y.BILLS.CNT
        IF Y.BILL.TYPE<1,1,Y.VAR1> EQ 'PAYOFF' THEN         ;* We need not to show payoff bill in schedule.
            Y.VAR1 += 1 ;* R22 Auto Conversion
            CONTINUE
        END
        Y.BILL.ID = Y.BILL.IDS<1,1,Y.VAR1>
        RET.ERROR = ''
        R.BILL.DETAILS = ''
        CALL AA.GET.BILL.DETAILS(ARR.ID, Y.BILL.ID, R.BILL.DETAILS, RET.ERROR)
        GOSUB GET.RESPECTIVES.AMOUNT
        LOCATE Y.PENAL.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS THEN

            APAP.TAM.redoGetAdjustedAmount(Y.PENAL.PROPERTY,Y.BILL.ID,Y.PENAL.AMT);* R22 Manual conversion
            IF Y.PENAL.AMT GT 0 THEN
                Y.CHG.PROPERTY = Y.PENAL.PROPERTY
                Y.CHG.AMT      = Y.PENAL.AMT
                GOSUB UPDATE.ARRAY
            END
        END
        LOCATE Y.CHQ.RET.PROP IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS THEN
            APAP.TAM.redoGetAdjustedAmount(Y.CHQ.RET.PROP,Y.BILL.ID,Y.CHQ.RET.AMT);* R22 Manual conversion
            IF Y.CHQ.RET.AMT GT 0 THEN
                Y.CHG.PROPERTY = Y.CHQ.RET.PROP
                Y.CHG.AMT      = Y.CHQ.RET.AMT
                GOSUB UPDATE.ARRAY
            END
        END
        Y.VAR1 += 1 ;* R22 Auto Conversion
    REPEAT

    Y.PREV.POS = ''

    CHANGE '*' TO @VM IN SCHED.ARR
    Y.TOTAL.AMOUNT = 0
    Y.ARRAY.CNT = DCOUNT(SCHED.ARR,@FM)
    Y.LOOP.CNT = 1
    LOOP
    WHILE Y.LOOP.CNT LE Y.ARRAY.CNT
        Y.TOT.AMT = SCHED.ARR<Y.LOOP.CNT,3>
        IF Y.TOT.AMT THEN
            IF Y.PREV.POS THEN
                SCHED.ARR<Y.PREV.POS,3> = Y.TOTAL.AMOUNT
                Y.PREV.POS = Y.LOOP.CNT
                Y.TOTAL.AMOUNT = SCHED.ARR<Y.LOOP.CNT,5>
            END ELSE
                Y.PREV.POS = 1
                Y.TOTAL.AMOUNT += SCHED.ARR<Y.LOOP.CNT,5>
            END

        END ELSE
            Y.TOTAL.AMOUNT += SCHED.ARR<Y.LOOP.CNT,5>

        END
        Y.LOOP.CNT += 1 ;* R22 Auto Conversion
    REPEAT
    SCHED.ARR<Y.PREV.POS,3> = Y.TOTAL.AMOUNT
    CHANGE @VM TO '*' IN SCHED.ARR
RETURN
*-------------------------------------
GET.RESPECTIVES.AMOUNT:
*-------------------------------------
    Y.PROPERTIES  =  R.BILL.DETAILS<AA.BD.PROPERTY>
    Y.PROP.CNT    =  DCOUNT(Y.PROPERTIES,@VM)
    Y.VAR2 = 1
    Y.BILL.VALUE = "SETTLED" ;*PACS00940657
    LOOP
    WHILE Y.VAR2 LE Y.PROP.CNT
***PACS00940657***
        Y.BILL.STATUS = R.BILL.DETAILS<AA.BD.BILL.STATUS>
        FINDSTR Y.BILL.VALUE IN Y.BILL.STATUS SETTING POS.AF,POS.AV ELSE
            Y.PROPERTY = Y.PROPERTIES<1,Y.VAR2>
            IF Y.PENAL.PROPERTY NE Y.PROPERTY THEN
                GOSUB GET.AMOUNT
                FINDSTR Y.PROPERTY IN SCHED.ARR SETTING POS.AF,POS.AV THEN
                    Y.ARR = SCHED.ARR<POS.AF,POS.AV>
                    CHANGE '*' TO @FM IN Y.ARR
                    Y.ARR<5> = Y.FINAL.AMOUNT
                    CHANGE @FM TO '*' IN Y.ARR
                    SCHED.ARR<POS.AF,POS.AV> = Y.ARR
                END
            END
        END
        Y.VAR2 += 1 ;* R22 Auto Conversion
    REPEAT
RETURN
*-------------------------------------
GET.AMOUNT:
*-------------------------------------
    Y.EXCLUSION.ADJ.STATUS = 'SUSPEND':@VM:'CAPTURE.BILL':@VM:'RESUME'
    Y.FINAL.AMOUNT = 0
    ADJ.AMOUNT     = 0
    Y.ADJUSTED.REF = R.BILL.DETAILS<AA.BD.ADJUST.REF,Y.VAR2>
    Y.ADJUSTED.AMT = R.BILL.DETAILS<AA.BD.ADJUST.AMT,Y.VAR2>
    Y.ADJUSTED.CNT = DCOUNT(Y.ADJUSTED.REF,@SM)
    Y.VAR3 = 1
    LOOP
    WHILE Y.VAR3 LE Y.ADJUSTED.CNT
        Y.ADJUSTED.ID = Y.ADJUSTED.REF<1,1,Y.VAR3>
        Y.SECOND.PART = FIELD(Y.ADJUSTED.ID,'-',2)
        IF Y.SECOND.PART MATCHES Y.EXCLUSION.ADJ.STATUS ELSE
            ADJ.AMOUNT += Y.ADJUSTED.AMT<1,1,Y.VAR3>
        END
        Y.VAR3 += 1 ;* R22 Auto Conversion
    REPEAT
    Y.FINAL.AMOUNT = R.BILL.DETAILS<AA.BD.OR.PROP.AMOUNT,Y.VAR2> + ADJ.AMOUNT
RETURN
*-------------------------------------
GET.PROPERTY.CLASS:
*-------------------------------------
    CALL F.READ(FN.AA.PROPERTY,Y.PROPERTY,R.PROP,F.AA.PROPERTY,PROP.ERR)
    Y.PROPERTY.CLASS = R.PROP<AA.PROP.PROPERTY.CLASS>
RETURN
*-----------------------------------
UPDATE.ARRAY:
*-----------------------------------
    FINDSTR Y.CHG.PROPERTY IN SCHED.ARR SETTING POS.AF,POS.AV THEN
        Y.ARR = SCHED.ARR<POS.AF,POS.AV>
        CHANGE '*' TO @FM IN Y.ARR
        Y.ARR<5> = Y.CHG.AMT
        CHANGE @FM TO '*' IN Y.ARR
        SCHED.ARR<POS.AF,POS.AV> = Y.ARR

    END ELSE
        IF Y.CHG.PROPERTY EQ Y.PENAL.PROPERTY THEN
            SCHED.ARR<-1> = 'MORA':'*':'DUE':'*':Y.CHG.AMT:'*':Y.CHG.PROPERTY:'*':Y.CHG.AMT
        END
        IF Y.CHG.PROPERTY EQ Y.CHQ.RET.PROP THEN
            SCHED.ARR<-1> = 'COMCKDEV':'*':'DUE':'*':Y.CHG.AMT:'*':Y.CHG.PROPERTY:'*':Y.CHG.AMT
        END
    END
RETURN

END
