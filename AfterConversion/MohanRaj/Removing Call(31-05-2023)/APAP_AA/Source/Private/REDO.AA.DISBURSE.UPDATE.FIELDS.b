* @ValidationCode : MjotMjA4MDA3ODM4NzpDcDEyNTI6MTY4MzY5ODQyMTY3MTpJVFNTOi0xOi0xOi0xMjoxOnRydWU6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 May 2023 11:30:21
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -12
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.AA
SUBROUTINE REDO.AA.DISBURSE.UPDATE.FIELDS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
*This routine is used to define id and fields for the table REDO.AA.DISBURSE.UPDATE
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
* 28-04-2011          Bharath        ODR-2010-08-0017     Initial Creation
* 29-03-2023          Conversion Tool      R22 AUTO CONVERSTION - No Change
* 29-03-2023          ANIL KUMAR B         R22 MANUAL CONVERSTION -NO CHANGES
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_Table
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
*    CALL Table.defineId("@ID", T24_String)        ;* Define Table id
    ID.N = '30'    ; ID.F = '@ID'  ; ID.T = 'A'
*-----------------------------------------------------------------------------
*
    neighbour = ''

    fieldName = 'DISB.REF.ID'    ; fieldLength = '25'   ; fieldType = 'AMT' ;  GOSUB ADD.FIELDS

    fieldName = 'ARR.REF.ID'     ; fieldLength = '25'   ; fieldType = 'A' ;  GOSUB ADD.FIELDS

    fieldName = 'BRANCH.ID'      ; fieldLength = '20'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'INTERNAL.AC'    ; fieldLength = '25'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'DISB.TYPE'      ; fieldLength = '35'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'DISB.AMT'       ; fieldLength = '18'   ; fieldType = 'AMT' ;  GOSUB ADD.FIELDS

    fieldName = 'CREDIT.ACC'     ; fieldLength = '20'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'TRANS.REF'      ; fieldLength = '25'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'CHEQUE.TYPE'    ; fieldLength = '25'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'BENEFICIARY'    ; fieldLength = '25'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'NARRATIVE'      ; fieldLength = '35'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'REMARKS'        ; fieldLength = '35'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'DISB.INDICATOR' ; fieldLength = '35'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

    fieldName = 'DISB.ID.REF'    ; fieldLength = '35'   ; fieldType = 'A'   ;  GOSUB ADD.FIELDS

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

    CALL Table.addLocalReferenceField('XX.LOCAL.REF')

RETURN
*-----------------------------------------------------------------------------
***********
ADD.FIELDS:
***********
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

RETURN
*-----------------------------------------------------------------------------
END
