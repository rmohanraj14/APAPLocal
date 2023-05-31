$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.ACCOUNT.CATEGORY
*-----------------------------------------------------------------------------
* Company Name  : APAP DEV2
* Developed By  : Ravikiran
* Program Name  : REDO.AA.ACCOUNT.CATEGORY
*-----------------------------------------------------------------------------
* Description : This application is for Interest Claffification
*-----------------------------------------------------------------------------
* Linked With   : -NA-
* In Parameter  : -NA-
* Out Parameter : -NA-
*-----------------------------------------------------------------------------
* Modification History :

*
*-----------------------
* Reference              Date                Description
* ODR-2011-09-0029      23-Jan-2011          Initial draft
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023        Conversion Tool                    R22 Auto Code Conversion             Nochange
* ----------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'REDO.AA.ACCOUNT.CATEGORY'     ;* Full application name including product prefix
    Table.title = 'AA Account Category'       ;* Screen title
    Table.stereotype = 'H'    ;* H, U, L, W or T
    Table.product = 'AA'      ;* Must be on EB.PRODUCT
    Table.subProduct = ''     ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'FIN'        ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y'         ;* As per FILE.CONTROL
    Table.relatedFiles = ''   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''        ;* As per FILE.CONTROL
    Table.equatePrefix = 'REDO.AA.ACC.CAT'         ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''       ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = ''         ;* Space delimeted list of blocked functions
    Table.trigger = ''        ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
