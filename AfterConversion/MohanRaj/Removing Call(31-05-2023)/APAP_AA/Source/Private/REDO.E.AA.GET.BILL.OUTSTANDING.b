* @ValidationCode : Mjo5ODc0MTg1MzM6Q3AxMjUyOjE2ODAxODQ2NzI2MTY6SVRTUzotMTotMTo5ODoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 30 Mar 2023 19:27:52
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 98
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.E.AA.GET.BILL.OUTSTANDING
*****************************************
* This is a conversion routine
* This routine accepts Bill Id(with or without Sim Ref)
* and returns OS.TOTAL.AMOUNT from the sum of all OS.PROP.AMOUNT
*
*****************************************
*MODIFICATION HISTORY
*
* 05/01/09 - BG_100021512
*            Arguments changed for SIM.READ.
* Modification History:
* Date                 Who                              Reference                            DESCRIPTION
*29-03-2023          Conversion Tool                   AUTO R22 CODE CONVERSION              NO CHANGES
*29-03-2023          jayasurya H                       MANUAL R22 CODE CONVERSION            NO CHANGES

*****************************************
*
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AA.BILL.DETAILS
*****************************************
*
    BILL.ID = O.DATA['%',1,1]
    SIM.REF = O.DATA['%',2,1]
    R.AA.BILLS = ''
    IF SIM.REF THEN
        CALL SIM.READ(SIM.REF, "F.AA.BILL.DETAILS", BILL.ID, R.AA.BILLS, "", "", RET.ERR)
    END ELSE
        CALL F.READ("F.AA.BILL.DETAILS", BILL.ID, R.AA.BILLS, F.AA.BILLS, RET.ERR)
    END
*
    IF R.AA.BILLS THEN
        O.DATA = SUM(R.AA.BILLS<AA.BD.OS.PROP.AMOUNT>)
    END
*
RETURN
