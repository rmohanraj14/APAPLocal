$PACKAGE APAP.AA ;* R22 Manual Code Conversion 
SUBROUTINE REDO.AA.ACCOUNT.CATEGORY.FIELDS
*-----------------------------------------------------------------------------
* Company Name  : APAP DEV2
* Developed By  : Ravikiran
* Program Name  : REDO.AA.ACCOUNT.CATEGORY.FIELDS
*-----------------------------------------------------------------------------
* Description : This application is linked to REDO.AA.NAB.HISTORY
*-----------------------------------------------------------------------------
* Linked With   : -NA-
* In Parameter  : -NA-
* Out Parameter : -NA-
*-----------------------------------------------------------------------------
* Modification History :
*
*-----------------------
* Reference              Date                Description
* ODR-2011-09-0029      23-Jan-2012          Initial draft
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar       R22 Manual Code Conversion       Package Name added APAP.AA
* 29-March-2023        Conversion Tool                    R22 Auto Code Conversion             Nochange
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId('ID', T24_String)
    ID.CHECKFILE = 'AA.PRODUCT'
*-----------------------------------------------------------------------------

    fieldName = 'NAB.CHANGE.DATE'
    fieldLength = '8'
    fieldType = 'D'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName = 'CURRENCY'
    fieldLength = '3'
    fieldType = 'IN2CCY'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
