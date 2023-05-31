$PACKAGE APAP.AA
SUBROUTINE REDO.BUILD.AA.PAY.CHQ(ENQ.DATA)
*---------------------------------------------------------
*Description: Build routine not to display record in case all the cheques has
* returned.
*---------------------------------------------------------
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE                  
* 29-MAR-2023      Harsha                R22 Manual Conversion - No changes        
* 29-MAR-2023      Conversion Tool       R22 Auto Conversion - No changes                     
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.REDO.LOAN.FT.TT.TXN

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN
*---------------------------------------------------------
OPEN.FILES:
*---------------------------------------------------------

    FN.REDO.LOAN.FT.TT.TXN = 'F.REDO.LOAN.FT.TT.TXN'
    F.REDO.LOAN.FT.TT.TXN  = ''
    CALL OPF(FN.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN)

RETURN
*---------------------------------------------------------
PROCESS:
*---------------------------------------------------------


    LOCATE 'LOAN.ID' IN ENQ.DATA<2,1> SETTING POS1 THEN
        Y.LOAN.NO    = ENQ.DATA<4,POS1>
    END
    LOCATE 'DATE' IN ENQ.DATA<2,1> SETTING POS2 THEN
        Y.DATE       = ENQ.DATA<4,POS2>
    END
    LOCATE 'CHEQUE.REF' IN ENQ.DATA<2,1> SETTING POS3 THEN
        Y.CHEQUE.REF = ENQ.DATA<4,POS3>
    END

    SEL.CMD = 'SELECT ':FN.REDO.LOAN.FT.TT.TXN:' WITH LOAN.ID EQ ':Y.LOAN.NO:' AND DATE EQ ':Y.DATE:' AND CHEQUE.REF EQ ':Y.CHEQUE.REF
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)
    Y.RLT.ID = SEL.LIST<1>
    CALL F.READ(FN.REDO.LOAN.FT.TT.TXN,Y.RLT.ID,R.RLT,F.REDO.LOAN.FT.TT.TXN,RLT.ERR)
    IF R.RLT THEN
        IF R.RLT<LN.FT.TT.CHQ.AMOUNT> EQ R.RLT<LN.FT.TT.TOTAL.RETURN.AMT> THEN
            ENQ.ERROR = 'EB-REDO.ALL.CHQ.RET'
        END
    END

RETURN
END
