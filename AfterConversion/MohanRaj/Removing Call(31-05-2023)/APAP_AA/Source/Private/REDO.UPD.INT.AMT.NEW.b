* @ValidationCode : MjotMTc4ODM5NDQ2NjpDcDEyNTI6MTY4NTUzMjM3OTQ1Mjo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 31 May 2023 16:56:19
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
$PACKAGE APAP.AA
SUBROUTINE REDO.UPD.INT.AMT.NEW
***********************************************************************
* COMPANY NAME: ASOCIACION POPULAR DE AHORROS Y PRESTAMOS
* DEVELOPED BY: H GANESH
* PROGRAM NAME: REDO.UPD.INT.AMT.NEW
* ODR NO      : PACS00045355-B.16
*----------------------------------------------------------------------
*DESCRIPTION: This is a post routine for LENDING-NEW-ARRANGEMENT activity for PRINCIPAL INTEREST property
* to update the interest amounts in local fields


*IN PARAMETER  : NA
*OUT PARAMETER : NA
*LINKED WITH   : NA
*----------------------------------------------------------------------
* Modification History :
*-----------------------
*DATE           WHO           REFERENCE         DESCRIPTION
*31-MAR-2011  H GANESH     PACS00045355-B.16  INITIAL CREATION
** 29-03-2023 R22 Auto Conversion � FM TO @FM, VM to @VM, SM to @SM
** 29-03-2023 Skanda R22 Manual Conversion - CALL method format changed
*----------------------------------------------------------------------


    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ACCOUNT.DETAILS
    $INSERT I_AA.LOCAL.COMMON
    $INSERT I_F.AA.INTEREST
    $INSERT I_F.AA.PAYMENT.SCHEDULE


    IF c_aalocActivityStatus NE 'AUTH' THEN       ;* Routine exits if other than authorisation stage
        RETURN
    END

    GOSUB OPEN.FILES
    GOSUB GET.MULTI.LOC.REF
    GOSUB PROCESS

RETURN
*----------------------------------------------------------------------
OPEN.FILES:
*----------------------------------------------------------------------

    INT.AMT=0

    FN.AA.ACCOUNT.DETAILS='F.AA.ACCOUNT.DETAILS'
    F.AA.ACCOUNT.DETAILS=''
    CALL OPF(FN.AA.ACCOUNT.DETAILS,F.AA.ACCOUNT.DETAILS)

RETURN
*----------------------------------------------------------------------
GET.MULTI.LOC.REF:
*----------------------------------------------------------------------
    LOC.REF.APPLICATION="AA.PRD.DES.INTEREST"
    LOC.REF.FIELDS="L.AA.INT.AMTOLD":@VM:"L.AA.INT.AMTNEW":@VM:"L.AA.DIFF.AMT"
    LOC.REF.POS=''
    CALL MULTI.GET.LOC.REF(LOC.REF.APPLICATION,LOC.REF.FIELDS,LOC.REF.POS)
    POS.L.AA.INT.AMTOLD=LOC.REF.POS<1,1>
    POS.L.AA.INT.AMTNEW=LOC.REF.POS<1,2>
    POS.L.AA.DIFF.AMT=  LOC.REF.POS<1,3>

RETURN
*----------------------------------------------------------------------
PROCESS:
*----------------------------------------------------------------------
    Y.ARRANGEMENT.ID=c_aalocArrId
    PROPERTY=c_aalocPropertyId
*TUS change START
*logic changed to avoid looping of CHANGE-INTEREST activity. Because inside CHANGE-INTEREST another CHANGE-INTEREST activity getting trigered.
*So update directly will happen in R.NEW and no need to post OFS
    INT.AMT = ''
    APAP.AA.redoGetTotalInterest(Y.ARRANGEMENT.ID,PROPERTY,INT.AMT);* R22 Manual conversion

    IF R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTNEW> NE INT.AMT THEN

        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTOLD>=R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTNEW>
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTNEW>=INT.AMT
        R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.DIFF.AMT>= R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTOLD>-R.NEW(AA.INT.LOCAL.REF)<1,POS.L.AA.INT.AMTNEW>
*IF INT.AMT THEN
*GOSUB POST.OFS
*END
    END
*TUS change END

RETURN
*----------------------------------------------------------------------
POST.OFS:
*----------------------------------------------------------------------

    APP.NAME = 'AA.ARR.INTEREST'
    OFSFUNCT=''
    PROCESS  = ''
    OFSVERSION = ''
    GTSMODE = ''
    TRANSACTION.ID=''
    OFSRECORD = ''
    OFS.MSG.ID =''
    OFS.ERR = ''
    NO.OF.AUTH=0

    CALL OFS.BUILD.RECORD(APP.NAME,OFSFUNCT,PROCESS,OFSVERSION,GTSMODE,NO.OF.AUTH,TRANSACTION.ID,R.PROPERTY.COND,OFSRECORD)
    CHANGE ',' TO @FM IN OFSRECORD
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    DEL OFSRECORD<1>
    FIELD.COUNT=DCOUNT(OFSRECORD,@FM)
    OFS.STRING=''
    VAR2=1
    LOOP
    WHILE VAR2 LE FIELD.COUNT
        IF OFSRECORD<VAR2> THEN
            OFS.STRING:='FIELD.NAME:1:':VAR2:'=':FIELD(OFSRECORD<VAR2>,'=',1):','
            OFS.STRING:='FIELD.VALUE:1:':VAR2:'=':FIELD(OFSRECORD<VAR2>,'=',2):','
        END
        VAR2 += 1 ;** R22 Auto Conversion
    REPEAT
    Y.PROPERTY = c_aalocPropertyId
    ARR.ID     = c_aalocArrId
    Y.ACTIVITY = 'LENDING-CHANGE-':c_aalocPropertyId
    OFS.MSG="AA.ARRANGEMENT.ACTIVITY,APAP/I/PROCESS,,,ARRANGEMENT:1:1=":ARR.ID:",ACTIVITY:1:1=":Y.ACTIVITY:',PROPERTY:1:1=':Y.PROPERTY:',':OFS.STRING


    OFS.SRC = 'AA.INT.UPDATE'
    OPTIONS = ''
    OFS.STRING.FINAL:=OFS.MSG:"EFFECTIVE.DATE:1:1=":c_aalocActivityEffDate
    CALL OFS.POST.MESSAGE(OFS.STRING.FINAL,OFS.MSG.ID,OFS.SRC,OPTIONS)


RETURN

END
