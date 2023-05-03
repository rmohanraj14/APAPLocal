* @ValidationCode : MjotMzQwNTAwMDg1OkNwMTI1MjoxNjgxODE1MzYyOTE3OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:26:02
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
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
SUBROUTINE REDO.V.TEMP.UPD.DISB.REF
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*  This routine is an input routine attached to Disbursement version to update FT or TT
*  reference in the live template and to update the field disb indicator
*
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS     : -NA-
* CALLED BY : -NA-
*
* Revision History:
*-----------------------------------------------------------------------------
*   Date               who           Reference            Description
*-----------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.REDO.FT.TT.TRANSACTION
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AA.ARRANGEMENT
    $INSERT I_System
    $INSERT I_F.REDO.AA.DISB.LOAN
    $INSERT I_F.REDO.AA.DISBURSE.UPDATE
    $INSERT I_F.REDO.BRANCH.INT.ACCT.PARAM
    $INSERT I_F.REDO.DISB.CHAIN
    $INSERT I_F.REDO.CREATE.ARRANGEMENT
    $INSERT I_F.REDO.FC.TEMP.DISB

    GOSUB INIT
    GOSUB UPD.REDO.AA.DISBURSE.UPDATE
    GOSUB CHECK.DUP

RETURN
*-----------------------------------------------------------------------------
******
INIT:
******
* Initialize all the variables

    FN.REDO.AA.DISB.LOAN = 'F.REDO.AA.DISB.LOAN'
    F.REDO.AA.DISB.LOAN  = ''
    R.REDO.AA.DISB.LOAN  = ''
    CALL OPF(FN.REDO.AA.DISB.LOAN,F.REDO.AA.DISB.LOAN)

    FN.REDO.AA.DISBURSE.UPDATE = 'F.REDO.AA.DISBURSE.UPDATE'
    F.REDO.AA.DISBURSE.UPDATE = ''
    R.REDO.AA.DISBURSE.UPDATE = ''
    CALL OPF(FN.REDO.AA.DISBURSE.UPDATE,F.REDO.AA.DISBURSE.UPDATE)

    FN.REDO.CREATE.ARRANGEMENT = "F.REDO.CREATE.ARRANGEMENT"
    F.REDO.CREATE.ARRANGEMENT  = ""
    CALL OPF(FN.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT)

    RETRY = ''
    FN.REDO.DISB.CHAIN  = 'F.REDO.DISB.CHAIN'
    F.REDO.DISB.CHAIN   = ''
    R.REDO.DISB.CHAIN   = ''

    FN.REDO.FC.TEMP.DISB = "F.REDO.FC.TEMP.DISB"
    F.REDO.FC.TEMP.DISB  = ""
    CALL OPF(FN.REDO.FC.TEMP.DISB,F.REDO.FC.TEMP.DISB)

    CALL OPF(FN.REDO.DISB.CHAIN,F.REDO.DISB.CHAIN)

RETURN
*--------------------------------------------------------------------------------
UPD.REDO.AA.DISBURSE.UPDATE:
*--------------------------------------------------------------------------------
*
*    Y.DISB.UPD.ID = R.NEW(FT.PAYMENT.DETAILS)<1,2>
*    Y.DISB.UPD.ID = System.getVariable("CURRENT.DISB.ID")

    CALL F.READ(FN.REDO.AA.DISBURSE.UPDATE,Y.DISB.UPD.ID,R.REDO.AA.DISBURSE.UPDATE,F.REDO.AA.DISBURSE.UPDATE,UPD.ERR)
    IF R.REDO.AA.DISBURSE.UPDATE THEN
        IF APPLICATION EQ 'TELLER' THEN
            IF V$FUNCTION EQ 'I' THEN
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.TRANS.REF>   = ID.NEW
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.INDICATOR> = 'DISB.UNAUTH'
            END
            IF V$FUNCTION EQ 'A' THEN
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.INDICATOR> = 'DISB.AUTH'
            END
        END
        IF APPLICATION EQ 'REDO.FT.TT.TRANSACTION' THEN
            IF V$FUNCTION EQ 'I' THEN
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.TRANS.REF>   = ID.NEW
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.INDICATOR> = 'DISB.UNAUTH'
            END
            IF V$FUNCTION EQ 'A' THEN
                R.REDO.AA.DISBURSE.UPDATE<DISB.UPD.DISB.INDICATOR> = 'DISB.AUTH'
            END
        END

        CALL F.WRITE(FN.REDO.AA.DISBURSE.UPDATE,Y.DISB.UPD.ID,R.REDO.AA.DISBURSE.UPDATE)
    END

RETURN
*--------------------------------------------------------------------------------
CHECK.DUP:


    IF V$FUNCTION EQ 'I' THEN
        WVCR.RDC.ID = R.NEW(FT.TN.L.INITIAL.ID)

        RTNDISB = ""
        CALL F.READ(FN.REDO.DISB.CHAIN, WVCR.RDC.ID, R.REDO.DISB.CHAIN, F.REDO.DISB.CHAIN, ERR.MSJDISB)
        Y.AMOUNT = R.NEW(FT.TN.AMOUNT.CREDITED)
        Y.VERSION = APPLICATION:PGM.VERSION

        GOSUB CHECK.DETAIL.DUP
        LOCATE Y.AMOUNT IN R.REDO.DISB.CHAIN<DS.CH.AMOUNT,1> SETTING Y.POS.RDC THEN
            Y.RECORD.STATUS = R.REDO.DISB.CHAIN<DS.CH.TR.STATUS,Y.POS.RDC>
            Y.VERSION.NAME = R.REDO.DISB.CHAIN<DS.CH.VERSION,Y.POS.RDC>

            IF Y.RECORD.STATUS EQ 'INAU' AND Y.VERSION.NAME EQ Y.VERSION THEN
                IF Y.ALLOW EQ '' THEN
                    AF = FT.TN.AMOUNT.CREDITED
                    AV = ''
                    ETEXT = "EB-REDO.FT.DUP"
                    CALL STORE.END.ERROR
                END
            END

        END
    END

RETURN

CHECK.DETAIL.DUP:


    Y.RCA.ID = ''
    Y.RCA.ID =  R.REDO.DISB.CHAIN<DS.CH.RCA.ID>
    Y.VERSION = APPLICATION:PGM.VERSION
    Y.ALLOW = ''
    Y.AMOUNT.CHECK = Y.AMOUNT[4,99]
    CALL F.READ(FN.REDO.CREATE.ARRANGEMENT,Y.RCA.ID,R.REDO.CREATE.ARRANGEMENT,F.REDO.CREATE.ARRANGEMENT,ERR.MSJ)
    Y.CNT.DIS.TYPE = DCOUNT(R.REDO.CREATE.ARRANGEMENT<REDO.FC.DIS.TYPE>,@VM)

    WRCA.CODTXN       = R.REDO.CREATE.ARRANGEMENT<REDO.FC.DIS.CODTXN>
    WRCA.DIS.AMT      = R.REDO.CREATE.ARRANGEMENT<REDO.FC.DIS.AMT>
    WRCA.DIS.TYPE     = R.REDO.CREATE.ARRANGEMENT<REDO.FC.DIS.TYPE>


    LOOP
        REMOVE WDIS.TYPE FROM WRCA.DIS.TYPE SETTING Y.TXN.POS
    WHILE WDIS.TYPE:Y.TXN.POS DO
        REMOVE WTXN.ID FROM WRCA.CODTXN SETTING Y.TXN.POS
        REMOVE WDIS.AMT FROM WRCA.DIS.AMT SETTING Y.TXN.POS
        CALL F.READ(FN.REDO.FC.TEMP.DISB,WDIS.TYPE,R.REDO.FC.TEMP.DISB,F.REDO.FC.TEMP.DISB,DISB.ERR)

        Y.CHECK.VERSION = R.REDO.FC.TEMP.DISB<FC.TD.NAME.VRN>
        IF WTXN.ID EQ "" THEN

            IF Y.VERSION EQ Y.CHECK.VERSION AND Y.AMOUNT.CHECK EQ WDIS.AMT THEN
                Y.ALLOW = '1'
            END

        END

    REPEAT


RETURN
END
