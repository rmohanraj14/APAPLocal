* @ValidationCode : MjozMDkzNjI5Njg6Q3AxMjUyOjE2ODU1MzE3OTUzNDM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:46:35
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
$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.POST.UPDATE.RESTRUCTURED
*----------------------------------------------------------------------
*Description: This routine is to update the loan with Normal status
*             when the 3 consecutive bills has been paid by client
*             after the loan has been marked as restructured.
*--------------------------------------------------------------------------------
*Modification History
* Date           Who                 Reference                                       Descripition
* 29-03-2023   Conversion Tool        Auto R22 Code Conversion                     VM TO @VM, SM TO @SM
* 29-03-2023     Samaran T            Manual R22 code conversion                  Package Name Added APAP.AA,CALL method format changed
*--------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $USING APAP.TAM

    IF c_aalocActivityStatus MATCHES 'UNAUTH':@VM:'UNAUTH-CHG' AND c_aalocArrActivityId EQ c_aalocArrActivityRec<AA.ARR.ACT.MASTER.AAA> THEN ;*AUTO R22 CODE CONVERSION
        GOSUB PROCESS
    END

RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------

    GOSUB GET.LOCAL.REF.POS     ;* Get the multi get local ref position.
    GOSUB GET.OVERDUE.DETAILS   ;* Get the overdue condition details for the loan.

    IF Y.LOAN.STATUS EQ 'Restructured' THEN
        GOSUB PROCESS.RESTRUCT    ;* Restructure process begins here.
    END

RETURN
*-----------------------------------------------------------------------------

*** <region name= GET.OVERDUE.DETAILS>
GET.OVERDUE.DETAILS:
*** <desc>Get the overdue condition details for the loan.</desc>

    EFF.DATE         = c_aalocActivityEffDate
    PROP.CLASS       = 'OVERDUE'
    PROPERTY         = ''
    ERR.MSG          = ''
    R.OVERDUE.COND   = ''
    APAP.AA.redoCrrGetConditions(c_aalocArrId,EFF.DATE,PROP.CLASS,PROPERTY,R.OVERDUE.COND,ERR.MSG);* R22 Manual conversion

    Y.LOAN.STATUS           = R.OVERDUE.COND<AA.OD.LOCAL.REF,POS.L.LOAN.STATUS.1,1>
    Y.LOAN.COND             = R.OVERDUE.COND<AA.OD.LOCAL.REF,POS.L.LOAN.COND>
    Y.LOAN.STATUS.CHG.DATE  = R.OVERDUE.COND<AA.OD.LOCAL.REF,POS.L.STATUS.CHG.DT,1>

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.LOCAL.REF.POS>
GET.LOCAL.REF.POS:
*** <desc>Get the multi get local ref position.</desc>

    LOC.REF.APPLICATION = "AA.PRD.DES.OVERDUE"
    LOC.REF.FIELDS      = 'L.LOAN.STATUS.1':@VM:'L.LOAN.COND':@VM:'L.STATUS.CHG.DT' ;*AUTO R22 CODE CONVERSION
    LOC.REF.POS         = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.LOAN.STATUS.1 = LOC.REF.POS<1,1>
    POS.L.LOAN.COND     = LOC.REF.POS<1,2>
    POS.L.STATUS.CHG.DT = LOC.REF.POS<1,3>


    Y.ACC.PROPERTY = ''
    OUT.ERR = ''
    APAP.TAM.redoGetPropertyName(c_aalocArrId,'ACCOUNT','',Y.ACC.PROPERTY,OUT.ERR);* R22 Manual conversion

    Y.OVERDUE.PROPERTY = ''
    OUT.ERR = ''
    APAP.TAM.redoGetPropertyName(c_aalocArrId,'OVERDUE','',Y.OVERDUE.PROPERTY,OUT.ERR);* R22 Manual conversion

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.RESTRUCT>
PROCESS.RESTRUCT:
*** <desc>Restructure process begins here.</desc>
    GOSUB OPEN.FILES  ;* Open the required files.
    GOSUB GET.RESTRUCT.DATE     ;* Get the restructed date from the concat table - REDO.AA.LOAN.UPD.STATUS</desc>
    GOSUB GET.PAID.BILL.DETAILS ;* Here we will the details like, how many bills has been repaid after the loan has been marked as restructed.</desc>
    IF Y.BILL.FLAG GE 3 THEN
        GOSUB PROCESS.SECONDARY.ACTIVITY    ;* Trigger the secondary activity to update the Loan as Normal
    END

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.RESTRUCT.DATE>
GET.RESTRUCT.DATE:
*** <desc>Get the restructed date from the concat table - REDO.AA.LOAN.UPD.STATUS</desc>

    CALL F.READ(FN.REDO.AA.LOAN.UPD.STATUS,c_aalocArrId,R.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS,ST.ERR)
    Y.RESTRUCT.DATE = R.REDO.AA.LOAN.UPD.STATUS<1>
    IF Y.RESTRUCT.DATE EQ '' THEN         ;* If that concat table is not updated then it may be a migrated contract with restruct status.
        Y.RESTRUCT.DATE = Y.LOAN.STATUS.CHG.DATE      ;* Get the loan status change date from overdue.
        IF Y.RESTRUCT.DATE ELSE
            Y.RESTRUCT.DATE = TODAY ;* In case both the fields doesnt have value, assume that is Today.
        END
    END


RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= OPEN.FILES>
OPEN.FILES:
*** <desc>Open the required files.</desc>

    FN.REDO.AA.LOAN.UPD.STATUS = 'F.REDO.AA.LOAN.UPD.STATUS'
    F.REDO.AA.LOAN.UPD.STATUS  = ''
    CALL OPF(FN.REDO.AA.LOAN.UPD.STATUS,F.REDO.AA.LOAN.UPD.STATUS)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS  = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS  = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= GET.PAID.BILL.DETAILS>
GET.PAID.BILL.DETAILS:
*** <desc>Here we will the details like, how many bills has been repaid after the loan has been marked as restructed.</desc>
    CALL F.READ(FN.AA.ACCOUNT.DETAILS,c_aalocArrId,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AAD.ERR)

    Y.BILL.FLAG          = 0
    Y.BILL.IDS           = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.BILL.PAY.DATES     = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>
    Y.BILL.PAY.DATES.CNT = DCOUNT(Y.BILL.PAY.DATES,@VM) ;*AUTO R22 CODE CONVERSION

    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.BILL.PAY.DATES.CNT
        IF Y.BILL.PAY.DATES<1,Y.VAR1> GT Y.RESTRUCT.DATE THEN
            Y.BILL.REF = Y.BILL.IDS<1,Y.VAR1>
            GOSUB CHECK.ACCOUNT.PROP.DET      ;*
        END

        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= CHECK.ACCOUNT.PROPERTY>
CHECK.ACCOUNT.PROP.DET:
***
    Y.BILL.REF.CNT = DCOUNT(Y.BILL.REF,@SM) ;*AUTO R22 CODE CONVERSION
    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.BILL.REF.CNT
        Y.BILL.ID = Y.BILL.REF<1,1,Y.VAR2>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
        LOCATE Y.ACC.PROPERTY IN R.AA.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING PROP.POS THEN
            Y.OS.PROP.AMT = R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT,PROP.POS>
            IF Y.OS.PROP.AMT ELSE   ;* If the amount is repaid
                Y.BILL.FLAG += 1 ;*AUTO R22 CODE CONVERSION
            END
        END

        Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*** </region>

*-----------------------------------------------------------------------------

*** <region name= PROCESS.SECONDARY.ACTIVITY>
PROCESS.SECONDARY.ACTIVITY:
*** <desc>Trigger the secondary activity to update the Loan as Normal</desc>

    ARR.PROPERTY.LIST            = Y.OVERDUE.PROPERTY
    ARR.FIELD.NAME.LIST          = "L.LOAN.STATUS.1":@SM:"L.STATUS.CHG.DT" ;*AUTO R22 CODE CONVERSION
    ARR.FIELD.VALUE.LIST         = "Normal":@SM:TODAY ;*AUTO R22 CODE CONVERSION
    AAA.FIELDS.REC               = ""

    CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST, ARR.FIELD.VALUE.LIST, AAA.FIELDS.REC)
    NEW.ACTIVITY.ID = "LENDING-UPDATE-":Y.OVERDUE.PROPERTY
    RETURN.ERROR = ''
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(c_aalocArrId, NEW.ACTIVITY.ID, c_aalocActivityEffDate, "", c_aalocArrActivityId, AAA.FIELDS.REC, RETURN.ERROR)

RETURN
*** </region>
END
