* @ValidationCode : MjoxNTA2MDM4Mzc0OkNwMTI1MjoxNjgxOTcwNDAyMDQ4OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 20 Apr 2023 11:30:02
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
SUBROUTINE REDO.V.VAL.GET.GAR.BENEFICIARY
*----------------------------------------------------------------------
*Description:
*This is an Validation routine for the version APAP.H.GARNISH.DETAILS,DEL
*---------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : Prabhu N
* Program Name  : REDO.V.VAL.GET.GAR.BENEFICIARY
* ODR NUMBER    : ODR-2009-10-0531
*----------------------------------------------------------------------
*Input param = none
*output param =none

*-------------------------------------------------------------------------
*Date        Who                ref                    Desc
*01 nov 2011 Prabhu         PACS00149089           initial creation
*Modification history
*Date                Who               Reference                  Description
*20-04-2023      conversion tool     R22 Auto code conversion     No changes
*20-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*---------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.APAP.H.GARNISH.DETAILS
    GOSUB PROCESS
RETURN
*---------------------------------
PROCESS:
*---------------------------------
*Getting the values using R.NEW
*---------------------------------
    IF COMI EQ 'PAYMENT.TO.CREDITOR' AND NOT(VAL.TEXT) THEN
        R.NEW(APAP.GAR.BENEFICIARY)<1,1>=R.NEW(APAP.GAR.NAME.CREDITOR)
    END
    ELSE
        IF NOT(VAL.TEXT) THEN
            R.NEW(APAP.GAR.BENEFICIARY)<1,1>=''
        END
    END
RETURN
*-----------------------------------
END
