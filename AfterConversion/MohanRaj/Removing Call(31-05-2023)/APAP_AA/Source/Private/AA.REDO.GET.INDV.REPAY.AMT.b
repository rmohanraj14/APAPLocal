* @ValidationCode : MjotMTAwMjIyOTAyNzpDcDEyNTI6MTY4NTUyNzkzMzU4MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 15:42:13
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
$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE AA.REDO.GET.INDV.REPAY.AMT(TRANS.REF,ARR.ID,TOTAL.AMT)
*-----------------------------------------------------------------------------------------------
*Modification History:
*
* Date                     Who                        Reference                                        Description
* ----                    ----                                ----                                        ----
* 28-March-2023      Conversion Tool                 R22 Auto Code Conversion                         FM to @FM, SM to @SM, F.READ to CACHE.READ , F.AA.PROPERTY REMOVED
* 28-March-2023          Ajith Kumar              Manual R22 Code Conversion                Package Name added APAP.AA, CALL method format changed
*------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.REFERENCE.DETAILS
    $INSERT I_F.AA.ACTIVITY.BALANCES
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.PROPERTY
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $USING APAP.TAM

    IF TRANS.REF EQ '' OR ARR.ID EQ '' THEN
        TOTAL.AMT = 0
        GOSUB PGM.END
    END


    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*-----------------------------------------
OPENFILES:
*-----------------------------------------

    FN.AA.REFERENCE.DETAILS = 'F.AA.REFERENCE.DETAILS'
    F.AA.REFERENCE.DETAILS  = ''
    CALL OPF(FN.AA.REFERENCE.DETAILS,F.AA.REFERENCE.DETAILS)

    FN.AA.ACTIVITY.BALANCES = 'F.AA.ACTIVITY.BALANCES'
    F.AA.ACTIVITY.BALANCES  = ''
    CALL OPF(FN.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES)

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT  = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'

    FN.AA.PROPERTY = 'F.AA.PROPERTY'
    F.AA.PROPERTY  = ''
    CALL OPF(FN.AA.PROPERTY,F.AA.PROPERTY)

    FN.AA.ARRANGEMENT.ACTIVITY$NAU = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AA.ARRANGEMENT.ACTIVITY$NAU  = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY$NAU,F.AA.ARRANGEMENT.ACTIVITY$NAU)

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY  = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

    Y.PRINCIPAL.AMT = 0
    Y.INTEREST.AMT  = 0
    Y.CHARGE.AMT    = 0
    Y.PENALTY.AMT   = 0
    Y.ADVANCE.AMT   = 0

RETURN
*-----------------------------------------
PROCESS:
*-----------------------------------------

    CALL F.READ(FN.AA.ARRANGEMENT,ARR.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,ARR.ERR)
    Y.PRODUCT.GROUP = R.AA.ARRANGEMENT<AA.ARR.PRODUCT.GROUP>

    GOSUB GET.PRINCIPAL.PROP
    GOSUB GET.INTEREST.PROP
    GOSUB GET.PENALTY.PROP
    GOSUB GET.TRANSACTION.DETAILS

    TOTAL.AMT =  Y.PRINCIPAL.AMT:'*':Y.INTEREST.AMT:'*':Y.CHARGE.AMT:'*':Y.PENALTY.AMT:'*':Y.ADVANCE.AMT
RETURN
*-----------------------------------------
GET.PRINCIPAL.PROP:
*-----------------------------------------
    IN.PROPERTY.CLASS = 'ACCOUNT'
    OUT.PROPERTY      = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR);* R22 Manual conversion
    Y.PRINCIPAL.PROP = OUT.PROPERTY

RETURN
*-----------------------------------------
GET.INTEREST.PROP:
*-----------------------------------------
    ARR.INFO    = ''
    ARR.INFO<1> = ARR.ID
    R.ARRANGEMENT = ''
    Y.EFF.DATE = TODAY
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)

    CLASS.LIST = ''
    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes

    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    CLASS.CTR = ''
    Y.INTEREST.PROPERTY = ''

    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ "INTEREST" THEN
            Y.INTEREST.PROPERTY<1,-1> = PROP.LIST<CLASS.CTR>      ;*Get the interest property
        END
    REPEAT

RETURN
*-----------------------------------------
GET.PENALTY.PROP:
*-----------------------------------------

    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP,R.REDO.APAP.PROPERTY.PARAM,PAR.ERR)
    Y.PENALTY.CHARGE.PROP = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PENALTY.ARREAR>

RETURN
*-----------------------------------------
GET.TRANSACTION.DETAILS:
*-----------------------------------------

    CALL F.READ(FN.AA.REFERENCE.DETAILS,ARR.ID,R.AA.REFERENCE.DETAILS,F.AA.REFERENCE.DETAILS,AA.REF.ERR)
    LOCATE TRANS.REF IN R.AA.REFERENCE.DETAILS<AA.REF.TRANS.REF,1> SETTING POS1 THEN
        Y.AAA.ID = R.AA.REFERENCE.DETAILS<AA.REF.AAA.ID,POS1>
        GOSUB GET.LIST.OF.AAA     ;* Including child activity
        CALL F.READ(FN.AA.ACTIVITY.BALANCES,ARR.ID,R.AA.ACTIVITY.BALANCES,F.AA.ACTIVITY.BALANCES,AA.ACT.ERR)
        Y.ACT.CNT = DCOUNT(Y.FINAL.AAA.ID,@FM) ;*R22 Auto Code Conversion
        Y.LOOP1 = 1
        LOOP
        WHILE Y.LOOP1 LE Y.ACT.CNT
            Y.AAA.ID.INDV = Y.FINAL.AAA.ID<Y.LOOP1>
            LOCATE Y.AAA.ID.INDV IN R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.ACTIVITY.REF,1> SETTING POS2 THEN
                Y.PROPERTY     = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY,POS2>
                Y.PROPERTY.BAL.TYPE = FIELDS(Y.PROPERTY,'.',1)
                Y.PROPERTY.AMT = R.AA.ACTIVITY.BALANCES<AA.ACT.BAL.PROPERTY.AMT,POS2>
                GOSUB CALC.AMT
            END
            Y.LOOP1 += 1 ;*R22 Auto Code Conversion
        REPEAT
    END

RETURN
*-----------------------------------------
CALC.AMT:
*-----------------------------------------
    Y.PROP.CNT = DCOUNT(Y.PROPERTY,@SM) ;*R22 Auto Code Convertsion
    Y.CNT1 = 1
    LOOP
    WHILE Y.CNT1 LE Y.PROP.CNT
        Y.PROP = Y.PROPERTY.BAL.TYPE<1,1,Y.CNT1>
        CALL CACHE.READ(FN.AA.PROPERTY, Y.PROP, R.PROP.REC, PP.ERR) ;*R22 Auto Code Convertsion
        Y.PROP.CLASS = R.PROP.REC<AA.PROP.PROPERTY.CLASS>

        BEGIN CASE
            CASE Y.PROP EQ Y.PRINCIPAL.PROP
                Y.PRINCIPAL.AMT += Y.PROPERTY.AMT<1,1,Y.CNT1>
            CASE Y.PROP MATCHES Y.INTEREST.PROPERTY
                Y.INTEREST.AMT  += Y.PROPERTY.AMT<1,1,Y.CNT1>
            CASE Y.PROP EQ Y.PENALTY.CHARGE.PROP
                Y.PENALTY.AMT   += Y.PROPERTY.AMT<1,1,Y.CNT1>
            CASE Y.PROP NE Y.PENALTY.CHARGE.PROP AND Y.PROP.CLASS EQ 'CHARGE'
                Y.CHARGE.AMT    += Y.PROPERTY.AMT<1,1,Y.CNT1>
        END CASE
        Y.CNT1 += 1 ;*R22 Auto Code Convertsion
    REPEAT


RETURN
*-----------------------------------------
GET.LIST.OF.AAA:
*-----------------------------------------

    Y.FINAL.AAA.ID = ''
    Y.LOOP.BRK = 1
    LOOP
    WHILE Y.LOOP.BRK
        Y.FINAL.AAA.ID<-1> = Y.AAA.ID
        R.AAA = ''
        CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY$NAU,Y.AAA.ID,R.AAA,F.AA.ARRANGEMENT.ACTIVITY$NAU,AAA.ERR)
        IF R.AAA ELSE
            CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,Y.AAA.ID,R.AAA,F.AA.ARRANGEMENT.ACTIVITY,AAA.ERR)
        END
        Y.CHILD.ACTIVITY = R.AAA<AA.ARR.ACT.CHILD.ACTIVITY>
        IF R.AAA<AA.ARR.ACT.ACTIVITY.CLASS> EQ 'LENDING-CREDIT-ARRANGEMENT' THEN
            Y.ADVANCE.AMT += R.AAA<AA.ARR.ACT.ORIG.TXN.AMT>
        END

        Y.AAA.ID = Y.CHILD.ACTIVITY
        IF Y.CHILD.ACTIVITY ELSE
            Y.LOOP.BRK = 0
        END

    REPEAT
RETURN
*-----------------------------------------
PGM.END:
END
