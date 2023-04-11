* @ValidationCode : MjotMTYwNzQxOTQ1MDpDcDEyNTI6MTY4MTIxNDc5ODU3Njo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 11 Apr 2023 17:36:38
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
SUBROUTINE REDO.S.GET.SYS.DATE
*-------------------------------------------------------------------------
*Company   Name    :Asociacion Popular de Ahorros y Prestamos
*Developed By      :GANESH.R
*Program   Name    :REDO.S.GET.SYS.DATE
* Reference Number :ODR-2010-04-0424
*-------------------------------------------------------------------------

*DESCRIPTION       :This program is used to get the date and Convert the d
*                   dd mon yy (e.g. 01 JAN 09)
*LINKED WITH       :
*Modification history
*Date                Who               Reference                  Description
*10-04-2023      conversion tool     R22 Auto code conversion     No changes
*10-04-2023      Mohanraj R          R22 Manual code conversion   No changes
* ------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_ENQUIRY.COMMON

    GOSUB PROCESS
RETURN

PROCESS:
    TOD.DAY=TODAY
    TOD.DAY=ICONV(TOD.DAY,"D2")
    O.DATA=OCONV(TOD.DAY,"D2")

RETURN
END
