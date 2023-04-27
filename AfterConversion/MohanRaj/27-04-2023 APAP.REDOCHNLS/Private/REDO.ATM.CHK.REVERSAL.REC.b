* @ValidationCode : MjotMTE3MzYzMjY2NTpDcDEyNTI6MTY4MTM4MDg0MTQzNDpJVFNTOi0xOi0xOjQwMDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 400
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATM.CHK.REVERSAL.REC (YY.ATM.TXN.REF,R.ATM.REVERSAL)

*This routine is to identify the ATM.REVERSAL record for acquirer transactions
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 11-APR-2023      Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.FUNDS.TRANSFER
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.ATM.REVERSAL
    $INSERT I_AT.ISO.COMMON
    $INSERT I_ATM.BAL.ENQ.COMMON
    $INSERT I_F.ACCOUNT
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.APAP.H.PARAMETER
    $INSERT I_F.CURRENCY

    Y.ATM.TXN.REF=YY.ATM.TXN.REF

    FN.REDO.ATM.ACQUIRER='F.REDO.ATM.ACQUIRER'
    F.REDO.ATM.ACQUIRER=''
    CALL OPF(FN.REDO.ATM.ACQUIRER,F.REDO.ATM.ACQUIRER)

    FN.ATM.REVERSAL='F.ATM.REVERSAL'
    F.ATM.REVERSAL=''
    CALL OPF(FN.ATM.REVERSAL,F.ATM.REVERSAL)

    CALL F.READ(FN.REDO.ATM.ACQUIRER,Y.ATM.TXN.REF,R.REDO.ATM.ACQUIRER,F.REDO.ATM.ACQUIRER,ERR.ACQ)

    IF NOT(R.REDO.ATM.ACQUIRER) THEN
        RETURN
    END

    Y.CARD.NUM=AT$INCOMING.ISO.REQ(2)
    Y.AUT.COD=AT$INCOMING.ISO.REQ(38)
    Y.TXN.DATE.TIME=AT$INCOMING.ISO.REQ(90)
    Y.TXN.DATE.TIME=Y.TXN.DATE.TIME[11,10]
    Y.TERM.ID=AT$INCOMING.ISO.REQ(41)
    BRK.FLAG=1
    LOOP
        REMOVE Y.AT.REV.ID FROM R.REDO.ATM.ACQUIRER SETTING POS.REV

    WHILE Y.AT.REV.ID:POS.REV

        IF BRK.FLAG THEN

            CALL F.READ(FN.ATM.REVERSAL,Y.AT.REV.ID,R.ATM.REVERSAL,F.ATM.REVERSAL,REV.ERR)

            Y.ORG.CARD=R.ATM.REVERSAL<AT.REV.CARD.NUMBER>
            Y.ORG.TXN.DATE.TIME=R.ATM.REVERSAL<AT.REV.TRANS.DATE.TIME>
            Y.ORG.AUT.COD=R.ATM.REVERSAL<AT.REV.AUTH.CODE>
            Y.ORG.TERM.ID=R.ATM.REVERSAL <AT.REV.TERM.ID>

            IF Y.CARD.NUM EQ Y.ORG.CARD AND Y.AUT.COD EQ Y.ORG.AUT.COD AND Y.TXN.DATE.TIME EQ Y.ORG.TXN.DATE.TIME AND Y.TERM.ID EQ Y.ORG.TERM.ID THEN
                Y.ATM.TXN.REF=Y.AT.REV.ID
                YY.ATM.TXN.REF=Y.ATM.TXN.REF
                BRK.FLAG=0

            END
        END

    REPEAT

    IF BRK.FLAG THEN
        R.ATM.REVERSAL=''
    END
RETURN

END
