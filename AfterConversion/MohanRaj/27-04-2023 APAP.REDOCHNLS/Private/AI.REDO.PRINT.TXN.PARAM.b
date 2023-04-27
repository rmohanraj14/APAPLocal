$PACKAGE APAP.REDOCHNLS
* @ValidationCode : MjoxNjY0MDA5NzU1OkNwMTI1MjoxNjgwNzcyMjM0MDIxOkhhcmlzaHZpa3JhbUM6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 06 Apr 2023 14:40:34
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

SUBROUTINE AI.REDO.PRINT.TXN.PARAM
*-----------------------------------------------------------------------------
*<doc>
* TODO add a description of the application here
* @author riyasbasha@temenos.com
* @stereotype Application
* Reference:ODR-2010-08-0031

* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 06/06/2012 -
*            New Template changes
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
* ---------------------------------------------------------------------------
*    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name       = 'AI.REDO.PRINT.TXN.PARAM'    ;* Full application name including product prefix
    Table.title      = 'Print Transaction Param'    ;* Screen title
    Table.stereotype = 'H'      ;* H, U, L, W or T
    Table.product    = 'AI'     ;* Must be on EB.PRODUCT
    Table.subProduct = ''       ;* Must be on EB.SUB.PRODUCT
    Table.classification    = 'FIN'       ;* As per FILE.CONTROL
    Table.systemClearFile   = 'Y'         ;* As per FILE.CONTROL
    Table.relatedFiles      = ''          ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''          ;* As per FILE.CONTROL
    Table.equatePrefix      = 'AI.PRI'    ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix         = '' ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = '' ;* Space delimeted list of blocked functions
    Table.trigger          = '' ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
