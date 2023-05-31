$PACKAGE APAP.AA ;*Manual R22 code conversion
SUBROUTINE REDO.POST.PAYOFF.SUSP
*----------------------------------------------------------
* Description: This routine is to trigger FT transaction during payoff with UNC
* Input Arg: N/A
* Output Arg: N/A
*
*------------------------------------------------------------------------
* Modification History :
*Date           Who                 Reference                                  Descripition
* 29-03-2023     Samaran T        Manual R22 code conversion                Package Name Added APAP.AA
* 29-03-2023  Conversion Tool       Auto R22 Code Conversion                      no changes
*------------------------------------------------------------------------
* DATE WHO REFERENCE DESCRIPTION
* 01/08/2017 Edwin Charles - B.43 Initial Draft.
*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_AA.APP.COMMON
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.FUNDS.TRANSFER

    IF c_aalocCurrActivity EQ 'LENDING-ADJUST.SUSP.BALANCE-MANT.SALD.CUOTA' AND c_aalocActivityStatus EQ 'AUTH' THEN
        GOSUB INIT
        GOSUB PROCESS
    END

RETURN

INIT:
*----
    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT, F.ACCOUNT)

RETURN

*-----------------------------------------------------------
PROCESS:
*-----------------------------------------------------------
    Y.CUS.ID = ''
    Y.BALANCE = '0'
    ACCOUNT.ID = AA$LINKED.ACCOUNT
    BALANCE.TO.CHECK = 'CURACCOUNT'
    START.DATE = TODAY
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, REQUEST.TYPE, START.DATE, END.DATE, SYSTEM.DATE, BAL.DETAILS, ERROR.MESSAGE)
    Y.CUR.BALANCE += ABS(BAL.DETAILS<IC.ACT.BALANCE>)

    ACCOUNT.ID = AA$LINKED.ACCOUNT
    BALANCE.TO.CHECK = 'ACCPRINCIPALINT'
    START.DATE = TODAY
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, REQUEST.TYPE, START.DATE, END.DATE, SYSTEM.DATE, BAL.DETAILS, ERROR.MESSAGE)
    Y.ACC.BALANCE += ABS(BAL.DETAILS<IC.ACT.BALANCE>)
    Y.BALANCE = Y.CUR.BALANCE + Y.ACC.BALANCE
    CALL F.READ(FN.ACCOUNT,ACCOUNT.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    Y.CUS.ID = R.ACCOUNT<AC.CUSTOMER>
    IF Y.BALANCE AND Y.CUS.ID THEN
        R.FT<FT.CREDIT.CURRENCY> = R.ACCOUNT<AC.CURRENCY>
        R.FT<FT.CREDIT.ACCT.NO> = AA$LINKED.ACCOUNT
        R.FT<FT.DEBIT.CURRENCY> = LCCY
        R.FT<FT.DEBIT.AMOUNT> = Y.BALANCE
        R.FT<FT.DEBIT.VALUE.DATE> = TODAY
        R.FT<FT.CREDIT.VALUE.DATE> = TODAY
        R.FT<FT.ORDERING.CUST> = Y.CUS.ID

        APP.NAME = 'FUNDS.TRANSFER'
        OFSFUNCTION = 'I'
        PROCESS = 'PROCESS'
        OFS.SOURCE.ID = 'FT.UNC.CK'
        OFSVERSION = 'FUNDS.TRANSFER,REDO.UNC.CUR'
        GTSMODE = ''
        NO.OF.AUTH = '0'
        TRANSACTION.ID = ''
        OFSSTRING = ''
        OFS.ERR = ''

        CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCTION,PROCESS,OFSVERSION,GTS.MODE,NO.OF.AUTH,TRANSACTION.ID,R.FT,OFSSTR)
        CALL OFS.POST.MESSAGE(OFSSTR,OFS.MSG.ID,OFS.SOURCE.ID,OFS.ERR)
    END
RETURN
END
