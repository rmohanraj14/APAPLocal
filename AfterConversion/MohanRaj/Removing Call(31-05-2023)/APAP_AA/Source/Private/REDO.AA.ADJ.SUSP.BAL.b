$PACKAGE APAP.AA ;*R22 Manual Code Conversion 
SUBROUTINE REDO.AA.ADJ.SUSP.BAL

* This Routine adjust the suspense balances while payoff is done with UNC balance
*
* Input/Output:
*----------------
*
* IN  : -NA-
* OUT : -NA-
*---------------
*
*----------------------------------------------------------------------------------------------------------------------------
*
* Modification History :
*----------------------------------------------------------------------------------------------------------------------------
*   Date               |           Who                    |           Reference                    |          Description
*----------------------------------------------------------------------------------------------------------------------------
* 01/08/2017                   Edwin Charles D                    R15 Upgrade                           Changes for R15 upgrade
*----------------------------------------------------------------------------------------------------------------------------
** Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023         Conversion Tool                      R22 Auto Code Conversion             Nochange

* All file INSERTS done here
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.AA.ACCOUNT
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.AA.UNC.PENDING
    $INSERT I_F.REDO.AA.REVERSE.REPAY

*----------------------------------------------------------------------------------------------------------------------------
* Main Logic
*
    GOSUB OPEN.FILES
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------------------------------------------------------------
* Initialise all the variables
*
OPEN.FILES:
  
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

    FN.REDO.AA.UNC.PENDING = 'F.REDO.AA.UNC.PENDING'
    F.REDO.AA.UNC.PENDING = ''
    CALL OPF(FN.REDO.AA.UNC.PENDING, F.REDO.AA.UNC.PENDING)

    FN.REDO.AA.REVERSE.REPAY = 'F.REDO.AA.REVERSE.REPAY'
    F.REDO.AA.REVERSE.REPAY = ''
    CALL OPF(FN.REDO.AA.REVERSE.REPAY, F.REDO.AA.REVERSE.REPAY)

RETURN
*----------------------------------------------------------------------------------------------------------------------------
PROCESS:
*------
    ARR.ID             = ''
    Y.REPAY.REF        = ''
    Y.ACCT.ID          = R.NEW(FT.DEBIT.ACCT.NO)
    Y.TRANSACTION.TYPE = R.NEW(FT.TRANSACTION.TYPE)
    CALL F.READ(FN.ACCOUNT, Y.ACCT.ID, R.ACCOUNT, F.ACCOUNT, ACC.ERR)
    ARR.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    Y.RECORD.STATUS = R.NEW(FT.RECORD.STATUS)

    IF Y.RECORD.STATUS EQ 'INAU' THEN
        IF Y.TRANSACTION.TYPE EQ 'ACUN' AND ARR.ID THEN
            R.REDO.AA.UNC.PENDING<AA.UN.ARR.STATUS> = 'PENDING.CLOSURE'
            CALL F.WRITE(FN.REDO.AA.UNC.PENDING,ARR.ID,R.REDO.AA.UNC.PENDING)
            Y.REPAY.REF = R.NEW(FT.DEBIT.THEIR.REF)
            IF Y.REPAY.REF[1,2] EQ 'FT' THEN
                CALL F.READ(FN.REDO.AA.REVERSE.REPAY,ARR.ID,R.REDO.AA.REVERSE.REPAY,F.REDO.AA.REVERSE.REPAY,REVERSE.ERR)
                R.REDO.AA.REVERSE.REPAY<AA.RE.REPAY.FT.REF, -1> = Y.REPAY.REF
                R.REDO.AA.REVERSE.REPAY<AA.RE.UNC.FT.REF, -1> = ID.NEW
                CALL F.WRITE(FN.REDO.AA.REVERSE.REPAY,ARR.ID,R.REDO.AA.REVERSE.REPAY)
            END
        END
    END

    IF Y.RECORD.STATUS EQ 'RNAU' THEN
        IF Y.TRANSACTION.TYPE EQ 'ACUN' AND ARR.ID THEN
            Y.REPAY.REF = R.NEW(FT.DEBIT.THEIR.REF)
            IF Y.REPAY.REF[1,2] EQ 'FT' THEN
                CALL F.READ(FN.REDO.AA.REVERSE.REPAY,ARR.ID,R.REDO.AA.REVERSE.REPAY,F.REDO.AA.REVERSE.REPAY,REVERSE.ERR)
                REPAY.FT.REF.LIST = R.REDO.AA.REVERSE.REPAY<AA.RE.REPAY.FT.REF>
                LOCATE Y.REPAY.REF IN REPAY.FT.REF.LIST<1,1> SETTING FT.POS THEN
                    DEL R.REDO.AA.REVERSE.REPAY<AA.RE.REPAY.FT.REF,FT.POS>
                    DEL R.REDO.AA.REVERSE.REPAY<AA.RE.UNC.FT.REF,FT.POS>
                    CALL F.WRITE(FN.REDO.AA.REVERSE.REPAY,ARR.ID,R.REDO.AA.REVERSE.REPAY)
                END
            END
        END
    END

RETURN
*----------------------------------------------------------------------------------------------------------------------------
END
