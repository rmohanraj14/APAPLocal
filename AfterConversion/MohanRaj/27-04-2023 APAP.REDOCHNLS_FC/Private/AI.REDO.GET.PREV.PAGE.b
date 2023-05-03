$PACKAGE APAP.REDOCHNLS
* @ValidationCode : MjotMTI5OTgzNjMxODpDcDEyNTI6MTY4MDc3MjQ3ODU1MTpIYXJpc2h2aWtyYW1DOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Apr 2023 14:44:38
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : HarishvikramC
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.

SUBROUTINE AI.REDO.GET.PREV.PAGE
*-----------------------------------------------------------------------------
*Company   Name    : APAP
*Developed By      : Martin Macias
*Program   Name    : AI.REDO.GET.PREV.PAGE
*-----------------------------------------------------------------------------
* DATE              WHO                REFERENCE               Description
* 04-APR-2023     Conversion tool    R22 Auto conversion      if condition added
* 04-APR-2023      Harishvikram C   Manual R22 conversion       No changes

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_System

    FN.REDO.EB.USER.PRINT.VAR='F.REDO.EB.USER.PRINT.VAR'
    F.REDO.EB.USER.PRINT.VAR=''
    CALL OPF(FN.REDO.EB.USER.PRINT.VAR,F.REDO.EB.USER.PRINT.VAR)


    HTML.PREV.PAGE = ''
    Y.USR.VAR = System.getVariable("EXT.EXTERNAL.USER")
    IF E EQ "EB-UNKNOWN.VARIABLE" THEN ;*R22 Auto conversion - start
        Y.USR.VAR = ""
    END					;*R22 Auto conversion - End
    Y.USR.VAR = Y.USR.VAR:"-":"CURRENT.PREV.PAGE"
*  READ HTML.PREV.PAGE FROM F.REDO.EB.USER.PRINT.VAR,Y.USR.VAR ELSE HTML.PREV.PAGE = '' ;*Tus Start
    CALL F.READ(FN.REDO.EB.USER.PRINT.VAR,Y.USR.VAR,HTML.PREV.PAGE,F.REDO.EB.USER.PRINT.VAR,HTML.PREV.PAGE.ERR)
    IF HTML.PREV.PAGE.ERR THEN
        HTML.PREV.PAGE = ''
    END   ;*Tus End

    O.DATA = HTML.PREV.PAGE

RETURN
END
