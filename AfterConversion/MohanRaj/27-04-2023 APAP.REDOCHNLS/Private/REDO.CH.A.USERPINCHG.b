* @ValidationCode : MjotMTEyNTk1MTU4NjpDcDEyNTI6MTY4MDc3MzYyNjk2NTpIYXJpc2h2aWtyYW1DOi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:03:46
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
SUBROUTINE REDO.CH.A.USERPINCHG
**
* Subroutine Type : VERSION
* Attached to     : REDO.CH.PINADM,RESET.PIN
* Attached as     : AUTHORIZATION.ROUTINE
* Primary Purpose : Display the new PIN number assigned during change
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 8/01/13 - First Version
*           ODR Reference: ODR-2010-06-0155
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP)
*           Roberto Mondragon - TAM Latin America
*           rmondragon@temenos.com
*
* 04-APR-2023     Conversion tool    R22 Auto conversion      REM to DISPLAY.MESSAGE(TEXT, '')
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.REDO.CH.PINADM
    $INSERT I_REDO.CH.V.USERPINCHG.COMMON
*PIN Generation
    PINMAIL = RND(9) : RND(9) : RND(9) : RND(9)
    PIN = PINMAIL
    PIN.AS = PIN

*PIN Encription
    KEYUSED = "7"
*    PIN = ENCRYPT(PIN,KEYUSED,JBASE_CRYPT_3DES)
    PIN = ENCRYPT(PIN,KEYUSED,2)

    R.NEW(REDO.CH.PINADMIN.PIN) = PIN

    TEXT = "Nuevo PIN temporal asignado: ": PIN.AS
    CALL DISPLAY.MESSAGE(TEXT, '');*R22 Auto conversion

RETURN

END
