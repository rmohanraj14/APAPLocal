* @ValidationCode : MjozNTg1OTM1MTI6Q3AxMjUyOjE2ODU1Mjc4NjkwODA6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 15:41:09
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
$PACKAGE APAP.AA ;*MANUAL R22 CODE CONVERSION
SUBROUTINE AA.GET.INTEREST.RATE
*--------------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Program Name : AA.GET.INTEREST.RATE
*--------------------------------------------------------------------------------
* Description: This is the pre routine for the INTEREST property to get the interest rate
* from the collateral and it will be defaulted to the loan
*
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*
*  DATE             WHO           REFERENCE          DESCRIPTION
* 05.12.2009    RAJA SAKTHIVEL  ODR-2009-10-0523   INITIAL CREATION
* 04/04/2011    Ravikiran AV    PACS00032743       If Interest Slabs are not
*                                                  defined in INTEREST property,
*                                                  then populate it in the first MV SET
* 08-Apr-2011   H GANESH        PACS00032977       Modified as per the issue
* 12-Apr-2011   Ravikiran AV    PACS00075170       Update the NOMINAL.RATE field by adding fixed rate and margin
*                                                  Core doesnt do it
* 21-Nov-2011   Luis Pazmino    ODR-2011-06-0242   Minor fixes to obtain the ACCOUNT.ID
*                                                  when a COLLATERAL is created through FC
* 28/03/2023   Conversion Tool     AUTO R22 CODE CONVERSION      FM to @FM, VM to @VM, Y.VAR1++ to  Y.VAR1 += 1, ADD END,  Y.VAR2++ to Y.VAR2 += 1, CALL F.READ to CALL F.CACHE
* 28/03/2023    SURESH     MANUAL R22 CODE CONVERSION    Package Name added APAP.AA, CALL method format changed
*----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.COLLATERAL
    $INSERT I_F.AZ.ACCOUNT
    $INSERT I_F.GROUP.DATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.LIMIT
    $USING APAP.TAM
    GOSUB INIT
    GOSUB PROCESS
    GOSUB UPDATE.NOMINAL      ;*PACS00075170

RETURN
*---------------------------------------------------------------------------------
INIT:
*---------------------------------------------------------------------------------

    Y.TOTAL.INT.RATE = ''
    Y.COLLATERAL.IDS = ''

* lfpazmino 24.01.2012
* PQC Review
* Obtain the local ref position
    CL.LOCAL.REF = "LOCAL.REF"
    CALL EB.FIND.FIELD.NO("COLLATERAL", CL.LOCAL.REF)

    LOC.REF.APPLICATION = "AA.PRD.DES.INTEREST" : @FM : "COLLATERAL" ;*AUTO R22 CODE CONVERSION
    LOC.REF.FIELDS = 'L.AA.REV.RT.TY' : @FM : 'L.COL.NUM.INSTR' ;*AUTO R22 CODE CONVERSION
    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION, LOC.REF.FIELDS, LOC.REF.POS)

    POS.L.AA.REV.RT.TY = LOC.REF.POS<1,1>
    Y.ACCOUNT.POS = LOC.REF.POS<2,1>

    FN.REDO.T.DEP.COLLATERAL = 'F.REDO.T.DEP.COLLATERAL'
    F.REDO.T.DEP.COLLATERAL = ''
    CALL OPF(FN.REDO.T.DEP.COLLATERAL,F.REDO.T.DEP.COLLATERAL)

    FN.LI.COLLATERAL.RIGHT = 'F.LI.COLLATERAL.RIGHT'
    F.LI.COLLATERAL.RIGHT = ''
    CALL OPF(FN.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT)

    FN.RIGHT.COLLATERAL = 'F.RIGHT.COLLATERAL'
    F.RIGHT.COLLATERAL = ''
    CALL OPF(FN.RIGHT.COLLATERAL,F.RIGHT.COLLATERAL)

    FN.COLLATERAL = 'F.COLLATERAL'
    F.COLLATERAL = ''
    CALL OPF(FN.COLLATERAL,F.COLLATERAL)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AZ.ACCOUNT = 'F.AZ.ACCOUNT'
    F.AZ.ACCOUNT = ''
    CALL OPF(FN.AZ.ACCOUNT,F.AZ.ACCOUNT)

    FN.GROUP.DATE = 'F.GROUP.DATE'
    F.GROUP.DATE = ''
    CALL OPF(FN.GROUP.DATE,F.GROUP.DATE)

RETURN

*---------------------------------------------------------------------------------
PROCESS:
*---------------------------------------------------------------------------------
    Y.INT.PAY.TYPE=R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.REV.RT.TY>

    IF Y.INT.PAY.TYPE NE 'BACK.TO.BACK' THEN
        RETURN
    END

    Y.LIMIT.REFERENCE = C$SPARE(500)

    EFF.DATE     = c_aalocActivityEffDate
    Y.PROP.CLASS = 'LIMIT'
    PROPERTY     = ''
    R.CONDITION  = ''
    ERR.MSG      = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,Y.PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG);* R22 Manual conversion
    Y.LIMIT.REFERENCE = R.CONDITION<AA.LIM.LIMIT.REFERENCE>
    Y.LIMIT.SERIAL = R.CONDITION<AA.LIM.LIMIT.SERIAL>

    IF Y.LIMIT.REFERENCE EQ '' THEN
        RETURN
    END

    GOSUB GET.COLLATERAL
    GOSUB CHECK.COLLATERAL.RATE

RETURN
*---------------------------------------------------------------------------------
GET.COLLATERAL:
*---------------------------------------------------------------------------------
* Here list of collateral ids linked to that limit are read

    R.REDO.T.DEP.COLLATERAL = ''
    Y.CUSTOMER.ID = c_aalocArrActivityRec<AA.ARR.ACT.CUSTOMER>
    REF.NO = FMT(Y.LIMIT.REFERENCE,"7'0'R")
    SEQ.NO = FMT(Y.LIMIT.SERIAL,"2'0'R")
    Y.LIMIT.ID = Y.CUSTOMER.ID:".":REF.NO:".":SEQ.NO
    IF c_aalocActivityStatus EQ 'AUTH' THEN
*CALL CACHE.READ(FN.REDO.T.DEP.COLLATERAL, 'SYSTEM', R.REDO.T.DEP.C, ERR.DEP.COLL)
*IF R.REDO.T.DEP.COLLATERAL THEN
*LOCATE c_aalocArrId IN R.REDO.T.DEP.COLLATERAL SETTING POS ELSE
*R.REDO.T.DEP.COLLATERAL<-1> = c_aalocArrId
*END
*END ELSE
*R.REDO.T.DEP.COLLATERAL<1> = c_aalocArrId
*END
*Y.WRITE.ID = 'SYSTEM'
        Y.WRITE.ID = c_aalocArrId
        CALL F.WRITE(FN.REDO.T.DEP.COLLATERAL,Y.WRITE.ID,R.REDO.T.DEP.COLLATERAL)
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        Y.WRITE.ID = c_aalocArrId
        CALL CACHE.READ(FN.REDO.T.DEP.COLLATERAL,Y.WRITE.ID, R.REDO.T.DEP.COLLATERAL, ERR.DEP.COLL)
        CALL F.DELETE(FN.REDO.T.DEP.COLLATERAL,Y.WRITE.ID)
*LOCATE c_aalocArrId IN R.REDO.T.DEP.COLLATERAL SETTING POS THEN
*DEL R.REDO.T.DEP.COLLATERAL<POS>
*Y.WRITE.ID = 'SYSTEM'
*CALL F.WRITE(FN.REDO.T.DEP.COLLATERAL,Y.WRITE.ID,R.REDO.T.DEP.COLLATERAL)
*END
    END
    CALL F.READ(FN.LI.COLLATERAL.RIGHT,Y.LIMIT.ID,R.LI.COLLATERAL.RIGHT,F.LI.COLLATERAL.RIGHT,ERR.LI.COLLATERAL.RIGHT)
    Y.COLLATERAL.ID = ''
    Y.LI.COL.CNT = DCOUNT(R.LI.COLLATERAL.RIGHT,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.LI.COL.CNT
        Y.COLLATERAL.RIGHT.ID = R.LI.COLLATERAL.RIGHT<Y.VAR1>
        CALL F.READ(FN.RIGHT.COLLATERAL,Y.COLLATERAL.RIGHT.ID,R.RIGHT.COLLATERAL.ARR,F.RIGHT.COLLATERAL,ERR.RIGHT.COLLATERAL)
        Y.COLLATERAL.IDS<-1> = R.RIGHT.COLLATERAL.ARR
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN
*-------------------------------------------------------------------
CHECK.COLLATERAL.RATE:
*-------------------------------------------------------------------
* In this part rate of each collateral will be fetched
    Y.COLLATERAL.CNT=DCOUNT(Y.COLLATERAL.IDS,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.COLLATERAL.CNT
        Y.COLL.ID = Y.COLLATERAL.IDS<Y.VAR1>
        CALL F.READ(FN.COLLATERAL,Y.COLL.ID,R.COLLATERAL,F.COLLATERAL,ERR.COLLATERAL)
        Y.ACCOUNT.ID = R.COLLATERAL<COLL.APPLICATION.ID>

* lfpazmino 22.11.2011 / ODR-2011-06-0242
* In case of using collaterals created by Fabrica de Credito interface
* there is a local field which holds the account number, since APPLICATION.ID
* is not used due to specific user's requirements
        IF Y.ACCOUNT.ID EQ '' THEN
            Y.ACCOUNT.ID = R.COLLATERAL<CL.LOCAL.REF,Y.ACCOUNT.POS>
        END

        IF Y.ACCOUNT.ID THEN
            CALL F.READ(FN.ACCOUNT,Y.ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ERR.ACCOUNT)
            Y.APP.ID = R.ACCOUNT<AC.ALL.IN.ONE.PRODUCT>
            Y.FINAL.WRITE.ID = Y.APP.ID
            Y.ACI.DATE = R.ACCOUNT<AC.ACCT.CREDIT.INT>
            IF Y.ACI.DATE EQ '' THEN
                Y.ACI.ID = ''
            END ELSE
                Y.ACI.ID = Y.ACCOUNT.ID:'-':Y.ACI.DATE<1,DCOUNT(Y.ACI.DATE,@VM)> ;*AUTO R22 CODE CONVERSION
            END
            IF Y.APP.ID NE '' THEN
                CALL F.READ(FN.AZ.ACCOUNT,Y.ACCOUNT.ID,R.AZ.ACCOUNT,F.AZ.ACCOUNT,ERR.AZ.ACCOUNT)
                Y.AZ.INTEREST.RATE = R.AZ.ACCOUNT<AZ.INTEREST.RATE>
                Y.TOTAL.INT.RATE<-1> = Y.AZ.INTEREST.RATE
            END
            ELSE ;*AUTO R22 CODE CONVERSION
                IF Y.ACI.ID NE '' THEN
                    Y.ACI.CUR = R.ACCOUNT<AC.CURRENCY>
                    GOSUB GET.HIGH.ACI
                END
                ELSE
                    Y.CONDITION.GROUP = R.ACCOUNT<AC.CONDITION.GROUP>
                    Y.GCI.CUR = R.ACCOUNT<AC.CURRENCY>
                    Y.COND.AND.CURR = Y.CONDITION.GROUP:Y.GCI.CUR
*CALL F.READ(FN.GROUP.DATE,Y.COND.AND.CURR,R.GROUP.DATE,F.GROUP.DATE,GROUP.ERR)
                    CALL CACHE.READ(FN.GROUP.DATE, Y.COND.AND.CURR, R.GROUP.DATE, GROUP.ERR) ;*AUTO R22 CODE CONVERSION
                    Y.GCI.ID = Y.COND.AND.CURR:R.GROUP.DATE<AC.GRD.CREDIT.GROUP.DATE>
                    GOSUB GET.HIGH.GCI
                END ;*AUTO R22 CODE CONVERSION
            END
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
    IF Y.TOTAL.INT.RATE THEN
        Y.FINAL.RATE = MAXIMUM(Y.TOTAL.INT.RATE)
        Y.FIXED.RATE.CNT = DCOUNT(R.NEW(AA.INT.FIXED.RATE),@VM) ;*AUTO R22 CODE CONVERSION
        Y.VAR2 = 0
        LOOP
        WHILE Y.VAR2 LE Y.FIXED.RATE.CNT
            IF Y.FIXED.RATE.CNT EQ 0 THEN
                R.NEW(AA.INT.FIXED.RATE)<1,Y.VAR2+1> = Y.FINAL.RATE
                R.NEW(AA.INT.FLOATING.INDEX)<1,Y.VAR2+1> = ''
            END ELSE
                IF Y.VAR2 NE 0 THEN
                    R.NEW(AA.INT.FIXED.RATE)<1,Y.VAR2> = Y.FINAL.RATE
                    R.NEW(AA.INT.FLOATING.INDEX)<1,Y.VAR2> = ''
                END
            END
            Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
        REPEAT
    END
RETURN
*----------------------------------------------------------------------------
GET.HIGH.ACI:
*----------------------------------------------------------------------------

    APAP.TAM.redoGetHighAci(Y.ACI.ID,Y.ACI.CUR,Y.RATE.ACI);* R22 Manual conversion
    Y.TOTAL.INT.RATE<-1> = Y.RATE.ACI

RETURN

*----------------------------------------------------------------------------
GET.HIGH.GCI:
*----------------------------------------------------------------------------
    APAP.TAM.redoGetHighGci(Y.GCI.ID,Y.GCI.CUR,Y.RATE.GCI);* R22 Manual conversion
    Y.TOTAL.INT.RATE<-1> = Y.RATE.GCI

RETURN

*----------------------------------------------------------------------------
UPDATE.NOMINAL:
*----------------------------------------------------------------------------
    TOT.FIXED = DCOUNT(R.NEW(AA.INT.FIXED.RATE),@VM) ;*AUTO R22 CODE CONVERSION
    TIER.I = 1

    LOOP
    WHILE TOT.FIXED GE TIER.I
        IF R.NEW(AA.INT.FIXED.RATE)<1,TIER.I> NE '' THEN
            CURRENT.RATE = R.NEW(AA.INT.FIXED.RATE)<1,TIER.I>
            MARGIN.RATES = R.NEW(AA.INT.MARGIN.RATE)<1,TIER.I>
            MARGIN.OPERANDS = R.NEW(AA.INT.MARGIN.OPER)<1,TIER.I>
            MAX.TIER.CAP = R.NEW(AA.INT.TIER.MAX.RATE)<1,TIER.I>
            MIN.TIER.CAP = R.NEW(AA.INT.TIER.MIN.RATE)<1,TIER.I>
*TUS START
            PRICING.OPERAND = R.NEW(AA.INT.RELATIONSHIP.OPERAND)<1,TIER.I>
            PRICING.MARGIN = R.NEW(AA.INT.RELATIONSHIP.MARGIN)<1,TIER.I>
            CALL AA.GET.INTEREST.NOMINAL.RATE(CURRENT.RATE, NEGATIVE.RATE, MARGIN.RATES, MARGIN.OPERANDS, MAX.TIER.CAP, MIN.TIER.CAP, PRICING.OPERAND, PRICING.MARGIN, NOMINAL.RATE)
*TUS END
            R.NEW(AA.INT.EFFECTIVE.RATE)<1,TIER.I> = NOMINAL.RATE
        END

        TIER.I += 1
    REPEAT

RETURN
 
*----------------------------------------------------------------------------
END
