$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE REDO.REC.BAL.MAIN.ADJUST
*------------------------------------------------------------------------------------
*Modification History:
*Date           Who                 Reference                                    Descripition
* 29-03-2023     Samaran T            Manual R22 Code Conversion               Package Name Added APAP.AA
* 29-03-2023   Conversion Tool          Auto R22 Code Conversion                  FM TO @FM ,VM TO @VM, SM TO @SM
*---------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.BALANCE.MAINTENANCE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

PROCESS:


    APPL = 'AA.PRD.DES.BALANCE.MAINTENANCE'
    F.FLDS = 'BAL.PROP.NAME':@VM:'TOT.OS.PRP.AMT':@VM:'BILL.CNT':@VM:'AMT.ADJ.BILL':@VM:'TOT.AMT.ADJ'
    CALL MULTI.GET.LOC.REF(APPL,F.FLDS,POS.SS)

    FN.AAC = 'F.AA.ACCOUNT.DETAILS'
    F.AAC = ''
    CALL OPF(FN.AAC,F.AAC)

    FN.BILL = 'F.AA.BILL.DETAILS'
    F.BILL = ''
    CALL OPF(FN.BILL,F.BILL)

    Y.PS.PRP = POS.SS<1,1>
    Y.PS.TOT = POS.SS<1,2>
    Y.PS.CNT = POS.SS<1,3>
    Y.PS.ADJ = POS.SS<1,4>
    Y.PS.ADJ.AM = POS.SS<1,5>

    Y.AMT.ADJ.PBIL = R.NEW(AA.BM.LOCAL.REF)<1,Y.PS.ADJ>
    Y.TOT.ADJ.AMT = R.NEW(AA.BM.LOCAL.REF)<1,Y.PS.ADJ.AM>


    Y.AA.ID = ID.NEW
    Y.AA.ID = FIELD(Y.AA.ID,'-',1)

    CALL F.READ(FN.AAC,Y.AA.ID,R.AAC,F.AAC,AAC.ERR)
    Y.BILS = R.AAC<AA.AD.BILL.ID> ; Y.BILS = CHANGE(Y.BILS,@VM,@FM) ; Y.BILS = CHANGE(Y.BILS,@SM,@FM)

    Y.CNT = DCOUNT(Y.BILS,@FM) ; FLG = ''

    GOSUB PROCESS.BILLS
    GOSUB PROCESS.CALC

    R.NEW(AA.BM.ADJ.PROP.AMT)<1,1,1> = 0

    GOSUB PGM.END

RETURN

PROCESS.BILLS:

    LOOP
    WHILE Y.CNT GT 0 DO
        FLG += 1
        Y.BL = Y.BILS<FLG>
        CALL F.READ(FN.BILL,Y.BL,R.BILL,F.BILL,BIL.ERR)
        Y.PROPS = R.BILL<AA.BD.PROPERTY> ; Y.PR.CNT = DCOUNT(Y.PROPS,@VM) ; FLG.PR = ''
        IF FLG EQ 1 THEN
            Y.BUCKET.PRP = R.BILL<AA.BD.PROPERTY>
            Y.BUCK.AMT = R.BILL<AA.BD.OS.PROP.AMOUNT>
            FLG.M = ''
            GOSUB CNT.PRP
        END ELSE
            GOSUB PROCES.PROPS
        END
        Y.CNT -= 1
    REPEAT

RETURN

CNT.PRP:

    LOOP
    WHILE Y.PR.CNT GT 0 DO
        FLG.M += 1
        Y.BUCK.CNT<1,-1> = 1
        Y.PR.CNT -= 1
    REPEAT

RETURN

PROCES.PROPS:

    LOOP
    WHILE Y.PR.CNT GT 0 DO
        FLG.PR += 1
        Y.PAR.PRP = Y.PROPS<1,FLG.PR>
        LOCATE Y.PAR.PRP IN Y.BUCKET.PRP<1,1> SETTING POS.PR THEN
            Y.BUCK.AMT<1,POS.PR,-1> = R.BILL<AA.BD.OS.PROP.AMOUNT,FLG.PR>
            Y.BUCK.CNT<1,POS.PR> = Y.BUCK.CNT<1,POS.PR> + 1
        END ELSE
            Y.BUCKET.PRP<1,-1> = Y.PAR.PRP
            Y.BUCK.AMT<1,-1> = R.BILL<AA.BD.OS.PROP.AMOUNT,FLG.PR>
            Y.BUCK.CNT<1,-1> = 1
        END
        Y.PR.CNT -= 1
    REPEAT

RETURN

PROCESS.CALC:

    Y.VM.CNT = DCOUNT(Y.BUCKET.PRP,@VM)
    FLG.S = ''
    LOOP
    WHILE Y.VM.CNT GT 0 DO
        FLG.S += 1
        R.NEW(AA.BM.LOCAL.REF)<1,Y.PS.PRP,FLG.S> = Y.BUCKET.PRP<1,FLG.S>
        R.NEW(AA.BM.LOCAL.REF)<1,Y.PS.TOT,FLG.S> = SUM(Y.BUCK.AMT<1,FLG.S>)
        R.NEW(AA.BM.LOCAL.REF)<1,Y.PS.CNT,FLG.S> = Y.BUCK.CNT<1,FLG.S>
        Y.VM.CNT -= 1
    REPEAT

RETURN

PGM.END:

END
