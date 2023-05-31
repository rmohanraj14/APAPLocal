* @ValidationCode : MjoxMzYwNTU3MTI1OkNwMTI1MjoxNjgzNjk4NDIyNDc4OklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.PART.DISBURSE.FC.VALIDATE
*-----------------------------------------------------------------------------
*    First Release :
*    Developed for : APAP
*    Developed by  : TAM
*    Date          : 2012-NOV-28
*    Attached to   :
*    Attached as   :
*
* This is .validate routine to check the amount entered in REDO.AA.PART.DISBURSE.FC

* Modification History:

* PACS00236823           Marimuthu S        28-Nov-2012
* Date                   who                   Reference              
* 29-03-2023        CONVERSTION TOOL      R22 AUTO CONVERSTION - No Change
* 29-03-2023          ANIL KUMAR B      R22 MANUAL CONVERSTION -NO CHANGES
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.AA.PART.DISBURSE.FC

    Y.DIS.CHARGE = R.NEW(REDO.PDIS.CHARG.AMOUNT)
    Y.DIS.AMT = R.NEW(REDO.PDIS.DIS.AMT)
    Y.DIS.AMOUNT.TOT =  R.NEW(REDO.PDIS.DIS.AMT.TOT)

    Y.DIS.AMT.ALL=SUM(Y.DIS.AMT) + SUM(Y.DIS.CHARGE)

    IF Y.DIS.AMT.ALL NE Y.DIS.AMOUNT.TOT THEN
        AF = REDO.PDIS.DIS.AMT
        ETEXT = "EB-FC-TYPE-DISBT-NO.SAME"
        CALL STORE.END.ERROR
    END

END
