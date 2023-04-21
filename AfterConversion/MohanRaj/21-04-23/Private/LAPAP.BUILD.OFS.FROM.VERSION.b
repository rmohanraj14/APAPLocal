* @ValidationCode : Mjo0Nzk5NzY4MjY6Q3AxMjUyOjE2ODIwNjk1NzMzMzE6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 21 Apr 2023 15:02:53
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
*-----------------------------------------------------------------------------
*-----------------------------------------------------------------------------
SUBROUTINE LAPAP.BUILD.OFS.FROM.VERSION(APP,FUNC,ID,RSS)
*========================================================================
* Technical report:
* =================
* Company Name   : APAP
* Program Name   : LAPAP.BUILD.OFS.LOAD
* Date           : 2018-07-03
* Item ID        : --------------
*========================================================================
* Brief description :
* -------------------
* This program allow build and send OFS message just passing certain
* parameters, as long as exist ,MB.DM.LOAD version for the table to will
* inject data.
*========================================================================
* Modification History :
* ======================
* Date           Author            Modification Description
* -------------  -----------       ---------------------------
* 2019-09-13     Richard HC         Initial Development
*========================================================================
* Content summary :
* =================
* Table name     :N/A
* Auto Increment :N/A
* Views/versions :N/A
* EB record      :LAPAP.BUILD.OFS.FROM.VERSION
* Routine        :LAPAP.BUILD.OFS.FROM.VERSION
*Modification history
*Date                Who               Reference                  Description
*21-04-2023      conversion tool     R22 Auto code conversion     No changes
*21-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*========================================================================

****    D O  N O T  M O D I F Y  T H I S  R O U T I N E    ****

* A lot of requeriments could be depending to this program if you unknown
* all of those previous soluctions, take as sugerence doesn't edit any
* fragment of code content here. In case that you need solve particular
* cases, please kindly create a new soluction independent to this one.
*------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE

    APPL.NAME = APP ;* Table
    VERS.NAME = APP:",MB.DM.LOAD"       ;* Version (MB.DM.LOAD, must exist)
    Y.FUNC = FUNC   ;* Action to execute {delete,insert..etc}
    Y.PRO.VAL = "PROCESS"     ;* Static value
    Y.ID  = ID      ;* Record or userId to change

*   DEBUG

    CALL OFS.BUILD.RECORD(APPL.NAME,Y.FUNC,Y.PRO.VAL,VERS.NAME,Y.GTS.CONTROL,Y.NO.OF.AUTH,Y.ID,RSS,FINAL.OFS)
    CALL OFS.POST.MESSAGE(FINAL.OFS,'',"DM.OFS.SRC.VAL",'')

*    CALL JOURNAL.UPDATE('')

RETURN

END
