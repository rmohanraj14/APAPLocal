* @ValidationCode : MjotMTI2MDAyOTk2NjpDcDEyNTI6MTY4MTM4MDg1ODU4ODpJVFNTOi0xOi0xOi0zNjoxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:18
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -36
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.INTERFACE.VAL.ID
*-----------------------------------------------------------------------------
*----------------------------------------------------------------------------------------------------
*DESCRIPTION : This validation routine is used to display the accounts of a selected customer in a drop-down list
*-----------------------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------------------
* * Input / Output
* --------------
* IN     : -NA-
* OUT    : -NA-
*-----------------------------------------------------------------------------------------------------
* COMPANY NAME : APAP
* DEVELOPED BY : Sakthi Sellappillai
* PROGRAM NAME : REDO.VAL.ISSUE.COMP.ARC.CUST
*-----------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE             WHO                     REFERENCE         DESCRIPTION
* 04.10.2010      Sakthi Sellappillai                        INITIAL CREATION
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.INTERFACE.PARAM
    GOSUB INITIALISE
    GOSUB FIRST.PROCESS
RETURN
*------------------------------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------------------------------
    Y.ENTERED.ID.VAL = ''
    Y.FIRST.THREE.VAL = ''
    Y.LAST.THREE.VAL = ''
RETURN
*------------------------------------------------------------------------------------------------------
FIRST.PROCESS:
*------------------------------------------------------------------------------------------------------
    Y.ENTERED.ID.VAL = COMI
    Y.FIRST.THREE.VAL = Y.ENTERED.ID.VAL[1,3]
    Y.LAST.THREE.VAL = Y.ENTERED.ID.VAL[4,3]
    IF ALPHA(Y.FIRST.THREE.VAL) THEN
        GOSUB SECOND.PROCESS
    END ELSE
        E = 'EB-REDO.INT.PARAM.ID'
    END
RETURN
*------------------------------------------------------------------------------------------------------
SECOND.PROCESS:
*------------------------------------------------------------------------------------------------------
    IF NUM(Y.LAST.THREE.VAL) THEN
        GOSUB THIRD.PROCESS
    END ELSE
        E = 'EB-REDO.INT.PARAM.ID'
    END
RETURN
*-----------------------------------------------------------------------------------------------------
THIRD.PROCESS:
*-----------------------------------------------------------------------------------------------------
    Y.LEN.VAL1 = LEN(Y.ENTERED.ID.VAL)
    IF Y.LEN.VAL1 EQ '6' THEN
        GOSUB GOEND
    END ELSE
        E = 'EB-REDO.INT.PARAM.ID'
    END
RETURN
*------------------------------------------------------------------------------------------------------
GOEND:
*------------------------------------------------------------------------------------------------------
END
*-----------------------------------------*END OF SUBROUTINE*------------------------------------------
