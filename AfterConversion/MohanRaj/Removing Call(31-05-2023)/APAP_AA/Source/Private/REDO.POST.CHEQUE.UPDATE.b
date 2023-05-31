* @ValidationCode : Mjo3NTA0NjY5NTI6Q3AxMjUyOjE2ODU1MzEzMDk1ODQ6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:38:29
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
SUBROUTINE REDO.POST.CHEQUE.UPDATE
*----------------------------------------------------------
* Description: This routine is to trigger lending-update-account to update the
* Posting restrict for the account...
* Input Arg: N/A
* Output Arg: N/A
*
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
* DATE WHO REFERENCE DESCRIPTION
* 02-JAN-2012 H GANESH PACS00174524 - B.43 Initial Draft.
* 29-MAY-2012 MARIMUTHU S PACS00187932
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL       AUTO R22 CODE CONVERSION        VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.PRODUCT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.CHARGE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.APAP.PROPERTY.PARAM
    $INSERT I_F.APAP.H.INSURANCE.DETAILS
    $INSERT I_F.ACCOUNT
    $USING APAP.TAM
    IF c_aalocActivityStatus MATCHES 'AUTH':@VM:'UNAUTH':@VM:'UNAUTH-CHG' THEN ;*AUTO R22 CODE CONVERSION
        GOSUB OPEN.FILES
        GOSUB PROCESS
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN   ;* Insurance are marked as closed in Payoff FT auth routine level.
* reversal will happen at Activity API level.
        GOSUB OPEN.FILES
        GOSUB REVERSE.INSURANCE
*CALL REDO.CANC.CHARGE.PAYOFF.PS
    END


RETURN
*------------------------------------------------------
OPEN.FILES:
*------------------------------------------------------

    FN.REDO.APAP.PROPERTY.PARAM = 'F.REDO.APAP.PROPERTY.PARAM'
    F.REDO.APAP.PROPERTY.PARAM = ''
    CALL OPF(FN.REDO.APAP.PROPERTY.PARAM,F.REDO.APAP.PROPERTY.PARAM)

    FN.REDO.LOAN.PAYOFF.DATE = 'F.REDO.LOAN.PAYOFF.DATE'
    F.REDO.LOAN.PAYOFF.DATE = ''
    CALL OPF(FN.REDO.LOAN.PAYOFF.DATE,F.REDO.LOAN.PAYOFF.DATE)

    FN.APAP.H.INSURANCE.DETAILS = 'F.APAP.H.INSURANCE.DETAILS'
    F.APAP.H.INSURANCE.DETAILS = ''
    CALL OPF(FN.APAP.H.INSURANCE.DETAILS,F.APAP.H.INSURANCE.DETAILS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    LOC.REF.APPLICATION="AA.PRD.DES.CHARGE"
    LOC.REF.FIELDS='POL.NUMBER'
    LOC.REF.POS=''
    CALL GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.POL.NUMBER = LOC.REF.POS<1,1>


    R.REDO.LOAN.PAYOFF.DATE = ''

    Y.PRODUCT.GROUP.ID = c_aalocArrangementRec<AA.ARR.PRODUCT.GROUP>  ;* Product Group ID
    CALL CACHE.READ(FN.REDO.APAP.PROPERTY.PARAM,Y.PRODUCT.GROUP.ID,R.REDO.APAP.PROPERTY.PARAM,PROP.PARAM.ERR)

    Y.PAYOFF.ACTIVITY = R.REDO.APAP.PROPERTY.PARAM<PROP.PARAM.PAYOFF.ACTIVITY>
RETURN
*-----------------------------------------------------------
PROCESS:
*-----------------------------------------------------------

    IF Y.PAYOFF.ACTIVITY THEN
**LOCATE AA$CURR.ACTIVITY IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN
*****Manual R22 Code Conversion*****
        LOCATE c_aalocCurrActivity IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN
        
            IF c_aalocActivityStatus MATCHES 'UNAUTH':@VM:'UNAUTH-CHG' THEN ;*AUTO R22 CODE CONVERSION
                APAP.AA.redoPostPayoffRemPaysch()  ;* This routine to remove the scheduled charge after payoff. ;* R22 Manual conversion
            END
            IF c_aalocActivityStatus EQ 'AUTH' THEN
                GOSUB CHECK.UNC
            END

            GOSUB UPDATE.POST.RESTRICT
            GOSUB UPDATE.PAYOFF.DATE    ;* This is for B.43 Letter's.
            RETURN
        END
    END

    GOSUB GET.MATURITY.DATE
    Y.TRANSACTION.AMOUNT = c_aalocArrActivityRec<AA.ARR.ACT.ORIG.TXN.AMT>
    IF c_aalocActivityEffDate GE Y.MATURITY.DATE THEN
        VAR.ARR.ID = c_aalocArrId
        APAP.TAM.redoGetTotalOutstandingSinUncUnd(VAR.ARR.ID,PROP.AMT,TOTAL.AMT);* R22 Manual conversion
        IF Y.TRANSACTION.AMOUNT GE TOTAL.AMT THEN
            GOSUB UPDATE.POST.RESTRICT
            GOSUB UPDATE.PAYOFF.DATE    ;* This is for B.43 Letter's.
        END
    END
RETURN

CHECK.UNC:

    ACCOUNT.ID = AA$LINKED.ACCOUNT
    BALANCE.TO.CHECK = 'UNCACCOUNT'
    START.DATE = TODAY
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, REQUEST.TYPE, START.DATE, END.DATE, SYSTEM.DATE, BAL.DETAILS, ERROR.MESSAGE)

    Y.BALANCE += ABS(BAL.DETAILS<IC.ACT.BALANCE>)

    R.FT<FT.CREDIT.CURRENCY> = LCCY
    R.FT<FT.CREDIT.ACCT.NO> = AA$LINKED.ACCOUNT
    R.FT<FT.DEBIT.CURRENCY> = LCCY
    R.FT<FT.DEBIT.ACCT.NO> = AA$LINKED.ACCOUNT
    R.FT<FT.DEBIT.AMOUNT> = Y.BALANCE
    R.FT<FT.DEBIT.VALUE.DATE> = TODAY
    R.FT<FT.CREDIT.VALUE.DATE> = TODAY

    APP.NAME = 'FUNDS.TRANSFER'
    OFSFUNCTION = 'I'
    PROCESS = 'PROCESS'
    OFS.SOURCE.ID = 'FT.UNC.CK'
    OFSVERSION = 'FUNDS.TRANSFER,REDO.UNC.CK'
    GTSMODE = ''
    NO.OF.AUTH = '0'
    TRANSACTION.ID = ''
    OFSSTRING = ''
    OFS.ERR = ''

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCTION,PROCESS,OFSVERSION,GTS.MODE,NO.OF.AUTH,TRANSACTION.ID,R.FT,OFSSTR)
    CALL OFS.POST.MESSAGE(OFSSTR,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)

RETURN

*-----------------------------------------------------------
UPDATE.POST.RESTRICT:
*-----------------------------------------------------------

    GOSUB GET.ACCOUNT.PROPERTY

    ARR.PROPERTY.LIST = OUT.PROPERTY
    ARR.FIELD.NAME.LIST = 'POSTING.RESTRICT'
    ARR.FIELD.VALUE.LIST = '75'
    AAA.FIELDS.REC = ""
    NEW.ACTIVITY.ID = ""      ;* PACS00641421
    CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)
    IF OUT.PROPERTY EQ "ACCOUNT" THEN   ;* PACS00641421 -S
        NEW.ACTIVITY.ID = 'LENDING-UPDATE-POST.RESTRICT'
    END ELSE
        NEW.ACTIVITY.ID = 'LENDING-UPDATE-':OUT.PROPERTY
    END   ;* PACS00641421 -E
*   NEW.ACTIVITY.ID = 'LENDING-UPDATE-POST.RESTRICT'
    RETURN.ERROR = ''
    VAR.ACT.EFF.DATE = c_aalocActivityEffDate
    VAR.ACT.ID = c_aalocArrActivityId
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(IN.AA.ID, NEW.ACTIVITY.ID, VAR.ACT.EFF.DATE, "", VAR.ACT.ID, AAA.FIELDS.REC, RETURN.ERROR)

RETURN
*-----------------------------------------------------------
GET.ACCOUNT.PROPERTY:
*-----------------------------------------------------------
    IN.AA.ID = c_aalocArrId
    IN.PROPERTY.CLASS = 'ACCOUNT'
    OUT.PROPERTY = ''
    APAP.TAM.redoGetPropertyName(IN.AA.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR);* R22 Manual conversion
RETURN
*-----------------------------------------------------------
GET.MATURITY.DATE:
*-----------------------------------------------------------

    EFF.DATE = ''
    PROP.CLASS='TERM.AMOUNT'
    PROPERTY = ''
    R.CONDITION.TERM.AMOUNT = ''
    ERR.MSG = ''
    VAR.ID = c_aalocArrId
    APAP.AA.redoCrrGetConditions(VAR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.TERM.AMOUNT,ERR.MSG);* R22 Manual conversion
    Y.MATURITY.DATE = R.CONDITION.TERM.AMOUNT<AA.AMT.MATURITY.DATE>

RETURN
*---------------------------------------------------------------
UPDATE.PAYOFF.DATE:
*---------------------------------------------------------------
* This is for B.43 Letter's.
    Y.ID = c_aalocLinkedAccount
    Y.VALUE = c_aalocArrId:"-":c_aalocActivityEffDate
    R.REDO.LOAN.PAYOFF.DATE = Y.VALUE
    CALL F.WRITE(FN.REDO.LOAN.PAYOFF.DATE,Y.ID,R.REDO.LOAN.PAYOFF.DATE)

RETURN
*-----------------------------------------------------------------
REVERSE.INSURANCE:
*-----------------------------------------------------------------

    IF Y.PAYOFF.ACTIVITY THEN
**LOCATE AA$CURR.ACTIVITY IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN
******Manual Code Conversion*******
        LOCATE c_aalocCurrActivity IN Y.PAYOFF.ACTIVITY<1,1> SETTING POS.PA THEN
            GOSUB PROCESS.REVERSAL
        END
    END

RETURN
*-----------------------------------------------------------------
PROCESS.REVERSAL:
*-----------------------------------------------------------------
    ARR.ID = c_aalocArrId
    GOSUB GET.INSURANCE.POL.NO
    IF Y.INSURANCE.ARRAY EQ '' THEN
        RETURN
    END
    Y.PROCESSED.CHARGE.PROP = ''
    Y.CHRG.PROPERTY = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,'CHARGE',R.OUT.AA.RECORD,Y.CHRG.PROPERTY,OUT.ERR);* R22 Manual conversion
    Y.PROPERTY.LIST = Y.CHRG.PROPERTY
    Y.CHARGE.PROP.CNT = DCOUNT(Y.PROPERTY.LIST,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.CHARGE.PROP.CNT

        EFF.DATE = ''
        PROP.CLASS = 'CHARGE'
        PROPERTY = Y.PROPERTY.LIST<Y.VAR1>
        R.CONDITION.CHARGE = ''
        ERR.MSG = ''
        APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.CHARGE,ERR.MSG);* R22 Manual conversion
        Y.POLICY.NO = ''
        Y.POLICY.NO = R.CONDITION.CHARGE<AA.CHG.LOCAL.REF,POS.POL.NUMBER>

        IF Y.POLICY.NO THEN
            GOSUB WRITE.INSURANCE.DETAILS
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN

*---------------------------------------------------------------------------------
WRITE.INSURANCE.DETAILS:
*---------------------------------------------------------------------------------

    Y.POLICY.NO.CNT = DCOUNT(Y.POLICY.NO,@SM) ;*AUTO R22 CODE CONVERSION
    Y.VAR2 = 1

    LOOP
    WHILE Y.VAR2 LE Y.POLICY.NO.CNT

        Y.POL.NO = Y.POLICY.NO<1,1,Y.VAR2>
        LOCATE Y.POL.NO IN Y.INSURANCE.ARRAY<2,1> SETTING POS.INS THEN
            Y.INSURANCE.ID = Y.INSURANCE.ARRAY<1,POS.INS>
            CALL F.READ(FN.APAP.H.INSURANCE.DETAILS,Y.INSURANCE.ID,R.INSURANCE.DETAILS,F.APAP.H.INSURANCE.DETAILS,INSURANCE.ERR)

            IF R.INSURANCE.DETAILS THEN
                R.INSURANCE.DETAILS<INS.DET.POLICY.STATUS> = 'VIGENTE'
*CALL F.WRITE(FN.APAP.H.INSURANCE.DETAILS,Y.INSURANCE.ID,R.INSURANCE.DETAILS)
                WRITE R.INSURANCE.DETAILS TO F.APAP.H.INSURANCE.DETAILS,Y.INSURANCE.ID
                GOSUB POST.OFS
            END
        END

        Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*---------------------------------------------------
POST.OFS:
*---------------------------------------------------

    Y.CHG = R.INSURANCE.DETAILS<INS.DET.CHARGE>
    LOCATE Y.CHG IN Y.PROCESSED.CHARGE.PROP<1> SETTING POS1 THEN
        RETURN
    END ELSE
        Y.PROCESSED.CHARGE.PROP<-1> = Y.CHG
    END

*Y.ACT = 'LENDING-CHANGE-':Y.CHG
    Y.ACT = 'REDO.CANCEL.POLICY'

    Y.AAA.REQ<AA.ARR.ACT.ARRANGEMENT> = ARR.ID
    Y.AAA.REQ<AA.ARR.ACT.ACTIVITY> = Y.ACT
    Y.AAA.REQ<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
    Y.AAA.REQ<AA.ARR.ACT.PROPERTY,1> = Y.CHG
    Y.AAA.REQ<AA.ARR.ACT.FIELD.NAME,1,1> = 'STATUS.POLICY'
    Y.AAA.REQ<AA.ARR.ACT.FIELD.VALUE,1,1> = 'VIGENTE'

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    IN.FUNCTION = 'I'
    VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ZERO.AUTH'

    CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, Y.AAA.REQ, PROCESS.MSG)

    OFS.MSG.ID = ''
    OFS.SOURCE = 'TRIGGER.INSURANCE'
    OFS.ERR = ''

    CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)

RETURN
*----------------------------------------------
GET.INSURANCE.POL.NO:
*----------------------------------------------
    Y.INSURANCE.ARRAY = ''
    SEL.CMD = 'SELECT ':FN.APAP.H.INSURANCE.DETAILS:' WITH ASSOCIATED.LOAN EQ ':ARR.ID
    SEL.LIST = ''
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)
    Y.VAR3 = 1
    LOOP
    WHILE Y.VAR3 LE SEL.NOR
        Y.INS.ID = SEL.LIST<Y.VAR3>
        CALL F.READ(FN.APAP.H.INSURANCE.DETAILS,Y.INS.ID,R.INSURANCE,F.APAP.H.INSURANCE.DETAILS,INS.ERR)
        IF R.INSURANCE<INS.DET.POLICY.NUMBER> THEN
            Y.INSURANCE.ARRAY<1,-1> = Y.INS.ID
            Y.INSURANCE.ARRAY<2,-1> = R.INSURANCE<INS.DET.POLICY.NUMBER>
        END
        Y.VAR3 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT


RETURN
END
