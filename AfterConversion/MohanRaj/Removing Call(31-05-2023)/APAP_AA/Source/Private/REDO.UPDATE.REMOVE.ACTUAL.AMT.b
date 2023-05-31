* @ValidationCode : MjoxNTIzNDUwMDk6Q3AxMjUyOjE2ODAwNzEwODE4OTA6SVRTUzotMTotMTowOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
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
SUBROUTINE REDO.UPDATE.REMOVE.ACTUAL.AMT
*------------------------------------------------------------------
*Description: This is the Post routine for lending change payment schedule activity
*             to update the concat table REDO.REMOVE.ACTUAL.AMT. To show that manual
*             maintenance has been done on the loan for the field ACTUAL.AMT.
*------------------------------------------------------------------
* Modification History
** 30-03-2023 R22 Auto Conversion – FM TO @FM, VM to @VM, SM to @SM
** 30-03-2023 Skanda R22 Manual Conversion - No changes

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.PAYMENT.SCHEDULE



    GOSUB INIT
    IF c_aalocActivityStatus EQ 'AUTH' AND R.NEW(AA.PS.LOCAL.REF)<1,POS.L.MIGRATED.LN> EQ 'YES' THEN
        GOSUB UPDATE.AUTH.CONCAT
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        GOSUB UPDATE.REVERSE.CONCAT
    END



RETURN

*------------------------------------------------------------------
INIT:
*------------------------------------------------------------------

    LOC.REF.APPLICATION   = "AA.PRD.DES.PAYMENT.SCHEDULE"
    LOC.REF.FIELDS        = 'L.MIGRATED.LN'
    LOC.REF.POS           = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.MIGRATED.LN     = LOC.REF.POS<1,1>

    FN.REDO.REMOVE.ACTUAL.AMT = 'F.REDO.REMOVE.ACTUAL.AMT'
    F.REDO.REMOVE.ACTUAL.AMT  = ''
    CALL OPF(FN.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT)

RETURN
*------------------------------------------------------------------
UPDATE.AUTH.CONCAT:
*------------------------------------------------------------------

    Y.PAYMENT.TYPE     = R.NEW(AA.PS.PAYMENT.TYPE)
    Y.PAYMENT.TYPE.CNT = DCOUNT(Y.PAYMENT.TYPE,@VM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.PAYMENT.TYPE.CNT
        Y.PROPERTY = R.NEW(AA.PS.PROPERTY)<1,Y.VAR1>
        LOCATE 'ACCOUNT' IN Y.PROPERTY<1,1,1> SETTING POS1 THEN
            LOCATE 'PRINCIPALINT' IN Y.PROPERTY<1,1,1> SETTING POS2 THEN
                IF R.NEW(AA.PS.ACTUAL.AMT)<1,Y.VAR1> NE R.OLD(AA.PS.ACTUAL.AMT)<1,Y.VAR1> THEN
                    GOSUB UPDATE.CONCAT.TABLE
                END
            END
        END

        Y.VAR1 += 1 ;** R22 Auto Conversion
    REPEAT

RETURN
*------------------------------------------------------------------
UPDATE.CONCAT.TABLE:
*------------------------------------------------------------------

    CALL F.READ(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT,CNCT.ERR)
    IF R.REDO.REMOVE.ACTUAL.AMT<2> EQ ''  THEN
        R.REDO.REMOVE.ACTUAL.AMT<1> = 'YES' ;* This flag is to indicate that the actual amount passed during migration for constant pay sch has been removed, so here after we need not to remove actual amt when any changes made on loan.
        R.REDO.REMOVE.ACTUAL.AMT<2> = c_aalocArrActivityId
        CALL F.WRITE(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT)
    END
RETURN
*------------------------------------------------------------------
UPDATE.REVERSE.CONCAT:
*------------------------------------------------------------------

    CALL F.READ(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT,CNCT.ERR)
    IF R.REDO.REMOVE.ACTUAL.AMT<2> EQ c_aalocArrActivityId THEN
        R.REDO.REMOVE.ACTUAL.AMT<1>    = ''
        R.REDO.REMOVE.ACTUAL.AMT<3,-1> = R.REDO.REMOVE.ACTUAL.AMT<2>
        R.REDO.REMOVE.ACTUAL.AMT<2>    = ''
        CALL F.WRITE(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT)

    END

RETURN
END
