* @ValidationCode : MjotMTQ0NjQ2MjcxMTpDcDEyNTI6MTY4MDE4Nzc1NzM5ODpJVFNTOi0xOi0xOjU3MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:19:17
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 570
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AUT.EXP.LIMIT.CLS.LN
    
*--------------------------------------------------------------------------------------------------------
* Modification History:
* DATE              WHO                REFERENCE                 DESCRIPTION
* 29-MAR-2023      Conversion Tool    R22 Auto conversion     F.READ to CACHE.READ
* 29-MAR-2023      Harishvikram C     Manual R22 conversion   Modified AA$CURR.ACTIVITY to c_aalocCurrActivity
*---------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.LIMIT
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.LIMIT
    $INSERT I_F.AA.ARRANGEMENT

MAIN:

    FN.AA.ARR = 'F.AA.ARRANGEMENT'
    F.AA.ARR = ''
    CALL OPF(FN.AA.ARR,F.AA.ARR)

    FN.LIMIT = 'F.LIMIT'
    F.LIMIT = ''
    CALL OPF(FN.LIMIT,F.LIMIT)

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.AA.PRODUCT = 'F.AA.PRODUCT'
    F.AA.PRODUCT = ''
    CALL OPF(FN.AA.PRODUCT,F.AA.PRODUCT)

    Y.PRODUCT.ID = c_aalocArrProductId  ;* Product ID

    CALL CACHE.READ(FN.AA.PRODUCT, Y.PRODUCT.ID, R.PRODUCT, PROD.ERR) ;*R22 Auto conversion
    Y.PRODUCT.GROUP.ID = R.PRODUCT<AA.PDT.PRODUCT.GROUP>    ;* Product Group ID
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY.PARAM,PROP.PARAM.ERR)

    Y.PAYOFF.ACTIVITY =  R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PAYOFF.ACTIVITY>

    IF Y.PAYOFF.ACTIVITY THEN
*    IF AA$CURR.ACTIVITY EQ Y.PAYOFF.ACTIVITY THEN
        IF c_aalocCurrActivity EQ Y.PAYOFF.ACTIVITY THEN ;*R22 Manual conversion
            IF c_aalocActivityStatus EQ 'AUTH' THEN
                GOSUB PROCES.LIMITS
            END
        END
    END

RETURN

PROCES.LIMITS:


    Y.AA.ID = c_aalocArrId

    idArrangementComp = Y.AA.ID
    idPropertyClass = 'LIMIT'
    idProperty = ''
    effectiveDate = TODAY
    returnIds = ''
    returnConditions = ''
    returnError = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(idArrangementComp, idPropertyClass, idProperty, effectiveDate, returnIds, returnConditions, returnError)

    returnConditions = RAISE(returnConditions)
    Y.LIMIT.ID = returnConditions<AA.LIM.LIMIT.REFERENCE>
*AA Chnages 20161013
    Y.LIMIT.SERIAL = returnConditions<AA.LIM.LIMIT.SERIAL>
*AA Changes 20161013
    CALL F.READ(FN.AA.ARR,Y.AA.ID,R.AA.ARR,F.AA.ARR,AA.ARR.ERR)

    Y.CUS = R.AA.ARR<AA.ARR.CUSTOMER>
*AA Changes 20161013
*  Y.LI.ID = Y.CUS:'.000':Y.LIMIT.ID
    Y.LI.ID = Y.CUS:'.000':Y.LIMIT.ID:".":Y.LIMIT.SERIAL
*AA Changes 20161013
    Y.MIG = ''
    CALL F.READ(FN.LIMIT,Y.LI.ID,R.LIMIT,F.LIMIT,LIM.ERR)

    IF R.LIMIT THEN
        GOSUB CHECK.MIG

        IF Y.NOTES EQ 'AUTO' THEN
            GOSUB FORM.OFS.LIM
        END ELSE
            IF Y.MIG NE 'Y' THEN
                Y.NOTES = R.LIMIT<LI.NOTES,1>
                IF Y.NOTES NE 'MANUAL_LIMIT' THEN
                    GOSUB FORM.OFS.LIM
                END
            END
        END
    END

RETURN

CHECK.MIG:

    Y.NOTES = R.LIMIT<LI.NOTES,2>
    IF Y.NOTES EQ 'AUTO' OR Y.NOTES EQ 'MANUAL' THEN
        Y.MIG = 'Y'
    END

RETURN

FORM.OFS.LIM:

    Y.CHLD.TOT.AMT = 0
    Y.CLD.SEC.AMT = 0

    Y.PARENT = R.LIMIT<LI.RECORD.PARENT>

    Y.EF.DATE = c_aalocActivityEffDate
    R.OFS.LIM<LI.EXPIRY.DATE> = Y.EF.DATE
    R.OFS.LIM<LI.REVIEW.FREQUENCY> = Y.EF.DATE:'DAILY'
    R.OFS.LIM<LI.MAXIMUM.TOTAL> = Y.CHLD.TOT.AMT
    R.OFS.LIM<LI.MAXIMUM.SECURED> = Y.CLD.SEC.AMT

    APP.NAME = 'LIMIT'
    OFSFUNCTION = 'I'
    PROCESS = 'PROCESS'
    OFS.SOURCE.ID = 'REDO.LIM'
    OFSVERSION = 'LIMIT,AP'
    GTSMODE = ''
    NO.OF.AUTH = '0'
    TRANSACTION.ID = Y.LI.ID
    OFSSTRING = ''
    OFS.ERR = ''

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCTION,PROCESS,OFSVERSION,GTS.MODE,NO.OF.AUTH,TRANSACTION.ID,R.OFS.LIM,OFSSTR)

    CALL OFS.POST.MESSAGE(OFSSTR,OFS.MSG.ID,OFS.SOURCE.ID,Y.GEN.USER.NAME)

RETURN

END
