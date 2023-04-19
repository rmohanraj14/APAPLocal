* @ValidationCode : MjoxMDc5OTc2MTc5OkNwMTI1MjoxNjgxODkwMDg1NTQyOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 19 Apr 2023 13:11:25
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.VAL.DISBURSE.LOAN
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used as validation routine to default the disbursement amount
*-------------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*------------------
*   Date               who           Reference            Description
* 05-09-2011        S.MARIMUTHU     PACS00134035         Initial Creation
* 27-04-2012     S.MARIMUTHU     PACS00142807
*Modification history
*Date                Who               Reference                  Description
*19-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM,SM TO @SM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCT.ACTIVITY
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.TERM.AMOUNT
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.REDO.H.AA.DIS.CHG
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.AA.BILL.DETAILS

MAIN:

    GOSUB PROCESS
    GOSUB PGM.END

PROCESS:

    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END

    FN.REDO.H.AA.DIS.CHG = 'F.REDO.H.AA.DIS.CHG'
    F.REDO.H.AA.DIS.CHG = ''

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)


    Y.AMT = COMI
    Y.AC.ID = R.NEW(FT.DEBIT.ACCT.NO)

    ACCOUNT.ID = Y.AC.ID
    BALANCE.TO.CHECK = 'CURCOMMITMENT'
    DATE.OPTIONS = ''
    EFFECTIVE.DATE = TODAY
    DATE.OPTIONS<4>  = 'ECB'
    BALANCE.AMOUNT = ""
    CALL AA.GET.PERIOD.BALANCES(ACCOUNT.ID, BALANCE.TO.CHECK, DATE.OPTIONS, EFFECTIVE.DATE, "", "", BAL.DETAILS, "")
    PRIN.BALANCE = BAL.DETAILS<IC.ACT.BALANCE>
    PRIN.BALANCE = ABS(PRIN.BALANCE)

    CALL F.READ(FN.ACCOUNT,Y.AC.ID,R.ACCOUNT,F.ACCOUNT,AC.ERR)
    Y.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
    CALL AA.GET.ARRANGEMENT.CONDITIONS(Y.AA.ID,'TERM.AMOUNT','','',PROP.COND,RET.COND,RET.ERR)
    RET.COND = RAISE(RET.COND)
    Y.TERM.AMOUNT = RET.COND<AA.AMT.AMOUNT>


    GOSUB GET.CHARGE

    Y.POP.AMT = COMI - Y.TOT.AMT

    IF Y.POP.AMT LE PRIN.BALANCE THEN
        COMI = Y.POP.AMT
    END ELSE
*AF = FT.DEBIT.AMOUNT
*ETEXT = 'EB-DISB.AMT.EXCEED':FM:PRIN.BALANCE
*CALL STORE.END.ERROR
    END
RETURN

GET.CHARGE:

    CALL CACHE.READ(FN.REDO.H.AA.DIS.CHG,'SYSTEM',R.REDO.H.AA.DIS.CHG,DIS.CHG.ERR)
    Y.PROP.NAMES = R.REDO.H.AA.DIS.CHG<REDO.DIS.CHG.PROPERTY.NAME>
    Y.PROP.NAMES = CHANGE(Y.PROP.NAMES,@VM,@FM)

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,Y.AA.ID,R.AA.ACC.DET,F.AA.ACCOUNT.DETAILS,AA.ACC.ERR)
    Y.BILL.IDS = R.AA.ACC.DET<AA.AD.BILL.ID>
    Y.BILL.IDS = CHANGE(Y.BILL.IDS,@SM,@FM)
    Y.BILL.IDS = CHANGE(Y.BILL.IDS,@VM,@FM)

    Y.CNT = DCOUNT(Y.PROP.NAMES,@FM)
    FLG = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        FLG += 1
        Y.PROP.NAME = Y.PROP.NAMES<FLG>
        FLG.AAA = ''
        GOSUB READ.AA.BILLS
        Y.CNT -= 1
    REPEAT

RETURN

READ.AA.BILLS:

    Y.CNT.BL = ''
    Y.CNT.BL = DCOUNT(Y.BILL.IDS,@FM)
    LOOP
    WHILE Y.CNT.BL GT 0 DO
        FLG.AAA += 1
        Y.BL.ID = Y.BILL.IDS<FLG.AAA>
        CALL F.READ(FN.AA.BILL.DETAILS,Y.BL.ID,R.BILL.DET,F.AA.BILL.DETAILS,BIL.ERR)
        Y.ACT.PROP = R.BILL.DET<AA.BD.PROPERTY>
        LOCATE Y.PROP.NAME IN Y.ACT.PROP<1,1> SETTING POS.PR THEN
            Y.STS = R.BILL.DET<AA.BD.SETTLE.STATUS,1>
            IF Y.STS EQ 'UNPAID' THEN
                Y.TOT.AMT = Y.TOT.AMT + R.BILL.DET<AA.BD.OS.PROP.AMOUNT,POS.PR>
            END
        END
        Y.CNT.BL -= 1
    REPEAT

RETURN

PGM.END:

END
