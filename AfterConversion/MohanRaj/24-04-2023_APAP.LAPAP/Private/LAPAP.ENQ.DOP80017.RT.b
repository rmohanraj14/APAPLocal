* @ValidationCode : MjotMTI5MTU5OTQ5NzpDcDEyNTI6MTY4MjMxMzQzMzczOTo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Apr 2023 10:47:13
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
SUBROUTINE LAPAP.ENQ.DOP80017.RT
*--------------------------------------------------------------------------------------------------------
*--------------------------------------------------------------------------------------------------------
*Description  : This is a ID routine to from ENQUIRY.SERVICE
*Linked With version  : ENQUIRY.REPORT,DOP80017
*In Parameter : N/A
*Out Parameter: N/A
*--------------------------------------------------------------------------------------------------------
* Modification History :
*-----------------------
*    Date            Who                  Reference               Description
*   ------         ------               -------------            -------------
*  23/09/2020    Juan Garcia               MDP-1200             Initial Creation
*Modification history
*Date                Who               Reference                  Description
*24-04-2023      conversion tool     R22 Auto code conversion     No changes
*24-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*--------------------------------------------------------------------------------------------------------
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_GTS.COMMON
    $INSERT I_F.ENQUIRY.REPORT

    GOSUB PROCESS

RETURN

PROCESS:
********

    COMI = 'LAPAP.STMT.ENTRY.DOP80017'

RETURN

*--------------------------------------------------------------------------------------------------------
