* @ValidationCode : MjotMTE0MzU0NDE5MjpDcDEyNTI6MTY4MTMwMDkyNTQ5NTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 12 Apr 2023 17:32:05
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
SUBROUTINE REDO.V.AUT.ST.BUY.SELL
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: Arulprakasam P
* PROGRAM NAME: REDO.V.AUT.ST.BUY.SELL
* ODR NO      : ODR-2010-07-0082
*-----------------------------------------------------------------------------
*DESCRIPTION: This is AUTHORISATION routine for SEC.TRADE,APAP.BUY.OWN.BOOK
* to launch an enquiry  based on type of letter

*IN PARAMETER:  NA
*OUT PARAMETER: NA
*LINKED WITH: SEC.TRADE,APAP.BUY.OWN.BOOK
*----------------------------------------------------------------------
* Modification History :
*-----------------------
* Date             Author            Reference                   Description
* 27-Apr-2011      Pradeep S         PACS00056285                Removed the Actiual Coupon days logic and
*                                                                moved it to Input routine
*Modification history
*Date                Who               Reference                  Description
*12-04-2023      conversion tool     R22 Auto code conversion     VM TO @VM,FM TO @FM
*12-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_RC.COMMON
    $INSERT I_F.SEC.TRADE
    $INSERT I_F.SECURITY.MASTER
    $INSERT I_GTS.COMMON

    IF V$FUNCTION EQ 'A' THEN
        GOSUB INIT
        GOSUB PROCESS
    END
RETURN

INIT:

    LOC.REF.APPLICATION = 'SEC.TRADE'
    LOC.REF.FIELDS = 'L.ST.ACTCOUPDAY':@VM:'L.ST.HOLD.REF'
    LOC.REF.POS = ''

RETURN

PROCESS:

    FIELD.POS = ''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,FIELD.POS)
    POS.ACTCOUPDAY = FIELD.POS<1,1>
    POS.HOLD.REF = FIELD.POS<1,2>

    OFS$DEAL.SLIP.PRINTING = '1'
    SAVE.APPLICATION = APPLICATION

    DEAL.SLIP.ID = 'REDO.BUY.SELL'
    CALL PRODUCE.DEAL.SLIP(DEAL.SLIP.ID)

    ST.HOLD.ID = C$LAST.HOLD.ID
    CHANGE ',' TO @FM IN ST.HOLD.ID
    IF LEN(ST.HOLD.ID<1>) EQ '17' THEN
        ST.HOLD.ID = ST.HOLD.ID<1>
    END ELSE
        ST.HOLD.ID = ST.HOLD.ID<2>
    END

    R.NEW(SC.SBS.LOCAL.REF)<1,POS.HOLD.REF> = ST.HOLD.ID

RETURN

END
