* @ValidationCode : MjotODE1OTg2NTk2OkNwMTI1MjoxNjgxODE2MTc2ODc1OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 18 Apr 2023 16:39:36
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
SUBROUTINE REDO.V.UPD.LATAM.CARD.SERIES
*-----------------------------------------------------------------------------
* DESCRIPTION
*-----------
* This is a routine will be called by CARD.ISSUE,SBP during authorization
*
*-------------------------------------------------------------------------------------
* This subroutine caters the following task :-
* This routine will update the LATAM.CARD.ORDER application when a changes made is CARD.ISSUE start no
* table through OFS
*-----------------------------------------------------------------------------------------
* Input / Output
* --------------
* IN     : -na-
* OUT    : -na-
* Dependencies
* ------------
*
*-------------------------------------------------------------------------------------------
* Revision History
*-------------------------
*    Date             Who               Reference       Description
*  20-Apr-2011   Balagurunathan           TDN4            Initial Draft
*Modification history
*Date                Who               Reference                  Description
*18-04-2023      conversion tool     R22 Auto code conversion     No changes
*18-04-2023      Mohanraj R          R22 Manual code conversion   No changes___________________________________________________________________________________________

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.CARD.ISSUE
    $INSERT I_F.LATAM.CARD.ORDER

    FN.LATAM.CARD.ORDER='F.LATAM.CARD.ORDER'
    F.LATAM.CARD.ORDER=''
    CALL OPF(FN.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER)

    CALL F.READU(FN.LATAM.CARD.ORDER,ID.NEW,R.LATAM.CARD.ORDER,F.LATAM.CARD.ORDER,ERR,'P')

    R.LATAM.CARD.ORDER<CARD.IS.CARD.START.NO>=R.NEW(CARD.IS.CARD.START.NO)

    CALL F.WRITE(FN.LATAM.CARD.ORDER,ID.NEW,R.LATAM.CARD.ORDER)

RETURN

END
