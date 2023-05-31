$PACKAGE APAP.AA ;*R22 Manual Code Conversion 
SUBROUTINE REDO.AA.DISB.LOAN.FIELDS
*-----------------------------------------------------------------------------
*DESCRIPTION:
*------------
* This routine is used to define id and fields for the table REDO.AA.DISB.LOAN
*-----------------------------------------------------------------------------
* Input/Output:
*--------------
* IN  : -NA-
* OUT : -NA-
*-----------------------------------------------------------------------------------

* Modification History: 
* Date                  Who                               Reference           Description
* ----                  ----                                ----                 ----
* 29-March-2023          Ajith Kumar         R22 Manual Code Conversion      Package Name added APAP.AA
* 29-March-2023      Conversion Tool                      R22 Auto Code Conversion             Nochange
* ----------------------------------------------------------------------------

*-----------------------------------------------------------------------------------

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
*    CALL Table.defineId("@ID", T24_String)       ;* Define Table id
    ID.T = 'A'  ;  ID.N = '15' ;     ID.F = '@ID' ;
*-----------------------------------------------------------------------------
*
    neighbour = ''         ; fieldLength = '20.1'   ; fieldType = 'A' ; fieldType<3> = 'NOCHANGE'
    fieldName = 'ARRANGEMENT.ID'
    GOSUB ADD.FIELDS
    CALL Field.setCheckFile('AA.ARRANGEMENT')

    fieldName = 'LOAN.CCY'  ; fieldLength = '3'   ; fieldType = 'CCY' ; fieldType<3> = 'NOCHANGE'  ;   GOSUB ADD.FIELDS
    CALL Field.setCheckFile('CURRENCY')

    neighbour = ''         ; fieldLength = '20'   ; fieldType = 'A'
    fieldName = 'MAIN.BRANCH.ID'
    GOSUB ADD.FIELDS
    CALL Field.setCheckFile('COMPANY')

    fieldName = 'XX<MN.DISB.TYPE'   ; fieldLength = '35'  ; fieldType = 'A'   ; fieldType<3> = 'NOCHANGE'
    fieldType = ''
    virtualTableName = 'MN.DISB.TYPE'
    CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour)

    fieldName = 'XX>MN.DISB.AMT'  ; fieldLength = '18' ; fieldType = 'AMT'     ; fieldType<2,2> = '2'  ; fieldType<3> = 'NOCHANGE';  GOSUB ADD.FIELDS

    fieldName = 'MN.BRANCH.AC'    ; fieldLength = '35'   ; fieldType = 'INT'   ; fieldType<3> = 'NOCHANGE';  GOSUB ADD.FIELDS

    fieldName = 'MN.TOT.AMT'      ; fieldLength = '35'   ; fieldType = 'AMT'   ; fieldType<3> = 'NOINPUT'; ; fieldType<2,2> = '2'; GOSUB ADD.FIELDS

    fieldName = 'MN.DISB.REF'     ; fieldLength = '35'   ; fieldType = 'A'  ; fieldType<3> = 'NOINPUT'  ; GOSUB ADD.FIELDS

    neighbour = '' ; fieldLength = '20'   ; fieldType = 'A' ;
    fieldName = 'XX<DISB.BRANCH.ID'
    GOSUB ADD.FIELDS
    CALL Field.setCheckFile('COMPANY')

    fieldName = 'XX-XX<BR.DISB.TYPE'; fieldLength = '35'  ; fieldType = 'A'   ; fieldType<3> = 'NOCHANGE'
    fieldType = ''
    virtualTableName='BR.DISB.TYPE'
    CALL Table.addFieldWithEbLookup(fieldName,virtualTableName,neighbour)

    fieldName = 'XX-XX>BR.DISB.AMT' ; fieldLength = '18' ; fieldType = 'AMT'     ; fieldType<2,2> = '2'  ; fieldType<3> = 'NOCHANGE';  GOSUB ADD.FIELDS

    fieldName = 'XX-BR.DISB.AC'   ; fieldLength = '35'   ; fieldType = 'INT'   ; fieldType<3> = 'NOCHANGE';  GOSUB ADD.FIELDS

    fieldName = 'XX-BR.TOT.AMT'      ; fieldLength = '35'   ; fieldType = 'AMT'   ; fieldType<3> = 'NOINPUT' ;  fieldType<2,2> = '2'; GOSUB ADD.FIELDS

    fieldName = 'XX>BR.DISB.REF'  ; fieldLength = '35'   ; fieldType = 'A'     ; fieldType<3> = 'NOINPUT' ;  GOSUB ADD.FIELDS

    fieldName = 'TOT.DISB.AMT'    ; fieldLength = '35'   ; fieldType = 'AMT'   ; fieldType<2,2> = '2'     ; fieldType<3> = 'NOINPUT' ;  GOSUB ADD.FIELDS

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

    CALL Table.addOverrideField

    CALL Table.setAuditPosition ;* Poputale audit information

RETURN
*-----------------------------------------------------------------------------
***********
ADD.FIELDS:
***********
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)   ;* Add a new field

RETURN
*-----------------------------------------------------------------------------
END
