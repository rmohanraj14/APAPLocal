$PACKAGE APAP.AA;*MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.H.AA.DIS.CHG
    
    
*-----------------------------------------------------------------------------------

* Modification History:
*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023     CONVERSION TOOL        AUTO R22 CODE CONVERSION            NO CHANGES
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA

*-----------------------------------------------------------------------------------


*-------------------------------
*DESCRIPTION:
*------------
*This routine is used to define id and fields for the table REDO.H.AA.DIS.CHG
*--------------------------------------------------------------------------------
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
*------------------
*   Date               who           Reference            Description
* 10-08-2011        S.MARIMUTHU     PACS00102835          Initial Creation
*------------------------------------------------------------------------------
* <region name= Inserts>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
* </region>
*-----------------------------------------------------------------------------
    Table.name = 'REDO.H.AA.DIS.CHG'      ;* Full application name including product prefix
    Table.title = 'REDO.H.AA.DIS.CHG'     ;* Screen title
    Table.stereotype = 'H'      ;* H, U, L, W or T
    Table.product = 'EB'        ;* Must be on EB.PRODUCT
    Table.subProduct = ''       ;* Must be on EB.SUB.PRODUCT
    Table.classification = 'INT'          ;* As per FILE.CONTROL
    Table.systemClearFile = 'Y' ;* As per FILE.CONTROL
    Table.relatedFiles = ''     ;* As per FILE.CONTROL
    Table.isPostClosingFile = ''          ;* As per FILE.CONTROL
    Table.equatePrefix = 'REDO.DIS.CHG'   ;* Use to create I_F.EB.LOG.PARAMETER
*-----------------------------------------------------------------------------
    Table.idPrefix = ''         ;* Used by EB.FORMAT.ID if set
    Table.blockedFunctions = '' ;* Space delimeted list of blocked functions
    Table.trigger = ''          ;* Trigger field used for OPERATION style fields
*-----------------------------------------------------------------------------

RETURN
END
