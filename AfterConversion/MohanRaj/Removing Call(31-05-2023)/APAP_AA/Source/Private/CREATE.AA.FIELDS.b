$PACKAGE APAP.AA ;*R22 Manual Code Conversion
SUBROUTINE CREATE.AA.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine YOURAPPLICATION.FIELDS
*
* @author tcoleman@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package infra.eb
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
* 
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
* * Date                  Who                               Reference                                                Description
* ----                  ----                                ----                                                        ----
* 29-March-2023          Ajith Kumar                    R22 Manual Code Conversion                          Package Name added APAP.AA
* 29-march-2023           Conversion Tool                              R22 Auto Code Conversion                                  No Change
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
    $INSERT I_F.REDO.COLL.TYPE.DET
    $INSERT I_F.REDO.EMP.RESP.MVMT
    $INSERT I_F.COLLATERAL.RIGHT
    $INSERT I_F.COLLATERAL


*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("@ID", T24_String)          ;* Define Table id

*-----------------------------------------------------------------------------
    neighbour = ''
    fieldName = 'LIMIT'
    fieldLength = '30'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
*
    neighbour = ''
    fieldName = 'CUSTOMER'
    fieldLength = '20.1'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile("CUSTOMER")
*
*
*
    neighbour = ''
    fieldName = 'XX<ID.COLL.RIGHT'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile("COLLATERAL.RIGHT")


    neighbour = ''
    fieldName = 'XX-COLLATERAL.CODE'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile("COLLATERAL")


    neighbour = ''
    fieldName = 'XX-COLL.SD'
    fieldLength = '20'
    fieldType<3> = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

    neighbour = ''
    fieldName = 'XX>MAX.LOAN'
    fieldLength = '20'
    fieldType<3> = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

    neighbour = ''
    fieldName = 'AMOUNT'
    fieldLength = '35.1'
    fieldType = 'AMT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field


    neighbour = ''
    fieldName = 'DIS.AMOUNT.TOT'
    fieldLength = '20'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field



    neighbour = ''
    fieldName = 'ARRANGEMENT.ID'
    fieldLength = '20'
    fieldType<3> = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

    CALL Table.addField("XX.OVERRIDE", T24_String, Field_NoInput ,"")

*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
