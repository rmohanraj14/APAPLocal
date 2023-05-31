* @ValidationCode : MjotMTkwODY1MzU5NjpDcDEyNTI6MTY4MDE4NDY3MjQ0NjpJVFNTOi0xOi0xOi02OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -6
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.E.AA.FIND.TXN.VER
************************************
* Modification History
*
* 02/03/17 - PACS00574750
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES
*
*
************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
*
************************************
    TXN.ID = O.DATA
*
************************************

    BEGIN CASE
        CASE TXN.ID[1,3] EQ "TFS"
            O.DATA = "TELLER.FINANCIAL.SERVICES"
        CASE TXN.ID AND NUM(TXN.ID) EQ 1
            O.DATA = "PAYMENT.STOP"
        CASE TXN.ID[1,2] EQ "TT"
            O.DATA = "TELLER"
        CASE TXN.ID[1,2] EQ "PD"
            O.DATA = "PD.PAYMENT.DUE"
        CASE TXN.ID[1,2] EQ "LD"
            O.DATA = "LD.LOANS.AND.DEPOSITS"
        CASE TXN.ID[1,2] EQ "MD"
            O.DATA = "MD.DEAL"
        CASE TXN.ID[1,2] EQ "TF"
            O.DATA = "LETTER.OF.CREDIT"
        CASE TXN.ID[1,2] EQ "FT"
            O.DATA = "FUNDS.TRANSFER"
        CASE 1
            O.DATA = "AA.ARRANGEMENT.ACTIVITY,REDO.AA.AUTH"
    END CASE
*
************************************
RETURN
*
************************************
END
