* @ValidationCode : MjotMTUxNDI3NzA2MzpDcDEyNTI6MTY4MTgxNTI5MDg1NDo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:24:50
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
SUBROUTINE REDO.V.TEMP.ROU.CREDIT.OVERRIDE
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Program   Name    :REDO.V.TEMP.ROU.CREDIT.OVERRIDE
*---------------------------------------------------------------------------------

*DESCRIPTION       :This routine will be used to throw the override depends on credit card status

*LINKED WITH       :

*------------------------------------------------------------------------------------
*Modification Details:
*=====================
*   Date               who           Reference            Description
* 06-Jun-2017       Edwin Charles D  R15 Upgrade         Initial Creation
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.FT.TT.TRANSACTION

MAIN:

    GOSUB PROCESS
    GOSUB PGM.END

PROCESS:

    Y.CREDIT.CARD.ST = R.NEW(FT.TN.L.FT.CR.CRD.STS)
    Y.CR.ACCT.ST = R.NEW(FT.TN.L.FT.AC.STATUS)
    IF Y.CREDIT.CARD.ST NE 'CANCELADA' AND Y.CREDIT.CARD.ST NE 'ACTIVA' THEN
        AF = FT.TN.L.FT.CR.CRD.STS
        CURR.NO = DCOUNT(R.NEW(FT.TN.OVERRIDE),@VM) + 1
        TEXT = 'REDO.CR.CRD.ST':@FM:Y.CREDIT.CARD.ST
        CALL STORE.OVERRIDE(CURR.NO)
    END

    IF Y.CR.ACCT.ST NE 'CANCELADA' AND Y.CR.ACCT.ST NE 'ACTIVA' AND Y.CR.ACCT.ST NE 'CERRADO' THEN
        AF = FT.TN.L.FT.AC.STATUS
        CURR.NO = DCOUNT(R.NEW(FT.TN.OVERRIDE),@VM) + 1
        TEXT = 'REDO.CR.CRD.AC.ST':@FM:Y.CR.ACCT.ST
        CALL STORE.OVERRIDE(CURR.NO)
    END


RETURN

PGM.END:

END
