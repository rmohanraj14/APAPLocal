* @ValidationCode : MjotMjQyNzcxMDE6Q3AxMjUyOjE2ODEzODA4NTg0Njc6SVRTUzotMTotMTotMTU6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -15
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERFACE.SMAIL
*-----------------------------------------------------------------------------
*<doc>
*
* This table is used to store all the events in the interface activity
*
* author: rshankar@temenos.com
*
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* 26/07/2010 - C.22 New Template creation
*
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
* ----------------------------------------------------------------------------
* <region name= Inserts>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table

* </region>
*-----------------------------------------------------------------------------
    Table.name = 'REDO.INTERFACE.SMAIL'   ;* Full application name including product prefix
    Table.title = 'Servidor Correo Interfaces'      ;* Screen title
    Table.stereotype = 'U'      ;* H, U, L, W or T
    Table.product = 'ST'        ;* Must be on EB.PRODUCT
    Table.subProduct = 'CUSTOMER'         ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'          ;* As per FILE.CONTROL
    Table.systemClearFile = 'N' ;* As per FILE.CONTROL
    Table.relatedFiles = ''     ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''          ;* As per FILE.CONTROL
    Table.equatePrefix = 'REDO.INT.SMAIL' ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''         ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = '' ;* Space delimeted list of blocked functions
    Table.trigger = ''          ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
