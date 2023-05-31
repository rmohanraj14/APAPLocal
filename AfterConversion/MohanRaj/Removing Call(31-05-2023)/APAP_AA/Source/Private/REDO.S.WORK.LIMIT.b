* @ValidationCode : MjotMTcxNjA0ODg1NTpDcDEyNTI6MTY4MDE5MDE2MTA1NTpJVFNTOi0xOi0xOjI3ODoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 20:59:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 278
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

$PACKAGE APAP.AA
SUBROUTINE REDO.S.WORK.LIMIT
*----------------------------------------------------------------------------------------------------
* DESCRIPTION :  This routine is an ACTIVITY.API Post routine attached to LIMIT property class
*                This will be executed after inputting arrangements for AA Loan Contracts
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* PROGRAM NAME : REDO.S.WORK.LIMIT
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date             Author             Reference                   Description
* 21-Jul-2010      SUJITHA.S       ODR-2009100344               Inital creation
*
* 02-Mar-2010      Ravikiran AV     PACS00035728                Read customer ID from the AAA Activity
*
* 15-mAR-2010      Ravikiran AV     PACS00034161                Store the Limit id
*
*
* Date             Who                   Reference      Description
* 30.03.2023                             R22            Auto Conversion     - No changes
* 30.03.2023       Shanmugapriya M       R22            Manual Conversion   - No changes
*------------------------------------------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.AA.LIMIT
    $INSERT I_System


    GOSUB INIT
    GOSUB PROCESS

RETURN

*-------------------------------------------------------------------------------------------------------
INIT:
*-------------------------------------------------------------------------------------------------------

    ARR.ID=c_aalocArrId
    EFF.DATE=TODAY
    PROP.CLASS='CUSTOMER'
    PROPERTY=''
    R.CONDITION=''
    ERR.MSG=''

    FN.LIMIT.ARRANGEMENT='F.LIMIT.ARRANGEMENT'
    F.LIMIT.ARRANGEMENT=''
    R.LIMIT.ARRANGEMENT=''
    CALL OPF(FN.LIMIT.ARRANGEMENT,F.LIMIT.ARRANGEMENT)

RETURN

*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------

*    CALL REDO.CRR.GET.CONDITIONS(ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION,ERR.MSG)
*    Y.CUSTOMER=R.CONDITION<AA.CUS.PRIMARY.OWNER>
    Y.CUSTOMER = c_aalocArrangementRec<AA.ARR.CUSTOMER>
    Y.LIMIT.REFERENCE=R.NEW(AA.LIM.LIMIT.REFERENCE)
*AA Changes 20161013
    Y.LIMIT.SERIAL =R.NEW(AA.LIM.LIMIT.SERIAL)
*  Y.LIMIT.ID=Y.CUSTOMER:'.':'000':Y.LIMIT.REFERENCE
    Y.LIMIT.ID=Y.CUSTOMER:'.':'000':Y.LIMIT.REFERENCE:".":Y.LIMIT.SERIAL
*AA Changes 20161013
*PACS00034161
*    CALL System.setVariable("CURRENT.LIMIT.ID", ID.NEW)
*PACS00034161
    CALL F.READ(FN.LIMIT.ARRANGEMENT,Y.LIMIT.ID,R.LIMIT.ARRANGEMENT,F.LIMIT.ARRANGEMENT,LIM.ERR)

    IF NOT(LIM.ERR) THEN
        R.LIMIT.ARRANGEMENT<1>=ARR.ID
        CALL F.WRITE(FN.LIMIT.ARRANGEMENT,Y.LIMIT.ID,R.LIMIT.ARRANGEMENT)
    END

RETURN
END
