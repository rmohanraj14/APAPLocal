* @ValidationCode : MjoxODQzNDY1NjYxOkNwMTI1MjoxNjgwMDcxMDgxNzQ4OklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:41
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
SUBROUTINE REDO.UPDATE.PAYOFF.DETAILS
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :Temenos Application Management
*Program   Name    :REDO.UPDATE.PAYOFF.DETAILS
*Reference         :ODR-2010-03-0171
*Date              :31 AUG 2010
*---------------------------------------------------------------------------------
*
*DESCRIPTION       :This program is used to update the local CONCAT file
*                   REDO.AA.PAYOFF.DETAILS with the arrangement ID which is to be processed in COB
*
*LINKED WITH       :Attached to ACTIVITY.API, for the activity LENDING-SETTLE-PAYOFF and triggered during PAYOFF
*                   Update Action
*** 29-03-2023 R22 Auto Conversion - No changes
** 29-03-2023 Skanda R22 Manual Conversion - No changes
*--------------------------------------------------------------------------------------------------------
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.REDO.AA.PAYOFF.DETAILS

    GOSUB OPEN.FILES
    GOSUB WRITE.VALUE
    GOSUB DELETE.FILE
RETURN
*------------------------------------------------------------------------------------------------------------------
OPEN.FILES:
*----------

    FN.REDO.AA.PAYOFF.DETAILS = 'F.REDO.AA.PAYOFF.DETAILS'
    F.REDO.AA.PAYOFF.DETAILS = ''
    CALL OPF(FN.REDO.AA.PAYOFF.DETAILS,F.REDO.AA.PAYOFF.DETAILS)

RETURN
*-------------------------------------------------------------------------------------------------------------------
* Update the Arrangement ID in the CONCAT file REDO.AA.PAYOFF.DETAILS
*
WRITE.VALUE:
*-----------

    CONCAT.ID = c_aalocArrActivityId
    R.REDO.AA.PAYOFF.DETAILS = TODAY
    CALL F.WRITE(FN.REDO.AA.PAYOFF.DETAILS, CONCAT.ID,R.REDO.AA.PAYOFF.DETAILS)   ;* For Payoff Update the CONCAT file with the Arrangement ID

RETURN
*-----------------------------------------------------------------------------------------------------------------------------
DELETE.FILE:
*-----------

    Y.STATUS = R.NEW(AA.ARR.ACT.RECORD.STATUS)
    CURR.STATUS = c_aalocActivityStatus
    IF Y.STATUS EQ 'RNAU' AND CURR.STATUS EQ 'AUTH' THEN
        CALL F.DELETE(FN.REDO.AA.PAYOFF.DETAILS,CONCAT.ID)
    END
RETURN
END
