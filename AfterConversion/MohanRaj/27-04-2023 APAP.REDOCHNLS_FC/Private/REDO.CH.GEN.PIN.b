* @ValidationCode : MjoxODIyODc5MjYwOkNwMTI1MjoxNjgxMjE1MTY0ODI5OklUU1M6LTE6LTE6OTY6MTpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:42:44
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : ITSS
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : 96
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : true
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOCHNLS
SUBROUTINE REDO.CH.GEN.PIN
**
* Subroutine Type : VERSION
* Attached to     : EB.EXTERNAL.USER,REDO.PERS.NEWTEL
* Attached as     : INPUT.ROUTINE
* Primary Purpose : Generate a PIN number for Telephone Channel User.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 1/11/10 - First Version.
*           ODR Reference: ODR-2010-06-0155.
*           Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
*
* 16/11/10 - Version changed from REDO.CH.PINADM, to REDO.CH.PINADM,NEWTEMP to
*            be used in OFS message.
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
*
* 5/12/11 - Update to key for PIN encryption.
*           Roberto Mondragon - TAM Latin America.
*           rmondragon@temenos.com
*
* 10-APR-2023      Conversion tool    R22 Auto conversion       No changes
* 10-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON

    $INSERT I_F.EB.EXTERNAL.USER
    $INSERT I_F.REDO.CH.PINADM
    $INSERT I_REDO.CH.GENNEWUSR.COMMON

    FN.REDO.CH.PINADM = 'F.REDO.CH.PINADM'
    FV.REDO.CH.PINADM = ''
    CALL OPF(FN.REDO.CH.PINADM,FV.REDO.CH.PINADM)

*PIN Encription.
    KEYUSED = "7"
*    PINSTORE = ENCRYPT(PIN,KEYUSED,JBASE_CRYPT_3DES)
    PINSTORE = ENCRYPT(PIN,KEYUSED,2)
    STARTTIME = FIELD(TIMEDATE()," ",0)

*PIN record creation for REDO.CH.PINADM application as an OFS message.
    OFS.HEADER = "REDO.CH.PINADM,/I/PROCESS/1/0,/,": ID.NEW :","
    OFS.BODY = "PIN:1:1=": PINSTORE :","
    OFS.BODY := "START.DATE:1:1=": TODAY :","
    OFS.BODY := "START.TIME:1:1=": STARTTIME :","
    OFS.BODY := "TYPE:1:1=TEMPORAL,"

    OFS.MSG = OFS.HEADER : OFS.BODY

*Input PIN record created.
    OFS.SRC = "CHADMONPROC2"
    RESP.OFS.MSG= ""
    TXN.COMM= ""

    CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG,RESP.OFS.MSG,TXN.COMM)

RETURN

END
