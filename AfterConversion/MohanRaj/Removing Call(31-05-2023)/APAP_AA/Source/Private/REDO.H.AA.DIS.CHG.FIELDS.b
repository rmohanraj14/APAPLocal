$PACKAGE APAP.AA;* MANUAL R22 CODE CONVERSION
SUBROUTINE REDO.H.AA.DIS.CHG.FIELDS
    
*-----------------------------------------------------------------------------------

* Modification History:

*DATE              WHO                REFERENCE                        DESCRIPTION
*29-03-2023    CONVERSION TOOL         AUTO R22 CODE CONVERSION           NO CHANGES
*29-03-2023      MOHANRAJ R        MANUAL R22 CODE CONVERSION         Package name added APAP.AA
*-----------------------------------------------------------------------------------


    
*-----------------------------------------------------------------------------
*This routine is used to define id and fields for the table REDO.H.AA.DIS.CHG
*-----------------------------------------------------------------------------------
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
* 23-06-2010        S.MARIMUTHU   PACS00102835           Initial Creation
* 16-01-2012        S.MARIMUTHU   PACS00170057           Field added for balance maintenance property
*-----------------------------------------------------------------------------
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*-----------------------------------------------------------------------------
    CALL Table.defineId("@ID", T24_String)          ;* Define Table id
    ID.F = '@ID'
    ID.N = '6'
    ID.T = ''
    ID.T<2> = 'SYSTEM'
*-----------------------------------------------------------------------------

* CALL Table.addField(fieldName, fieldType, args, neighbour)        ;* Add a new fields
* CALL Field.setCheckFile(fileName)   ;* Use DEFAULT.ENRICH from SS or just field 1

    fieldName = 'XX.PROPERTY.NAME'
    fieldLength = '15'
    fieldType = 'A'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('AA.PROPERTY')

    fieldName = 'INTERNAL.ACCOUNT'
    fieldLength = '20'
    fieldType = 'A'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('ACCOUNT')

    fieldName = 'RET.CHQ.CHARGE'
    fieldLength = '20'
    fieldType = 'A'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('AA.PROPERTY')

    fieldName = 'BALANCE.MAIN.PROP'
    fieldLength = '20'
    fieldType = 'A'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('AA.PROPERTY')

    fieldName = 'RES.TO.NORM.DAYS'
    fieldLength = '5'
    fieldType = ''
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

    fieldName = 'REVERSE.INT.ACC'
    fieldLength = '20'
    fieldType = 'A'
    neighbour = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('ACCOUNT')

    fieldName   = 'XX<ACTUAL.FTTC'
    fieldLength = '20'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')

    fieldName   = 'XX>REVERSAL.FTTC'
    fieldLength = '20'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')


    fieldName   = 'XX.DISB.CHG.FTTC'
    fieldLength = '20'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')

    fieldName   = 'XX.REPAY.CHG.FTTC'
    fieldLength = '20'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')

    fieldName   = 'XX.CHG.DISB.ACTIVITY'
    fieldLength = '55'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('AA.ACTIVITY')

    fieldName   = 'XX.CHG.REPAY.ACTIVITY'
    fieldLength = '55'
    fieldType   = 'A'
    neighbour   = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field
    CALL Field.setCheckFile('AA.ACTIVITY')

    CALL Table.addReservedField('RESERVED.12')
    CALL Table.addReservedField('RESERVED.11')
    CALL Table.addReservedField('RESERVED.10')
    CALL Table.addReservedField('RESERVED.9')
    CALL Table.addReservedField('RESERVED.8')
    CALL Table.addReservedField('RESERVED.7')
    CALL Table.addReservedField('RESERVED.6')
    CALL Table.addReservedField('RESERVED.5')
    CALL Table.addReservedField('RESERVED.4')
    CALL Table.addReservedField('RESERVED.3')
    CALL Table.addReservedField('RESERVED.2')
    CALL Table.addReservedField('RESERVED.1')


*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
