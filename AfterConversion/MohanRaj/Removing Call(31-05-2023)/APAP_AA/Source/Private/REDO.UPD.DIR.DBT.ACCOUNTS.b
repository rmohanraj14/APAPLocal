* @ValidationCode : MjotNTYwNzk0MTI2OkNwMTI1MjoxNjg1NTMyMzU2MjM2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:55:56
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
SUBROUTINE REDO.UPD.DIR.DBT.ACCOUNTS
*---------------------------------------------
*Description: This Post activity api routine will update the
*             concat table REDO.DIRECT.DEBIT.ACCOUNTS with the
*             arrangement  details
** 29-03-2023 Conversion Tool R22 Auto Conversion   FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion CALL method format changed
*---------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ID.COMPONENT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $USING APAP.TAM

    IF c_aalocActivityStatus MATCHES 'AUTH':@VM:'AUTH-REV' THEN
        GOSUB PROCESS
    END
    IF c_aalocActivityStatus EQ 'UNAUTH' THEN
        GOSUB PROCESS.VALIDATION
    END
RETURN
*---------------------------------------------
PROCESS.VALIDATION:
*---------------------------------------------
    GOSUB INITIALISE

    IF R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.PAY.METHD> EQ 'Direct Debit' AND R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> EQ '' THEN
        AF = AA.PS.LOCAL.REF
        AV = POS.L.AA.DEBT.AC
        ETEXT = 'AA-DEBIT.AC'
        CALL STORE.END.ERROR
    END

    IF R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.PAY.METHD> NE 'Direct Debit' AND R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> NE '' THEN
        AF = AA.PS.LOCAL.REF
        AV = POS.L.AA.DEBT.AC
        ETEXT = 'AA-DEBIT.AC'
        CALL STORE.END.ERROR
    END
RETURN

*---------------------------------------------
PROCESS:
*---------------------------------------------
    IF c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> MATCHES 'LENDING-NEW-ARRANGEMENT':@VM:'LENDING-TAKEOVER-ARRANGEMENT' THEN
        GOSUB PROCESS.NEW         ;* Here we needs to update the concat for new and migrated loans
    END
    IF c_aalocArrActivityRec<AA.ARR.ACT.ACTIVITY.CLASS> MATCHES 'LENDING-CHANGE-PAYMENT.SCHEDULE' THEN
        GOSUB PROCESS.MODIFICATION          ;* Here we need to handle the process of modification of direct debit accounts
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= PROCESS.NEW>
PROCESS.NEW:
*** <desc>Here we needs to update the concat for new and migrated loans.</desc>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE  ;* Here we need to initiaze the required variables
    IF R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.PAY.METHD> EQ 'Direct Debit' AND R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> NE '' ELSE
        RETURN          ;* Exit from the routine
    END

    Y.DD.DEBIT.ACC = R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC>
    CALL F.READU(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.DD.DEBIT.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,CNCT.ERR,"")
    LOCATE c_aalocArrId IN R.REDO.DIRECT.DEBIT.ACCOUNTS<1> SETTING ACC.POS ELSE
        R.REDO.DIRECT.DEBIT.ACCOUNTS<-1> = c_aalocArrId
        CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.DD.DEBIT.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS)
    END
    CALL F.READ(FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,c_aalocArrId,R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,F.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,DET.ERR)
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<1,-1> = c_aalocArrActivityId
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<2,-1> = c_aalocActivityEffDate
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<3,-1> = OPERATOR
    CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,c_aalocArrId,R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS)
    CALL F.RELEASE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.DD.DEBIT.ACC,F.REDO.DIRECT.DEBIT.ACCOUNTS)
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= PROCESS.MODIFICATION>
PROCESS.MODIFICATION:
*** <desc>Here we need to handle the process of modification of direct debit accounts.</desc>
*-----------------------------------------------------------------------------
    GOSUB INITIALISE  ;* Here we need to initiaze the required variables

    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB PROCESS.MODIFY.AUTH ;* Modification of authorization
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        GOSUB PROCESS.MODIFY.REVERSE        ;* Here we will handle the reversal of Change Payment schedule activity
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= INITIALISE>
INITIALISE:
*** <desc>Here we need to initiaze the required variables.</desc>
*-----------------------------------------------------------------------------

    FN.REDO.DIRECT.DEBIT.ACCOUNTS = 'F.REDO.DIRECT.DEBIT.ACCOUNTS'
    F.REDO.DIRECT.DEBIT.ACCOUNTS  = ''
    CALL OPF(FN.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS)

    FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS = 'F.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS'          ;* This template is for report Presn1.
    F.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS  = ''
    CALL OPF(FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,F.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS)

    LOC.REF.APPLICATION           = "AA.PRD.DES.PAYMENT.SCHEDULE"
    LOC.REF.FIELDS                = 'L.AA.PAY.METHD':@VM:'L.AA.DEBT.AC'
    LOC.REF.POS                   = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.PAY.METHD = LOC.REF.POS<1,1>
    POS.L.AA.DEBT.AC   = LOC.REF.POS<1,2>

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MODIFY.AUTH>
PROCESS.MODIFY.AUTH:
*** <desc>Modification of authorization.</desc>
*-----------------------------------------------------------------------------
    IF R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> NE R.OLD(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> THEN
        GOSUB PROCESS.MODIFY.DD.AUTH        ;* Here we handle the modification of DD account using change payment schedule activity
    END
RETURN
*** </region>
*-----------------------------------------------------------------------------

*** <region name= PROCESS.MODIFY.DD.AUTH>
PROCESS.MODIFY.DD.AUTH:
*** <desc>Here we handle the modification of DD account using change payment schedule activity.</desc>
    Y.OLD.DD.ACC = R.OLD(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC>
    IF Y.OLD.DD.ACC THEN
        CALL F.READU(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,CNCT.ERR,"")
        LOCATE c_aalocArrId IN R.REDO.DIRECT.DEBIT.ACCOUNTS<1> SETTING ACC.POS THEN
            DEL R.REDO.DIRECT.DEBIT.ACCOUNTS<ACC.POS>
            CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS)
        END
        CALL F.RELEASE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,F.REDO.DIRECT.DEBIT.ACCOUNTS)
    END
    Y.NEW.DD.ACC = R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC>
    IF Y.NEW.DD.ACC THEN
        CALL F.READU(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,CNCT.ERR,"")
        LOCATE c_aalocArrId IN R.REDO.DIRECT.DEBIT.ACCOUNTS<1> SETTING ACC.POS ELSE
            R.REDO.DIRECT.DEBIT.ACCOUNTS<-1> = c_aalocArrId
            CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS)
        END
        CALL F.RELEASE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,F.REDO.DIRECT.DEBIT.ACCOUNTS)
    END
    CALL F.READ(FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,c_aalocArrId,R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,F.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,DET.ERR)
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<1,-1> = c_aalocArrActivityId
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<2,-1> = c_aalocActivityEffDate
    R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS<3,-1> = OPERATOR
    CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS,c_aalocArrId,R.REDO.DIRECT.DEBIT.ACCOUNTS.DETAILS)
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MODIFY.REVERSE>
PROCESS.MODIFY.REVERSE:
*** <desc>Here we will handle the reversal of Change Payment schedule activity</desc>
*-----------------------------------------------------------------------------
    GOSUB GET.PREVIOUS.CONDITION          ;* Here we will get the previous condition record
    IF R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC> NE R.PROPERTY.COND<AA.PS.LOCAL.REF,POS.L.AA.DEBT.AC> THEN
        GOSUB PROCESS.MODIFY.DD.REV         ;* Here we handle Modification of the Payment Schedule is reversed
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.MODIFY.DD.REV>
PROCESS.MODIFY.DD.REV:
*** <desc>Here we handle Modification of the Payment Schedule is reversed.</desc>
*-----------------------------------------------------------------------------
    Y.NEW.DD.ACC = R.PROPERTY.COND<AA.PS.LOCAL.REF,POS.L.AA.DEBT.AC>
    IF Y.NEW.DD.ACC THEN
        CALL F.READU(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,CNCT.ERR,"")
        LOCATE c_aalocArrId IN R.REDO.DIRECT.DEBIT.ACCOUNTS<1> SETTING ACC.POS ELSE
            R.REDO.DIRECT.DEBIT.ACCOUNTS<-1> = c_aalocArrId
            CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS)
        END
        CALL F.RELEASE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.NEW.DD.ACC,F.REDO.DIRECT.DEBIT.ACCOUNTS)
    END
    Y.OLD.DD.ACC = R.NEW(AA.PS.LOCAL.REF)<1,POS.L.AA.DEBT.AC>
    IF Y.OLD.DD.ACC THEN
        CALL F.READU(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS,F.REDO.DIRECT.DEBIT.ACCOUNTS,CNCT.ERR,"")
        LOCATE c_aalocArrId IN R.REDO.DIRECT.DEBIT.ACCOUNTS<1> SETTING ACC.POS THEN
            DEL R.REDO.DIRECT.DEBIT.ACCOUNTS<ACC.POS>
            CALL F.WRITE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,R.REDO.DIRECT.DEBIT.ACCOUNTS)
        END
        CALL F.RELEASE(FN.REDO.DIRECT.DEBIT.ACCOUNTS,Y.OLD.DD.ACC,F.REDO.DIRECT.DEBIT.ACCOUNTS)
    END
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.PREVIOUS.CONDITION>
GET.PREVIOUS.CONDITION:
*** <desc>Here we will get the previous condition record.</desc>

    OPTION=''
    PROPERTY.CLASS='PAYMENT.SCHEDULE'
    EFFECTIVE.DATE=''
    R.PROPERTY=''
    RET.ERROR=''
    APAP.TAM.redoGetPropertyName(c_aalocArrId,PROPERTY.CLASS,R.OUT.AA.RECORD,ARR.PROPERTY.ID,OUT.ERR);* R22 Manual conversion
    ID.COMPONENT = ""
    ID.COMPONENT<AA.IDC.ARR.NO>  = c_aalocArrId
    ID.COMPONENT<AA.IDC.PROPERTY>= ARR.PROPERTY.ID
    ID.COMPONENT<AA.IDC.EFF.DATE>= ''

    CALL AA.GET.PREVIOUS.PROPERTY.RECORD(OPTION, PROPERTY.CLASS, ID.COMPONENT, EFFECTIVE.DATE, R.PROPERTY.COND, RET.ERROR)

RETURN
*** </region>
END
