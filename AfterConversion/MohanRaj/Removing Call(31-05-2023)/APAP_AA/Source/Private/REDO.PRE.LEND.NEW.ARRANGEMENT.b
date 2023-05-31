* @ValidationCode : MjotMTAxNTAzMDU4MTpDcDEyNTI6MTY4NTUzMTg0MzczNjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:47:23
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
SUBROUTINE REDO.PRE.LEND.NEW.ARRANGEMENT
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine will be used as a PRE routine to the activity
* LENDING-CHANGE-INTEREST to Update the NEXT.REVIEW.DATE depending upon the RATE.REVIEW.FREQUENCY
*
* Input/Output:
*--------------
* IN : -NA-
* OUT : -NA-
*---------------
*-----------------------------------------------------------------------------
* Modification History :
*   Date            Who           Reference            Description
* 01-JUL-2010    Kishore.SP    ODR-2009-10-0325      Initial Creation
*-----------------------------------------------------------------------------
*Modification History :
*Date           Who                 Reference                                  Descripition
* 29-03-2023   Conversion Tool    Auto R22 code coversion                    VM TO @VM
* 29-03-2023     Samaran T         Manual R22 code conversion               Package Name Added APAP.AA,CALL method format changed
*----------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_GTS.COMMON
    $USING APAP.TAM
*-----------------------------------------------------------------------------
    IF V$FUNCTION EQ 'I' THEN
        GOSUB GET.LOC.VALUES
        GOSUB GET.ARR.COND
    END
RETURN
*-----------------------------------------------------------------------------
GET.LOC.VALUES:
*--------------
* Get the local field position
*
    LOC.REF.APPL="AA.PRD.DES.INTEREST"
    LOC.REF.FIELDS="L.AA.REV.RT.TY":@VM:"L.AA.NXT.REV.DT":@VM:"L.AA.LST.REV.DT":@VM:"L.AA.RT.RV.FREQ":@VM:"L.AA.INT.AMTOLD":@VM:"L.AA.REV.FORM":@VM:"L.AA.FIR.REV.DT"
    LOC.REF.POS=""
    CALL MULTI.GET.LOC.REF(LOC.REF.APPL,LOC.REF.FIELDS,LOC.REF.POS)
    Y.RT.TYPE.POS         =  LOC.REF.POS<1,1>
    Y.NEXT.REV.DATE.POS   =  LOC.REF.POS<1,2>
    Y.LST.REV.DATE.POS    =  LOC.REF.POS<1,3>
    Y.RATE.REV.FREQ.POS   =  LOC.REF.POS<1,4>
    Y.AMT.OLD.POS         =  LOC.REF.POS<1,5>
    Y.L.AA.REV.FORM.POS   =  LOC.REF.POS<1,6>
    Y.L.AA.FIR.REV.DT.POS =  LOC.REF.POS<1,7>
*
RETURN
*-----------------------------------------------------------------------------
GET.ARR.COND:
*------------
* Get the Interest properties of the arrangement
*
    Y.ARRG.ID = c_aalocArrId
    PROP.NAME='PRINCIPAL'       ;* Interest Property to obtain
    APAP.TAM.redoGetInterestProperty(Y.ARRG.ID,PROP.NAME,OUT.PROP,ERR);* R22 Manual conversion
    Y.PRIN.PROP=OUT.PROP        ;* This variable hold the value of principal interest property


    PROPERTY.CLASS = 'TERM.AMOUNT'
    PROPERTY = ''
    EFF.DATE = ''
    ERR.MSG = ''
    R.ARR.COND = ''
*
    APAP.AA.redoCrrGetConditions(Y.ARRG.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.ARR.TM.COND,ERR.MSG);* R22 Manual converison
    LOAN.MATURITY.DATE = R.ARR.TM.COND<AA.AMT.MATURITY.DATE>
*
    Y.ARRG.ID = c_aalocArrId
    PROPERTY.CLASS = 'INTEREST'
    PROPERTY = Y.PRIN.PROP
    EFF.DATE = ''
    ERR.MSG = ''
    R.ARR.COND = ''
*
    APAP.AA.redoCrrGetConditions(Y.ARRG.ID,EFF.DATE,PROPERTY.CLASS,PROPERTY,R.ARR.COND,ERR.MSG);* R22 Manual converison
    IF R.ARR.COND NE '' THEN
        GOSUB CHECK.RT.TYPE
    END
RETURN
*-----------------------------------------------------------------------------
CHECK.RT.TYPE:
*-------------
* Get the local field values
*
    Y.RATE.REVIEW.TYPE  = R.ARR.COND<AA.INT.LOCAL.REF><1,Y.RT.TYPE.POS>
    Y.NEXT.REVIEW.DATE  = R.ARR.COND<AA.INT.LOCAL.REF><1,Y.NEXT.REV.DATE.POS>
    Y.LAST.REVIEW.DATE  = R.ARR.COND<AA.INT.LOCAL.REF><1,Y.LST.REV.DATE.POS>
    Y.FIRST.REVIEW.DATE = R.ARR.COND<AA.INT.LOCAL.REF><1,Y.L.AA.FIR.REV.DT.POS>
*
    IF Y.RATE.REVIEW.TYPE EQ 'Periodic' THEN
        GOSUB ASSIGN.VALUES
    END
*
RETURN
*-----------------------------------------------------------------------------
ASSIGN.VALUES:
*-------------
* Get the Rate review frequency
* find the next review date from today's date using the frquency
* update in next review date
*
    Y.RATE.REVIEW.FREQUENCY = R.NEW(AA.INT.LOCAL.REF)<1,Y.RATE.REV.FREQ.POS>
*
    IF Y.RATE.REVIEW.FREQUENCY EQ '' THEN
        Y.RATE.REVIEW.FREQUENCY = R.ARR.COND<AA.INT.LOCAL.REF><1,Y.RATE.REV.FREQ.POS>
    END
*
    IF Y.RATE.REVIEW.FREQUENCY NE '' THEN
        COMI = Y.RATE.REVIEW.FREQUENCY
        CALL CFQ
        Y.OUT.DATE = COMI
        Y.DATE = Y.OUT.DATE[1,8]
*
        IF Y.DATE GE LOAN.MATURITY.DATE THEN
            Y.DATE = LOAN.MATURITY.DATE
        END
*
        R.NEW(AA.INT.LOCAL.REF)<1,Y.NEXT.REV.DATE.POS>   = Y.DATE
*
        R.NEW(AA.INT.LOCAL.REF)<1,Y.LST.REV.DATE.POS>    = TODAY
*
        R.NEW(AA.INT.LOCAL.REF)<1,Y.L.AA.REV.FORM.POS> = R.OLD(AA.INT.LOCAL.REF)<1,Y.L.AA.REV.FORM.POS>
*
        R.NEW(AA.INT.LOCAL.REF)<1,Y.L.AA.FIR.REV.DT.POS> = Y.FIRST.REVIEW.DATE
*
        Y.FRQ.LN =  LEN(Y.RATE.REVIEW.FREQUENCY)
        Y.NEW.FQ = Y.RATE.REVIEW.FREQUENCY[9,Y.FRQ.LN]
        Y.NEW.RATE.REV.FQ = Y.DATE:Y.NEW.FQ
        R.NEW(AA.INT.LOCAL.REF)<1,Y.RATE.REV.FREQ.POS> = Y.NEW.RATE.REV.FQ
*
    END
RETURN
END
*------------------------------------------------------------------------------
