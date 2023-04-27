* @ValidationCode : Mjo5NTQ4NDE4NTI6Q3AxMjUyOjE2ODA3NzM0NzI4NDk6SGFyaXNodmlrcmFtQzotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 06 Apr 2023 15:01:12
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
SUBROUTINE REDO.CH.OFSPROC(OFS.MSG,OFS.SRC)
**
* Subroutine Type :
* Attached to     : Subroutine REDO.CH.CHGPROFILE
* Attached as     :
* Primary Purpose : Process the first OFS message to change the UIBEHAVIOUR activity.
*-----------------------------------------------------------------------------
* MODIFICATIONS HISTORY
*
* 05/07/12 - First Version.
*            ODR Reference: ODR-2010-06-0155.
*            Project: NCD Asociacion Popular de Ahorros y Prestamos (APAP).
*            Roberto Mondragon - TAM Latin America.
*            rmondragon@temenos.com
* 04-APR-2023     Conversion tool    R22 Auto conversion       No changes
* 04-APR-2023      Harishvikram C   Manual R22 conversion      No changes
*-----------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    GOSUB PROCESS

RETURN

********
PROCESS:
********

    TXN.COMM = ''
    CALL OFS.CALL.BULK.MANAGER(OFS.SRC,OFS.MSG,RESP.OFS.MSG,TXN.COMM)

RETURN

END
