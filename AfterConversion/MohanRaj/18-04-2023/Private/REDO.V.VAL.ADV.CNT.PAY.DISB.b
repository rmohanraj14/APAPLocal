* @ValidationCode : MjoxOTMyMTcyMjYxOkNwMTI1MjoxNjgxODIyMTc0MTk5OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 18:19:34
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
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM,SM TO @SM
*18-04-2023      Mohanraj R          R22 Manual code conversion  CALL method format modified
SUBROUTINE REDO.V.VAL.ADV.CNT.PAY.DISB
*-------------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used as validation routine for the the local field L.ADV.INS.CNT
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
* 14-09-2011        S.MARIMUTHU     PACS00080530         Initial Creation
*-------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.PAYMENT.SCHEDULE
    $INSERT I_F.FUNDS.TRANSFER

MAIN:

    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PGM.END

OPENFILES:

    FN.AA.ARRANGEMENT = 'F.AA.ARRANGEMENT'
    F.AA.ARRANGEMENT = ''
    CALL OPF(FN.AA.ARRANGEMENT,F.AA.ARRANGEMENT)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    APPLS = 'FUNDS.TRANSFER'
*  F.FIELDS = 'L.NO.OF.INSTAL':VM:'L.ADV.INS.CNT'
    F.FIELDS = 'L.NO.OF.INSTAL'
    POS.VAL=''
    CALL MULTI.GET.LOC.REF(APPLS,F.FIELDS,POS.VAL)
    POS.NO.INS = POS.VAL<1,1>
* POS.ADV.INS = POS.VAL<1,2>

RETURN

PROCESS:



    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END

* Y.ADV.INS = COMI
* IF Y.ADV.INS EQ '' THEN
*     RETURN
* END
* Y.NO.OF.INS = R.NEW(FT.LOCAL.REF)<1,POS.NO.INS>

    Y.NO.OF.INS = COMI
* Y.CREDIT.AMT = R.NEW(FT.CREDIT.AMOUNT)
    R.NEW(FT.CREDIT.AMOUNT) = ''

    VAR.AA.ID = R.NEW(FT.CREDIT.ACCT.NO)

    IF VAR.AA.ID[1,2] NE 'AA' THEN
        CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
        IF NOT(R.ACCOUNT) THEN
            RETURN
        END
        VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>
        Y.CUS = R.ACCOUNT<AC.CUSTOMER>
    END ELSE
        CALL F.READ(FN.AA.ARRANGEMENT,VAR.AA.ID,R.AA.ARRANGEMENT,F.AA.ARRANGEMENT,AA.ARR.ERR)
        IF NOT(R.AA.ARRANGEMENT) THEN
            RETURN
        END
        Y.CUS = R.AA.ARRANGEMENT<AA.ARR.CUSTOMER>
    END

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,VAR.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.AC.ERR)
    IF NOT(R.AA.ACCOUNT.DETAILS) THEN
        RETURN
    END
    Y.CNT = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>,@VM)
    FLG = ''
    LOOP
    WHILE Y.CNT GT 0 DO
        FLG.VAL += 1
        Y.TYPE = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL>
        Y.CNT.TYPE = DCOUNT(Y.TYPE,@SM)
        IF Y.CNT.TYPE EQ 1 THEN
            IF R.AA.ACCOUNT.DETAILS<AA.AD.BILL.TYPE,FLG.VAL,1> EQ 'PAYMENT' THEN
                Y.BILL.ID = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID,FLG.VAL,1>
                CALL F.READ(FN.AA.BILL.DETAILS,Y.BILL.ID,R.AA.BILL.DETAILS,F.AA.BILL.DETAILS,BILL.ERR)
                Y.SETTLE.STATUS = R.AA.BILL.DETAILS<AA.BD.SETTLE.STATUS,1>
                GOSUB SET.ST.UNP
            END
        END
        Y.CNT -= 1
    REPEAT

*   IF FLG NE '' AND Y.NO.OF.INS NE FLG THEN
*       AF = FT.LOCAL.REF
*       AV = POS.ADV.INS
*       ETEXT = 'EB-DUES.ARE.THERE'
*       CALL STORE.END.ERROR
*   END ELSE
    PROP.CLASS='PAYMENT.SCHEDULE'
    CALL APAP.TAM.REDO.CRR.GET.CONDITIONS(VAR.AA.ID,EFF.DATE,PROP.CLASS, PROPERTY,R.CONDITION,ERR.MSG) ;* R22 Manual Conversion - CALL method format modified
    VAR.CALC.AMOUNT.LIST=R.CONDITION<AA.PS.CALC.AMOUNT>
    VAR.ACC.LIST   =R.CONDITION<AA.PS.PROPERTY>
    CHANGE @VM TO @FM IN VAR.CALC.AMOUNT.LIST
    CHANGE @VM TO @FM IN VAR.ACC.LIST
    CHANGE @SM TO @FM IN VAR.ACC.LIST
    LOCATE 'ACCOUNT' IN  VAR.ACC.LIST SETTING VAR.ACC.POS THEN
        VAR.CALC.AMOUNT=VAR.CALC.AMOUNT.LIST<VAR.ACC.POS>
    END
    VAR.INSTALL.AMOUNT = VAR.CALC.AMOUNT * Y.NO.OF.INS
    Y.FIN.AMT.SH = VAR.INSTALL.AMOUNT
    R.NEW(FT.CREDIT.AMOUNT) = Y.FIN.AMT + Y.FIN.AMT.SH
*  END

RETURN
*-----------
SET.ST.UNP:
*-----------

    IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
        Y.FIN.AMT += SUM(R.AA.BILL.DETAILS<AA.BD.OS.PROP.AMOUNT>)
        FLG += 1
    END
RETURN
PGM.END:

END
