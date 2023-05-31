$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSTION
SUBROUTINE REDO.GET.AAA.ID.PDIS
    
*-----------------------------------------------------------------------------------

* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023   CONVERSION TOOL         AUTO R22 CODE CONVERSION           FM TO @FM
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA



*-----------------------------------------------------------------------------------


    
*-----------------------------------------------------------------------------
* Developed by : TAM (Marimuthus)
*------------------------------------------------------------------------------
** OFS FIX**

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    FN.REDO.GET.AAA.NEW.CHG.PDIS = 'F.REDO.GET.AAA.NEW.CHG.PDIS'
    F.REDO.GET.AAA.NEW.CHG.PDIS = ''
    CALL OPF(FN.REDO.GET.AAA.NEW.CHG.PDIS,F.REDO.GET.AAA.NEW.CHG.PDIS)


    POS.S = ''
    F.AAPL = 'AA.ARRANGEMENT.ACTIVITY'
    F.AL.FIELDS = 'DIS.REF.ID'
    CALL MULTI.GET.LOC.REF(F.AAPL,F.AL.FIELDS,POS.S)
    Y.GL.POS = POS.S<1,1>

    Y.PID = R.NEW(AA.ARR.ACT.LOCAL.REF)<1,Y.GL.POS>

    IF V$FUNCTION EQ 'I' THEN
        Y.AAA.ID = ID.NEW

        CALL F.READ(FN.REDO.GET.AAA.NEW.CHG.PDIS,Y.PID,R.REDO.GET.AAA.NEW.CHG.PDIS,F.REDO.GET.AAA.NEW.CHG.PDIS,PDIS.ERR)
        IF R.REDO.GET.AAA.NEW.CHG.PDIS THEN
            R.REDO.GET.AAA.NEW.CHG.PDIS<-1> = Y.AAA.ID
        END ELSE
            R.REDO.GET.AAA.NEW.CHG.PDIS = Y.AAA.ID
        END
        CALL F.WRITE(FN.REDO.GET.AAA.NEW.CHG.PDIS,Y.PID,R.REDO.GET.AAA.NEW.CHG.PDIS)
    END

    IF V$FUNCTION EQ 'R' THEN
        Y.AAA.ID = ID.NEW
        Y.OP = ''
        CALL F.READU(FN.REDO.GET.AAA.NEW.CHG.PDIS,Y.PID,R.REDO.GET.AAA.NEW.CHG.PDIS,F.REDO.GET.AAA.NEW.CHG.PDIS,PDIS.ERR,Y.OP)
        Y.CNT = DCOUNT(R.REDO.GET.AAA.NEW.CHG.PDIS,@FM) ;*AUTO R22 CODE CONVERSION
        IF Y.CNT EQ 1 OR Y.CNT EQ 0 THEN
            CALL F.DELETE(FN.REDO.GET.AAA.NEW.CHG.PDIS,Y.PID)
        END ELSE
            LOCATE Y.AAA.ID IN R.REDO.GET.AAA.NEW.CHG.PDIS SETTING POS.AA THEN
                DEL R.REDO.GET.AAA.NEW.CHG.PDIS<POS.AA>
                CALL F.WRITE(FN.REDO.GET.AAA.NEW.CHG.PDIS,Y.PID,R.REDO.GET.AAA.NEW.CHG.PDIS)
            END
        END
    END

RETURN

END
