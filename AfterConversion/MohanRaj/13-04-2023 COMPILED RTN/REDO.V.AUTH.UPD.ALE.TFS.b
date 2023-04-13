* @ValidationCode : Mjo4MDE1NjY1ODE6Q3AxMjUyOjE2ODEzODE3Njg1MzY6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 15:59:28
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
$PACKAGE APAP.REDOVER
SUBROUTINE REDO.V.AUTH.UPD.ALE.TFS
*---------------------------------------------------------------------------------
*This is an Authorisation routine for the version AC.LOCKED.EVENTS,INPUT it will lock
*the customer's account
*----------------------------------------------------------------------------------
* Company Name  : ASOCIACION POPUL
* Developed By  : GANESH R
* Program Name  : REDO.V.INP.GARNISHMENT.MAINT
* ODR NUMBER    : ODR-2009-10-0531
* HD REFERENCE  : HD1016159
*Routine Name   :REDO.V.AUTH.LOCK.ACCT
*LINKED WITH:
*----------------------------------------------------------------------
*Input param = none
*output param =none
*-----------------------------------------------------------------------
*MODIFICATION DETAILS:
* Date               By              HD ISSUE
* 16-10-2011        Prabhu.N         PACS00146120  Routine to post ofs message for AC.LOCKED.EVENTS
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion     No changes
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.REDO.TFS.ALE
    GOSUB INIT
    GOSUB PROCESS
RETURN
INIT:
    FN.REDO.ALE.TFS='F.REDO.TFS.ALE'
    F.REDO.ALE.TFS=''
    CALL OPF(FN.REDO.ALE.TFS,F.REDO.ALE.TFS)
    FN.AC.LOCKED.EVENTS = 'F.AC.LOCKED.EVENTS'
    F.AC.LOCKED.EVENTS = ''
    CALL OPF(FN.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS)
RETURN

PROCESS:
    R.REDO.ALE.TFS<TFS.ALE.ALE>=ID.NEW
*    CALL F.READ(FN.AC.LOCKED.EVENTS,ID.NEW,R.AC.LOCKED.EVENTS,F.AC.LOCKED.EVENTS,ALE.ERR)
    Y.LCK.LOCKED.AMOUNT  = R.NEW(AC.LCK.LOCKED.AMOUNT)
    R.REDO.ALE.TFS<TFS.ALE.ALE.AMOUNT> = Y.LCK.LOCKED.AMOUNT
    Y.ID.ALE.TFS=R.NEW(AC.LCK.DESCRIPTION)
    CALL F.WRITE(FN.REDO.ALE.TFS,Y.ID.ALE.TFS,R.REDO.ALE.TFS)
RETURN
END
