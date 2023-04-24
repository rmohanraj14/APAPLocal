* @ValidationCode : MjoxOTk2NjI3NzUyOkNwMTI1MjoxNjgxMjE2NDgxOTY2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 18:04:41
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
SUBROUTINE REDO.V.ANC.DEFAULT.TELLER
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.V.ANC.DEFAULT.TELLER
* ODR NO      : ODR-2009-12-0285
*----------------------------------------------------------------------
*DESCRIPTION: This routine is auto new content routine attached to TELLER.ID
* field in below versions
* TELLER,CHQ.OTHERS
* TELLER,CHQ.NO.TAX
* TELLER,CHQ.TAX
* TELLER,MGR.CHQ.TAX
* TELLER,MGR.CHQ.NOTAX
* TELLER,MGR.CHQ.TAX
* TELLER,MGR.CHQ.NOTAX


*IN PARAMETER: NA
*OUT PARAMETER: NA
*LINKED WITH: TELLER
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*19.02.2010  H GANESH     ODR-2009-12-0285  INITIAL CREATION
*Modification history
*Date                Who               Reference                  Description
*11-04-2023      conversion tool     R22 Auto code conversion     No changes
*11-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    $INSERT I_TT.COMMON
    $INSERT I_F.TELLER.ID

    GOSUB OPENFILES
    GOSUB PROCESS
RETURN
*----------------------------------------------------------------------
OPENFILES:
*----------------------------------------------------------------------
    FN.TELLER.ID='F.TELLER.ID'
    F.TELLER.ID=''
    CALL OPF(FN.TELLER.ID,F.TELLER.ID)
RETURN

*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    SEL.CMD="SELECT ":FN.TELLER.ID:" WITH USER EQ '":OPERATOR:"' AND STATUS EQ OPEN"
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',SEL.NOR,SEL.RET)
    R.NEW(TT.TE.TELLER.ID.1)=SEL.LIST<1,1>
    R.NEW(TT.TE.TELLER.ID.2)=SEL.LIST<1,1>
RETURN
END
