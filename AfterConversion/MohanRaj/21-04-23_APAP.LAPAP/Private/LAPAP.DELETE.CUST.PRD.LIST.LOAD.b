* @ValidationCode : MjoxODI1MzIyNzc3OkNwMTI1MjoxNjgyMDczODYwOTAxOjkxNjM4Oi0xOi0xOjA6MDpmYWxzZTpOL0E6UjIxX0FNUi4wOi0xOi0x
* @ValidationInfo : Timestamp         : 21 Apr 2023 16:14:20
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
$PACKAGE APAP.LAPAP
*========================================================================
SUBROUTINE LAPAP.DELETE.CUST.PRD.LIST.LOAD
*========================================================================
* Technical report:
* =================
* Company Name   : APAP
* Program Name   : LAPAP.DELETE.CUST.PRD.LIST.LOAD
* Date           : 2018-01-31
* Item ID        : CN00
*========================================================================
* Brief description :
* -------------------
* This a multi-threading program for inject data in monitor interface
* without use any version.
*========================================================================
* Modification History :
* ======================
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2018-01-31     Richard HC        Initial Development
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*========================================================================
* Content summary :
* =================
* Table name     :
* Auto Increment : N/A
* Views/versions : N/A
* EB record      : LAPAP.DELETE.CUST.PRD.LIST.LOAD
* Routine        : LAPAP.DELETE.CUST.PRD.LIST.LOAD
*========================================================================


    $INSERT I_COMMON
    $INSERT I_EQUATE

    $INSERT I_F.REDO.CUST.PRD.LIST

    FN.PRD.LIST = "F.REDO.CUST.PRD.LIST"
    F.PRD.LIST = ""
    CALL OPF(FN.PRD.LIST,F.PRD.LIST)

RETURN

END
