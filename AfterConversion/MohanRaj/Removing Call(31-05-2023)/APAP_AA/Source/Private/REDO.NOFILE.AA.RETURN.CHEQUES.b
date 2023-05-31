* @ValidationCode : MjotNTI0MDQ2ODA0OkNwMTI1MjoxNjg1NTMxMTM1MjUyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:35:35
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
$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.NOFILE.AA.RETURN.CHEQUES(Y.FINAL.ARRAY)
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL         AUTO R22 CODE CONVERSION          VM TO @VM,++ TO +=1
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed

*-----------------------------------------------------------------------------------

    
*--------------------------------------------------------------
*Description: This nofile enquiry for the AA user to return the cheque.
*--------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.REDO.LOAN.FT.TT.TXN
    $USING APAP.REDOENQ

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*--------------------------------------------------------------
OPEN.FILES:
*--------------------------------------------------------------

    Y.FINAL.ARRAY = ''

    INS 'STATUS'   BEFORE D.FIELDS<1>
    INS '1'        BEFORE D.LOGICAL.OPERANDS<1>
    INS 'RETURNED' BEFORE D.RANGE.AND.VALUE<1>


    FN.REDO.LOAN.FT.TT.TXN = 'F.REDO.LOAN.FT.TT.TXN'
    F.REDO.LOAN.FT.TT.TXN  = ''
    CALL OPF(FN.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN)

RETURN
*--------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------


    APAP.REDOENQ.redoEFormSelStmt(FN.REDO.LOAN.FT.TT.TXN, '', '', SEL.CMD);* R22 Manual conversion
    CALL EB.READLIST(SEL.CMD,IDS.LIST,'',NO.OF.REC,SEL.ERR)
    IF IDS.LIST THEN
        GOSUB FORM.ARRAY
    END
RETURN
*--------------------------------------------------------------
FORM.ARRAY:
*--------------------------------------------------------------

    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE NO.OF.REC
        Y.ID = IDS.LIST<Y.VAR1>
        CALL F.READ(FN.REDO.LOAN.FT.TT.TXN,Y.ID,R.REDO.LOAN.FT.TT.TXN,F.REDO.LOAN.FT.TT.TXN,TXN.ERR)
        Y.FT.IDS = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.FT.TRANSACTION.ID>
        IF Y.FT.IDS THEN
            GOSUB PROCESS.REMAIN
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*--------------------------------------------------------------
PROCESS.REMAIN:
*--------------------------------------------------------------
    Y.FT.IDS.CNT = DCOUNT(Y.FT.IDS,@VM) ;*AUTO R22 CODE CONVERSION
    Y.VAR2 = 1
    LOOP
    WHILE Y.VAR2 LE Y.FT.IDS.CNT
        Y.RETURN.AMOUNT   = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.RETURN.AMOUNT,Y.VAR2>
        Y.RETURNED.AMOUNT = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.RETURNED.AMOUNT,Y.VAR2>
        Y.AMOUNT          = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.AMOUNT,Y.VAR2>
        IF Y.RETURN.AMOUNT NE Y.RETURNED.AMOUNT AND Y.RETURN.AMOUNT NE '' THEN
            GOSUB FORM.ARRAY.FINAL
        END
        Y.VAR2 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*--------------------------------------------------------------
FORM.ARRAY.FINAL:
*--------------------------------------------------------------
    Y.PROCESS.ID = ''
    Y.TXN.ID     = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.FT.TRANSACTION.ID,Y.VAR2>
    Y.REV.ID     = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.RETURN.FT.REF,Y.VAR2>
    Y.LOAN.ID    = R.REDO.LOAN.FT.TT.TXN<LN.FT.TT.LOAN.ID,Y.VAR2>
    IF Y.REV.ID THEN
        Y.PROCESS.ID = Y.REV.ID
    END ELSE
        Y.PROCESS.ID = Y.TXN.ID
    END
    IF Y.PROCESS.ID THEN
        Y.FINAL.ARRAY<-1> = Y.LOAN.ID:"*":Y.AMOUNT:"*":Y.TXN.ID:"*":Y.RETURN.AMOUNT:"*":Y.PROCESS.ID
    END

RETURN
END
