* @ValidationCode : MjotMTI1ODI1NTMwMjpDcDEyNTI6MTY4MTM4NzU0MzQyMjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 17:35:43
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
SUBROUTINE REDO.V.DEL.AVAILABILITY(DEL.ID)
*-----------------------------------------------------------------------------
* Description:
* This routine is a multithreaded routine to delete the records in the mentioned applns
*------------------------------------------------------------------------------------------
* * Input / Output
*
* --------------
* IN     : -NA-
* OUT    : -NA-
*------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : MARIMUTHU S
* PROGRAM NAME : REDO.V.DEL.AVAILABILITY
*------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO            REFERENCE         DESCRIPTION
* 15.04.2010  MARIMUTHU S     ODR-2009-11-0200  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* -----------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.H.DEPOSIT.RECEIPTS
    $INSERT I_F.REDO.H.PASSBOOK.INVENTORY
    $INSERT I_F.REDO.H.ADMIN.CHEQUES
    $INSERT I_F.REDO.H.BANK.DRAFTS
    $INSERT I_F.REDO.H.DEBIT.CARDS
    $INSERT I_REDO.V.DEL.AVAILABILITY.COMMON
    $INSERT I_BATCH.FILES
*-----------------------------------------------------------------------------
    GOSUB PROCESS
    GOSUB PROGRAM.END
*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    BEGIN CASE

        CASE CONTROL.LIST<1,1> EQ 'REDO.H.DEPOSIT.RECEIPTS'
            CALL F.DELETE(FN.REDO.H.DEPOSIT.RECEIPTS,DEL.ID)

        CASE CONTROL.LIST<1,1> EQ 'REDO.H.PASSBOOK.INVENTORY'
            CALL F.DELETE(FN.REDO.H.PASSBOOK.INVENTORY,DEL.ID)

        CASE CONTROL.LIST<1,1> EQ 'REDO.H.ADMIN.CHEQUES'
            CALL F.DELETE(FN.REDO.H.ADMIN.CHEQUES,DEL.ID)

        CASE CONTROL.LIST<1,1> EQ 'REDO.H.BANK.DRAFTS'
            CALL F.DELETE(FN.REDO.H.BANK.DRAFTS,DEL.ID)

        CASE CONTROL.LIST<1,1> EQ 'REDO.H.DEBIT.CARDS'
            CALL F.DELETE(FN.REDO.H.DEBIT.CARDS,DEL.ID)

    END CASE

RETURN
*-----------------------------------------------------------------------------
PROGRAM.END:
*-----------------------------------------------------------------------------
END
