* @ValidationCode : MjotMjc5NTE1MjE2OkNwMTI1MjoxNjgwMDcxMDc4MDk5OklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 29 Mar 2023 11:54:38
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
SUBROUTINE REDO.UPD.CUS.ARRANGEMENT
*------------------------------------------------------------------------
*Description : This routine is to update the REDO.CUSTOMER.ARRANGEMENT
* application for the loan created for the customer
*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : This will be attached as post routine for ACTIVITY API for CUSTOMER
* property
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO         REFERENCE            DESCRIPTION
* 03-MAR-2011     H GANESH  ODR-2010-10-0045 N.107   Initial Draft
** 29-03-2023 R22 Auto Conversion – FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - No changes
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.REDO.CUSTOMER.ARRANGEMENT



    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB PROCESS
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        GOSUB REV.PROCESS
    END

RETURN

*------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------
    FN.REDO.CUSTOMER.ARRANGEMENT='F.REDO.CUSTOMER.ARRANGEMENT'
    F.REDO.CUSTOMER.ARRANGEMENT=''
    CALL OPF(FN.REDO.CUSTOMER.ARRANGEMENT,F.REDO.CUSTOMER.ARRANGEMENT)

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------

    GOSUB INIT
    Y.OWN.IDS=R.NEW(AA.CUS.OWNER)
    GOSUB UPDATE.OWN.ARR
    Y.OTHER.IDS=R.NEW(AA.CUS.OTHER.PARTY)
    GOSUB UPDATE.OTHER.ARR

RETURN
*------------------------------------------------------------------------
UPDATE.OWN.ARR:
*------------------------------------------------------------------------
* Updates the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OWN.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS

        Y.CUS.ID=Y.OWN.IDS<1,Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.PRIMARY.ARR=R.CUS.ARR<CUS.ARR.OWNER>
        Y.NO.OF.ARR=DCOUNT(Y.PRIMARY.ARR,@VM)
        LOCATE c_aalocArrId IN Y.PRIMARY.ARR<1,1> SETTING POS.VAL ELSE
            R.CUS.ARR<CUS.ARR.OWNER,Y.NO.OF.ARR+1>=c_aalocArrId
            CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------------------------
UPDATE.OTHER.ARR:
*------------------------------------------------------------------------
* Updates the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OTHER.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS
        Y.CUS.ID=Y.OTHER.IDS<1,Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.OTHER.ARR=R.CUS.ARR<CUS.ARR.OTHER.PARTY>
        Y.NO.OF.OTHER=DCOUNT(Y.OTHER.ARR,@VM)
        R.CUS.ARR<CUS.ARR.OTHER.PARTY,Y.NO.OF.OTHER+1>=c_aalocArrId
        CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------------------------
REV.PROCESS:
*------------------------------------------------------------------------
    GOSUB INIT

    Y.OWN.IDS=R.NEW(AA.CUS.OWNER)
    GOSUB DEL.OWN.ARR
    Y.OTHER.IDS=R.NEW(AA.CUS.OTHER.PARTY)
    GOSUB DEL.OTHER.ARR

RETURN
*------------------------------------------------------------------------
DEL.OWN.ARR:
*------------------------------------------------------------------------
* Deletes the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OWN.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS

        Y.CUS.ID=Y.OWN.IDS<1,Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.PRIMARY.ARR=R.CUS.ARR<CUS.ARR.OWNER>
*Y.NO.OF.ARR=DCOUNT(Y.PRIMARY.ARR,VM)
*R.CUS.ARR<CUS.ARR.OWNER,Y.NO.OF.ARR+1>=c_aalocArrId
        LOCATE c_aalocArrId IN Y.PRIMARY.ARR<1,1> SETTING POS1 THEN
            DEL R.CUS.ARR<CUS.ARR.OWNER,POS1>
        END
        CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN

*------------------------------------------------------------------------
DEL.OTHER.ARR:
*------------------------------------------------------------------------

* Updates the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OTHER.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS
        Y.CUS.ID=Y.OTHER.IDS<1,Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.OTHER.ARR=R.CUS.ARR<CUS.ARR.OTHER.PARTY>
*Y.NO.OF.OTHER=DCOUNT(Y.OTHER.ARR,VM)
*R.CUS.ARR<CUS.ARR.OTHER.PARTY,Y.NO.OF.OTHER+1>=c_aalocArrId

        LOCATE c_aalocArrId IN Y.OTHER.ARR<1,1> SETTING POS1 THEN
            DEL R.CUS.ARR<CUS.ARR.OTHER.PARTY,POS1>
        END
        CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN

END
