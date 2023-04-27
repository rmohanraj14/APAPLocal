* @ValidationCode : MjoxODY2NjY0NzA4OkNwMTI1MjoxNjgxMzgwODU4MzE1OklUU1M6LTE6LTE6LTYzOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -63
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
* Version 2 02/06/00  GLOBUS Release No. G11.0.00 29/06/00
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
SUBROUTINE REDO.INTERFACE.SMAIL.VALIDATE
*-----------------------------------------------------------------------------
*** Template FOR validation routines
* @author hpasquel@temenos.com
* @stereotype validator
* @package infra.eb
*!
*-----------------------------------------------------------------------------
*** <region name= Modification History>
*-----------------------------------------------------------------------------
* 07/06/06 - BG_100011433
*            Creation
*
* 10-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------
*** </region>
*** <region name= Main section>
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.SMAIL

    GOSUB INITIALISE
    GOSUB PROCESS.MESSAGE
RETURN
*** </region>
*-----------------------------------------------------------------------------
VALIDATE:
* TODO - Add the validation code here
* Set AF, AV and AS to the field, multi value and sub value and invoke STORE.END.ERROR
* Set ETEXT to point to the EB.ERROR.TABLE

*      AF = MY.FIELD.NAME                 <== Name of the field
*      ETEXT = 'EB-EXAMPLE.ERROR.CODE'    <== The error code
*      CALL STORE.END.ERROR               <== Needs to be invoked per error

    IF V$FUNCTION MATCHES 'I' : @VM : 'C' THEN
        IF R.NEW(REDO.INT.SMAIL.AUTH.REQUIRED) EQ 'SI' THEN
            IF R.NEW(REDO.INT.SMAIL.USERNAME) EQ '' THEN
                AF = REDO.INT.SMAIL.USERNAME
                ETEXT = "ST-REDO.BCR-MANDATORY-FIELD"
                ETEXT<2> = "USERNAME"
                CALL STORE.END.ERROR
                RETURN
            END
            IF R.NEW(REDO.INT.SMAIL.PASSWORD) EQ '' THEN
                AF = REDO.INT.SMAIL.PASSWORD
                ETEXT = "ST-REDO.BCR-MANDATORY-FIELD"
                ETEXT<2> = "PASSWORD"
                CALL STORE.END.ERROR
                RETURN
            END
        END
        yPath = R.NEW(REDO.INT.SMAIL.PROP.FILE.PATH)
        CALL BR.CREATE.PATH('CHECK.PATH', yPath)
        IF ETEXT NE '' THEN
            AF = REDO.INT.SMAIL.PROP.FILE.PATH
            ETEXT = "ST-REDO.BCR.PATH.MISSING"
            ETEXT<2> = R.NEW(REDO.INT.SMAIL.PROP.FILE.PATH)
            CALL STORE.END.ERROR
        END
    END


RETURN
*-----------------------------------------------------------------------------
*** <region name= Initialise>
INITIALISE:
***

*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= Process Message>
PROCESS.MESSAGE:
    BEGIN CASE
        CASE MESSAGE EQ ''          ;* Only during commit
            BEGIN CASE
                CASE V$FUNCTION EQ 'D'
                    GOSUB VALIDATE.DELETE
                CASE V$FUNCTION EQ 'R'
                    GOSUB VALIDATE.REVERSE
                CASE OTHERWISE  ;* The real VALIDATE
                    GOSUB VALIDATE
            END CASE
        CASE MESSAGE EQ 'AUT' OR MESSAGE EQ 'VER'       ;* During authorisation and verification
            GOSUB VALIDATE.AUTHORISATION
    END CASE
*
RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VALIDATE.DELETE>
VALIDATE.DELETE:
* Any special checks for deletion

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VALIDATE.REVERSE>
VALIDATE.REVERSE:
* Any special checks for reversal

RETURN
*** </region>
*-----------------------------------------------------------------------------
*** <region name= VALIDATE.AUTHORISATION>
VALIDATE.AUTHORISATION:
* Any special checks for authorisation

RETURN
*** </region>
*-----------------------------------------------------------------------------
END
