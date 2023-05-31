* @ValidationCode : MjotNDU2Njk4OTg2OkNwMTI1MjoxNjgwMDcxMDc5ODQyOklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:39
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.UPDATE.LOAN.ACCOUNT.STATUS

* DESCRIPTION:
*
* This routine is attached as a POST routine to ACTIVITY.API for LENDING-UPDATE-OVERDUE property
* The purpose of this routine is to trigger an OFS which the Loan Status field in Account condition.
* --------------------------------------------------------------------------------------------------------------------------
*   Date               who           Reference                       Description
**
*** 29-03-2023 R22 Auto Conversion – FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - No changes
*---------------------------------------------------------------------------------------------------------------------------
*
* All File INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.LOAN.ACCOUNT.STATUS
    $INSERT I_F.REDO.AA.NAB.HISTORY
*-----------------------------------------------------------------------------------------------------------------
*Main Logic of the routine
*
MAIN.LOGIC:

    GOSUB INITIALISE

    GOSUB PROCESS

    GOSUB UPDATE.LOAN.RES


RETURN
*-----------------------------------------------------------------------------------------------------------------
* Initialise the required variables
*
INITIALISE:

    Y.ARR.ID = c_aalocArrId

    FN.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.ARRANGEMENT = ''
    CALL OPF (FN.ARRANGEMENT, F.ARRANGEMENT)

    CALL F.READ(FN.ARRANGEMENT, Y.ARR.ID, R.AA.ARRANGEMENT, F.ARRANGEMENT, ARR.ERR)
    Y.PRODUCT.ID = R.AA.ARRANGEMENT<AA.ARR.PRODUCT>

    Y.ACTIVITY = 'LENDING-UPDATE-LOAN.STATUS'

    FN.REDO.LOAN.ACCOUNT.STATUS = 'F.REDO.LOAN.ACCOUNT.STATUS'
    F.REDO.LOAN.ACCOUNT.STATUS = ''
    CALL OPF(FN.REDO.LOAN.ACCOUNT.STATUS, F.REDO.LOAN.ACCOUNT.STATUS)
    FN.REDO.AA.LOAN.UPD.STATUS = 'F.REDO.AA.LOAN.UPD.STATUS'
    F.REDO.AA.LOAN.UPD.STATUS = ''
    CALL OPF(FN.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS)

    FN.REDO.AA.NAB.HISTORY = 'F.REDO.AA.NAB.HISTORY'
    F.REDO.AA.NAB.HISTORY = ''
    CALL OPF(FN.REDO.AA.NAB.HISTORY,F.REDO.AA.NAB.HISTORY)

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Updation of local table for RESTRUCTURED status
*
UPDATE.LOAN.RES:

    OD.LOAN.STATUS = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    OD.LOAN.STATUS.OLD = R.OLD(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    IF OD.LOAN.STATUS NE OD.LOAN.STATUS.OLD THEN
        IF OD.LOAN.STATUS  EQ 'Restructured' THEN
            CALL F.READ(FN.REDO.AA.LOAN.UPD.STATUS,Y.ARR.ID,R.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS,Y.ER.RES)
            R.REDO.AA.LOAN.UPD.STATUS = c_aalocActivityEffDate
            CALL F.WRITE(FN.REDO.AA.LOAN.UPD.STATUS,Y.ARR.ID,R.REDO.AA.LOAN.UPD.STATUS)
            GOSUB CHANGE.COND.RESTR
        END
    END
RETURN

CHANGE.COND.RESTR:

    Y.RES.COND = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>
    Y.CND.CNT = DCOUNT(OD.LOAN.COND,@SM) ; FLP = ''
    IF R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS> EQ '' THEN
        R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS> = 'Restructured'
    END ELSE
        LOCATE 'Restructured' IN Y.RES.COND<1,1,1> SETTING RE.PS ELSE
            R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS,Y.CND.CNT+1> = 'Restructured'
        END
    END

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Trigger OFS message to update the Account Condition with Loan Status
*
PROCESS:

    GOSUB GET.ACCOUNT.PROPERTY  ;*Get the account property used in the Product

    GOSUB GET.LOAN.STATUS       ;* Get the loan status from the Overdue Record

    IF (c_aalocActivityStatus EQ 'UNAUTH') THEN

        ARR.PROPERTY.LIST = ACC.PROPERTY

        ARR.FIELD.NAME.LIST = 'L.LOAN.STATUS:1:1'

        ARR.FIELD.VALUE.LIST = '"':OD.AC.LOAN.STATUS:'"'        ;* Value is entered in "", because value 0 is considered as null in the routine AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS

        AAA.FIELDS.REC = ''

        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST,  ARR.FIELD.VALUE.LIST,  AAA.FIELDS.REC)

        RETURN.ERROR = ''

        Y.AC.DATE = c_aalocActivityEffDate
        Y.ACCT.ID = c_aalocArrActivityId
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(Y.ARR.ID, Y.ACTIVITY, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)

*  APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
*  OFS.FUNCTION='I'
*  PROCESS='PROCESS'
*  OFS.SOURCE.ID='LOAN.ACC.STATUS'
*  OFSVERSION='AA.ARRANGEMENT.ACTIVITY,'
*  GTSMODE=''
*  NO.OF.AUTH='0'
*  TRANSACTION.ID= ''
*  R.APP.RECORD=''
*  OFS.STRING=''

*  R.APP.RECORD<AA.ARR.ACT.ARRANGEMENT> = Y.ARR.ID
*  R.APP.RECORD<AA.ARR.ACT.ACTIVITY> = Y.ACTIVITY
*  R.APP.RECORD<AA.ARR.ACT.EFFECTIVE.DATE> = c_aalocActivityEffDate
*  R.APP.RECORD<AA.ARR.ACT.PRODUCT> = Y.PRODUCT.ID
*  R.APP.RECORD<AA.ARR.ACT.PROPERTY> = ACC.PROPERTY
*  R.APP.RECORD<AA.ARR.ACT.FIELD.NAME> = 'L.LOAN.STATUS:1:1'
*  R.APP.RECORD<AA.ARR.ACT.FIELD.VALUE> = OD.AC.LOAN.STATUS

*  CALL OFS.BUILD.RECORD(APP.NAME,OFS.FUNCTION,PROCESS,OFSVERSION,GTS.MODE,NO.OF.AUTH,TRANSACTION.ID,R.APP.RECORD,OFS.MESSAGE)
*  OFS.MSG.ID = ''
*  OPTIONS = ''
*  OFS.ERR = ''

*  CALL OFS.POST.MESSAGE(OFS.MESSAGE,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)

        CALL F.READ(FN.REDO.AA.NAB.HISTORY,Y.ARR.ID,R.REDO.AA.NAB.HISTORY,F.REDO.AA.NAB.HISTORY,HIS.ERR)

        IF R.REDO.AA.NAB.HISTORY THEN
            R.REDO.AA.NAB.HISTORY<REDO.NAB.HIST.L.LOAN.STATUS> = OD.AC.LOAN.STATUS
            CALL F.WRITE(FN.REDO.AA.NAB.HISTORY,Y.ARR.ID,R.REDO.AA.NAB.HISTORY)
        END
    END


RETURN
*-----------------------------------------------------------------------------------------------------------------
* Get the account property used in the product
*
GET.ACCOUNT.PROPERTY:

    Y.EFF.DATE = R.AA.ARRANGEMENT<AA.ARR.PROD.EFF.DATE>
    ARR.INFO = ''
    ARR.INFO<1> =Y.ARR.ID
    R.ARRANGEMENT=''
    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)
    CLASS.LIST = ''
    ACC.PROPERTY = ''
    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes
    CLASS.LIST = RAISE(CLASS.LIST)
    PROP.LIST = RAISE(PROP.LIST)
    CLASS.CTR = ''
    LOOP
        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS
        CLASS.CTR +=1
    WHILE Y.CLASS:CLASS.POS
        IF Y.CLASS EQ "ACCOUNT" THEN
            ACC.PROPERTY = PROP.LIST<CLASS.CTR>
            CLASS.LIST = ''
        END
    REPEAT

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Get the Loan Status from the Overdue property
*
GET.LOAN.STATUS:

    AA.OD.LRF.POS = ''
    AA.OD.LRF = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND'
    CALL MULTI.GET.LOC.REF('AA.PRD.DES.OVERDUE',AA.OD.LRF,AA.OD.LRF.POS)
    AA.LOAN.STATUS.POS = AA.OD.LRF.POS<1,1>
    AA.LOAN.COND.POS = AA.OD.LRF.POS<1,2>

    OD.LOAN.STATUS = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>
    OD.LOAN.COND = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.COND.POS>

    IF NOT(OD.LOAN.STATUS) THEN ;* Update the LOAN.STATUS to 'NORMAL'

        R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS> = 'Normal'
        OD.LOAN.STATUS = R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.STATUS.POS>

    END

* Get the LOAN.STATUS from the Parameter file REDO.LOAN.ACCOUNT.STATUS

    CALL F.READ(FN.REDO.LOAN.ACCOUNT.STATUS,OD.LOAN.STATUS,R.REDO.LOAN.STATUS,F.REDO.LOAN.ACCOUNT.STATUS, RET.ERR)

    OD.AC.LOAN.STATUS = R.REDO.LOAN.STATUS<REDO.LN.AC.ST.CONSOL.KEY.VAL>

RETURN
*-----------------------------------------------------------------------------------------------------------------
*
*
END
