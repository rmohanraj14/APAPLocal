* @ValidationCode : MjotMjAxNTI2MTQxMjpDcDEyNTI6MTY4MjMxNDE2MDQyMzo5MTYzODotMTotMTowOjA6ZmFsc2U6Ti9BOlIyMV9BTVIuMDotMTotMQ==
* @ValidationInfo : Timestamp         : 24 Apr 2023 10:59:20
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
*Modification history
*Date                Who               Reference                  Description
*24-04-2023      conversion tool     R22 Auto code conversion     No changes
*24-04-2023      Mohanraj R          R22 Manual code conversion   No changes
*Routine to form Posting Restriction Activities String using the Arrangement ID from SL.CLEAR.AA savedlist file.
*OFS string will be saved in STRING.IDS file under &SAVEDLISTS&.
*Creator: Durga Venkatraman
*-----------------------------------------------------------------------------

SUBROUTINE LAPAP.FORM.POST.RESTR.ACTIVITY(AA.ID)
    $INSERT I_COMMON
    $INSERT I_EQUATE
    $INSERT I_F.AA.ARRANGEMENT

    GOSUB OPEN.FILES
    GOSUB FORM.OFS.STR

RETURN

**************
OPEN.FILES:
**************
    Y.AA.ID = AA.ID
    FN.AA = 'F.AA.ARRANGEMENT'
    F.AA = ''
    CALL OPF(FN.AA,F.AA)

    FN.SL = './&SAVEDLISTS&'
    F.SL = ''
    CALL OPF(FN.SL,F.SL)
    STRING.ID = ''

RETURN
**************
FORM.OFS.STR:
**************
    R.AA = ''
    READ R.AA FROM F.AA,Y.AA.ID THEN
        Y.CO.CODE = ''; Y.CO.CODE = R.AA<AA.ARR.CO.CODE>
        Y.TODAY = ''; Y.TODAY = TODAY
        STRING.ID<-1> = "AA.ARRANGEMENT.ACTIVITY,TEST/I/PROCESS//0,//":Y.CO.CODE:",,ARRANGEMENT:1:1=":Y.AA.ID:",ACTIVITY:1:1=LENDING-UPDATE-POST.RESTRICT,EFFECTIVE.DATE:1:1=":Y.TODAY:",PROPERTY:1:1=ACCOUNT,FIELD.NAME:1=POSTING.RESTRICT,FIELD.VALUE:1=75"
        STRING.ID<-1> = "AA.ARRANGEMENT.ACTIVITY,TEST/I/PROCESS//0,//":Y.CO.CODE:",,ARRANGEMENT:1:1=":Y.AA.ID:",ACTIVITY:1:1=LENDING-UPDATE-OD.STATUS,EFFECTIVE.DATE:1:1=":Y.TODAY:",PROPERTY:1:1=ACCOUNT,FIELD.NAME:1:1=L.OD.STATUS:1:1,FIELD.VALUE:1:1=CUR,FIELD.NAME:1:2=L.OD.STATUS.2:1:1,FIELD.VALUE:1:2=CUR"
    END
    WRITE STRING.ID TO F.SL,'STRING.IDS'
    Y.LIST.NAME = 'STRING.IDS'
    Y.LIST.NAME.EB = 'AA.ADJ.BAL'
    CALL LAPAP.TRG.OFS.STRING(Y.LIST.NAME)
    CALL LAPAP.PACS.RAISE.ENTRY(Y.LIST.NAME.EB)
RETURN
