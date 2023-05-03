* @ValidationCode : MjoxOTE5OTk2NzYxOkNwMTI1MjoxNjgyMDcwNzkwNzU2OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:23:10
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
$PACKAGE APAP.LAPAP
SUBROUTINE LAPAP.CHK.OCC.CUSTOMER
*--------------------------------------------------------------------------------------------------------------------------------
* DESCRIPTION :
*
* Note    : Make all occasional customer fields no inputable at first
*--------------------------------------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN Parameter    : NA
* OUT Parameter   : NA
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : J.Q.
* PROGRAM NAME : LAPAP.CHK.OCC.CUSTOMER
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------------------------------
* Date             Author             Reference         Description
*
* 25-07-2022      JQ - APAP           CTO-46       Making all occasional customer field as non-inputable field
*                                                  to achieve the if Client is Non-APAP & using Passport, those fields
*                                                  need to be an inputtable field.
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-----------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ID.CARD.CHECK
    $INSERT I_System

    GOSUB GET.L.REF
    GOSUB MAKE.NO.INPUT
    GOSUB CLEAR.CURR.VAR

RETURN

*---------------------------------------------------------------------------------------------------------

GET.L.REF:
*-------------
    APPL.NAME.ARR = "REDO.ID.CARD.CHECK"
    FLD.NAME.ARR = "L.ADDRESS" : @VM : "L.TELEPHONE" : @VM : "L.ADI.INFO" : @VM : "L.NACIONALITY" : @VM : "L.BIRTH.DATE"
    FLD.NAME.ARR := @VM : "L.OCC.GENDER" : @VM : "L.OCC.D.ADDRESS"
    CALL MULTI.GET.LOC.REF(APPL.NAME.ARR,FLD.NAME.ARR,FLD.POS.ARR)
RETURN
*---------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------

MAKE.NO.INPUT:
*-------------
    Y.L.ADDRESS.POS = FLD.POS.ARR<1,1>
    Y.L.TELEPHONE.POS = FLD.POS.ARR<1,2>
    Y.L.ADI.INFO.POS = FLD.POS.ARR<1,3>
    Y.L.NACIONALITY.POS = FLD.POS.ARR<1,4>
    Y.L.BIRTH.DATE.POS = FLD.POS.ARR<1,5>
    Y.L.OCC.GENDER.POS = FLD.POS.ARR<1,6>
    Y.L.OCC.D.ADDRESS.POS = FLD.POS.ARR<1,7>

    T.LOCREF<Y.L.ADDRESS.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.TELEPHONE.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.ADI.INFO.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.NACIONALITY.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.BIRTH.DATE.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.OCC.GENDER.POS,7> = 'NOINPUT'
    T.LOCREF<Y.L.OCC.D.ADDRESS.POS,7> = 'NOINPUT'


RETURN
*----------------------------------------------------------------------------------------------------------
CLEAR.CURR.VAR:
    CALL System.setVariable("CURRENT.VAR.ACCTY.RAN","")
    CALL System.setVariable("CURRENT.VAR.ACCTY.VAL","")

RETURN

END
