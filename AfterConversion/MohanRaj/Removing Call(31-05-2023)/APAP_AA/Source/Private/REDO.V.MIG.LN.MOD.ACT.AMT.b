$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.V.MIG.LN.MOD.ACT.AMT

*-----------------------------------------------------------------------------------
* Modification History:
*
* DATE                 WHO                  REFERENCE                    DESCRIPTION
* 29/03/2023         SURESH              MANUAL R22 CODE CONVERSTION            Package Name added APAP.AA
* 29/03/2023         Conversion Tool     AUTO R22 CODE CONVERSTION               VM to @VM, SM to @SM
*-----------------------------------------------------------------------------------
*-----------------------------------------------------------------------------
* Developed by : TAM (Marimuthus)
* PACS00239748
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_AA.LOCAL.COMMON


    GOSUB OPEN.FILES
    IF c_aalocActivityStatus MATCHES 'AUTH':@VM:'UNAUTH' THEN ;*AUTO R22 CODE CONVERSION
        GOSUB MAIN
    END
    IF c_aalocActivityStatus EQ 'AUTH-REV' THEN
        GOSUB UPDATE.REVERSE.AUTH.CONCAT
    END
    GOSUB PGM.END

OPEN.FILES:


    PSO = ''
    Y.FIELDS = 'L.MIGRATED.LN'
    Y.APL = 'AA.PRD.DES.PAYMENT.SCHEDULE'
    CALL MULTI.GET.LOC.REF(Y.APL,Y.FIELDS,PSO)
    Y.POS.MIG = PSO<1,1>

    FN.REDO.REMOVE.ACTUAL.AMT = 'F.REDO.REMOVE.ACTUAL.AMT'
    F.REDO.REMOVE.ACTUAL.AMT  = ''
    CALL OPF(FN.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT)

RETURN

MAIN:

    Y.AA.ID = c_aalocArrId
    Y.PRP.CLS = 'PAYMENT.SCHEDULE' ; PROP = '' ; EFF.DATE = ''; RET.IDS = ''; RET.COND = ''
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,Y.PRP.CLS,PROP,EFF.DATE,RET.IDS,RET.COND,RET.ERR)
    RET.COND = RAISE(RET.COND)
    Y.VAL.MIG = RET.COND<AA.PS.LOCAL.REF,Y.POS.MIG>

    IF Y.VAL.MIG EQ 'YES' THEN
        GOSUB PROCESS.ACT.AMT
    END ELSE
        GOSUB PGM.END
    END

RETURN
*------------------------------------------------------------------------
PROCESS.ACT.AMT:
*------------------------------------------------------------------------


    CALL F.READ(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT,CNCT.ERR)
    IF R.REDO.REMOVE.ACTUAL.AMT<1> EQ 'YES' THEN
        RETURN          ;* If it is YES, then it means that Actual amount passed for constant schedule during migration has been removed already.
    END

    Y.PAYMNT.TYPE = R.NEW(AA.PS.PAYMENT.TYPE)
    Y.CNT = DCOUNT(Y.PAYMNT.TYPE,@VM) ; FLG = '' ;*AUTO R22 CODE CONVERSION

    LOOP
    WHILE Y.CNT GT 0 DO
        FLG += 1
        Y.PROP.VLS = R.NEW(AA.PS.PROPERTY)<1,FLG>
        Y.PROP.VLS = CHANGE(Y.PROP.VLS,@SM,@VM) ;*AUTO R22 CODE CONVERSION

        Y.SET = 'Y'
        LOCATE 'ACCOUNT' IN Y.PROP.VLS<1,1> SETTING POS.AC THEN
            LOCATE 'PRINCIPALINT' IN Y.PROP.VLS<1,1> SETTING POS.IN THEN
                Y.SET = 'N'
            END
        END

        IF Y.SET EQ 'N' THEN

            R.NEW(AA.PS.ACTUAL.AMT)<1,FLG> = ''
            IF c_aalocActivityStatus EQ 'AUTH' THEN
                GOSUB UPDATE.AUTH.CONCAT
            END

        END
        Y.CNT -= 1
    REPEAT

RETURN
*-----------------------------------------------------------------
UPDATE.AUTH.CONCAT:
*-----------------------------------------------------------------

    IF R.REDO.REMOVE.ACTUAL.AMT<2> EQ ''  THEN
        R.REDO.REMOVE.ACTUAL.AMT<1> = 'YES' ;* This flag is to indicate that the actual amount passed during migration for constant pay sch has been removed, so here after we need not to remove actual amt when any changes made on loan.
        R.REDO.REMOVE.ACTUAL.AMT<2> = c_aalocArrActivityId
        CALL F.WRITE(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT)
    END

RETURN
*-----------------------------------------------------------------
UPDATE.REVERSE.AUTH.CONCAT:
*-----------------------------------------------------------------
    CALL F.READ(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT,F.REDO.REMOVE.ACTUAL.AMT,CNCT.ERR)
    IF R.REDO.REMOVE.ACTUAL.AMT<2> EQ c_aalocArrActivityId THEN
        R.REDO.REMOVE.ACTUAL.AMT<1>    = ''
        R.REDO.REMOVE.ACTUAL.AMT<3,-1> = R.REDO.REMOVE.ACTUAL.AMT<2>
        R.REDO.REMOVE.ACTUAL.AMT<2>    = ''
        CALL F.WRITE(FN.REDO.REMOVE.ACTUAL.AMT,c_aalocArrId,R.REDO.REMOVE.ACTUAL.AMT)

    END

RETURN
PGM.END:

END
