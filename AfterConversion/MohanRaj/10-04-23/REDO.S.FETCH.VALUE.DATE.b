* @ValidationCode : Mjo4MTI0NzE3MjpDcDEyNTI6MTY4MTEyMzI3NzU1NTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 10 Apr 2023 16:11:17
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
SUBROUTINE REDO.S.FETCH.VALUE.DATE(VAL.DATE)
*--------------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :SUDHARSANAN S
*Program   Name    :REDO.S.FETCH.VALUE.DATE
*---------------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the date and Convert the date into
*                   dd mon yy (e.g. 01 JAN 09)
*LINKED WITH       :
* ----------------------------------------------------------------------------------
*MODIFICATION HISTORY:
* DATE            WHO               REFERENCE              DESCRIPTION
* 26 JUN 2011     Sudharsanan S     PACS00075461         This code is used to get the date format based on user language  (01 JAN 2011 OR 01 ENE 2011)
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes

*-------------------------------------------------------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.TELLER
    GOSUB PROCESS
RETURN

PROCESS:
    TEMP.COMI = COMI ; TEMP.N1=N1 ; TEMP.T1 = T1
    COMI= R.NEW(TT.TE.VALUE.DATE.1) ; N1=8 ; T1=".D"
    CALL IN2D(N1,T1)
    VAL.DATE = V$DISPLAY
    COMI = TEMP.COMI ; N1 = TEMP.N1 ; T1 = TEMP.T1
RETURN
END
*----------------------------------------------- End Of Record ----------------------------------
