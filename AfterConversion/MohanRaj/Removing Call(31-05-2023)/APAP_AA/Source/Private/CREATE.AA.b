$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE CREATE.AA
*-----------------------------------------------------------------------------
*<doc>
* TODO add a description of the application here
* @author youremail@temenos.com
* @stereotype Application
* @package TODO define the product group and product, e.g. infra.eb
* </doc>
*-----------------------------------------------------------------------------
* TODO - You MUST write a REDO.CREATE.ARRANGEMENT.FIELDS routine for the field definitions
*-----------------------------------------------------------------------------
* Modification History :
*
*-----------------------
*   Date                         Who                     Reference                                        Description
* 19/05/2010                                                                                            Initial Creation
*  29-March-2023          Ajith Kumar                 R22 manual Code Conversion                       Package Name added APAP.AA
*  29-March-2023     Conversion Tool                                R22 Auto Code Conversion                               No Change
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'CREATE.AA'    ;* Full application name including product prefix
    Table.title = 'CREATE.AA'   ;* Screen title
    Table.stereotype = 'H'      ;* H, U, L, W or T
    Table.product = 'ST'        ;* Must be on EB.PRODUCT
    Table.subProduct = ''       ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'          ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y' ;* As per FILE.CONTROL
    Table.relatedFiles = ''     ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''          ;* As per FILE.CONTROL
    Table.equatePrefix = 'REDO.CR.AA'     ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''         ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = '' ;* Space delimeted list of blocked functions
    Table.trigger = ''          ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------
RETURN
END
