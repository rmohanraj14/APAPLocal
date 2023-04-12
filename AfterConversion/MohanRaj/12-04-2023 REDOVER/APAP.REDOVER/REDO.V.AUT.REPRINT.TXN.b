* @ValidationCode : MjoxOTgxNzM0OTAxOkNwMTI1MjoxNjgxMzAwMzY3NTczOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:22:47
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
SUBROUTINE REDO.V.AUT.REPRINT.TXN
***********************************************************
*----------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : S SUDHARSANAN
* PROGRAM NAME : REDO.V.AUT.REPRINT.TXN
* ODR NUMBER   : ODR-2009-10-0472
*----------------------------------------------------------
* DESCRIPTION : This Auth routine is used for reprinting the required Deal Slips
*------------------------------------------------------------

*    IN PARAMETER: NONE
*    OUT PARAMETER: NONE
* Modification History:
*----------------------------------------------------------------
* DATE            WHO            REFERENCE          DESCRIPTION
* 12.03.2011   V NAVA           PACS00146852     OFS$DEAL.SLIP.PRINTING
* variable was moved to PROCESS section to avoid DEAL.SLIP.FORMAT screen empty
* PRT.ADVICED.PRODUCED added after DS generation
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.DEAL.SLIP.FORMAT
    $INSERT I_F.REDO.REPRINT.TXN
    $INSERT I_GTS.COMMON
    $INSERT I_DEAL.SLIP.COMMON
    $INSERT I_ENQUIRY.COMMON

    GOSUB INIT
    GOSUB PROCESS
RETURN

INIT:
*****
    FN.REDO.REP.TXN='F.REDO.REPRINT.TXN'
    F.REDO.REP.TXN=''
    CALL OPF(FN.REDO.REP.TXN,F.REDO.REP.TXN)

* OFS$DEAL.SLIP.PRINTING = 1
    V$FUNCTION = "I"
    SAVE.APPLICATION = APPLICATION

RETURN

PROCESS:
*********
    Y.CONTRACT.NO=R.NEW(REP.TXN.CONTRACT.NO)
    Y.CONT.NO=Y.CONTRACT.NO[1,2]
    Y.SPOOL.ENT.ID = R.NEW(REP.TXN.HOLD.CONTROL.ID)
    IF Y.SPOOL.ENT.ID EQ "" THEN
        ETEXT = 'TT-RET.IDHC.MISS'
        CALL STORE.END.ERROR
        RETURN
    END
*
    IF Y.CONT.NO EQ 'FT' THEN
*
        GOSUB GET.ENQ.HC
*
*        OFS$DEAL.SLIP.PRINTING = 1
*        ID.NEW=Y.CONTRACT.NO
*        DEAL.SLIP.ID='AML.FT.RTE.FORM'
*        CALL PRODUCE.DEAL.SLIP(DEAL.SLIP.ID)
*        PRT.ADVICED.PRODUCED = ""
    END
    IF Y.CONT.NO EQ 'TT' THEN
*
        GOSUB GET.ENQ.HC
*
*        OFS$DEAL.SLIP.PRINTING = 1
*        ID.NEW=Y.CONTRACT.NO
*        DEAL.SLIP.ID='AML.TT.RTE.FORM'
*        CALL PRODUCE.DEAL.SLIP(DEAL.SLIP.ID)
*        PRT.ADVICED.PRODUCED = ""
    END
    IF Y.CONTRACT.NO[1,5] EQ 'T24FS' THEN
        GOSUB GET.ENQ.HC
    END


RETURN
*
GET.ENQ.HC:
***********
*
    ENQ.DETS = 'ENQ REDO.RTE.REPORT.LIST'
    ENQ.DETS<2,1> = '@ID'
    ENQ.DETS<3,1> = 'EQ'
    ENQ.DETS<4,1> = Y.SPOOL.ENT.ID

    NEXT.TASK = ENQ.DETS<1> :' ': ENQ.DETS<2,1> :' ': ENQ.DETS<3,1> :' ': ENQ.DETS<4,1>

    CALL EB.SET.NEW.TASK(NEXT.TASK)
*
RETURN
*
END
