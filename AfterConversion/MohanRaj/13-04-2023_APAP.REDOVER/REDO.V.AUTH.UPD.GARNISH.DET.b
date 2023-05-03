* @ValidationCode : Mjo0ODUxNzc2MzQ6Q3AxMjUyOjE2ODEzODE5MTgzMTg6OTE2Mzg6LTE6LTE6MDowOmZhbHNlOk4vQTpSMjFfQU1SLjA6LTE6LTE=
* @ValidationInfo : Timestamp         : 13 Apr 2023 16:01:58
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
SUBROUTINE REDO.V.AUTH.UPD.GARNISH.DET
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
* 16-02-2011        Prabhu.N         PACS00023885  Routine to post ofs message for AC.LOCKED.EVENTS
*Modification history
*Date                Who               Reference                  Description
*13-04-2023      conversion tool     R22 Auto code conversion    VM TO @VM,FM TO @FM
*13-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*----------------------------------------------------------------------------------

    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.ACCOUNT
    $INSERT I_F.AC.LOCKED.EVENTS
    $INSERT I_F.LOCKING
    $INSERT I_F.OVERRIDE
    $INSERT I_F.APAP.H.GARNISH.DETAILS


    GOSUB INIT
    GOSUB PROCESS
RETURN
INIT:
    FN.APAP.H.GARNISH.DETAILS='F.APAP.H.GARNISH.DETAILS'
    F.APAP.H.GARNISH.DETAILS=''
    CALL OPF(FN.APAP.H.GARNISH.DETAILS,F.APAP.H.GARNISH.DETAILS)
    LREF.FIELD='L.AC.GAR.REF.NO'
    LREF.APP='AC.LOCKED.EVENTS'
    LREF.POS=''
    CALL MULTI.GET.LOC.REF(LREF.APP,LREF.FIELD,LREF.POS)
RETURN
PROCESS:

    Y.AHG.ID=R.NEW(AC.LCK.LOCAL.REF)<1,LREF.POS>
    CALL F.READU(FN.APAP.H.GARNISH.DETAILS,Y.AHG.ID,R.APAP.H.GARNISH.DETAILS,F.APAP.H.GARNISH.DETAILS,ERR,'')
    Y.ACCOUNT.LIST=R.APAP.H.GARNISH.DETAILS<APAP.GAR.ACCOUNT.NO>
    CHANGE @VM TO @FM IN Y.ACCOUNT.LIST
    Y.ACCOUNT=R.NEW(AC.LCK.ACCOUNT.NUMBER)
    LOCATE Y.ACCOUNT IN Y.ACCOUNT.LIST SETTING POS THEN
        R.APAP.H.GARNISH.DETAILS<APAP.GAR.ALE.REF,POS>=ID.NEW
    END
    CALL F.WRITE(FN.APAP.H.GARNISH.DETAILS,Y.AHG.ID,R.APAP.H.GARNISH.DETAILS)
    CALL F.RELEASE(FN.APAP.H.GARNISH.DETAILS,Y.AHG.ID,F.APAP.H.GARNISH.DETAILS)
RETURN
END
