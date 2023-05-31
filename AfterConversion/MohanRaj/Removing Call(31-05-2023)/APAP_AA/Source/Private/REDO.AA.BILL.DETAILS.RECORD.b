* @ValidationCode : MjoxNjM2NTQ2ODYwOkNwMTI1MjoxNjg1NTI4MDQ4MzU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 15:44:08
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
$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.BILL.DETAILS.RECORD

*-----------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : AA.BILL.DETAILS
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                          DESCRIPTION
* 06-FEB-2011     H GANESH     PACS00178946 CR-PENALTY CHARGE               Initial Draft.
* 29-March-2023       Conversion Tool                     R22 Auto Code Conversion             SM to @SM
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA, CALL method format changed
*------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.REDO.AA.BILL.DETAILS
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM
    V$FUNCTION = 'S'

    GOSUB PROCESS
RETURN
*--------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------

    Y.BILL.CHARGE = 0

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)


    Y.BILL.REF = ID.NEW
    CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.REF,R.BILL,F.AA.BILL.DETAILS,BILL.ERR)

    IF R.BILL ELSE
        RETURN
    END
    MATPARSE R.NEW FROM R.BILL

    ARR.ID = R.NEW(AA.BD.ARRANGEMENT.ID)

    GOSUB CALC.AMOUNT

    VAR.DUE.AMT = R.NEW(AA.BD.OS.PROP.AMOUNT)
    R.NEW(REDO.AA.BD.OS.TOTAL.AMOUNT) = SUM(VAR.DUE.AMT)
RETURN
*--------------------------------------------------------------
CALC.AMOUNT:
*--------------------------------------------------------------

    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PARAM.ERR)
    Y.PENALTY.PROPERTY = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>

    CALL F.READ(FN.AA.ACTIVITY.HISTORY,ARR.ID,R.AA.HISTORY,F.AA.ACTIVITY.HISTORY,HIST.ERR)

    LOCATE Y.PENALTY.PROPERTY IN R.NEW(REDO.AA.BD.PROPERTY)<1,1> SETTING PROP.POS THEN
        APAP.TAM.redoGetAdjustedAmount(Y.PENALTY.PROPERTY,Y.BILL.REF,Y.BILL.CHARGE);* R22 Manual conversion
        R.NEW(REDO.AA.BD.OR.PROP.AMOUNT)<1,PROP.POS> = Y.BILL.CHARGE
        GOSUB REMOVE.PENAL.CHARGE.ADJUST
    END
    FINDSTR Y.PENALTY.PROPERTY IN R.NEW(REDO.AA.BD.PAY.PROPERTY) SETTING PROP.AF,PROP.AV,PROP.AS THEN
        R.NEW(REDO.AA.BD.OR.PR.AMT)<1,PROP.AV,PROP.AS> = Y.BILL.CHARGE
    END

RETURN
*--------------------------------------------------------------
REMOVE.PENAL.CHARGE.ADJUST:
*--------------------------------------------------------------
    Y.ADJUST.REF = R.NEW(REDO.AA.BD.ADJUST.REF)<1,PROP.POS>
    Y.ADJUST.REF.CNT = DCOUNT(Y.ADJUST.REF,@SM) ;*R22 Auto Code Conversion
    Y.VAR1 =1
    LOOP
    WHILE Y.VAR1 LE Y.ADJUST.REF.CNT
        Y.AAA.ID = FIELD(Y.ADJUST.REF<1,1,Y.VAR1>,'-',1)
        FINDSTR Y.AAA.ID IN R.AA.HISTORY<AA.AH.ACTIVITY.REF> SETTING POS.AF,POS.AV,POS.AS THEN
            IF R.AA.HISTORY<AA.AH.ACTIVITY,POS.AV,POS.AS> EQ 'MORA.CHARGE.ADJUSTMENT' THEN
                R.NEW(REDO.AA.BD.ADJUST.AMT)<1,PROP.POS,Y.VAR1> = ''
            END
        END
        Y.VAR1 += 1 ;*R22 Auto Code Conversion
    REPEAT

RETURN
END
