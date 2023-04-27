* @ValidationCode : Mjo1NjcxNTg2MjI6Q3AxMjUyOjE2ODA3NzMyMTEyMjI6SGFyaXNodmlrcmFtQzotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Apr 2023 14:56:51
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
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CLEARING.PROCESS.VALIDATE
****************************************************************
*-------------------------------------------------------------------------
* Company Name  : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By  : KAVITHA S
* Program Name  : REDO.INTERFACE.PARAMETER
* ODR NUMBER    : ODR-2010-09-0251
*-------------------------------------------------------------------------

* Description : This Routine is used to format the Field values of fields BUSINESS.DIV
*               PECF,AICF,TCF to their required length

* In parameter : None
* out parameter : None


*-----------------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* DATE              WHO                REFERENCE                 DESCRIPTION
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*----------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CLEARING.PROCESS

    GOSUB PROCESS

RETURN
********
PROCESS:
********

    BEGIN CASE

        CASE R.NEW(PRE.PROCESS.IN.PROCESS.PATH)

            FILE.PATH = R.NEW(PRE.PROCESS.IN.PROCESS.PATH)
            AF = PRE.PROCESS.IN.PROCESS.PATH
            GOSUB FILE.ERROR.CHECK

        CASE R.NEW(PRE.PROCESS.IN.RETURN.PATH)
            FILE.PATH = R.NEW(PRE.PROCESS.IN.RETURN.PATH)
            AF = PRE.PROCESS.IN.RETURN.PATH
            GOSUB FILE.ERROR.CHECK

        CASE R.NEW(PRE.PROCESS.OUT.PROCESS.PATH)
            FILE.PATH = R.NEW(PRE.PROCESS.OUT.PROCESS.PATH)
            AF = PRE.PROCESS.OUT.PROCESS.PATH
            GOSUB FILE.ERROR.CHECK

        CASE R.NEW(PRE.PROCESS.OUT.RETURN.PATH)
            FILE.PATH = R.NEW(PRE.PROCESS.OUT.RETURN.PATH)
            AF = PRE.PROCESS.OUT.RETURN.PATH
            GOSUB FILE.ERROR.CHECK

    END CASE

RETURN
*-------------------------------------------------------------------
FILE.ERROR.CHECK:

    OPEN FILE.PATH TO F.FILE.NAME SETTING SET.VAR ELSE
        ETEXT = 'EB-INVALID.PATH'
        CALL STORE.END.ERROR
    END

RETURN
*------------------------------------------------------------------------
END
