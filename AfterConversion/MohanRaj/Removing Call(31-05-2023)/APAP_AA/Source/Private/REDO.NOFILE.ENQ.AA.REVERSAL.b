$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.NOFILE.ENQ.AA.REVERSAL(Y.DATA)
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL         AUTO R22 CODE CONVERSION            NO CHANGES
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------

    
*--------------------------------------------------
*Description: This nofile enquiry is to reverse the AA payment transactions.
*--------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_ENQUIRY.COMMON

    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*--------------------------------------------------
OPEN.FILES:
*--------------------------------------------------
    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.FUNDS.TRANSFER$HIS = 'F.FUNDS.TRANSFER$HIS'
    F.FUNDS.TRANSFER$HIS  = ''
    CALL OPF(FN.FUNDS.TRANSFER$HIS,F.FUNDS.TRANSFER$HIS)

RETURN
*--------------------------------------------------
PROCESS:
*--------------------------------------------------

    LOCATE '@ID' IN D.FIELDS<1> SETTING POS1 THEN
        Y.FT.ID = D.RANGE.AND.VALUE<POS1>
    END ELSE
        RETURN
    END
    Y.ID = Y.FT.ID
    CALL F.READ(FN.FUNDS.TRANSFER,Y.FT.ID,R.FT,F.FUNDS.TRANSFER,FT.ERR)

    IF R.FT THEN
        GOSUB UPDATE.ARRAY
        RETURN
    END

    CALL EB.READ.HISTORY.REC(F.FUNDS.TRANSFER$HIS,Y.FT.ID,R.FT,YERROR)

    IF R.FT THEN
        GOSUB UPDATE.ARRAY
        RETURN
    END

RETURN
*--------------------------------------------------
UPDATE.ARRAY:
*--------------------------------------------------

    Y.DATA= Y.ID:'*':R.FT<FT.DEBIT.ACCT.NO>:'*':R.FT<FT.CREDIT.ACCT.NO>:'*':R.FT<FT.CREDIT.AMOUNT>

RETURN
END
