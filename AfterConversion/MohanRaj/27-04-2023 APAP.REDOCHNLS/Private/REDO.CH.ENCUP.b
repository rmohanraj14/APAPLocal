* @ValidationCode : Mjo5MzEzNTY3MzU6Q3AxMjUyOjE2ODEyMTUxNjQ3Mzg6SVRTUzotMTotMTotMTc6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
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
SUBROUTINE REDO.CH.ENCUP
**************************************************************************
*------------------------------------------------------------------------
* Company Name : ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* Developed By : RMONDRAGON
* Program Name : REDO.CH.ENCUP
*------------------------------------------------------------------------

* Description: This subroutine is performed in REDO.CH.PREV.DBCM,INPUT version
* as before authorization subroutine when the unique record SYSTEM is authorized
* once it was parameterized
* The functionality is to encrypt user and password used in the
* database connection
* linked with : Version REDO.CH.PREV.DBCM,INPUT as Authorisation routine
* In Parameter : None
* Out Parameter : None

*--------------------------------------------------------------------
*MODIFICATION HISTORY:
*
* 10-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*--------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.REDO.CH.PREV.DBCM
    $INSERT JBC.h

    GOSUB INITIALIZE
    GOSUB ENCRYPT.AND.UPDATE

RETURN
*-------------------------------------------------
INITIALIZE:
* Description : Encryption key value is assigned here
*-------------------------------------------------
    KEY1="123456"
RETURN
*-------------------------------------------------------------------------
ENCRYPT.AND.UPDATE:

* Description : The values got from the version are encrypted and then
* username and password are updated
*-------------------------------------------------------------------------

    USER.ENC = ENCRYPT(R.NEW(REDO.PREV.DB.USER),KEY1,JBASE_CRYPT_DES_BASE64)
    PWD.ENC = ENCRYPT(R.NEW(REDO.PREV.DB.PWD),KEY1,JBASE_CRYPT_DES_BASE64)

    R.NEW(REDO.PREV.DB.USER) = USER.ENC
    R.NEW(REDO.PREV.DB.PWD) = PWD.ENC

RETURN

END
