* @ValidationCode : MjoxMTgyMTMyNTgyOkNwMTI1MjoxNjgxMjE1MTY0MjU3OklUU1M6LTE6LTE6MjkzOjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
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
SUBROUTINE REDO.ATH.STLMT.FILE.PROCESS(STML.FILE)
*--------------------------------------------------------------------------
*Company Name      : APAP Bank
*Developed By      : Temenos Application Management
*Program Name      : REDO.ATH.STLMT.FILE.PROCESS
*Date              : 06.12.2010
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
*23/11/2010      saktharrasool@temenos.com   ODR-2010-08-0469       Initial Version
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C     Manual R22 conversion      No changes
*------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.ATH.STLMT.PARAM
    $INSERT I_REDO.ATH.STLMT.FILE.PROCESS.COMMON

    GOSUB PROCESS

RETURN

*-------------------------------------------------------------------------
PROCESS:
*-------------------------------------------------------------------------


    CALL F.READ(FN.REDO.ATH.STLMT.CNCT.FILE,STML.FILE,R.REDO.ATH.STLMT.CNCT.FILE,F.REDO.ATH.STLMT.CNCT.FILE,CNCT.ERR)

    IF R.REDO.ATH.STLMT.CNCT.FILE NE '' THEN
        TC.CODE=R.REDO.ATH.STLMT.CNCT.FILE<2>[1,4]
        LOCATE TC.CODE IN R.REDO.ATH.STLMT.PARAM<ATH.STM.PARAM.TXN.CODE,1> SETTING POS.TC THEN
            IN.RTN=R.REDO.ATH.STLMT.PARAM<ATH.STM.PARAM.IN.PROCESS.RTN,POS.TC>
            IN.USR.DEF.RTN= R.REDO.ATH.STLMT.PARAM<ATH.STM.PARAM.IN.USR.DEF.RTN,POS.TC>
            ACCT.IN.RTN= R.REDO.ATH.STLMT.PARAM<ATH.STM.PARAM.IN.ACCT.RTN,POS.TC>
        END

        IF IN.RTN NE '' THEN
            CALL @IN.RTN(R.REDO.ATH.STLMT.CNCT.FILE)

            IF CONT.FLAG EQ 'TRUE' THEN
                CALL F.DELETE(FN.REDO.ATH.STLMT.CNCT.FILE,STML.FILE)
                RETURN
            END
        END

        IF IN.USR.DEF.RTN NE '' THEN
            CALL @IN.USR.DEF.RTN
        END

        IF ACCT.IN.RTN NE '' THEN
            CALL @ACCT.IN.RTN
        END
    END
    CALL F.DELETE(FN.REDO.ATH.STLMT.CNCT.FILE,STML.FILE)
RETURN
END
