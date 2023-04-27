* @ValidationCode : MjotMzQ1NjE2MTcxOkNwMTI1MjoxNjgxMzgwNzg2MTM5OklUU1M6LTE6LTE6MTk1OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:43:06
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 195
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE AI.REDO.KILL.OTH.SESSION
*-----------------------------------------------------------------------------
*Company   Name    : APAP
*Developed By      : Martin Macias
*Program   Name    : AI.REDO.KILL.OTH.SESSION
*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 11-APR-2023     Conversion tool    R22 Auto conversion       IF Condition added
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_EQUATE
    $INSERT I_System

    FN.TOKEN = 'F.OS.TOKEN'
    F.TOKEN = ''
    CALL OPF(FN.TOKEN,F.TOKEN)

    Y.USR.VAR = System.getVariable("CURRENT.EXT.USER.ID")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion -START
        Y.USR.VAR = ""
    END					;*R22 Auto conversion - END
    SEL.CMD = "SELECT ":FN.TOKEN:" WITH EXTERNAL.USER EQ ":Y.USR.VAR
    CALL EB.READLIST(SEL.CMD,SEL.LIST,'',NO.OF.REC,Y.ERR)

    IF NO.OF.REC NE 0 THEN
*    DELETE F.TOKEN,SEL.LIST<1> ;*Tus Start
        CALL F.DELETE(FN.TOKEN,SEL.LIST<1>) ;*Tus End
    END

RETURN
END
