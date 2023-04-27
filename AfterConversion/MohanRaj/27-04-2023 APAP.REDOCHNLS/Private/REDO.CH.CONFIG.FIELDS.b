* @ValidationCode : MjotNDQxODI3Mjg1OkNwMTI1MjoxNjgxMjE1MTY0NTY2OklUU1M6LTE6LTE6LTg6MTp0cnVlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -8
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : true
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.CONFIG.FIELDS
*-----------------------------------------------------------------------------
*<doc>
* Template for field definitions routine REDO.CH.CONFIG.FIELDS
*
* @author rmondragon@temenos.com
* @stereotype fields template
* @uses Table
* @public Table Creation
* @package
* </doc>
*-----------------------------------------------------------------------------
* Modification History :
*
* 19/10/07 - EN_10003543
*            New Template changes
*
* 14/11/07 - BG_100015736
*            Exclude routines that are not released
*
* 1/11/10 - First Version
*
* 28/09/11 - Update for fix PACS00106562
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
*** <region name= Header>
*** <desc>Inserts and control logic</desc>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_DataTypes
*** </region>
*-----------------------------------------------------------------------------
    CALL Table.defineId("CONFIG.ID", T24_String)    ;* Define Table id
*-----------------------------------------------------------------------------
    CALL Table.addField("VALTIMEPIN", T24_String, "", "")
    CALL Table.addField("VALTIMEPWD", T24_String, "", "")

    fieldName='XX<PROFILE.TYPE'
    fieldLength='30'
    fieldType=''
    fieldType<2> = 'Teleapap.Consultas_Teleapap.Txns_Apapenlinea.Consultas_Apapenlinea.Txns'
    neighbour=''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)

    fieldName='XX-MENU.COS'
    fieldLength='50'
    fieldType='A'
    neighbour=''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile("EB.COMPOSITE.SCREEN")

    fieldName='XX>USER.SMS.GROUP'
    fieldLength='25'
    fieldType='A'
    neighbour=''
    CALL Table.addFieldDefinition(fieldName, fieldLength, fieldType, neighbour)
    CALL Field.setCheckFile("USER.SMS.GROUP")

*-----------------------------------------------------------------------------
*   CALL Table.addLocalReferenceField
    CALL Table.addOverrideField
*-----------------------------------------------------------------------------
    CALL Table.setAuditPosition ;* Poputale audit information
*-----------------------------------------------------------------------------
RETURN
*-----------------------------------------------------------------------------
END
