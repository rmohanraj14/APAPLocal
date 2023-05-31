$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.LOAN.STATUS.UPDATE
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL        AUTO R22 CODE CONVERSION            SM TO @SM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA

*-----------------------------------------------------------------------------------

    

*
* This routine updates the local field L.OD.STATUS in AA.ARR.ACCOUNT with CUR when an arrangement is created
*
* Activity API Setup:
*
* ACTIVITY : LENDING-NEW-ARRANGEMENT
* WHEN     : POST ROUTINE
* PROPERTY : ACCOUNT
* ACTION   : MAINTAIN
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
*
*
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

*----------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
MAIN.LOGIC:


    IF (c_aalocActivityStatus EQ 'UNAUTH') THEN

        GOSUB INITIALISE

        GOSUB PROCESS

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Initialise all the variables
*
INITIALISE:

    R.ACCOUNT.DETAILS = c_aalocAccountDetails

    ARR.ID = c_aalocArrId

    ARR.EFF.DATE = c_aalocActivityEffDate

    R.ACCOUNT.ID = c_aalocLinkedAccount

    AGING.STATUS = ''

    LOC.REF.FIELDS = 'L.OD.STATUS'

    LOC.REF.APP = 'ACCOUNT'

    LOC.REF.POS = ''

    CALL MULTI.GET.LOC.REF(LOC.REF.APP, LOC.REF.FIELDS, LOC.REF.POS)

    L.OD.STATUS.POS = LOC.REF.POS<1,1>

    GOSUB OPEN.FILES

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* List of Open Files
*
OPEN.FILES:

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Processing Logic
*
PROCESS:

    GOSUB GET.LOAN.STATUS

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Get / Populate the Loan Status
*
GET.LOAN.STATUS:

    CALL F.READ(FN.ACCOUNT, R.ACCOUNT.ID, R.ACCOUNT.REC, F.ACCOUNT, ACC.ERR)

    ACC.LOAN.STATUS = R.ACCOUNT.REC<AC.LOCAL.REF, L.OD.STATUS.POS>


    IF NOT(ACC.LOAN.STATUS) THEN          ;* If L.OD.STATUS is present then don't trigger the Activity

        AGING.STATUS = 'CUR'      ;* After Disbursement the Arrangement Status would be CUR

        GOSUB TRIGGER.ACTIVITY

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Update the Arrangement Account With CUR using a Secondary Activity
*
TRIGGER.ACTIVITY:

    IF (AGING.STATUS) THEN

        GOSUB GET.ACCOUNT.PROPERTY

        ARR.PROPERTY.LIST = ACC.PROPERTY

        ARR.FIELD.NAME.LIST = 'L.OD.STATUS:1:1':@SM:'L.OD.STATUS.2:1:1' ;*AUTO R22 CODE CONVERSION

        ARR.FIELD.VALUE.LIST = AGING.STATUS:@SM:AGING.STATUS ;*AUTO R22 CODE CONVERSION

        AAA.FIELDS.REC = ''

        CALL AA.GEN.ARRANGEMENT.ACTIVITY.FIELDS(ARR.PROPERTY.LIST, ARR.FIELD.NAME.LIST,  ARR.FIELD.VALUE.LIST,  AAA.FIELDS.REC)

        NEW.ACTIVITY.ID = 'LENDING-UPDATE-OD.STATUS'

        RETURN.ERROR = ''

* Trigger LENDING-UPDATE-OD.STATUS as Secondary Activity to the Disbursement Activity

        Y.AC.DATE = c_aalocActivityEffDate
        Y.ACCT.ID = c_aalocArrActivityId
        CALL AA.GEN.NEW.ARRANGEMENT.ACTIVITY(ARR.ID, NEW.ACTIVITY.ID, Y.AC.DATE, "", Y.ACCT.ID, AAA.FIELDS.REC, RETURN.ERROR)

    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Get the Account Property Used
*
GET.ACCOUNT.PROPERTY:

    ARR.INFO<1> = ARR.ID

    R.ARRANGEMENT = ''

    Y.EFF.DATE = ARR.EFF.DATE

    CALL AA.GET.ARRANGEMENT.PROPERTIES(ARR.INFO, Y.EFF.DATE, R.ARRANGEMENT, PROP.LIST)

    CLASS.LIST = ''

    CALL AA.GET.PROPERTY.CLASS(PROP.LIST, CLASS.LIST)         ;* Find their Property classes

    CLASS.LIST = RAISE(CLASS.LIST)

    PROP.LIST = RAISE(PROP.LIST)

    CLASS.CTR = ''

    LOOP

        REMOVE Y.CLASS FROM CLASS.LIST SETTING CLASS.POS

        CLASS.CTR +=1

    WHILE Y.CLASS:CLASS.POS AND PROP.BREAKUP NE '1'

        IF Y.CLASS EQ "ACCOUNT" THEN

            ACC.PROPERTY = PROP.LIST<CLASS.CTR>         ;*Get the account property

            PROP.BREAKUP = 1

        END

    REPEAT

RETURN
*----------------------------------------------------------------------------------------------------------------------------

END
