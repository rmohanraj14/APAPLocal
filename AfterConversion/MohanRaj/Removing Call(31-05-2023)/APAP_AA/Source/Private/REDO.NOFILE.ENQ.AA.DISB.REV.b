* @ValidationCode : MjoxNTM1NDg0ODYwOkNwMTI1MjoxNjg1NTMxMjE3MzI1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 31 May 2023 16:36:57
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
SUBROUTINE REDO.NOFILE.ENQ.AA.DISB.REV(Y.DATA)
    
*-----------------------------------------------------------------------------------
* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023      CONVERSION TOOL         AUTO R22 CODE CONVERSION     VM TO @VM,FM TO @FM,SM TO @SM,++ TO +=1
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA, CALL method format changed

*-----------------------------------------------------------------------------------

    
*-----------------------------------------------------
*Description: This nofile enquiry is to reverse the loan disbursement
* FT.
*-----------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACTIVITY.HISTORY
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY
    $INSERT I_F.REDO.DISB.CHAIN
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_F.REDO.AA.DISB.REVERSE
    $USING APAP.TAM
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*-----------------------------------------------------
OPEN.FILES:
*-----------------------------------------------------
    FN.AA.ACTIVITY.HISTORY = 'F.AA.ACTIVITY.HISTORY'
    F.AA.ACTIVITY.HISTORY  = ''
    CALL OPF(FN.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY)

    FN.AAA = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AAA  = ''
    CALL OPF(FN.AAA,F.AAA)

    FN.AAA$NAU = 'F.AA.ARRANGEMENT.ACTIVITY$NAU'
    F.AAA$NAU  = ''
    CALL OPF(FN.AAA$NAU,F.AAA$NAU)

    FN.FUNDS.TRANSFER = 'F.FUNDS.TRANSFER'
    F.FUNDS.TRANSFER  = ''
    CALL OPF(FN.FUNDS.TRANSFER,F.FUNDS.TRANSFER)

    FN.FUNDS.TRANSFER$HIS = 'F.FUNDS.TRANSFER$HIS'
    F.FUNDS.TRANSFER$HIS  = ''
    CALL OPF(FN.FUNDS.TRANSFER$HIS,F.FUNDS.TRANSFER$HIS)

    FN.FUNDS.TRANSFER$NAU = 'F.FUNDS.TRANSFER$NAU'
    F.FUNDS.TRANSFER$NAU  = ''
    CALL OPF(FN.FUNDS.TRANSFER$NAU,F.FUNDS.TRANSFER$NAU)

    FN.REDO.DISB.CHAIN = 'F.REDO.DISB.CHAIN'
    F.REDO.DISB.CHAIN  = ''
    CALL OPF(FN.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN)

    FN.REDO.FT.TT.TRANSACTION = 'F.REDO.FT.TT.TRANSACTION'
    F.REDO.FT.TT.TRANSACTION  = ''
    CALL OPF(FN.REDO.FT.TT.TRANSACTION,F.REDO.FT.TT.TRANSACTION)

    FN.REDO.FT.TT.TRANSACTION.HIS = 'F.REDO.FT.TT.TRANSACTION$HIS'
    F.REDO.FT.TT.TRANSACTION.HIS  = ''
    CALL OPF(FN.REDO.FT.TT.TRANSACTION.HIS,F.REDO.FT.TT.TRANSACTION.HIS)

    FN.REDO.FT.TT.TRANSACTION.NAU = 'F.REDO.FT.TT.TRANSACTION$NAU'
    F.REDO.FT.TT.TRANSACTION.NAU  = ''
    CALL OPF(FN.REDO.FT.TT.TRANSACTION.NAU,F.REDO.FT.TT.TRANSACTION.NAU)

    FN.REDO.AA.DISB.REVERSE = 'F.REDO.AA.DISB.REVERSE'
    F.REDO.AA.DISB.REVERSE = ''
    CALL OPF(FN.REDO.AA.DISB.REVERSE,F.REDO.AA.DISB.REVERSE)

    Y.DATA = ''

RETURN
*-----------------------------------------------------
PROCESS:
*-----------------------------------------------------
    LOCATE '@ID' IN D.FIELDS<1> SETTING POS1 THEN
        Y.AA.ID = D.RANGE.AND.VALUE<POS1>
    END ELSE
        RETURN
    END

    IF NUM(Y.AA.ID[1,2]) THEN
        IN.ARR.ID = ''
        APAP.TAM.redoConvertAccount(Y.AA.ID,IN.ARR.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion
        ARR.ID   = OUT.ID
        Y.ACC.ID = Y.AA.ID
    END ELSE
        IN.ACC.ID = ''
        APAP.TAM.redoConvertAccount(IN.ACC.ID,Y.AA.ID,OUT.ID,ERR.TEXT);* R22 Manual conversion
        ARR.ID   = Y.AA.ID
        Y.ACC.ID = OUT.ID
    END

    GOSUB GET.TERM.AMOUNT.PROPERTY
    IF ENQ.SELECTION<1> EQ 'REDO.NOFILE.ENQ.AA.DISB.REV' THEN
        GOSUB CHECK.ACTIVITY.HISTORY.LIVE
    END
    IF ENQ.SELECTION<1> EQ 'REDO.NOFILE.ENQ.AA.DISB.REV.AUTH' THEN
        GOSUB CHECK.DISB.CHAIN
*        GOSUB CHECK.ACTIVITY.HISTORY.UNAUTH
    END

RETURN

CHECK.DISB.CHAIN:
*----------------

    R.REDO.AA.DISB.REVERSE = ''; DISB.ERR = ''
    CALL F.READ(FN.REDO.AA.DISB.REVERSE,ARR.ID,R.REDO.AA.DISB.REVERSE,F.REDO.AA.DISB.REVERSE,DISB.ERR)
    IF R.REDO.AA.DISB.REVERSE AND NOT(DISB.ERR) THEN

        Y.DISB.REF.LIST = R.REDO.AA.DISB.REVERSE<AA.RE.DESB.REF>
        Y.DISB.CNT = 0
        Y.DISB.CNT = DCOUNT(Y.DISB.REF.LIST,@VM) ;*AUTO R22 CODE CONVERSION
        TEMP.REF.LIST = ''
        Y.VAR1 = 1
        LOOP
        WHILE Y.VAR1 LE Y.DISB.CNT
            Y.TEMP.REF.LIST = R.REDO.AA.DISB.REVERSE<AA.RE.FT.TEMP.REF>
            GOSUB CHECK.TEMP.FT.LIST
            Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
        REPEAT

    END

RETURN

CHECK.TEMP.FT.LIST:
*------------------
    Y.TEMP.REF.CNT = 0
    Y.TEMP.REF.CNT = DCOUNT(Y.TEMP.REF.LIST<1,Y.VAR1>,@SM) ;*AUTO R22 CODE CONVERSION
    Y.REF1 = 1
    LOOP
    WHILE Y.REF1 LE Y.TEMP.REF.CNT
        Y.TEMP.FT.ID = ''
        Y.TEMP.FT.ID = Y.TEMP.REF.LIST<1,Y.VAR1,Y.REF1>
        GOSUB UPDATE.ARRAY.NAU
        Y.REF1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN

UPDATE.ARRAY.NAU:
*----------------
    R.REDO.FT.TT.TRANSACTION.NAU = ''; RE.FT.ERR = ''
    CALL F.READ(FN.REDO.FT.TT.TRANSACTION.NAU,Y.TEMP.FT.ID,R.REDO.FT.TT.TRANSACTION.NAU,F.FUNDS.TRANSFER$NAU,FT.ERR)

    IF NOT(FT.ERR) THEN
        IF R.REDO.FT.TT.TRANSACTION.NAU<FT.TN.CREDIT.AMOUNT> THEN
            Y.AMOUNT = R.REDO.FT.TT.TRANSACTION.NAU<FT.TN.CREDIT.AMOUNT>
        END ELSE
            Y.AMOUNT = R.REDO.FT.TT.TRANSACTION.NAU<FT.TN.DEBIT.AMOUNT>
        END
        Y.DATA<-1> = Y.TEMP.FT.ID:'*':R.REDO.FT.TT.TRANSACTION.NAU<FT.TN.DEBIT.ACCT.NO>:'*':R.REDO.FT.TT.TRANSACTION.NAU<FT.TN.CREDIT.ACCT.NO>:'*':Y.AMOUNT
    END

RETURN

*--------------------------------------------------------
CHECK.ACTIVITY.HISTORY.UNAUTH:
*--------------------------------------------------------

* This part is to fetch the FT records to authorize the reversed record.

    Y.DISB.ACTIVITY = 'LENDING-DISBURSE-':TERM.AMOUNT.PROP

    CALL F.READ(FN.AA.ACTIVITY.HISTORY,ARR.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,ACT.ERR)
    Y.ACTIVITIES      = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>
    Y.ACTIVITY.REF    = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY.REF>
    Y.ACTIVITY.STATUS = R.AA.ACTIVITY.HISTORY<AA.AH.ACT.STATUS>

    CHANGE @SM TO @FM IN Y.ACTIVITIES ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITIES ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.ACTIVITY.REF ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITY.REF ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.ACTIVITY.STATUS ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITY.STATUS ;*AUTO R22 CODE CONVERSION


    Y.ACTIVITY.CNT = DCOUNT(Y.ACTIVITIES,@FM) ;*AUTO R22 CODE CONVERSION
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.ACTIVITY.CNT
        GOSUB UNAUTH.PART
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT
RETURN
*--------------------------------------------------------
UNAUTH.PART:
*--------------------------------------------------------

    Y.AAA.ID = Y.ACTIVITY.REF<Y.VAR1>
    IF Y.ACTIVITIES<Y.VAR1> EQ Y.DISB.ACTIVITY AND Y.ACTIVITY.STATUS<Y.VAR1> EQ 'REVERSE' THEN
        CALL F.READ(FN.AAA$NAU,Y.AAA.ID,R.AAA,F.AAA$NAU,AAA.ERR)
        IF R.AAA THEN
            Y.FT.ID = R.AAA<AA.ARR.ACT.TXN.CONTRACT.ID>
            Y.ID    = Y.FT.ID
            CALL F.READ(FN.FUNDS.TRANSFER$NAU,Y.FT.ID,R.FT,F.FUNDS.TRANSFER$NAU,FT.ERR)
            IF R.FT THEN
                GOSUB UPDATE.ARRAY.NAU
            END
        END
    END
RETURN

*--------------------------------------------------------
CHECK.ACTIVITY.HISTORY.LIVE:
*--------------------------------------------------------
* This part is to fetch the FT records to reverse.

    Y.DISB.ACTIVITY = 'LENDING-DISBURSE-':TERM.AMOUNT.PROP

    CALL F.READ(FN.AA.ACTIVITY.HISTORY,ARR.ID,R.AA.ACTIVITY.HISTORY,F.AA.ACTIVITY.HISTORY,ACT.ERR)
    Y.ACTIVITIES      = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY>
    Y.ACTIVITY.REF    = R.AA.ACTIVITY.HISTORY<AA.AH.ACTIVITY.REF>
    Y.ACTIVITY.STATUS = R.AA.ACTIVITY.HISTORY<AA.AH.ACT.STATUS>

    CHANGE @SM TO @FM IN Y.ACTIVITIES ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITIES ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.ACTIVITY.REF ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITY.REF ;*AUTO R22 CODE CONVERSION
    CHANGE @SM TO @FM IN Y.ACTIVITY.STATUS ;*AUTO R22 CODE CONVERSION
    CHANGE @VM TO @FM IN Y.ACTIVITY.STATUS ;*AUTO R22 CODE CONVERSION


    GOSUB LIVE.PART

RETURN
*-------------------------------------------------------
LIVE.PART:
*-------------------------------------------------------

    Y.ACTIVITY.CNT = DCOUNT(Y.ACTIVITIES,@FM)
    Y.VAR1 = 1
    LOOP
    WHILE Y.VAR1 LE Y.ACTIVITY.CNT
        Y.AAA.ID = Y.ACTIVITY.REF<Y.VAR1>
        IF Y.ACTIVITIES<Y.VAR1> EQ Y.DISB.ACTIVITY AND Y.ACTIVITY.STATUS<Y.VAR1> EQ 'AUTH' THEN
            CALL F.READ(FN.AAA,Y.AAA.ID,R.AAA,F.AAA,AAA.ERR)
            IF R.AAA THEN
                Y.FT.ID = R.AAA<AA.ARR.ACT.TXN.CONTRACT.ID>
                Y.ID    = Y.FT.ID
                CALL F.READ(FN.FUNDS.TRANSFER,Y.FT.ID,R.FT,F.FUNDS.TRANSFER,FT.ERR)
                IF R.FT THEN
                    GOSUB UPDATE.ARRAY
                    Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
                    CONTINUE
                END
                CALL EB.READ.HISTORY.REC(F.FUNDS.TRANSFER$HIS,Y.FT.ID,R.FT,YERROR)

                IF R.FT<FT.RECORD.STATUS> EQ 'MAT' THEN     ;* Moved to History will have Mat status.
                    GOSUB UPDATE.ARRAY
                END

            END
        END
        Y.VAR1 += 1 ;*AUTO R22 CODE CONVERSION
    REPEAT

RETURN
*--------------------------------------------------
UPDATE.ARRAY:
*--------------------------------------------------
    Y.TEMP.FT.ID   = R.FT<FT.CREDIT.THEIR.REF>
    R.REDO.FT.TT.TRANSACTION = ''; RE.FT.ERR = ''
    CALL F.READ(FN.REDO.FT.TT.TRANSACTION,Y.TEMP.FT.ID,R.REDO.FT.TT.TRANSACTION,F.REDO.FT.TT.TRANSACTION,RE.FT.ERR)

    R.REDO.FT.TT.TRANSACTION.NAU = ''; RE.FT.ERR = ''
    CALL F.READ(FN.REDO.FT.TT.TRANSACTION.NAU,Y.TEMP.FT.ID,R.REDO.FT.TT.TRANSACTION.NAU,F.FUNDS.TRANSFER$NAU,FT.ERR)

    IF NOT(RE.FT.ERR) AND NOT(R.REDO.FT.TT.TRANSACTION.NAU) AND Y.TEMP.FT.ID THEN
        IF R.REDO.FT.TT.TRANSACTION<FT.TN.CREDIT.AMOUNT> THEN
            Y.AMOUNT = R.REDO.FT.TT.TRANSACTION<FT.TN.CREDIT.AMOUNT>
        END ELSE
            Y.AMOUNT = R.REDO.FT.TT.TRANSACTION<FT.TN.DEBIT.AMOUNT>
        END
        Y.DATA<-1> = Y.TEMP.FT.ID:'*':R.REDO.FT.TT.TRANSACTION<FT.TN.DEBIT.ACCT.NO>:'*':R.REDO.FT.TT.TRANSACTION<FT.TN.CREDIT.ACCT.NO>:'*':Y.AMOUNT
    END

*    IF R.FT<FT.CREDIT.AMOUNT> THEN
*        Y.AMOUNT = R.FT<FT.CREDIT.AMOUNT>
*    END ELSE
*        Y.AMOUNT = R.FT<FT.DEBIT.AMOUNT>
*    END

*    Y.DATA<-1> = Y.ID:'*':R.FT<FT.DEBIT.ACCT.NO>:'*':R.FT<FT.CREDIT.ACCT.NO>:'*':Y.AMOUNT

RETURN
*--------------------------------------------------------
GET.TERM.AMOUNT.PROPERTY:
*--------------------------------------------------------
    IN.PROPERTY.CLASS = 'TERM.AMOUNT'
    R.OUT.AA.RECORD   = ''
    APAP.TAM.redoGetPropertyName(ARR.ID,IN.PROPERTY.CLASS,R.OUT.AA.RECORD,OUT.PROPERTY,OUT.ERR);* R22 Manual conversion
    TERM.AMOUNT.PROP  = OUT.PROPERTY

RETURN
END
