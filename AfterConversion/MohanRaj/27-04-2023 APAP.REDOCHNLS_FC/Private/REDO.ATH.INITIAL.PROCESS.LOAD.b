* @ValidationCode : Mjo5NzcyOTY0MDc6Q3AxMjUyOjE2ODEyMTUxNjQwNTM6SVRTUzotMTotMToyOTM6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 293
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.ATH.INITIAL.PROCESS.LOAD
*--------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Temenos Application Management
*Program Name      : REDO.ATH.INITIAL.PROCESS.LOAD
*Date              : 6.12.2010
*-------------------------------------------------------------------------
* Incoming/Outgoing Parameters
*-------------------------------
* In  : --N/A--
* Out : --N/A--
*-----------------------------------------------------------------------------
* Revision History:
* -----------------
* Date                   Name                   Reference               Version
* -------                ----                   ----------              --------
*06/12/2010      saktharrasool@temenos.com   ODR-2010-08-0469       Initial Version
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_REDO.ATH.INITIAL.PROCESS.COMMON

    GOSUB INITIALISE

RETURN
*------------------------------------------------------------------------------------
INITIALISE:
*------------------------------------------------------------------------------------

    FN.REDO.ATH.PROCESS.INFO='F.REDO.ATH.PROCESS.INFO'
    F.REDO.ATH.PROCESS.INFO=''
    CALL OPF(FN.REDO.ATH.PROCESS.INFO,F.REDO.ATH.PROCESS.INFO)

    FN.REDO.STLMT.CNCT.FILE='F.REDO.STLMT.CNCT.FILE'
    F.REDO.STLMT.CNCT.FILE=''
    CALL OPF(FN.REDO.STLMT.CNCT.FILE,F.REDO.STLMT.CNCT.FILE)

    FN.REDO.ATH.STLMT.CNCT.FILE='F.REDO.ATH.STLMT.CNCT.FILE'
    F.REDO.ATH.STLMT.CNCT.FILE=''
    CALL OPF(FN.REDO.ATH.STLMT.CNCT.FILE,F.REDO.ATH.STLMT.CNCT.FILE)

    FN.REDO.ATH.STLMT.FILE.DETAILS='F.REDO.ATH.STLMT.FILE.DETAILS'

RETURN

END
