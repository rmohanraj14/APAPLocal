* @ValidationCode : MjotNDEyNTE5ODEwOkNwMTI1MjoxNjgxMjE1MTYxMDI1OklUU1M6LTE6LTE6MDoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:41
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
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.LIST.CRM.PRODUCTS.VALIDATE
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------------------------------------------------------------
*  DATE             WHO             REFERENCE         DESCRIPTION
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
    $INSERT I_F.AI.REDO.LIST.CRM.PRODUCTS

    AV.LIST = REDO.CRM.DESCRIPTION
    CALL  DUP.FLD.SET(AV.LIST)
END
