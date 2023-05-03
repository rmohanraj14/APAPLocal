* @ValidationCode : MjozNTg4OTI3NjE6Q3AxMjUyOjE2ODEzODA4NDE5OTU6SVRTUzotMTotMToyMDA6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:01
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 200
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GETARRID
**
* Subroutine Type : VERSION
* Attached to     : EB.EXTERNAL.USER,REDO.USER.AUTH
* Attached as     : CHECK.REC.RTN
* Primary Purpose : Assign an AA Arrangement created to the Channel User
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
*
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.AA.ARRANGEMENT.ACTIVITY

    FN.AA.ARRANGEMENT.ACTIVITY = 'F.AA.ARRANGEMENT.ACTIVITY'
    F.AA.ARRANGEMENT.ACTIVITY = ''
    CALL OPF(FN.AA.ARRANGEMENT.ACTIVITY,F.AA.ARRANGEMENT.ACTIVITY)

    CNT.REC = ""
    R.AA = ""

    SEL.CMD = "SELECT ":FN.AA.ARRANGEMENT.ACTIVITY:" WITH ARC.USR.ID EQ ":ID.NEW
    CALL EB.READLIST(SEL.CMD,NO.OF.REC,'',CNT.REC,RET.CD)
    FOR CNT = 1 TO CNT.REC
        SEL.REC = NO.OF.REC<CNT>
        CALL F.READ(FN.AA.ARRANGEMENT.ACTIVITY,SEL.REC,R.AA,F.AA.ARRANGEMENT.ACTIVITY,AA.ERR)
        R.NEW(EB.XU.ARRANGEMENT) = R.AA<AA.ARR.ACT.ARRANGEMENT>
    NEXT CNT

RETURN

END
