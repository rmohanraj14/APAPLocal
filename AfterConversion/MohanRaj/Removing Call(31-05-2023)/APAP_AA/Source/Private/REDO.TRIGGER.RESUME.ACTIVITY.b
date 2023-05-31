* @ValidationCode : MjotOTYzOTc2NjExOkNwMTI1MjoxNjgwMDcxMDc3OTk5OklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:37
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
SUBROUTINE REDO.TRIGGER.RESUME.ACTIVITY

*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Temenos Application Management
*Program   Name    :REDO.TRIGGER.RESUME.ACTIVITY
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to trigger RESUME activity when
*                   the Arrangement is suspended
*LINKED WITH       :REPAYMENT VERSION ATTACHED TO AA
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
* 20 AUG 2010    Ravikiran AV                  B.51          Initial Creation
*
*** 29-03-2023 R22 Auto Conversion 
** 29-03-2023 Skanda R22 Manual Conversion - No changes
*--------------------------------------------------------------------------------------------------------
* All File INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_AA.ACTION.CONTEXT

*--------------------------------------------------------------------------------------------------------------------
*Main Logic of the routine
*
MAIN.LOGIC:

    IF (c_aalocActivityStatus EQ 'AUTH') THEN

        GOSUB INITIALISE
        GOSUB CHK.REQD.INFO

    END

RETURN
*------------------------------------------------------------------------------------------------------------------
*Initialisation of Variables
*
INITIALISE:

    OFS.MSG = ''
    R.APP.RECORD = ''
    OFS.STRING = ''
    ARR.ID = c_aalocArrId
    R.ACC.DETAILS = c_aalocAccountDetails
    PRODUCT.ID = c_aalocArrProductId

RETURN
*-----------------------------------------------------------------------------------------------------------------------
* This checks whether the arrangement is repaid and its status is again set to accrued
*
CHK.REQD.INFO:

    ARRANGEMENT.STATUS = R.ACC.DETAILS<AA.AD.ARR.AGE.STATUS>

    CALL AA.GET.ARRANGEMENT.CONDITIONS(ARR.ID, 'OVERDUE','','', RET.IDS, OD.COND, RET.ERR)

    OD.COND = RAISE(OD.COND)

    IF R.ACC.DETAILS<AA.AD.SUSP.STATUS> EQ 'SUSPEND' THEN     ;*Check if the arrangement is suspended

        GOSUB TRIGGER.RESUME.ACTIVITY

    END

RETURN
*--------------------------------------------------------------------------------------------------------------------------
* This has the Business logic to trigger resume activity
*
TRIGGER.RESUME.ACTIVITY:

    IF (ARRANGEMENT.STATUS EQ 'CUR') THEN ;* There are NO Bills to recalculate ageing, so trigger resume :)

        GOSUB PROCESS.RESUME

    END ELSE

        GOSUB CHECK.OD.STATUS

    END

RETURN
*--------------------------------------------------------------------------------------------------------------------
*This is checked coz, AA recalculates the Ageing Activity after repayment, If the recalculated ageing status has
*SUSPENDED 'YES' then dont trigger resume activity
*
CHECK.OD.STATUS:

    LOCATE ARRANGEMENT.STATUS IN OD.COND<AA.OD.OVERDUE.STATUS,1,1> SETTING OD.POS THEN
        IF OD.COND<AA.OD.SUSPEND,1,OD.POS> NE 'YES' THEN
            GOSUB PROCESS.RESUME
        END
    END

RETURN
*-------------------------------------------------------------------------------------------------------------------------------
* This calls the required paras to process RESUME activity OFS message
*
PROCESS.RESUME:

    GOSUB BUILD.OFS
    GOSUB PROCESS.OFS

RETURN
*----------------------------------------------------------------------------------------------------------------------------
*This forms the OFS message for RESUME activity
*
BUILD.OFS:

    APP.NAME = 'AA.ARRANGEMENT.ACTIVITY'
    OFS.SOURCE.ID = ''
    PROCESS = 'PROCESS'
    OFS.VERSION = 'AA.ARRANGEMENT.ACTIVITY,'
    OFS.FUNCTION = 'I'
    GTS.MODE = ''
    NO.OF.AUTH = '0'
    TRANSACTION.ID = ''
    OFS.MESSAGE = ''
    R.APP.RECORD<AA.ARR.ACT.ARRANGEMENT> = ARR.ID
    R.APP.RECORD<AA.ARR.ACT.ACTIVITY> = 'LENDING-RESUME-ARRANGEMENT'
    R.APP.RECORD<AA.ARR.ACT.EFFECTIVE.DATE> = TODAY
    R.APP.RECORD<AA.ARR.ACT.PRODUCT> = PRODUCT.ID

    CALL OFS.BUILD.RECORD(APP.NAME, OFS.FUNCTION, PROCESS, OFS.VERSION, GTS.MODE, NO.OF.AUTH, TRANSACTION.ID, R.APP.RECORD, OFS.MESSAGE)

RETURN
*-------------------------------------------------------------------------------------------------------------------------------------
* This Process triggers the RESUME activity for the arrangement
*
PROCESS.OFS:

    OFS.SOURCE.ID<1> = 'RESUME.ARR'

    OFS.RESPONSE = ''
    TXN.COMMIT = ''

    CALL OFS.CALL.BULK.MANAGER(OFS.SOURCE.ID, OFS.MESSAGE, OFS.RESPONSE, TXN.COMMIT)        ;*Process the Activity :)

RETURN
*--------------------------------------------------------------------------------------------------------------------------------------
END
