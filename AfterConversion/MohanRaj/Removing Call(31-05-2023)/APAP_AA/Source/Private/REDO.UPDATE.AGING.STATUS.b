* @ValidationCode : MjoxNTE0OTQ5OTQzOkNwMTI1MjoxNjg1NTMyNDQ2MDY0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:57:26
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
SUBROUTINE REDO.UPDATE.AGING.STATUS

* This Routine reads AA.ACCOUNT.DETAILS for the Arrangement, Reads Each Bill and check whether the BILL has PRINCIPAL
* component, If so then Triggers a SECONDARY activity LENDING-UPDATE-OD.STATUS to update the OD.STATUS in AA.ARR.ACCOUNT and
* ACCOUNT applications
*
* This field holds the Arrangement Ageing status hereafter
*
*
* Activity API Setup:
*
* ACTIVITY : LENDING-AGE-OVERDUE
* STAGE    : POST ROUTINE
* PROPERTY : OVERDUE
* ACTION   : AGE.BILLS
*
*
* Activity API Setup:
*
* ACTIVITY : LENDING-APPLY.PAYMENT-PAYMENT.RULES
* STAGE    : POST ROUTINE
* PROPERTY : OVERDUE
* ACTION   : CHANGE.STATUS
*
*
* Input/Output:
*----------------
*
* IN  : -NA-
* OUT : -NA-
*---------------
*
*----------------------------------------------------------------------------------------------------------------------------
*
* Modification History
*
*----------------------------------------------------------------------------------------------------------------------------
*   Date               |           Who                    |           Reference                    |          Description
*----------------------------------------------------------------------------------------------------------------------------
*
*  Apr-12                      Ravikiran AV                      ODR-2012-01-0106 (CR-44)                    Zero Principal
*  JULY -24                    MARIMUTHU S                       ODR-2012-01-0106
*  OCT-29-2012                 MARIMUTHU S                       ODR-2012-01-0106                   PACS00202156 - Modified for NAB & WOF
*  26-07-2017                  Edwin Charles D                    PACS00612295                                R15 Upgrade changes
** 29-03-2023 R22 Auto Conversion FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - CALL method format changed
*----------------------------------------------------------------------------------------------------------------------------
*
* All file INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.PROPERTY
*   $INSERT I_F.AA.ACCOUNT  ;** R22 Auto Conversion
    $INSERT I_F.USER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

*----------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
MAIN.LOGIC:



    GOSUB INITIALISE

    GOSUB PROCESS


RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Initialise all the variables
*
INITIALISE:

    R.ACCOUNT.DETAILS = c_aalocAccountDetails


    ARR.ID = c_aalocArrId


    ARR.EFF.DATE = c_aalocAccountDetails<AA.AD.START.DATE>

    R.ACCOUNT.ID = c_aalocLinkedAccount


    AGING.STATUS = ''

    LOC.REF.FIELDS = 'L.OD.STATUS':@VM:'L.OD.STATUS.2':@FM:'L.OD.STATUS':@VM:'L.OD.STATUS.2'

    LOC.REF.APP = 'ACCOUNT':@FM:'AA.PRD.DES.ACCOUNT'

    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APP, LOC.REF.FIELDS, LOC.REF.POS)

    L.OD.STATUS.POS    = LOC.REF.POS<1,1>
    L.OD.ST.2.POS      = LOC.REF.POS<1,2>
    POS.L.OD.STATUS    = LOC.REF.POS<2,1>
    POS.L.OD.STATUS.2  = LOC.REF.POS<2,2>

    GOSUB OPEN.FILES

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* List of Open Files
*
OPEN.FILES:

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.AA.PROPERTY = 'F.AA.PROPERTY'
    F.AA.PROPERTY = ''
    CALL OPF(FN.AA.PROPERTY,F.AA.PROPERTY)

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Processing Logic
*
PROCESS:

    GOSUB READ.ACCOUNT


    Y.ACTIVITY = c_aalocCurrActivity

    Y.PROPERTY = FIELD(Y.ACTIVITY,'-',3)
    Y.PROPERTY = FIELD(Y.PROPERTY,'*',1)


    CALL CACHE.READ(FN.AA.PROPERTY, Y.PROPERTY, R.PROPERTY, PROP.ERR) ;** R22 Auto Conversion
    Y.PROP.CLASS = R.PROPERTY<AA.PROP.PROPERTY.CLASS>



    IF Y.PROP.CLASS EQ 'OVERDUE' OR Y.PROP.CLASS EQ 'PAYMENT.SCHEDULE' THEN
        IF (ACC.LOAN.STATUS NE 'NAB') THEN        ;* Dont check Bills and Trigger Activity if the Arrangement is already in NAB


            GOSUB GET.BILL.INFO

            GOSUB TRIGGER.ACTIVITY

        END
* IF ACC.LOAN.STATUS EQ 'NAB' THEN
*     GOSUB TRIGGER.ACTIVITY.1
* END
    END

    IF Y.PROP.CLASS EQ 'PAYMENT.RULES' THEN


        GOSUB GET.BILL.INFO

        GOSUB TRIGGER.ACTIVITY
    END

    GOSUB PROCESS.ADJUST.SUSP.BAL

RETURN

*----------------------------------------------------------------------------------------------------------------------------
* Read account record to get the Arrangement OD status
*
READ.ACCOUNT:
*CALL F.READ(FN.ACCOUNT, R.ACCOUNT.ID, R.ACCOUNT.REC, F.ACCOUNT, ACC.ERR)

    EFF.DATE         = c_aalocActivityEffDate
    PROP.CLASS       = 'ACCOUNT'
    PROPERTY         = ''
    R.CONDITION.ACC  = ''
    ERR.MSG          = ''



    APAP.AA.redoCrrGetConditions(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.ACC,ERR.MSG);* R22 Manual conversion


    ACC.LOAN.STATUS   = R.CONDITION.ACC<AA.AC.LOCAL.REF,POS.L.OD.STATUS>
    ACC.LOAN.STATUS.2 = R.CONDITION.ACC<AA.AC.LOCAL.REF,POS.L.OD.STATUS.2>

*ACC.LOAN.STATUS = R.ACCOUNT.REC<AC.LOCAL.REF, L.OD.STATUS.POS>
*ACC.LOAN.STATUS.2 = R.ACCOUNT.REC<AC.LOCAL.REF,L.OD.ST.2.POS>

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Get the BILLS which are UNPAID
*
GET.BILL.INFO:

    Y.ALL.NTST = ''

    ARR.BILL.IDS = R.ACCOUNT.DETAILS<AA.AD.BILL.ID>         ;* Get the Arrangement BILL ids
    ARR.BILL.STATUS = R.ACCOUNT.DETAILS<AA.AD.BILL.STATUS>  ;* Get the Bill Status for the corresponding BILLS
    ARR.BILL.TYPE = R.ACCOUNT.DETAILS<AA.AD.BILL.TYPE>      ;* Get the Bill Type, Coz only the Scheduled BILLS are aged



    CHANGE @VM TO @FM IN ARR.BILL.IDS
    CHANGE @SM TO @FM IN ARR.BILL.IDS

    CHANGE @VM TO @FM IN ARR.BILL.STATUS
    CHANGE @SM TO @FM IN ARR.BILL.STATUS

    CHANGE @VM TO @FM IN ARR.BILL.TYPE
    CHANGE @SM TO @FM IN ARR.BILL.TYPE


    BILL.COUNT = DCOUNT(ARR.BILL.IDS, @FM)

*FOR BILL = 1 TO BILL.COUNT          ;* Loop thru each BILL
    BILL = 1
    BREAK.UP = 0

    LOOP
    WHILE (BILL LE BILL.COUNT) AND (BREAK.UP NE 1) DO

        IF ARR.BILL.STATUS<BILL> NE 'SETTLED' AND ARR.BILL.TYPE<BILL> EQ 'PAYMENT' THEN   ;* Check whether the BILL is in UNPAID status. The first BILL would be the worst aging status


            AGING.STATUS = ''
            GOSUB GET.BILL.DETAILS

            IF (AGING.STATUS) THEN

                BREAK.UP = 1  ;* Break the FOR Loop. No need to loop other bills. We have already got the worst aging status
                Y.ALL.NTST = 'YES'

            END

        END

        BILL += 1 ;** R22 Auto Conversion

    REPEAT
*NEXT BILL


    IF Y.ALL.NTST EQ '' THEN
        IF NOT(AGING.STATUS) OR ACC.LOAN.STATUS NE 'CUR' THEN         ;*If No ageing status is available for the arrangement, then default it to CUR
            GOSUB GET.ACCOUNT.PROPERTY
            AGING.STATUS = 'CUR'
            AGING.STATUS.2 = 'CUR'

        END
    END


    IF Y.ALL.NTST EQ 'YES' THEN
        IF AGING.STATUS EQ 'NAB' THEN
            AGING.STATUS.2 = 'NAB'
        END
        IF NOT(AGING.STATUS.2) THEN
            GOSUB GET.STATUS.2
        END
    END


RETURN

GET.STATUS.2:

    Y.LATEST.BILL = ARR.BILL.IDS<BILL.COUNT>
    GOSUB GET.ACCOUNT.PROPERTY
    BILL -= 1 ;** R22 Auto Conversion

    LOOP
    WHILE BILL LE BILL.COUNT DO
        BILL += 1 ;** R22 Auto Conversion
        IF ARR.BILL.STATUS<BILL> NE 'SETTLED' AND ARR.BILL.TYPE<BILL> EQ 'PAYMENT' THEN
            AGING.STATUS.2 = ''
            Y.BL.BILL = ARR.BILL.IDS<BILL>
            CALL F.READ(FN.AA.BILL.DETAILS,Y.BL.BILL,R.BL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
            IF R.BL.DETAILS THEN        ;*PACS00687323
                GOSUB GET.PERF.ST
            END     ;*PACS00687323
        END
    REPEAT

    IF AGING.STATUS.2 EQ '' THEN
        AGING.STATUS.2 = AGING.STATUS
    END

RETURN

GET.PERF.ST:

    LOCATE ACC.PROPERTY IN R.BL.DETAILS<AA.BD.PROPERTY,1> SETTING  ACC.POS THEN


        Y.AGE.ST = R.BL.DETAILS<AA.BD.AGING.STATUS,1>


        IF NOT(Y.AGE.ST) THEN
            AGING.STATUS.2 = 'CUR'
        END ELSE
            IF Y.AGE.ST EQ 'SETTLED' THEN
                AGING.STATUS.2 = 'CUR'
            END ELSE
                AGING.STATUS.2 = Y.AGE.ST
            END
        END
        BILL = BILL.COUNT + 1
    END ELSE
        AGING.STATUS.2 = 'CUR'
    END

RETURN

*-----------------------------------------------------------------------------------------------------------------------------
* Get the BILL Information to get the worst AGING status
*
GET.BILL.DETAILS:

    BILL.ID = ARR.BILL.IDS<BILL>


    CALL F.READ(FN.AA.BILL.DETAILS, BILL.ID, R.BILL.DETAILS, F.AA.BILL.DETAILS, RET.ERR)

    GOSUB GET.ACCOUNT.PROPERTY

    LOCATE ACC.PROPERTY IN R.BILL.DETAILS<AA.BD.PROPERTY,1> SETTING  ACC.POS THEN

        AGING.STATUS = R.BILL.DETAILS<AA.BD.AGING.STATUS,1> ;* This has the worst aging status

        IF AGING.STATUS EQ 'SETTLED' THEN
*            AGING.STATUS = 'CUR'                ;*PACS00687323
            AGING.STATUS = '' ;*PACS00687323
        END

    END


RETURN
*------------------------------------------------------------------------------------------------------------------------------
* Get the Account Property Used
*
GET.ACCOUNT.PROPERTY:

    ARR.INFO<1> = ARR.ID

    R.ARRANGEMENT = ''

    Y.EFF.DATE = ARR.EFF.DATE

    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)

    CLASS.LIST = ''

    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)       ;* Find their Property classes

    CLASS.LIST = RAISE(CLASS.LIST)

    PROP.LIST = RAISE(PROP.LIST)

    CLASS.CTR = ''

    LOOP

        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS

        CLASS.CTR +=1

    WHILE Y.CLASS:CLASS.POS AND PROP.BREAKUP NE '1'

        IF Y.CLASS EQ "ACCOUNT"  THEN

            ACC.PROPERTY = PROP.LIST<CLASS.CTR>   ;*Get the account property

            PROP.BREAKUP = 1

        END

    REPEAT

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Update the Arrangement Account With respective Aging status using a Secondary Activity
*
TRIGGER.ACTIVITY:


    IF (AGING.STATUS) AND ((AGING.STATUS NE ACC.LOAN.STATUS) OR (AGING.STATUS.2 NE ACC.LOAN.STATUS.2)) THEN   ;* Dont trigger activity if the Aging status is already updated

        ARR.PROPERTY.LIST = ACC.PROPERTY

        ARR.FIELD.NAME.LIST = 'L.OD.STATUS:1:1':@SM:'L.OD.STATUS.2:1:1'


        ARR.FIELD.VALUE.LIST = AGING.STATUS:@SM:AGING.STATUS.2


        AAA.FIELDS.REC = ''

        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST,  ARR.FIELD.VALUE.LIST,  AAA.FIELDS.REC)

        NEW.ACTIVITY.ID = 'LENDING-UPDATE-OD.STATUS'

        RETURN.ERROR = ''

* Trigger LENDING-UPDATE-OD.STATUS as Secondary Activity

        Y.AC.DATE = c_aalocActivityEffDate
        Y.ACCT.ID = c_aalocArrActivityId
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)


    END

RETURN

TRIGGER.ACTIVITY.1:

    ARR.PROPERTY.LIST = 'ACCOUNT'

    ARR.FIELD.NAME.LIST = 'L.OD.STATUS:1:1':@SM:'L.OD.STATUS.2:1:1'

    ARR.FIELD.VALUE.LIST = 'NAB':@SM:'NAB'

    AAA.FIELDS.REC = ''

    CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST,  ARR.FIELD.VALUE.LIST,  AAA.FIELDS.REC)

    NEW.ACTIVITY.ID = 'LENDING-UPDATE-OD.STAT'

    RETURN.ERROR = ''


    Y.AC.DATE = c_aalocActivityEffDate
    Y.ACCT.ID = c_aalocArrActivityId
    CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)

RETURN

PROCESS.ADJUST.SUSP.BAL:
*-----------------------
    Y.CURR.DATE = TODAY
    Y.AC.DATE = c_aalocActivityEffDate
    Y.ACCT.ID = c_aalocArrActivityId
    Y.ACTIVITY = c_aalocCurrActivity
    Y.ACT.STATUS = c_aalocActivityStatus
    Y.BALANCE.TYPE     = 'AASUSPENSE'
    Y.REQUEST.DATE.LAST= ''
    Y.BALANCE.AMOUNT.LAST = ''
    Y.ACTIVITY.ACTION = ''
    Y.ACTIVITY.ACTION = FIELD(Y.ACTIVITY,'-',2)
    CALL AA.GET.ECB.BALANCE.AMOUNT(R.ACCOUNT.ID,Y.BALANCE.TYPE,Y.REQUEST.DATE.LAST,Y.BALANCE.AMOUNT.LAST,Y.RET.ERROR)
    IF Y.AC.DATE LT Y.CURR.DATE AND Y.ACTIVITY.ACTION EQ 'APPLYPAYMENT' AND Y.ACT.STATUS EQ 'AUTH-REV' THEN
        NEW.ACTIVITY.ID = 'LENDING-ADJUST.SUSP.BALANCE-MANT.SALD.CUOTA'
        RETURN.ERROR = ''
        AAA.REQUEST<AA.ARR.ACT.ARRANGEMENT> = ARR.ID
        AAA.REQUEST<AA.ARR.ACT.ACTIVITY> = 'LENDING-ADJUST.SUSP.BALANCE-MANT.SALD.CUOTA'
        AAA.REQUEST<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
        APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
        IN.FUNCTION = 'I'
        VERSION.NAME = 'AA.ARRANGEMENT.ACTIVITY,ZERO.AUTH'

        CALL OFS.BUILD.RECORD(APP.NAME, IN.FUNCTION, "PROCESS", VERSION.NAME, "", "0", AAA.ID, AAA.REQUEST, PROCESS.MSG)          ;*Form the OFS Message
        OFS.MSG.ID = ''
        OFS.SOURCE = 'FT.UNC.CK'
        OFS.ERR = ''

        CALL OFS.POST.MESSAGE(PROCESS.MSG,OFS.MSG.ID,OFS.SOURCE,OFS.ERR)


    END
RETURN
*----------------------------------------------------------------------------------------------------------------------------

*----------------------------------------------------------------------------------------------------------------------------
END
