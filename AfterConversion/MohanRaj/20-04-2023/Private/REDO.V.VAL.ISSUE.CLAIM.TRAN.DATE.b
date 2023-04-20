* @ValidationCode : MjotMTc0NjU0OTM2NjpDcDEyNTI6MTY4MTk3MDY5MDM4MTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:34:50
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
SUBROUTINE REDO.V.VAL.ISSUE.CLAIM.TRAN.DATE
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : A Validation routine is written to check whether the TRANSACTION.DATE is greater
*than 4 years from today, an error message is displayed as no valid claim date
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : SUDHARSANAN S
* PROGRAM NAME : REDO.V.VAL.ISSUE.CLAIM.TRAN.DATE
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
* DATE             WHO                REFERENCE         DESCRIPTION
* 27.07.2010      SUDHARSANAN S     ODR-2009-12-0283  INITIAL CREATION
* 26.05.2011      PRADEEP S         PACS00071941      Validations changed for TRANSACTION.DATE
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    IF COMI THEN
        GOSUB PROCESS
    END
RETURN

*--------------------------------------------------------------------------------------------------------
PROCESS:
*--------------------------------------------------------------------------------------------------------
*PACS00071941 - Previous logic was removed

    IF COMI GT TODAY THEN
        ETEXT = 'EB-DATE.CANT.GT.THAN.TODAY'
        CALL STORE.END.ERROR
        RETURN
    END

    Y.TXN.DATE = COMI
    Y.TODAY = TODAY
    Y.SIGN = '-'
    Y.DISP = '4Y'
    CALL CALENDAR.DAY(Y.TODAY,Y.SIGN,Y.DISP)

    IF Y.DISP AND Y.TXN.DATE LT Y.DISP THEN
        ETEXT  = 'EB-NO.VAL.CLAIM.DATE'
        CALL STORE.END.ERROR
    END

*IF DATE.TODAY NE '' AND TXN.DATE NE '' THEN
*CALL CDD('',DATE.TODAY,TXN.DATE,NO.OF.DAYS)
*END
*IF NO.OF.DAYS GT 1461 THEN
*ETEXT  = 'EB-NO.VAL.CLAIM.DATE'
*CALL STORE.END.ERROR
*END

RETURN
*----------------------------------------------------------------------------------------------
END
