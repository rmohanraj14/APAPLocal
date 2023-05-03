* @ValidationCode : MjotMjExODEzMTcwMjpDcDEyNTI6MTY4MTg4Njc0MjA1OTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 19 Apr 2023 12:15:42
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
*19-04-2023      conversion tool     R22 Auto code conversion    SM TO @SM,FM TO @FM,VM TO @VM
*19-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.VAL.CHECK.DUE.ADV

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.BILL.DETAILS


MAIN:

    IF MESSAGE EQ 'VAL' THEN
        RETURN
    END

    FN.AA.AC = 'F.AA.ACCOUNT.DETAILS'
    F.AA.AC = ''
    CALL OPF(FN.AA.AC,F.AA.AC)

    FN.AC = 'F.ACCOUNT'
    F.AC = ''
    CALL OPF(FN.AC,F.AC)

    FN.BILL = 'F.AA.BILL.DETAILS'
    F.BILL = ''
    CALL OPF(FN.BILL,F.BILL)

    APPLS = 'FUNDS.TRANSFER'
    POS.VAL = ''
    F.FIELDS = 'L.ADV.INS.CNT'
    CALL MULTI.GET.LOC.REF(APPLS,F.FIELDS,POS.VAL)
    POS.ADV.INS = POS.VAL<1,1>

    Y.ID = R.NEW(FT.CREDIT.ACCT.NO)

    CALL F.READ(FN.AC,Y.ID,R.AC,F.AC,AC.ERR)
    Y.AA.ID = R.AC<AC.ARRANGEMENT.ID>

    CALL F.READ(FN.AA.AC,Y.AA.ID,R.AA.AC,F.AA.AC,AA.AC.ER)
    Y.BILLS = R.AA.AC<AA.AD.BILL.ID>
    Y.BILLS = CHANGE(Y.BILLS,@SM,@VM)
    Y.BILLS = CHANGE(Y.BILLS,@VM,@FM)
    Y.CNT = DCOUNT(Y.BILLS,@FM)
    Y.FLG = '' ; Y.UNPAID.CNT = 0

    LOOP
    WHILE Y.CNT GT 0 DO
        Y.FLG += 1
        Y.BL = Y.BILLS<Y.FLG>
        CALL F.READ(FN.BILL,Y.BL,R.BILL,F.BILL,BILL.ER)
        Y.ST = R.BILL<AA.BD.SETTLE.STATUS,1>
        IF Y.ST EQ 'UNPAID' THEN
            Y.UNPAID.CNT += 1
        END
        Y.CNT -= 1
    REPEAT

    GOSUB PROCESS.UNPAID

    GOSUB PGM.END

RETURN

PROCESS.UNPAID:

    Y.ADV.BL = R.NEW(FT.LOCAL.REF)<1,POS.ADV.INS>
    IF Y.UNPAID.CNT EQ 0 AND Y.ADV.BL EQ '' THEN
        Y.AMT = COMI
        IF Y.AMT GT 0 THEN
            AF = FT.CREDIT.AMOUNT
            ETEXT = 'EB-PAY.NT.ALLOW.NOT.DUE'
            CALL STORE.END.ERROR
        END
    END

RETURN

PGM.END:

END
