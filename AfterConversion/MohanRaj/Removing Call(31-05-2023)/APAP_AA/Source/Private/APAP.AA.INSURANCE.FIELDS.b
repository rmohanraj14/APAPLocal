$PACKAGE APAP.AA ;*Manual R22 Code Conversion
SUBROUTINE APAP.AA.INSURANCE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine REDO.FC.LIMIT.AA
*
* @author lpazminodiaz@temenos.com
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
* * Date                     Who                        Reference                                        Description
* ----                    ----                                ----                                        ----
* 29-March-2023          Ajith Kumar              Manual R22 Code Conversion                Package Name added APAP.AA
* 29-March-2023        Conversion Tool                           R22 Auto  Code Conversion                               No Change
*
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------------

*

*-----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes

*-----------------------------------------------------------------------------

    CALL Table.defineId("ARRAMGEMENT.ID", T24_String)         ;* Define Table id

*-----------------------------------------------------------------------------

    neighbour = ''
    fieldName = 'XX.INSURANCE.ID'
    fieldLength = '50'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field


*-----------------------------------------------------------------------------
END
