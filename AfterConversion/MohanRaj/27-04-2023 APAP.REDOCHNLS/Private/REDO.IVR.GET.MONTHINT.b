* @ValidationCode : MjotMjEwNzI5NjAyOTpDcDEyNTI6MTY4MTM4MDg2MzE4NzpJVFNTOi0xOi0xOjE4NToxOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:23
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 185
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.GET.MONTHINT
*-------------------------------------------------------------------------
* DESCRIPTION:
*------------
*   To get the interest of the month.
*-------------------------------------------------------------------------
* HISTORY:
*---------
*   Date               who           Reference            Description

* 08-MAY-2014       RMONDRAGON      ODR-2011-02-0099     Initial Creation

* 11-APR-2023     Conversion tool   R22 Auto conversion   VM to @VM, ++ to +=
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_ENQUIRY.COMMON
    $INSERT I_F.AZ.SCHEDULES

    GOSUB OPEN.FILES
    GOSUB PROCESS
RETURN

*-----------------------------------------------------------------------------
OPEN.FILES:
*-----------------------------------------------------------------------------

    FN.AZ.SCHEDULES = 'F.AZ.SCHEDULES'
    F.AZ.SCHEDULES = ''
    CALL OPF(FN.AZ.SCHEDULES,F.AZ.SCHEDULES)

RETURN

*-----------------------------------------------------------------------------
PROCESS:
*-----------------------------------------------------------------------------

    R.AZ.SCHEDULES = ''; AZ.ERR = ''
    CALL F.READ(FN.AZ.SCHEDULES,O.DATA,R.AZ.SCHEDULES,F.AZ.SCHEDULES,AZ.ERR)
    IF R.AZ.SCHEDULES THEN
        Y.DATES = R.AZ.SCHEDULES<AZ.SLS.DATE>
        Y.INT.AMTS = R.AZ.SCHEDULES<AZ.SLS.TYPE.I>
    END

    Y.DATE.TO.CHECK = TODAY[1,6]

    Y.TOT.DATES = DCOUNT(Y.DATES,@VM)
    Y.CNT.DATE = 1
    LOOP
    WHILE Y.CNT.DATE LE Y.TOT.DATES
        Y.DATE = FIELD(Y.DATES,@VM,Y.CNT.DATE)
        Y.DATE = Y.DATE[1,6]
        IF (Y.DATE.TO.CHECK EQ Y.DATE) AND (Y.CNT.DATE NE 1) THEN
            Y.INT.AMT = FIELD(Y.INT.AMTS,@VM,Y.CNT.DATE)
            Y.CNT.DATE = Y.TOT.DATES
        END
        Y.CNT.DATE += 1
    REPEAT

    O.DATA = Y.INT.AMT

RETURN

*-----------------------------------------------------------------------------
END
