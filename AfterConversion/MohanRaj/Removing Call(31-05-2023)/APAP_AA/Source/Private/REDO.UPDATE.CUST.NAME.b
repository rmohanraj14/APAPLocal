* @ValidationCode : Mjo4MDgzNzY1NDM6Q3AxMjUyOjE2ODAwNzEwNzk3NjM6SVRTUzotMTotMTowOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
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
SUBROUTINE REDO.UPDATE.CUST.NAME

* DESCRIPTION:
*
* This routine is attached as a PRE routine to ACTIVITY.API for LENDING-UPDATE-OVERDUE property.
* The purpose of this routine is to get the Customer name
* --------------------------------------------------------------------------------------------------------------------------
*   Date               who           Reference                       Description
**
*** 29-03-2023 R22 Auto Conversion - no changes
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
    $INSERT I_F.CUSTOMER
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.REDO.AA.NAB.HISTORY
*-----------------------------------------------------------------------------------------------------------------
*Main Logic of the routine
*

    IF c_aalocActivityStatus EQ 'UNAUTH' THEN

        GOSUB INITIALISE
        GOSUB PROCESS

    END

RETURN
*-----------------------------------------------------------------------------------------------------------------
* Initialise the required variables
*
INITIALISE:

    FN.CUSTOMER = "F.CUSTOMER"
    F.CUSTOMER = ""
    R.RCUSTOMER = ''
    CALL OPF(FN.CUSTOMER, F.CUSTOMER)

    Y.ARR.ID = c_aalocArrId
    Y.CUSTOMER.ID =  c_aalocArrangementRec<AA.ARR.CUSTOMER>

    AA.OD.LRF.POS = ''
    AA.OD.LRF = 'L.BEN.CUST.NAME'
    CALL MULTI.GET.LOC.REF('AA.PRD.DES.OVERDUE',AA.OD.LRF,AA.OD.LRF.POS)
    AA.LOAN.CUSTNAME = AA.OD.LRF.POS<1,1>



RETURN

*-----------------------------------------------------------------------------------------------------------------
* Trigger OFS message to update the Account Condition with Loan Status
*
PROCESS:
*MG
    CALL F.READ(FN.CUSTOMER,Y.CUSTOMER.ID,R.RCUSTOMER,F.CUSTOMER,HIS.ERR)

    IF R.RCUSTOMER THEN
        Y.CUST.NAME = R.RCUSTOMER<EB.CUS.SHORT.NAME>
        R.NEW(AA.OD.LOCAL.REF)<1,AA.LOAN.CUSTNAME> = Y.CUST.NAME
    END




RETURN

END
