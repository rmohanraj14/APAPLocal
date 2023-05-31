$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE APAP.AA.INSURANCE
*-----------------------------------------------------------------------------
*<doc>
* TODO add a description of the application here.
* @author youremail@temenos.com
* @stereotype Application
* @package TODO define the product group and product, e.g. infra.eb
* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*-----------------------
* Date                  Who                               Reference           Description
* 19/10/07 - EN_10003543
*            New Template changes
** Date                     Who                        Reference                                        Description
* ----                    ----                                ----                                        ----
* 29-March-2023          Ajith Kumar              Manual R22 Code Conversion                Package Name added APAP.AA
* 29-March-2023          Conversion Tool              R22 Auto Code Conversion                              No Change
*
* ----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------


*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table

*-----------------------------------------------------------------------------
    Table.name = 'APAP.AA.INSURANCE'      ;* Full application name including product prefix
    Table.title = 'CONCAT AA - INSURANCE' ;* Screen title
    Table.stereotype = 'T'      ;* H, U, L, W or T
    Table.product = 'EB'        ;* Must be on EB.PRODUCT
    Table.subProduct = ''       ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'          ;* As per FILE.CONTROL
    Table.systemClearFile = ''  ;* As per FILE.CONTROL
    Table.relatedFiles = ''     ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''          ;* As per FILE.CONTROL
    Table.equatePrefix = 'AA.INS'         ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''         ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = '' ;* Space delimeted list of blocked functions
    Table.trigger = ''          ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
