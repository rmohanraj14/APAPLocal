$PACKAGE APAP.AA ;*R22 Manual Code Conversion 
SUBROUTINE REDO.AA.ACTIVITY.LOG.FIELDS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine is used to define id and fields for the table REDO.AA.DD.CATEGORY
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
*------------------
*   Date               who           Reference            Description
* 31-10-2017          Edwin Charles  PACS00625972         Initial Creation
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023       Conversion Tool                     R22 Auto Code Conversion             Nochange
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*** <region name= Header>
*-----------------------------------------------------------------------------------

*

*-----------------------------------------------------------------------------------

*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("@ID", T24_String)        ;* Define Table id
    ID.F = '@ID'
    ID.N = '25'
    ID.T = 'A'
*-----------------------------------------------------------------------------
*
    neighbour = ''
    fieldName = 'ARRANGEMENT.ID'
    fieldLength = '15'
    fieldType = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'EFFECTIVE.DATE'
    fieldLength = '12'
    fieldType = 'D'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'ACTIVITY.REF'
    fieldLength = '26'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'ACTIVITY.NAME'
    fieldLength = '65'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'INIT'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'IN.TIMESTAMP'
    fieldLength = '65'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    CALL Table.setAuditPosition         ;* Poputale audit information

RETURN
END
