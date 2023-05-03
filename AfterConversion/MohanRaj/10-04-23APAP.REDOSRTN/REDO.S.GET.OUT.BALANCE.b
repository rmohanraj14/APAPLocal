* @ValidationCode : MjoxNjg0NTUxMDE3OkNwMTI1MjoxNjgxMTI5OTY5NDM1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 18:02:49
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
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.GET.OUT.BALANCE(AA.ID,WAMT.AA)
*-----------------------------------------------------------------
* Description: This service routine is to calculate the outstanding balance of Loan.
*-----------------------------------------------------------------
* Input Arg: AA.ID    -> Arrangement ID.
* Out   Arg: WAMT.AA  -> Outstanding Amount.
*------------------------------------------------------------------------
* Modification History :
*------------------------------------------------------------------------
*  DATE             WHO                   REFERENCE             DESCRIPTION
* 29-AUG-2013     R GANESH              PACS00308600            Initial Draft.
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM, FM TO @FM,++ TO +=1
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.OVERDUE
    $INSERT I_F.ACCT.ACTIVITY

    GOSUB PROCESS

RETURN
*-----------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------

    IN.ACC.ID     = ''
    Y.PROP.AMT    = ''
    Y.ARR.ACC.ID  = ''
    Y.TOTAL.AMT   = ''
    IN.ARR.ID = AA.ID
    CALL REDO.CONVERT.ACCOUNT(IN.ACC.ID,IN.ARR.ID,Y.ARR.ACC.ID,ERR.TEXT)

    IF Y.ARR.ACC.ID ELSE
        RETURN
    END
    GOSUB GET.OVERDUE.STATUS
    GOSUB GET.ACCOUNT.PROP.BALANCE

    WAMT.AA = Y.ACC.BAL
RETURN
*-----------------------------------------------------------------
GET.OVERDUE.STATUS:
*-----------------------------------------------------------------
* Here Overdue property aging status are obtained.

    EFF.DATE = 'TODAY'
    PROP.CLASS='OVERDUE'
    PROPERTY = ''
    R.CONDITION.OVERDUE = ''
    ERR.MSG = ''
    CALL REDO.CRR.GET.CONDITIONS(IN.ARR.ID,EFF.DATE,PROP.CLASS,PROPERTY,R.CONDITION.OVERDUE,ERR.MSG)
    Y.OVERDUE.STATUS = R.CONDITION.OVERDUE<AA.OD.OVERDUE.STATUS>
*  CHANGE VM TO FM IN Y.OVERDUE.STATUS
    CHANGE @SM TO @FM IN Y.OVERDUE.STATUS

RETURN
*-----------------------------------------------------------------
GET.ACCOUNT.PROP.BALANCE:
*-----------------------------------------------------------------
* Here we will get the account property Balances.

    Y.ACC.BAL = 0
    Y.ACCOUNT.PROPERTY = ''
    CALL REDO.GET.PROPERTY.NAME(IN.ARR.ID,'ACCOUNT',R.OUT.AA.RECORD,Y.ACCOUNT.PROPERTY,OUT.ERR)

    ACC.BALANCE.TYPE = 'CUR':@FM:'DUE':@FM:Y.OVERDUE.STATUS
    Y.PROPERTY.LIST = Y.ACCOUNT.PROPERTY
    Y.BALANCE.TYPE  = ACC.BALANCE.TYPE
    GOSUB GET.BALANCE
    Y.ACC.BAL = Y.BALANCE
RETURN
*-----------------------------------------------------------------
GET.BALANCE:
*-----------------------------------------------------------------

    Y.BALANCE = 0
    Y.PROPERTY.CNT = DCOUNT(Y.PROPERTY.LIST,@FM)
    Y.BALANCE.CNT  = DCOUNT(Y.BALANCE.TYPE,@FM)
    DATE.OPTIONS = ''
    DATE.OPTIONS<4>  = 'ECB'
    Y.LOOP1 = 1
    LOOP
    WHILE Y.LOOP1 LE Y.PROPERTY.CNT
        Y.LOOP2 = 1
        LOOP
        WHILE Y.LOOP2 LE Y.BALANCE.CNT
            BALANCE.TO.CHECK = Y.BALANCE.TYPE<Y.LOOP2>:Y.PROPERTY.LIST<Y.LOOP1>
            BALANCE.AMOUNT=''
            CALL AA.GET.PERIOD.BALANCES(Y.ARR.ACC.ID,BALANCE.TO.CHECK,DATE.OPTIONS,TODAY, "", "",BALANCE.AMOUNT, "")
            Y.BALANCE += ABS(BALANCE.AMOUNT<IC.ACT.BALANCE>)
            Y.LOOP2 += 1
        REPEAT
        Y.LOOP1 += 1
    REPEAT

RETURN
END
