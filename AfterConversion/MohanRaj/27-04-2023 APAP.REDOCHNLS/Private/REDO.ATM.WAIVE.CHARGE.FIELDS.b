* @ValidationCode : MjoxNjA5MjI0MTkyOkNwMTI1MjoxNjgxMjE1MTY0NDA4OklUU1M6LTE6LTE6LTEwOjE6dHJ1ZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -10
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATM.WAIVE.CHARGE.FIELDS
*-----------------------------------------------------------------------------
*<doc>
******************************************************************************
*Company   Name    : APAP Bank
*Developed By      : Temenos Application Management
*Program   Name    : REDO.ATM.WAIVE.CHARGE.FIELDS
*-----------------------------------------------------------------------------
*Description       : This routine is a .FIELDS routine for template REDO.ATM.WAIVE.CHARGE
*
*</doc>
*-----------------------------------------------------------------------------
*Modification Details:
*=====================
* Date            Who                    Reference         Description
* ------          ------                 -------------     -------------
* 22-Jan-2019     Vignesh Kumaar M R     CI#2795720        BRD003 - UNARED
* 10-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
* ----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("ATM.WAIVE", T24_String)  ;* Define Table id
    ID.N = '11'    ; ID.T = 'ANY'
*-----------------------------------------------------------------------------
    neighbour = ''
    fieldName = 'BIN.NUMBER'
    fieldLength = '6'
    fieldType = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    CALL Field.setCheckFile("REDO.CARD.BIN")

    neighbour = ''
    fieldName = 'TERMINAL.ID'
    fieldLength = '8'
    fieldType = 'ANY':@FM:'':@FM:'NOINPUT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field

    neighbour = ''
    fieldName = 'MER.CATEG.CODE'
    fieldLength = '5'
    fieldType = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    CALL Field.setCheckFile("CATEGORY")

    neighbour = ''
    fieldName = 'ACC.CATEG.CODE'
    fieldLength = '5'
    fieldType = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    CALL Field.setCheckFile("CATEGORY")

    neighbour = ''
    fieldName = 'ACQ.CCY.CODE'
    fieldLength = '3'
    fieldType = ''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    CALL Field.setCheckFile("NUMERIC.CURRENCY")

    neighbour = ''
    fieldName = 'ACQ.INST.CODE'
    fieldLength = '2'
    fieldType = 'N':@FM:'':@FM:'NOINPUT'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour) ;* Add a new field
    CALL Field.setCheckFile("REDO.DC.TXN.INST")

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
    CALL Table.addOverrideField

    CALL Table.setAuditPosition         ;* Poputale audit information

RETURN
*-----------------------------------------------------------------------------
END
