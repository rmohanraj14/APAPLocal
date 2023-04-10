* @ValidationCode : MjoxMjc0NTA3MzYzOkNwMTI1MjoxNjgxMTE4NTI0MDk0OjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 10 Apr 2023 14:52:04
* @ValidationInfo : Encoding          : Cp1252
* @ValidationInfo : User Name         : 91638
* @ValidationInfo : Nb tests success  : N/A
* @ValidationInfo : Nb tests failure  : N/A
* @ValidationInfo : Rating            : N/A
* @ValidationInfo : Coverage          : N/A
* @ValidationInfo : Strict flag       : N/A
* @ValidationInfo : Bypass GateKeeper : false
* @ValidationInfo : Compiler Version  : R21_AMR.0
* @ValidationInfo : Copyright Temenos Headquarters SA 1993-2021. All rights reserved.
$PACKAGE APAP.REDOSRTN
SUBROUTINE REDO.S.FETCH.SYS.DATE(SYS.DATE)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.FETCH.SYS.DATE
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the date and Convert the date into
*                   dd mon yy (e.g. 01 JAN 09)
*LINKED WITH       :
* ----------------------------------------------------------------------------------
*MODIFICATION HISTORY:
* DATE            WHO               REFERENCE              DESCRIPTION
* 26 JUN 2011     Sudharsanan S     PACS00023988         This code is used to get the date format based on user language  (01 JAN 2011 OR 01 ENE 2011)
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*-------------------------------------------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS
RETURN

PROCESS:
*TOD.DAY=TODAY
*TOD.DAY=ICONV(TOD.DAY,"D2")
*SYS.DATE=OCONV(TOD.DAY,"D4")
*PACS00023988 - S
    TEMP.COMI = COMI ; TEMP.N1=N1 ; TEMP.T1 = T1
    COMI= TODAY ; N1=8 ; T1=".D"
    CALL IN2D(N1,T1)
    SYS.DATE = V$DISPLAY
    COMI = TEMP.COMI ; N1 = TEMP.N1 ; T1 = TEMP.T1
*PACS00023988 - E
RETURN
END
*----------------------------------------------- End Of Record ----------------------------------
