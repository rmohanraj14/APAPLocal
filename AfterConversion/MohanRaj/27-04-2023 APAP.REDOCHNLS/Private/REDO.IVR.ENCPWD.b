* @ValidationCode : MjotNzU1MDMxMDQ2OkNwMTI1MjoxNjgxMzgwODYyMDEwOklUU1M6LTE6LTE6LTE3OjE6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:44:22
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : -17
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.IVR.ENCPWD
**************************************************************************
*------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : RMONDRAGON
* Program Name : REDO.IVR.ENCPWD
*------------------------------------------------------------------------

* Description: This subroutine is performed in REDO.IVR.PARAMS,CREATE version
* as before authorization subroutine when the unique record SYSTEM is authorized
* once it was parameterized
* The functionality is to encrypt user and password used in the
* connection
* linked with : Version REDO.IVR.PARAMS,CREATE as Before Authorisation routine
* In Parameter : None
* Out Parameter : None

*--------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* 11-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 11-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*--------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.IVR.PARAMS
    $INSERT JBC.h

    GOSUB INITIALIZE
    GOSUB ENCRYPT.AND.UPDATE

RETURN
*-------------------------------------------------
INITIALIZE:
* Description : Encryption key value is assigned here
*-------------------------------------------------
    KEY1="456123"
RETURN
*-------------------------------------------------------------------------
ENCRYPT.AND.UPDATE:

* Description : The values got from the version are encrypted and then
* username and password are updated
*-------------------------------------------------------------------------

    USER.ENC = ENCRYPT(R.NEW(REDO.IVR.PAR.USER),KEY1,JBASE_CRYPT_DES_BASE64)
    PWD.ENC = ENCRYPT(R.NEW(REDO.IVR.PAR.PWD),KEY1,JBASE_CRYPT_DES_BASE64)

    R.NEW(REDO.IVR.PAR.USER) = USER.ENC
    R.NEW(REDO.IVR.PAR.PWD) = PWD.ENC

RETURN
END
