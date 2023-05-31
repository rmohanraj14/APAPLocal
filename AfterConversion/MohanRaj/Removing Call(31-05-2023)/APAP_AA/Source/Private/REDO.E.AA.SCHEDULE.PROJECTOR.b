* @ValidationCode : MjotMTQwMjEzMzQxNTpDcDEyNTI6MTY4NTUyOTk0NDIyOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:15:44
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
SUBROUTINE REDO.E.AA.SCHEDULE.PROJECTOR(SCHED.ARR)
*-----------------------------------------------------------------------------
* Description: This routine is to modify the output of Schedule projector enquiry in AA overview screen

*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : SCHED.ARR
* Deals With     : ENQUIRY -> REDO.AA.DETAILS.SCHEDULE
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 01-NOV-2011     H GANESH     ODR-2011-08-0106 CR-PENALTY CHARGE            Initial Draft
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              VM TO @VM ,FM TO @FM , SM TO @SM and I++ to I=+1
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            PACKAGE ADDED
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.PROPERTY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
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

    FN.AA.PROPERTY = 'F.AA.PROPERTY'
    F.AA.PROPERTY  = ''
    CALL OPF(FN.AA.PROPERTY,F.AA.PROPERTY)

RETURN
*--------------------------------------------------
PROCESS:
*--------------------------------------------------
* Here we call the schedule projector routine to build the array

    APAP.AA.redoEAaScheduleProjector(SCHED.ARR);*R22 Manual conversion

    LOCATE 'ARRANGEMENT.ID' IN ENQ.SELECTION<2,1> SETTING ARRPOS THEN
        ARR.ID = ENQ.SELECTION<4,ARRPOS>    ;* Pick the Arrangement Id
    END ELSE
        RETURN
    END

    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    IF R.REDO.APAP.PROPERTY.PARAM THEN
        Y.PENAL.PROPERTY        = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>
    END

    CHANGE '^' TO @VM IN SCHED.ARR
    GOSUB GET.BILLS
    CHANGE @VM TO '^' IN SCHED.ARR

RETURN
*--------------------------------------------------
GET.BILLS:
*--------------------------------------------------
* Here we will add the penalty charge amount to the bill

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,ARR.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,ACC.DET.ERR)
    Y.BILL.IDS      = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.SETTLE.STATUS = R.AA.ACCOUNT.DETAILS<AA.AD.SET.STATUS>
    Y.BILL.TYPES    = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>

*CHANGE SM TO FM IN Y.BILL.IDS
*CHANGE VM TO FM IN Y.BILL.IDS

    Y.VAR1=1
    Y.BILL.CNT = DCOUNT(Y.BILL.IDS,@VM)
    LOOP
    WHILE Y.VAR1 LE Y.BILL.CNT
        Y.INTEREST  = 0
        Y.PRINCIPAL = 0
        Y.CHARGE    = 0
        Y.PAYMENT.DATE = ''
        Y.NEW.BILL.IDS = DCOUNT(Y.BILL.IDS<1,Y.VAR1>,@SM)

        Y.VAR.NEW = 1
        LOOP
        WHILE Y.VAR.NEW LE Y.NEW.BILL.IDS

            Y.BILL.ID   = Y.BILL.IDS<1,Y.VAR1,Y.VAR.NEW>
            Y.BILL.TYPE = Y.BILL.TYPES<1,Y.VAR1,Y.VAR.NEW>
            IF Y.BILL.TYPE EQ 'PAYOFF' THEN   ;* We need not to show payoff bill in schedule.
                Y.VAR.NEW += 1 ;* R22 Auto Conversion
                CONTINUE
            END
            RET.ERROR = ''
            R.BILL.DETAILS = ''
            CALL AA.GET.BILL.DETAILS(ARR.ID, Y.BILL.ID, R.BILL.DETAILS, RET.ERROR)

            Y.PAYMENT.DATE = R.BILL.DETAILS<AA.BD.PAYMENT.DATE>   ;* Payment Date of the Bill
            GOSUB GET.RESPECTIVES.AMOUNT
            Y.VAR.NEW += 1 ;* R22 Auto Conversion
        REPEAT
        GOSUB UPDATE.OTHER.ARRAY
        LOCATE Y.PENAL.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING POS THEN
            APAP.TAM.redoGetAdjustedAmount(Y.PENAL.PROPERTY,Y.BILL.ID,Y.PENAL.AMT);* R22 Manual conversion
            IF Y.PENAL.AMT GT 0 THEN
                GOSUB UPDATE.ARRAY
            END
        END
        Y.VAR1 += 1 ;* R22 Auto Conversion
    REPEAT

RETURN
*-------------------------------------
GET.RESPECTIVES.AMOUNT:
*-------------------------------------

    Y.PROPERTIES  =  R.BILL.DETAILS<AA.BD.PROPERTY>
    Y.PROP.CNT    =  DCOUNT(Y.PROPERTIES,@VM)
    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.PROP.CNT
        Y.PROPERTY = Y.PROPERTIES<1,Y.VAR2>
        GOSUB GET.PROPERTY.CLASS
        IF Y.PROPERTY.CLASS EQ 'ACCOUNT' THEN
            GOSUB GET.AMOUNT
            Y.PRINCIPAL+= Y.FINAL.AMOUNT
        END
        IF Y.PROPERTY.CLASS EQ 'INTEREST' THEN
            GOSUB GET.AMOUNT
            Y.INTEREST+= Y.FINAL.AMOUNT
        END
        IF Y.PROPERTY.CLASS EQ 'CHARGE' THEN
            IF Y.PENAL.PROPERTY NE Y.PROPERTY THEN
                GOSUB GET.AMOUNT
                Y.CHARGE+= Y.FINAL.AMOUNT
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
    CALL CACHE.READ(FN.AA.PROPERTY, Y.PROPERTY, R.PROP, PROP.ERR) ;* R22 Auto Conversion - F.READ to CACHE.READ
    Y.PROPERTY.CLASS = R.PROP<AA.PROP.PROPERTY.CLASS>

RETURN
*-------------------------------------
UPDATE.ARRAY:
*-------------------------------------

    FINDSTR Y.PAYMENT.DATE IN SCHED.ARR SETTING POS.AF,POS.AV THEN
        SCHED.ARR<POS.AF,6> = SCHED.ARR<POS.AF,6>+Y.PENAL.AMT
        SCHED.ARR<POS.AF,2> = SCHED.ARR<POS.AF,2>+Y.PENAL.AMT

    END
RETURN
*-------------------------------------
UPDATE.OTHER.ARRAY:
*-------------------------------------
    FINDSTR Y.PAYMENT.DATE IN SCHED.ARR SETTING POS.AF,POS.AV THEN
        SCHED.ARR<POS.AF,4> = Y.PRINCIPAL
        SCHED.ARR<POS.AF,5> = Y.INTEREST
        SCHED.ARR<POS.AF,6> = Y.CHARGE
        SCHED.ARR<POS.AF,2> = Y.PRINCIPAL + Y.INTEREST + Y.CHARGE
    END
RETURN
END
