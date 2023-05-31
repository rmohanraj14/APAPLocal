* @ValidationCode : Mjo3ODMzMTMxMTI6Q3AxMjUyOjE2ODU1MzIzMzU4NDM6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 31 May 2023 16:55:35
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
SUBROUTINE REDO.UPD.CUS.ARRANGEMENT.MODIFY
*------------------------------------------------------------------------
*Description : This routine is to update the REDO.CUSTOMER.ARRANGEMENT
* application during modification of the loan
*------------------------------------------------------------------------
* Input Argument : NA
* Out Argument   : NA
* Deals With     : This will be attached as post routine for ACTIVITY API for CUSTOMER
* property and this will be triggered during the LENDING-UPDATE-CUSTOMER activity
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                 REFERENCE                DESCRIPTION
* 03-MAR-2011     H GANESH                  ODR-2010-10-0045 N.107   Initial Draft
* 22-MAY-2018     Gopala Krishnan R PACS00671804             System should not update duplicate values
** 29-03-2023 R22 Auto Conversion � FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - CALL method format changed
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.ID.COMPONENT
    $INSERT I_F.AA.CUSTOMER
    $INSERT I_F.REDO.CUSTOMER.ARRANGEMENT
    $USING APAP.TAM


*IF c_aalocActivityStatus NE 'AUTH' THEN
*RETURN
*END
    IF c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB INIT
        Y.NEW.IDS=R.NEW(AA.CUS.OWNER)
        Y.OLD.IDS=R.OLD(AA.CUS.OWNER)
*PACS00671804 - S
        IF Y.OLD.IDS EQ '' OR Y.OLD.IDS EQ '0' THEN
            GOSUB GET.PREVIOUS.COND
            Y.OLD.IDS=R.PROPERTY<AA.CUS.OWNER>
        END
*PACS00671804 - E
        GOSUB PROCESS
        Y.NEW.IDS=R.NEW(AA.CUS.OTHER.PARTY)
        Y.OLD.IDS=R.OLD(AA.CUS.OTHER.PARTY)
*PACS00671804 - S
        IF Y.OLD.IDS EQ '' OR Y.OLD.IDS EQ '0' THEN
            GOSUB GET.PREVIOUS.COND
            Y.OLD.IDS=R.PROPERTY<AA.CUS.OTHER.PARTY>
        END
*PACS00671804 - E
        GOSUB PROCESS2
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN

        GOSUB INIT
        GOSUB GET.PREVIOUS.COND
        Y.OLD.IDS=R.NEW(AA.CUS.OWNER)
        Y.NEW.IDS=R.PROPERTY<AA.CUS.OWNER>
        GOSUB PROCESS
        Y.OLD.IDS=R.NEW(AA.CUS.OTHER.PARTY)
        Y.NEW.IDS=R.PROPERTY<AA.CUS.OTHER.PARTY>
        GOSUB PROCESS2

    END


RETURN

*------------------------------------------------------------------------
INIT:
*------------------------------------------------------------------------
    FN.REDO.CUSTOMER.ARRANGEMENT='F.REDO.CUSTOMER.ARRANGEMENT'
    F.REDO.CUSTOMER.ARRANGEMENT=''
    CALL OPF(FN.REDO.CUSTOMER.ARRANGEMENT,F.REDO.CUSTOMER.ARRANGEMENT)

    Y.UPD.OWN=''
    Y.DEL.OWN=''

RETURN
*------------------------------------------------------------------------
PROCESS:
*------------------------------------------------------------------------

    Y.NEW.IDS.CNT=DCOUNT(Y.NEW.IDS,@VM)
    Y.OLD.IDS.CNT=DCOUNT(Y.OLD.IDS,@VM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NEW.IDS.CNT
        Y.ID= Y.NEW.IDS<1,Y.VAR1>
        LOCATE Y.ID IN Y.OLD.IDS<1,1> SETTING POS1 ELSE
            Y.UPD.OWN<-1>=Y.ID
        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
    Y.OWN.IDS=Y.UPD.OWN
    GOSUB UPDATE.OWN.ARR

    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.OLD.IDS.CNT
        Y.ID=Y.OLD.IDS<1,Y.VAR2>
        LOCATE Y.ID IN Y.NEW.IDS<1,1> SETTING POS2 ELSE
            Y.DEL.OWN<-1>=Y.ID
        END
        Y.VAR2 += 1 ;** R22 Auto Conversion
    REPEAT
    GOSUB DEL.OWN.ARR

RETURN
*------------------------------------------------------------------------
UPDATE.OWN.ARR:
*------------------------------------------------------------------------
* Updates the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OWN.IDS,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS
        Y.CUS.ID=Y.OWN.IDS<Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.PRIMARY.ARR=R.CUS.ARR<CUS.ARR.OWNER>
        Y.NO.OF.ARR=DCOUNT(Y.PRIMARY.ARR,@VM)
        R.CUS.ARR<CUS.ARR.OWNER,Y.NO.OF.ARR+1>=c_aalocArrId
        CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------------------------
DEL.OWN.ARR:
*------------------------------------------------------------------------
* Deletes the arrangement ID from REDO.CUSTOMER.ARRANGEMENT>CUSTOMER -> Owner

    Y.NO.OF.DEL.OWN=DCOUNT(Y.DEL.OWN,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.DEL.OWN
        Y.ID=Y.DEL.OWN<Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.PRIMARY.ARR=R.CUS.ARR<CUS.ARR.OWNER>
        LOCATE c_aalocArrId IN Y.PRIMARY.ARR<1,1> SETTING POS1 THEN
            DEL R.CUS.ARR<CUS.ARR.OWNER,POS1>
            CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.ID,R.CUS.ARR)
        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
RETURN

*------------------------------------------------------------------------
PROCESS2:
*------------------------------------------------------------------------

    Y.NEW.IDS.CNT=DCOUNT(Y.NEW.IDS,@VM)
    Y.OLD.IDS.CNT=DCOUNT(Y.OLD.IDS,@VM)
    Y.UPD.OTHER=''
    Y.DEL.OTHER=''
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NEW.IDS.CNT
        Y.ID= Y.NEW.IDS<1,Y.VAR1>
        LOCATE Y.ID IN Y.OLD.IDS<1,1> SETTING POS1 ELSE
            Y.UPD.OTHER<-1>=Y.ID
        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
    Y.OTHER.IDS=Y.UPD.OTHER
    GOSUB UPDATE.OTHER.ARR

    Y.VAR2=1
    LOOP
    WHILE Y.VAR2 LE Y.OLD.IDS.CNT
        Y.ID=Y.OLD.IDS<1,Y.VAR2>
        LOCATE Y.ID IN Y.NEW.IDS<1,1> SETTING POS2 ELSE
            Y.DEL.OTHER<-1>=Y.ID
        END
        Y.VAR2 += 1 ;** R22 Auto Conversion
    REPEAT
    GOSUB DEL.OTHER.ARR

RETURN
*------------------------------------------------------------------------
UPDATE.OTHER.ARR:
*------------------------------------------------------------------------
* Updates the owners in REDO.CUSTOMER.ARRANGEMENT application

    Y.NO.OF.CUS=DCOUNT(Y.OTHER.IDS,@FM)
    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.CUS
        Y.CUS.ID=Y.OTHER.IDS<Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.OTHER.ARR=R.CUS.ARR<CUS.ARR.OTHER.PARTY>
        Y.NO.OF.OTHER=DCOUNT(Y.OTHER.ARR,@VM)
        R.CUS.ARR<CUS.ARR.OTHER.PARTY,Y.NO.OF.OTHER+1>=c_aalocArrId
        CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.CUS.ID,R.CUS.ARR)
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------------------------
DEL.OTHER.ARR:
*------------------------------------------------------------------------
* Deletes the arrangement ID from REDO.CUSTOMER.ARRANGEMENT>CUSTOMER -> Other.Party

    Y.NO.OF.DEL.OWN=DCOUNT(Y.DEL.OTHER,@FM)

    Y.VAR1=1
    LOOP
    WHILE Y.VAR1 LE Y.NO.OF.DEL.OWN
        Y.ID=Y.DEL.OTHER<Y.VAR1>
        CALL F.READ(FN.REDO.CUSTOMER.ARRANGEMENT,Y.ID,R.CUS.ARR,F.REDO.CUSTOMER.ARRANGEMENT,CUS.ARR.ERR)
        Y.PRIMARY.ARR=R.CUS.ARR<CUS.ARR.OTHER.PARTY>
        LOCATE c_aalocArrId IN Y.PRIMARY.ARR<1,1> SETTING POS1 THEN
            DEL R.CUS.ARR<CUS.ARR.OTHER.PARTY,POS1>
            CALL F.WRITE(FN.REDO.CUSTOMER.ARRANGEMENT,Y.ID,R.CUS.ARR)
        END
        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT
RETURN
*------------------------------------------------------------------------
GET.PREVIOUS.COND:
*------------------------------------------------------------------------
* This part used read the previous CUSTOMER property arrangement condition

    OPTION=''
    PROPERTY.CLASS='CUSTOMER'
    EFFECTIVE.DATE=''
    R.PROPERTY=''
    RET.ERROR=''
    APAP.TAM.redoGetPropertyName(c_aalocArrId,PROPERTY.CLASS,R.OUT.AA.RECORD,ARR.PROPERTY.ID,OUT.ERR);* R22 Manual conversion
    ID.COMPONENT = ""
    ID.COMPONENT<AA.IDC.ARR.NO> = c_aalocArrId
    ID.COMPONENT<AA.IDC.PROPERTY>=ARR.PROPERTY.ID
    ID.COMPONENT<AA.IDC.EFF.DATE>=''

    CALL AA.GET.PREVIOUS.PROPERTY.RECORD(OPTION, PROPERTY.CLASS, ID.COMPONENT, EFFECTIVE.DATE, R.PROPERTY, RET.ERROR)



RETURN
END
