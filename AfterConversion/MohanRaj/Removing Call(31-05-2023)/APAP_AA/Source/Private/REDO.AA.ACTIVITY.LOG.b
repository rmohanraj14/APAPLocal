$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE REDO.AA.ACTIVITY.LOG
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This template is used to maintain the details for a categories for direct debit
*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*
* Dependencies:
*---------------
* CALLS : -NA-
* CALLED BY : -NA-
*
* Revision History:
*-----------------------------------------------------------------------------
*   Date               who              Reference            Description
* 31-Oct-2017        Edwin Charles D    PACS00625972        DD Direct Debit CR
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023        Conversion Tool                    R22 Auto Code Conversion             Nochange
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

* Modification History: Code conversion

* Package Name added APAP.AA

*-----------------------------------------------------------------------------------

* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'REDO.AA.ACTIVITY.LOG' ;* Full application name including product prefix
    Table.title = 'Redo Activity Log'   ;* Screen title
    Table.stereotype = 'H'    ;* H, U, L, W or T
    Table.product = 'EB'      ;* Must be on EB.PRODUCT
    Table.subProduct = ''     ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'        ;* As per FILE.CONTROL
    Table.systemClearFile = ''          ;* As per FILE.CONTROL
    Table.relatedFiles = ''   ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''        ;* As per FILE.CONTROL
    Table.equatePrefix = 'RE.LOG'       ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
RETURN
END
