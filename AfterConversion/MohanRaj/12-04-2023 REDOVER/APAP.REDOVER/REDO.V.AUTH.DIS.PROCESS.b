* @ValidationCode : MjotMTAzODUwNTkzNDpDcDEyNTI6MTY4MTMwMzAzNDYzOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 18:07:14
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
SUBROUTINE REDO.V.AUTH.DIS.PROCESS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is an authorisation routine attached to below versions,
*TELLER,COLLECT.AA.REPAY

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
* 10-11-2010        JEEVA T        ODR-2010-08-0017    Baselined after few logic changes
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     No changes
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*------------------------------------------------------------------------------------------
    $INSERT I_EQUATE
    $INSERT I_COMMON
    $INSERT I_F.TELLER
    $INSERT I_F.FUNDS.TRANSFER
*   $INSERT I_F.TELLER
    $INSERT I_F.REDO.MTS.DISBURSE


    GOSUB INIT
    GOSUB PROCESS
RETURN

******
INIT:
******
*Initialize all the variables

    FN.REDO.MTS.DISBURSE = 'F.REDO.MTS.DISBURSE'
    F.REDO.MTS.DISBURSE = ''
    CALL OPF(FN.REDO.MTS.DISBURSE,F.REDO.MTS.DISBURSE)

RETURN
*********
PROCESS:
*********
* Removal of Transaction ID from the local table

    IF APPLICATION EQ 'FUNDS.TRANSFER' AND PGM.VERSION EQ ",REDO.AA.CUS.PAY" THEN
        VAR.FT.PROCESS.ID=R.NEW(FT.CREDIT.THEIR.REF)
        CALL F.DELETE(FN.REDO.MTS.DISBURSE,VAR.FT.PROCESS.ID)
    END
    IF APPLICATION EQ 'TELLER' AND PGM.VERSION EQ ",REDO.AA.CUS.PAY" THEN
        VAR.FT.PROCESS.ID=R.NEW(TT.TE.NARRATIVE.1)
        CALL F.DELETE(FN.REDO.MTS.DISBURSE,VAR.FT.PROCESS.ID)
    END
RETURN
*******************************************************************************************
END
