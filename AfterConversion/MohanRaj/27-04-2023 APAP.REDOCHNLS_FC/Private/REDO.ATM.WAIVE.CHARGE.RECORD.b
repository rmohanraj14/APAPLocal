* @ValidationCode : MjotMTY2MzEyNDkzNTpDcDEyNTI6MTY4MTIxNTE2NDUwNzpJVFNTOi0xOi0xOjA6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATM.WAIVE.CHARGE.RECORD
*-----------------------------------------------------------------------------
* <doc>
********************************************************************************************************
* Company   Name    : APAP Bank
* Developed By      : Temenos Application Management
* Program   Name    : REDO.ATM.WAIVE.CHARGE
*--------------------------------------------------------------------------------------------------------
* Description       : This routine ia a Record routine. This template is used for defining the parameter
* details for ATM waive charge
* </doc>
*--------------------------------------------------------------------------------------------------------
* TODO - You MUST write a .FIELDS routine for the field definitions
*--------------------------------------------------------------------------------------------------------
* Modification Details:
* =====================
*   Date           Who                  Reference            Description
*   ------         ------               -------------        -------------
*   22/01/2019     Vignesh Kumaar R     BRD003 [UNARED]      ATM WAIVE CHARGE/COMMISSION
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C    Manual R22 conversion      No changes
*--------------------------------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ATM.WAIVE.CHARGE

    GET.TERMINAL.ID = FIELD(ID.NEW,'-',1)
    GET.ACQINSTCODE = FIELD(ID.NEW,'-',2)
    IF LEN(GET.TERMINAL.ID) GT 8 OR LEN(GET.ACQINSTCODE) GT 2 OR NOT(INDEX(ID.NEW, "-" , 1)) OR GET.ACQINSTCODE EQ '' OR NOT(NUM(GET.ACQINSTCODE)) THEN
        E = 'AC-INVALID.FORMAT.ID'
    END ELSE
        R.NEW(ATM.WAIVE.TERMINAL.ID)   = GET.TERMINAL.ID
        R.NEW(ATM.WAIVE.ACQ.INST.CODE) = GET.ACQINSTCODE
    END

RETURN
