* @ValidationCode : MjoxNzU4NzYxODQ2OkNwMTI1MjoxNjgxMzgyNzI3MTgxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:15:27
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
SUBROUTINE REDO.V.BEF.AUT.PRINT.DSLIP
***********************************************************
*----------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : IVAN ROMAN
* PROGRAM NAME : REDO.V.BEF.AUT.PRINT.DSLIP
*----------------------------------------------------------
* DESCRIPTION : This Auth routine is used for printing the required Deal Slips
*------------------------------------------------------------
*    IN PARAMETER: NONE
*    OUT PARAMETER: NONE
* Modification History:
*----------------------------------------------------------------
* DATE            WHO            REFERENCE          DESCRIPTION
* 2012.07.11      I ROMAN        PACS00186440 G8    OFS$DEAL.SLIP.PRINTING
* variable was moved to PROCESS section to avoid DEAL.SLIP.FORMAT screen empty
* PRT.ADVICED.PRODUCED added after DS generation
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DEAL.SLIP.FORMAT
    $INSERT I_GTS.COMMON
    $INSERT I_DEAL.SLIP.COMMON
    $INSERT I_F.VERSION
    $INSERT I_F.TELLER

    GOSUB INIT
    GOSUB PROCESS
RETURN

INIT:
*****

RETURN

PROCESS:
*********
*
    IF R.NEW(TT.TE.RECORD.STATUS) EQ 'INAU' THEN
        OFS$DEAL.SLIP.PRINTING = 1
        W.FUNCTION = RAISE(R.VERSION(EB.VER.D.SLIP.FUNCTION))
        W.DSFORMAT = RAISE(R.VERSION(EB.VER.D.SLIP.FORMAT))
        LOCATE "C" IN W.FUNCTION<1> SETTING DS.POS THEN
            DEAL.SLIP.ID = W.DSFORMAT<DS.POS>
            CALL PRODUCE.DEAL.SLIP(DEAL.SLIP.ID)
            PRT.ADVICED.PRODUCED = ""
        END
    END ELSE
        IF R.NEW(TT.TE.RECORD.STATUS) EQ 'INA2' THEN
            PRT.ADVICED.PRODUCED = 1
        END

    END

RETURN
END
