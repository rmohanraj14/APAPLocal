* @ValidationCode : MjoxNDM0MDA4MDIzOkNwMTI1MjoxNjgxMzgwODU0MjI5OklUU1M6LTE6LTE6LTcyOjE6dHJ1ZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:14
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -72
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERFACE.PARAM.FIELDS
*-----------------------------------------------------------------------------
* <doc>
*
* This table is used to store all the events in the interface activity
*
* author: rshankar@temenos.com
*
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
* 26/07/2010 - C.22 New Template Creation
* 07/07/2011 -PACS00032519            CON.ENC.KEY added
* 28/07/2011 - PACS00089082 - field property changed for DIR.PATH
*
* 10-APR-2023     Conversion tool   R22 Auto conversion   FM TO @FM
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes

*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("@ID", T24_String)          ;* Define Table id

    ID.F = '@ID'
    ID.N = '20'
    ID.T = 'A'
*-----------------------------------------------------------------------------

    fieldName="NAME"
    fieldLength="35.3"          ;* C.21
    fieldType="A"
    neighbour=""
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="PROCESS"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)


    fieldName="DESCRIPTION"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)


    fieldName="SEND.METHOD"
    fieldLength="35"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="ENCRIPTATION"
    fieldLength="2"
    fieldType=""
    fieldType<2>="SI_NO"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="ENCRIP.KEY"
    fieldLength="135" ;* C.21
    fieldType="PASSWD"          ;* C.21
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="ENCRIP.MET"
* C.21    fieldLength="35"
* C.21    fieldType="A"
* C.21    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    ebLoookUpTable = "REDO.INT.PARAM.ENCRIP.MET"
    CALL Table.addFieldWithEbLookup(fieldName, ebLoookUpTable, '');

*     PACS00089082 -S

    fieldName="DIR.PATH"
    fieldLength="100"
    fieldType="A"     ;* C.21
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

* PACS00089082 -E

    fieldName="FILE.NAME"
    fieldLength="35"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="MOV.ORIGIN"
    fieldLength="2"
    fieldType=""
    fieldType<2>="DR_CR"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="REP.TIME.RANGE"
    fieldLength="15"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="XX<TYPE.CONFIG"
    fieldLength="15"
    fieldType=""
    fieldType<2>="SQL_ORACLE_WS_FTP_EMAIL"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="XX>DATA.CONFIG"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="AUTOM.EXEC"
    fieldLength="2"
    fieldType=""
    fieldType<2>="SI_NO"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="AUTOM.EXEC.FREC"
    fieldLength="35"
    fieldType="FQU"   ;* C.21
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="AUTHORIZATION"
    fieldLength="7"
    fieldType=""
    fieldType<2>="MAKER_CHECKER"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

* C.21 <<
    fieldName="XX<PARAM.TYPE"
    ebLoookUpTable = "REDO.INT.PARAM.TYPE"
    CALL Table.addFieldWithEbLookup(fieldName, ebLoookUpTable, '');

    fieldName="XX>PARAM.VALUE"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
* >>

    GOSUB A100.ADD.FI.FIELDS


*    CALL Table.addField("RESERVED.4", T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.3", T24_String, Field_NoInput,"")
*
* -   Handling of RESERVED FIELDS - PART 1 - JCOSTA - 2010.10.21
*
*    CALL Table.addField("RESERVED.2", T24_String, Field_NoInput,"")
*    CALL Table.addField("RESERVED.1", T24_String, Field_NoInput,"")

    fieldName="CON.ENC.KEY"
    fieldLength="100"
    fieldType="PASSWD"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="MAIL.ADDRESS"
    fieldLength="65"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)


    GOSUB ADD.TXN.CODE.FIELDS

    fieldName="PAYMENT.REF"
    fieldLength="15"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="XX<AFF.COMPANY"
    fieldLength="35"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile('REDO.INTERFACE.PARAM')


    fieldName="XX-PROCES.SEQ"
    fieldLength="15"
    fieldType="A":@FM:"":@FM:"NOINPUT"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="XX>SEQ.STATUS"
    fieldLength="35"
    fieldType="A":@FM:"":@FM:"NOINPUT"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)


    fieldName="SERVICE.CONTROL"
    fieldLength="10"
    fieldType=""
    fieldType<2>="ACTIVE_INACTIVE"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)


    NUM.RESERVED.FIELDS = 0
    FIELD.NAME = 'RESERVED'
    GOSUB A200.ADD.RESERVED.FIELDS
*
* -   END  - Handling of RESERVED FIELDS - PART 1

    neighbour = ''
    fieldName = 'XX.LOCAL.REF'
    fieldLength = '35'
    fieldType = 'A'
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Populate audit information
*-----------------------------------------------------------------------------
RETURN
*
* =================
ADD.TXN.CODE.FIELDS:
* =================
    fieldName="DR.TXN.CODE"
    fieldLength="10"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')

    fieldName="CR.TXN.CODE"
    fieldLength="10"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')

    fieldName="RET.TXN.CODE"
    fieldLength="10"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')


    fieldName="RET.TAX.CODE"
    fieldLength="10"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile('FT.TXN.TYPE.CONDITION')
RETURN
* =================
A100.ADD.FI.FIELDS:
* =================
*
*    Adding fields for Flat Interface Processes - JCOSTA - 2010.10.21
*
* PACS00089082 -S
    fieldName="FI.AUTO.PATH"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="FI.MANUAL.PATH"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="FI.AUT.AVAIL.FUNDS"
    fieldLength="2"
    fieldType=""
    fieldType<2>="SI_NO"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
*
*    END - Adding fields for Flat Interface Processes - 2010.10.21
*

*
*    Adding fields for Flat Interface Processes - JCOSTA - 2010.10.25
*

    fieldName="FI.HISTORY.PATH"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="FI.REJECT.PATH"
    fieldLength="100"
    fieldType="A"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

** PACS00089082 -E

    fieldName="FI.ROUTINE.NAME"
    fieldLength="70"
    fieldType="HOOK"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="FI.USER.SIGN.ON"
    fieldLength="16"
    fieldType="AA"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName="FI.USER.PWD"
    fieldLength="15"
    fieldType="PASSWD"
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

*
*    END - Adding fields for Flat Interface Processes - 2010.10.25
*
RETURN
*
*
* -   Handling of RESERVED FIELDS - PART 2 - JCOSTA - 2010.10.21
*
* =======================
A200.ADD.RESERVED.FIELDS:
* =======================
*
*   Paragraph to add RESERVED FIELDS - JCOSTA - 2010.10.21
*
    FOR XX = 1 TO NUM.RESERVED.FIELDS
        RESERVED.FIELD.NAME = FIELD.NAME:'.':XX
        CALL Table.addField(RESERVED.FIELD.NAME, T24_String, Field_NoInput,"")
    NEXT XX

RETURN
*
* -   END  - Handling of RESERVED FIELDS - PART 2

*-----------------------------------------------------------------------------
END
