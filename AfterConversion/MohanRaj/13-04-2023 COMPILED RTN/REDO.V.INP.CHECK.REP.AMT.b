* @ValidationCode : MjoxOTcyOTAzNDEzOkNwMTI1MjoxNjgxMzg5ODY1NjIxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 18:14:25
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
SUBROUTINE REDO.V.INP.CHECK.REP.AMT

*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Program   Name    :REDO.V.INP.CHECK.REP.AMT
*---------------------------------------------------------------------------------
*

*DESCRIPTION       :It is a validation routine attached to install payment version of FT and TELLER
*LINKED WITH       :

* ----------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 4-NOV-2011        Marimuthu S     PACS00146864
* 12-FEB-2012       Marimuthu S     PACS00170057
* 02-AUG-2012       Nandhini M      PACS00210699
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     SM TO @SM,VM TO @VM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.BILL.DETAILS
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.VERSION
    $INSERT I_GTS.COMMON
*   $INSERT I_F.VERSION


MAIN:

    GOSUB OPENFILES
    GOSUB PROCESS
    GOSUB PGM.END

OPENFILES:

    FN.AA.BILL.DETAILS = 'F.AA.BILL.DETAILS'
    F.AA.BILL.DETAILS = ''
    CALL OPF(FN.AA.BILL.DETAILS,F.AA.BILL.DETAILS)

    FN.ACCOUNT = 'F.ACCOUNT'
    F.ACCOUNT = ''
    CALL OPF(FN.ACCOUNT,F.ACCOUNT)

    FN.AA.ACCOUNT.DETAILS = 'F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS = ''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

RETURN

PROCESS:


    L.APPL = 'FUNDS.TRANSFER'
    L.FIELDS = 'L.NO.OF.INSTAL'
    POS = ''
    CALL MULTI.GET.LOC.REF(L.APPL,L.FIELDS,POS)
    Y.POS.NOS = POS<1,1>

    VAR.AA.ID = R.NEW(FT.CREDIT.ACCT.NO)
    Y.NO.INS = R.NEW(FT.LOCAL.REF)<1,Y.POS.NOS>
    Y.DUP.NO.OF.INS = Y.NO.INS
    Y.CRD.AMT = R.NEW(FT.CREDIT.AMOUNT)
    IF Y.CRD.AMT EQ '' THEN
        Y.CRD.AMT = R.NEW(FT.DEBIT.AMOUNT)
    END


    CALL F.READ(FN.ACCOUNT,VAR.AA.ID,R.ACCOUNT,F.ACCOUNT,ACC.ERR)
    VAR.AA.ID = R.ACCOUNT<AC.ARRANGEMENT.ID>

    CALL F.READ(FN.AA.ACCOUNT.DETAILS,VAR.AA.ID,R.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS,AA.AC.ERR)
    Y.TOT.BILS = R.AA.ACCOUNT.DETAILS<AA.AD.BILL.ID>
    Y.TOT.BILS = CHANGE(Y.TOT.BILS,@SM,@VM)
    Y.CN.VM = DCOUNT(Y.TOT.BILS,@VM)
    Y.CNT = DCOUNT(R.AA.ACCOUNT.DETAILS<AA.AD.BILL.PAY.DATE>,@VM)
    FLG = '' ; FIN.CNT = ''
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
                GOSUB CHECK.UNPAID
            END
        END
        Y.CNT -= 1
    REPEAT

    GOSUB CHECK.ERROR

RETURN

* PACS00210699 - Start
RAISE.ERR.OVR:
*-------------
    BEGIN CASE
        CASE PGM.VERSION EQ ',REDO.MULTI.AA.ACRP.DISB'
            TEXT = 'EB-PART.NOT.ALLOW'
            CALL STORE.OVERRIDE(CURR.NO)
        CASE PGM.VERSION EQ ',REDO.MULTI.AA.PART.ACRP.DISB'
            TEXT = 'EB-PART.NOT.ALLOW'
            CALL STORE.OVERRIDE(CURR.NO)
        CASE 1
            ETEXT = 'EB-PART.NOT.ALLOW'
            CALL STORE.END.ERROR
    END CASE

RETURN

* PACS00210699 - End

CHECK.ERROR:

    IF Y.NO.INS EQ FLG THEN
        IF Y.CRD.AMT LT Y.FIN.AMT THEN
            AF = FT.CREDIT.AMOUNT
            GOSUB RAISE.ERR.OVR     ;* PACS00210699
            GOSUB PGM.END
        END
    END
    IF Y.NO.INS LT FLG THEN
        IF Y.NO.INS EQ '' THEN
            IF Y.CRD.AMT LT Y.DUPP.FIN.AMT THEN
                AF = FT.CREDIT.AMOUNT
                GOSUB RAISE.ERR.OVR   ;* PACS00210699
                GOSUB PGM.END
            END
        END ELSE
            GOSUB CHECK.OVR.COND
        END
    END

RETURN

CHECK.OVR.COND:

    IF Y.CRD.AMT LT Y.FIN.AMT AND Y.FIN.AMT NE '' THEN
        AF = FT.CREDIT.AMOUNT
        GOSUB RAISE.ERR.OVR       ;* PACS00210699
        GOSUB PGM.END
    END
    IF Y.CRD.AMT NE Y.FIN.AMT AND Y.FIN.AMT NE '' THEN
        IF Y.CRD.AMT LT Y.DUPP.FIN.AMT THEN
            AF = FT.CREDIT.AMOUNT
            GOSUB RAISE.ERR.OVR     ;* PACS00210699
            GOSUB PGM.END
        END
    END

RETURN
CHECK.UNPAID:

    IF Y.SETTLE.STATUS EQ 'UNPAID' THEN
        Y.DUPP.FIN.AMT += R.AA.BILL.DETAILS<AA.BD.OS.TOTAL.AMOUNT>
        Y.DUP.NO.OF.INS -= 1
        IF Y.DUP.NO.OF.INS GE 0 THEN
            Y.FIN.AMT += R.AA.BILL.DETAILS<AA.BD.OS.TOTAL.AMOUNT>
        END
        FLG += 1
    END ELSE
        FIN.CNT += 1
    END
RETURN

*****************
PGM.END:

END
